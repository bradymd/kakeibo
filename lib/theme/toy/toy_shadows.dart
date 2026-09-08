import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_colors.dart';

/// Hard offset shadows for the toy theme — no blur, a flat drop that
/// reads as a physical ledge under cards/buttons. See README "Spacing,
/// radius, shadow".
class ToyShadows {
  const ToyShadows._();

  /// Cards: `0 5px 0 #F3B9CD`.
  static List<BoxShadow> card({Color color = ToyColors.cardShadow, double offset = 5}) => [
        BoxShadow(color: color, blurRadius: 0, offset: Offset(0, offset)),
      ];

  /// Small buttons/pills: `0 4px 0`.
  static List<BoxShadow> small({required Color color, double offset = 4}) => [
        BoxShadow(color: color, blurRadius: 0, offset: Offset(0, offset)),
      ];

  /// Primary buttons/FAB: `0 6px 0`.
  static List<BoxShadow> primary({required Color color, double offset = 6}) => [
        BoxShadow(color: color, blurRadius: 0, offset: Offset(0, offset)),
      ];

  /// Pressed state: shrinks to a smaller offset, same colour. Pair with
  /// [ToyPressable] which also translates the element down to match.
  static List<BoxShadow> pressed({required Color color, double offset = 1}) => [
        BoxShadow(color: color, blurRadius: 0, offset: Offset(0, offset)),
      ];

  /// Tab bar's top ledge: `0 -3px 0 #F3B9CD`.
  static List<BoxShadow> tabBarTop({Color color = ToyColors.cardShadow}) => [
        BoxShadow(color: color, blurRadius: 0, offset: const Offset(0, -3)),
      ];
}
