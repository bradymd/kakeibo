import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// The base card shape used throughout the toy theme: white, rounded,
/// hard offset shadow, no blur. Radius defaults to 24 (README's 22–26
/// range) — pass [radius] for screens that need the low or high end.
class ToyCard extends StatelessWidget {
  const ToyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(ToyMetrics.cardPadding),
    this.radius = ToyMetrics.cardRadius,
    this.color = ToyColors.card,
    this.shadowColor = ToyColors.cardShadow,
    this.shadowOffset = 5,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color shadowColor;
  final double shadowOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: ToyShadows.card(color: shadowColor, offset: shadowOffset),
      ),
      child: child,
    );
  }
}
