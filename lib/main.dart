import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spindle/database/database.dart';
import 'package:spindle/di.dart';
import 'package:spindle/router/app_router.dart';
import 'package:spindle/service/audio_service.dart';
import 'package:spindle/util/app_theme.dart';
import 'package:spindle/util/window_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Database.instance.ensureInitialized();
  await DI.ensureInitialized();

  // Initialize audio session for background playback
  await AudioService.instance.init();

  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await WindowUtil.instance.ensureInitialized(
      title: 'Spindle',
      width: 1080,
      height: 720,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Spindle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router.config(),
    );
  }
}
