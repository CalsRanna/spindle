import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/widget/mini_player.dart';
import 'package:spindle/widget/sidebar.dart';

@RoutePage()
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  SidebarItem _selectedItem = SidebarItem.library;

  void _onSidebarItemSelected(SidebarItem item) {
    setState(() {
      _selectedItem = item;
    });

    switch (item) {
      case SidebarItem.search:
        context.router.replace(const SearchRoute());
        break;
      case SidebarItem.library:
        context.router.replace(const LibraryRoute());
        break;
      case SidebarItem.favorites:
        context.router.replace(const FavoritesRoute());
        break;
      case SidebarItem.settings:
        context.router.replace(const SettingsRoute());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedItem: _selectedItem,
            onItemSelected: _onSidebarItemSelected,
          ),
          Expanded(
            child: Stack(
              children: [
                const AutoRouter(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: MiniPlayer(
                    onTap: () => context.router.push(const PlayerRoute()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: Stack(
        children: [
          const AutoRouter(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(
              onTap: () => context.router.push(const PlayerRoute()),
            ),
          ),
        ],
      ),
    );
  }
}
