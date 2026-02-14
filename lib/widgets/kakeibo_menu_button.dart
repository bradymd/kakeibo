import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/theme/app_colors.dart';

enum _MenuRoute {
  home('/', 'Home', Icons.home_rounded),
  income('/income', 'Income', Icons.account_balance_wallet_rounded),
  expenses('/expenses', 'Expenses', Icons.receipt_long_rounded),
  fixedCosts('/fixed-expenses', 'Fixed Costs', Icons.account_balance_rounded),
  setup('/setup', 'Start of Month', Icons.play_arrow_rounded),
  reflection('/reflection', 'End of Month', Icons.self_improvement_rounded),
  settings('/settings', 'App Settings', Icons.settings_rounded);

  const _MenuRoute(this.path, this.label, this.icon);
  final String path;
  final String label;
  final IconData icon;
}

class KakeiboMenuButton extends StatelessWidget {
  const KakeiboMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return PopupMenuButton<_MenuRoute>(
      icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (route) => context.go(route.path),
      itemBuilder: (_) => _MenuRoute.values.map((route) {
        final isCurrent = _isCurrentRoute(location, route.path);
        return PopupMenuItem<_MenuRoute>(
          value: route,
          child: Row(
            children: [
              Icon(
                route.icon,
                size: 20,
                color: isCurrent ? AppColors.hotPink : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                route.label,
                style: TextStyle(
                  color: isCurrent ? AppColors.hotPink : AppColors.textPrimary,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _isCurrentRoute(String location, String path) {
    if (path == '/') return location == '/';
    return location.startsWith(path);
  }
}
