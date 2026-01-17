import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:signals/signals.dart';

import '../util/logger_util.dart';

class WiFiTransferService {
  static final WiFiTransferService instance = WiFiTransferService._();

  WiFiTransferService._();

  final _logger = LoggerUtil.instance;

  HttpServer? _server;
  final isRunning = Signal<bool>(false);
  final serverUrl = Signal<String?>(null);
  final uploadedFiles = Signal<List<UploadedFile>>([]);

  static const _port = 8080;
  static const _supportedExtensions = [
    '.mp3',
    '.flac',
    '.wav',
    '.aac',
    '.m4a',
    '.ogg',
    '.wma',
    '.aiff',
    '.alac',
  ];

  /// Start the HTTP server
  Future<bool> startServer() async {
    if (_server != null) {
      _logger.w('Server already running');
      return true;
    }

    try {
      final ip = await getLocalIP();
      if (ip == null) {
        _logger.e('Could not get local IP address');
        return false;
      }

      _server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
      isRunning.value = true;
      serverUrl.value = 'http://$ip:$_port';
      uploadedFiles.value = [];

      _logger.i('Server started at ${serverUrl.value}');

      _server!.listen(_handleRequest);
      return true;
    } catch (e) {
      _logger.e('Failed to start server: $e');
      return false;
    }
  }

  /// Stop the HTTP server
  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      isRunning.value = false;
      serverUrl.value = null;
      _logger.i('Server stopped');
    }
  }

  /// Get the local WiFi IP address
  Future<String?> getLocalIP() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (final interface in interfaces) {
        // Skip loopback and virtual interfaces
        if (interface.name.toLowerCase().contains('lo') ||
            interface.name.toLowerCase().contains('vmnet') ||
            interface.name.toLowerCase().contains('veth')) {
          continue;
        }

        for (final addr in interface.addresses) {
          // Skip link-local addresses
          if (!addr.address.startsWith('127.') &&
              !addr.address.startsWith('169.254.')) {
            _logger.i('Found IP: ${addr.address} on ${interface.name}');
            return addr.address;
          }
        }
      }
    } catch (e) {
      _logger.e('Error getting local IP: $e');
    }
    return null;
  }

  /// Handle incoming HTTP requests
  Future<void> _handleRequest(HttpRequest request) async {
    _logger.i('${request.method} ${request.uri.path}');

    // Add CORS headers
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers
        .add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', '*');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      return;
    }

    switch (request.uri.path) {
      case '/':
        await _serveUploadPage(request);
        break;
      case '/upload':
        if (request.method == 'POST') {
          await _handleUpload(request);
        } else {
          request.response.statusCode = HttpStatus.methodNotAllowed;
          await request.response.close();
        }
        break;
      case '/status':
        await _serveStatus(request);
        break;
      default:
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
    }
  }

  /// Serve the upload HTML page
  Future<void> _serveUploadPage(HttpRequest request) async {
    request.response.headers.contentType = ContentType.html;
    request.response.write(_uploadPageHtml);
    await request.response.close();
  }

  /// Serve server status
  Future<void> _serveStatus(HttpRequest request) async {
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({
      'running': isRunning.value,
      'files': uploadedFiles.value.map((f) => f.toJson()).toList(),
    }));
    await request.response.close();
  }

  /// Handle file upload
  Future<void> _handleUpload(HttpRequest request) async {
    try {
      final contentType = request.headers.contentType;
      if (contentType == null ||
          contentType.mimeType != 'multipart/form-data') {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write(jsonEncode({'error': 'Invalid content type'}));
        await request.response.close();
        return;
      }

      final boundary = contentType.parameters['boundary'];
      if (boundary == null) {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.write(jsonEncode({'error': 'No boundary found'}));
        await request.response.close();
        return;
      }

      final transformer = MimeMultipartTransformer(boundary);
      final parts = await transformer.bind(request).toList();

      final musicDir = await _getMusicDirectory();
      final List<String> savedFiles = [];

      for (final part in parts) {
        final contentDisposition = part.headers['content-disposition'];
        if (contentDisposition == null) continue;

        final filenameMatch =
            RegExp(r'filename="([^"]+)"').firstMatch(contentDisposition);
        if (filenameMatch == null) continue;

        String filename = filenameMatch.group(1)!;
        // Try to decode URL-encoded filename, fall back to original if it fails
        try {
          filename = Uri.decodeComponent(filename);
        } catch (_) {
          // Filename might not be URL-encoded, use as-is
        }

        // Check if file extension is supported
        final ext = filename.toLowerCase();
        final isSupported =
            _supportedExtensions.any((e) => ext.endsWith(e));
        if (!isSupported) {
          _logger.w('Unsupported file type: $filename');
          continue;
        }

        // Generate unique filename
        var destPath = '${musicDir.path}/$filename';
        var destFile = File(destPath);
        int counter = 1;
        while (await destFile.exists()) {
          final dotIndex = filename.lastIndexOf('.');
          final nameWithoutExt =
              dotIndex > 0 ? filename.substring(0, dotIndex) : filename;
          final extension = dotIndex > 0 ? filename.substring(dotIndex) : '';
          destPath = '${musicDir.path}/${nameWithoutExt}_$counter$extension';
          destFile = File(destPath);
          counter++;
        }

        // Save file
        final bytes = await part.fold<List<int>>(
          [],
          (prev, chunk) => prev..addAll(chunk),
        );
        await destFile.writeAsBytes(bytes);

        savedFiles.add(destPath);
        _logger.i('Saved file: $destPath');

        // Update uploaded files list
        final uploaded = UploadedFile(
          filename: filename,
          path: destPath,
          size: bytes.length,
          timestamp: DateTime.now(),
        );
        uploadedFiles.value = [...uploadedFiles.value, uploaded];
      }

      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({
        'success': true,
        'files': savedFiles,
      }));
      await request.response.close();
    } catch (e) {
      _logger.e('Upload error: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write(jsonEncode({'error': e.toString()}));
      await request.response.close();
    }
  }

  /// Get the music directory
  Future<Directory> _getMusicDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${docsDir.path}/Music');
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }
    return musicDir;
  }

  /// Clear uploaded files list
  void clearUploadedFiles() {
    uploadedFiles.value = [];
  }

  /// Get paths of all uploaded files (for importing)
  List<String> getUploadedFilePaths() {
    return uploadedFiles.value.map((f) => f.path).toList();
  }

  static const _uploadPageHtml = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Spindle - WiFi Transfer</title>
  <style>
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #121212;
      color: #ffffff;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 40px 20px;
    }
    h1 {
      font-size: 24px;
      font-weight: 600;
      margin-bottom: 8px;
      color: #1DB954;
    }
    .subtitle {
      color: #b3b3b3;
      margin-bottom: 40px;
    }
    .upload-area {
      width: 100%;
      max-width: 500px;
      border: 2px dashed #333;
      border-radius: 12px;
      padding: 60px 40px;
      text-align: center;
      cursor: pointer;
      transition: all 0.2s ease;
      background: #181818;
    }
    .upload-area:hover, .upload-area.dragover {
      border-color: #1DB954;
      background: #1a1a1a;
    }
    .upload-icon {
      font-size: 48px;
      margin-bottom: 16px;
    }
    .upload-text {
      font-size: 16px;
      color: #b3b3b3;
      margin-bottom: 8px;
    }
    .upload-hint {
      font-size: 13px;
      color: #666;
    }
    input[type="file"] {
      display: none;
    }
    .file-list {
      width: 100%;
      max-width: 500px;
      margin-top: 24px;
    }
    .file-item {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 12px 16px;
      background: #181818;
      border-radius: 8px;
      margin-bottom: 8px;
    }
    .file-name {
      flex: 1;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
      margin-right: 12px;
    }
    .file-status {
      font-size: 13px;
    }
    .file-status.success {
      color: #1DB954;
    }
    .file-status.uploading {
      color: #f0b400;
    }
    .file-status.error {
      color: #e74c3c;
    }
    .progress-bar {
      width: 100%;
      max-width: 500px;
      height: 4px;
      background: #333;
      border-radius: 2px;
      margin-top: 16px;
      overflow: hidden;
      display: none;
    }
    .progress-bar.active {
      display: block;
    }
    .progress-fill {
      height: 100%;
      background: #1DB954;
      width: 0%;
      transition: width 0.2s ease;
    }
    .supported-formats {
      margin-top: 40px;
      font-size: 12px;
      color: #666;
    }
  </style>
</head>
<body>
  <h1>Spindle</h1>
  <p class="subtitle">WiFi Transfer</p>

  <div class="upload-area" id="dropZone">
    <div class="upload-icon">+</div>
    <p class="upload-text">Drop audio files here or click to select</p>
    <p class="upload-hint">Multiple files supported</p>
  </div>
  <input type="file" id="fileInput" multiple accept=".mp3,.flac,.wav,.aac,.m4a,.ogg,.wma,.aiff,.alac">

  <div class="progress-bar" id="progressBar">
    <div class="progress-fill" id="progressFill"></div>
  </div>

  <div class="file-list" id="fileList"></div>

  <p class="supported-formats">
    Supported formats: MP3, FLAC, WAV, AAC, M4A, OGG, WMA, AIFF, ALAC
  </p>

  <script>
    const dropZone = document.getElementById('dropZone');
    const fileInput = document.getElementById('fileInput');
    const fileList = document.getElementById('fileList');
    const progressBar = document.getElementById('progressBar');
    const progressFill = document.getElementById('progressFill');

    dropZone.addEventListener('click', () => fileInput.click());

    dropZone.addEventListener('dragover', (e) => {
      e.preventDefault();
      dropZone.classList.add('dragover');
    });

    dropZone.addEventListener('dragleave', () => {
      dropZone.classList.remove('dragover');
    });

    dropZone.addEventListener('drop', (e) => {
      e.preventDefault();
      dropZone.classList.remove('dragover');
      handleFiles(e.dataTransfer.files);
    });

    fileInput.addEventListener('change', () => {
      handleFiles(fileInput.files);
    });

    async function handleFiles(files) {
      if (files.length === 0) return;

      progressBar.classList.add('active');

      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const itemId = 'file-' + Date.now() + '-' + i;

        // Add file to list
        const item = document.createElement('div');
        item.className = 'file-item';
        item.id = itemId;
        item.innerHTML = '<span class="file-name">' + file.name + '</span>' +
                        '<span class="file-status uploading">Uploading...</span>';
        fileList.insertBefore(item, fileList.firstChild);

        // Upload file
        try {
          const formData = new FormData();
          formData.append('file', file);

          const xhr = new XMLHttpRequest();
          xhr.open('POST', '/upload', true);

          xhr.upload.onprogress = (e) => {
            if (e.lengthComputable) {
              const percent = (e.loaded / e.total) * 100;
              progressFill.style.width = percent + '%';
            }
          };

          await new Promise((resolve, reject) => {
            xhr.onload = () => {
              if (xhr.status === 200) {
                resolve(JSON.parse(xhr.responseText));
              } else {
                reject(new Error('Upload failed'));
              }
            };
            xhr.onerror = () => reject(new Error('Network error'));
            xhr.send(formData);
          });

          document.querySelector('#' + itemId + ' .file-status').className = 'file-status success';
          document.querySelector('#' + itemId + ' .file-status').textContent = 'Done';
        } catch (err) {
          document.querySelector('#' + itemId + ' .file-status').className = 'file-status error';
          document.querySelector('#' + itemId + ' .file-status').textContent = 'Failed';
        }
      }

      progressBar.classList.remove('active');
      progressFill.style.width = '0%';
      fileInput.value = '';
    }
  </script>
</body>
</html>
''';
}

/// Uploaded file info
class UploadedFile {
  final String filename;
  final String path;
  final int size;
  final DateTime timestamp;

  UploadedFile({
    required this.filename,
    required this.path,
    required this.size,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'path': path,
        'size': size,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Multipart form data parser
class MimeMultipartTransformer
    extends StreamTransformerBase<List<int>, MimeMultipart> {
  final String boundary;

  MimeMultipartTransformer(this.boundary);

  @override
  Stream<MimeMultipart> bind(Stream<List<int>> stream) {
    return _parse(stream);
  }

  Stream<MimeMultipart> _parse(Stream<List<int>> stream) async* {
    final bytes = await stream.fold<List<int>>([], (prev, chunk) => prev..addAll(chunk));

    final boundaryBytes = utf8.encode('--$boundary');
    final doubleCrlfBytes = [13, 10, 13, 10]; // \r\n\r\n

    int pos = 0;

    // Find first boundary
    pos = _findSequence(bytes, boundaryBytes, pos);
    if (pos == -1) return;
    pos += boundaryBytes.length;

    while (pos < bytes.length) {
      // Skip CRLF after boundary
      if (pos + 2 <= bytes.length && bytes[pos] == 13 && bytes[pos + 1] == 10) {
        pos += 2;
      }

      // Check for end marker --
      if (pos + 2 <= bytes.length && bytes[pos] == 45 && bytes[pos + 1] == 45) {
        break; // End of multipart
      }

      // Find end of headers (double CRLF)
      final headerEnd = _findSequence(bytes, doubleCrlfBytes, pos);
      if (headerEnd == -1) break;

      // Parse headers
      final headerBytes = bytes.sublist(pos, headerEnd);
      final headerString = utf8.decode(headerBytes, allowMalformed: true);
      final headers = <String, String>{};

      for (final line in headerString.split('\r\n')) {
        final colonIndex = line.indexOf(':');
        if (colonIndex > 0) {
          final key = line.substring(0, colonIndex).trim().toLowerCase();
          final value = line.substring(colonIndex + 1).trim();
          headers[key] = value;
        }
      }

      // Body starts after double CRLF
      final bodyStart = headerEnd + 4;

      // Find next boundary
      final nextBoundaryPos = _findSequence(bytes, boundaryBytes, bodyStart);

      int bodyEnd;
      if (nextBoundaryPos == -1) {
        bodyEnd = bytes.length;
      } else {
        // Body ends before CRLF preceding boundary
        bodyEnd = nextBoundaryPos - 2; // Skip \r\n before boundary
        if (bodyEnd < bodyStart) bodyEnd = bodyStart;
      }

      final bodyBytes = bytes.sublist(bodyStart, bodyEnd);

      if (headers.isNotEmpty) {
        yield MimeMultipart(headers, Stream.value(bodyBytes));
      }

      // Move to next part
      if (nextBoundaryPos == -1) break;
      pos = nextBoundaryPos + boundaryBytes.length;
    }
  }

  int _findSequence(List<int> haystack, List<int> needle, [int start = 0]) {
    outer:
    for (var i = start; i <= haystack.length - needle.length; i++) {
      for (var j = 0; j < needle.length; j++) {
        if (haystack[i + j] != needle[j]) continue outer;
      }
      return i;
    }
    return -1;
  }
}

/// Represents a part in multipart form data
class MimeMultipart {
  final Map<String, String> headers;
  final Stream<List<int>> _stream;

  MimeMultipart(this.headers, this._stream);

  Future<List<int>> fold<T>(List<int> initial, List<int> Function(List<int>, List<int>) combine) async {
    var result = initial;
    await for (final chunk in _stream) {
      result = combine(result, chunk);
    }
    return result;
  }
}
