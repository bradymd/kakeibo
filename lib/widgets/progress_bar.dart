import 'package:flutter/material.dart';

class PillarProgressBar extends StatelessWidget {
  const PillarProgressBar({
    super.key,
    required this.spent,
    required this.budget,
    required this.color,
    this.height = 8,
  });

  final double spent;
  final double budget;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.5) : 0.0;
    final isOver = spent > budget;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(
                isOver ? Colors.red.shade400 : color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
