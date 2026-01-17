import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:spindle/router/app_router.gr.dart';
import 'package:spindle/widget/mini_player.dart';

@RoutePage()
class MobileMainPage extends StatelessWidget {
  const MobileMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AutoRouter(),
      bottomNavigationBar: MiniPlayer(
        onTap: () => context.router.push(const MobilePlayerRoute()),
      ),
    );
  }
}
