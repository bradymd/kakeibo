import 'package:flutter/material.dart';

class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 500),
    this.formatter,
  });

  final double value;
  final TextStyle style;
  final Duration duration;
  final String Function(double)? formatter;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      builder: (context, animatedValue, _) {
        final text = formatter != null
            ? formatter!(animatedValue)
            : animatedValue.toStringAsFixed(2);
        return Text(text, style: style);
      },
    );
  }
}
