import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spindle/util/app_theme.dart';

class BlurBackground extends StatelessWidget {
  final String? imagePath;
  final Widget child;
  final double blurSigma;
  final double opacity;

  const BlurBackground({
    super.key,
    this.imagePath,
    required this.child,
    this.blurSigma = 50,
    this.opacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image with blur
        if (imagePath != null && File(imagePath!).existsSync())
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: opacity),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          )
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2A2A2A),
                  AppTheme.backgroundColor,
                ],
              ),
            ),
          ),
        // Dark overlay
        Container(
          color: AppTheme.backgroundColor.withValues(alpha: 0.3),
        ),
        // Content
        child,
      ],
    );
  }
}
