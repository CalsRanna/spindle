import 'dart:io';

import 'package:tray_manager/tray_manager.dart';

class TrayUtil with TrayListener {
  static final TrayUtil instance = TrayUtil._();

  TrayUtil._();

  Future<void> dispose() async {
    trayManager.removeListener(this);
    await trayManager.destroy();
  }

  Future<void> ensureInitialized() async {
    trayManager.addListener(this);
    await _setTrayIcon();
  }

  @override
  void onTrayIconMouseDown() {
    // TODO: 实现托盘图标点击事件
  }

  @override
  void onTrayIconRightMouseDown() {
    // TODO: 实现托盘图标右键点击事件
  }

  Future<void> _setTrayIcon() async {
    try {
      String iconPath;
      bool isTemplate;
      if (Platform.isWindows) {
        iconPath = 'asset/tray_icon.ico';
        isTemplate = false;
      } else if (Platform.isMacOS) {
        iconPath = 'asset/tray_icon.png';
        isTemplate = true;
      } else if (Platform.isLinux) {
        iconPath = 'asset/tray_icon.png';
        isTemplate = false;
      } else {
        return;
      }

      await trayManager.setIcon(iconPath, isTemplate: isTemplate);
    } catch (e) {}
  }
}
