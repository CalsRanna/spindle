import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spindle/util/app_theme.dart';

class AlbumCover extends StatelessWidget {
  final String? imagePath;
  final double size;
  final double borderRadius;
  final bool showBorder;
  final bool isPlaying;

  const AlbumCover({
    super.key,
    this.imagePath,
    this.size = 48,
    this.borderRadius = 8,
    this.showBorder = false,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget cover;

    if (imagePath != null && File(imagePath!).existsSync()) {
      cover = Image.file(
        File(imagePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder,
      );
    } else {
      cover = _placeholder;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder || isPlaying
            ? Border.all(
                color: isPlaying ? AppTheme.accentColor : AppTheme.dividerColor,
                width: isPlaying ? 2 : 1,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - (showBorder ? 1 : 0)),
        child: cover,
      ),
    );
  }

  Widget get _placeholder => Container(
        width: size,
        height: size,
        color: AppTheme.cardBackground,
        child: Icon(
          Icons.music_note,
          color: AppTheme.textSecondary,
          size: size * 0.5,
        ),
      );
}
