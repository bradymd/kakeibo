import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// The toy-themed header menu button. Lists the destinations the new
/// [ToyTabBar] doesn't already cover. Home, Spend (Expenses), Fixed
/// Costs and Reflect (End of Month) moved to always-visible tabs;
/// Start of Month has no tab-bar slot of its own, so it stays here
/// alongside Income, Settings and About (mirrors `KakeiboMenuButton`
/// minus the four routes now reachable from the tab bar).
enum _ToyMenuRoute {
  income('/income', '収入', 'Income', Icons.account_balance_wallet_rounded),
  setup('/setup', '月のはじめ', 'Start of Month', Icons.play_arrow_rounded),
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
