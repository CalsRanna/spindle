import 'package:flutter/material.dart';
import 'package:spindle/util/app_theme.dart';

enum SidebarItem { search, library, favorites, settings }

class Sidebar extends StatelessWidget {
  final SidebarItem selectedItem;
  final ValueChanged<SidebarItem> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: AppTheme.cardBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
            child: Text(
              'SPINDLE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppTheme.accentColor,
              ),
            ),
          ),
          // Navigation items
          _SidebarItem(
            icon: Icons.search,
            label: 'Search',
            isSelected: selectedItem == SidebarItem.search,
            onTap: () => onItemSelected(SidebarItem.search),
          ),
          _SidebarItem(
            icon: Icons.library_music,
            label: 'Library',
            isSelected: selectedItem == SidebarItem.library,
            onTap: () => onItemSelected(SidebarItem.library),
          ),
          _SidebarItem(
            icon: Icons.favorite,
            label: 'Favorites',
            isSelected: selectedItem == SidebarItem.favorites,
            onTap: () => onItemSelected(SidebarItem.favorites),
          ),
          const Spacer(),
          const Divider(color: AppTheme.dividerColor),
          _SidebarItem(
            icon: Icons.settings,
            label: 'Settings',
            isSelected: selectedItem == SidebarItem.settings,
            onTap: () => onItemSelected(SidebarItem.settings),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentColor.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppTheme.accentColor : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppTheme.accentColor
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
