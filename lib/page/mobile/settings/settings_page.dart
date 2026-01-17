import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/util/app_theme.dart';

@RoutePage()
class MobileSettingsPage extends StatefulWidget {
  const MobileSettingsPage({super.key});

  @override
  State<MobileSettingsPage> createState() => _MobileSettingsPageState();
}

class _MobileSettingsPageState extends State<MobileSettingsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'v${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        children: [
          _buildSectionHeader('LIBRARY'),
          ListTile(
            leading: const Icon(Icons.folder, color: AppTheme.textPrimary),
            title: const Text('Import Music'),
            subtitle: const Text(
              'Add music from files or WiFi',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            onTap: () => context.router.push(const MobileImportRoute()),
          ),
          _buildSectionHeader('ABOUT'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppTheme.textPrimary),
            title: const Text('Spindle'),
            subtitle: Text(
              _version.isNotEmpty ? _version : 'A minimal music player',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
