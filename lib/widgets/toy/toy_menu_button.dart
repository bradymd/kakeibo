import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// The toy-themed header menu button. Month, Spend, Fixed and Income
/// are the four things tracked *during* the month, so they live on the
/// always-visible [ToyTabBar]. Start of Month and End of Month are the
/// two bookend rituals that open and close a month — paired together
/// here rather than split between a tab and a menu — followed by the
/// genuinely infrequent Settings and About.
enum _ToyMenuRoute {
  setup('/setup', '月のはじめ', 'Start of Month', Icons.play_arrow_rounded),
  reflect('/reflection', '反省', 'End of Month', Icons.self_improvement_rounded),
  settings('/settings', '設定', 'Settings and Tools', Icons.settings_rounded),
  about('/about', 'について', 'About Kakeibo', Icons.info_outline_rounded);

  const _ToyMenuRoute(this.path, this.japanese, this.label, this.icon);
  final String path;
  final String japanese;
  final String label;
  final IconData icon;
}

class ToyMenuButton extends StatelessWidget {
  const ToyMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return PopupMenuButton<_ToyMenuRoute>(
      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
      offset: const Offset(0, 48),
      color: ToyColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onSelected: (route) {
        if (!location.startsWith(route.path)) context.push(route.path);
      },
      itemBuilder: (_) => _ToyMenuRoute.values.map((route) {
        final isCurrent = location.startsWith(route.path);
        return PopupMenuItem<_ToyMenuRoute>(
          value: route,
          child: Row(
            children: [
              Icon(
                route.icon,
                size: 20,
                color: isCurrent ? ToyColors.brand : ToyColors.muted2,
              ),
              const SizedBox(width: 12),
              Text(
                route.label,
                style: ToyTextStyles.rowTitle(
                  fontSize: 13.5,
                  color: isCurrent ? ToyColors.brand : ToyColors.ink,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
