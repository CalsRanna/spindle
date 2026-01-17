import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/util/app_theme.dart';

@RoutePage()
class DesktopSettingsPage extends StatelessWidget {
  const DesktopSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('PLAYBACK'),
          _buildSettingsTile(
            icon: Icons.high_quality,
            title: 'Audio Quality',
            subtitle: 'High (320kbps)',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.equalizer,
            title: 'Equalizer',
            subtitle: 'Off',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.music_note,
            title: 'Gapless Playback',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeTrackColor: AppTheme.accentColor,
            ),
          ),

          _buildSectionHeader('LIBRARY'),
          _buildSettingsTile(
            icon: Icons.folder,
            title: 'Scan Folders',
            subtitle: 'Manage music folders',
            onTap: () => context.router.push(const DesktopImportRoute()),
          ),
          _buildSettingsTile(
            icon: Icons.image,
            title: 'Artworks & Metadata',
            subtitle: 'Download missing artwork',
            onTap: () {},
          ),

          _buildSectionHeader('APPEARANCE'),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'Theme',
            subtitle: 'Dark',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.apps,
            title: 'App Icon',
            subtitle: 'Default',
            onTap: () {},
          ),

          _buildSectionHeader('INFO'),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {},
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

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
