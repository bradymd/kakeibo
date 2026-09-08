import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// The 64x64 gold "+" FAB (README "Global chrome"): radius 32,
/// `#FFD24C`, glyph 34/900 in `#7A5600`, shadow `0 6px 0 #D9A400`.
class ToyFab extends StatelessWidget {
  const ToyFab({super.key, required this.onTap, this.icon = '+'});

  final VoidCallback onTap;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return ToyPressable(
      restOffset: 6,
      pressedOffset: 2,
      onTap: onTap,
      builder: (context, offset) => Container(
        width: ToyMetrics.fabSize,
        height: ToyMetrics.fabSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ToyColors.gold,
          borderRadius: BorderRadius.circular(ToyMetrics.fabRadius),
          boxShadow: ToyShadows.primary(color: ToyColors.goldShadow, offset: offset),
        ),
        child: Text(
          icon,
          style: ToyTextStyles.hero(fontSize: 34, color: ToyColors.goldInk),
        ),
      ),
    );
  }
}
