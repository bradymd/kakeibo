import 'package:flutter/material.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/theme/app_text_styles.dart';

class PillarBreakdownChart extends StatelessWidget {
  const PillarBreakdownChart({
    super.key,
    required this.pillarTotals,
    required this.formatAmount,
    this.height = 28,
  });

  final Map<Pillar, double> pillarTotals;
  final String Function(double) formatAmount;
  final double height;

  @override
  Widget build(BuildContext context) {
    final total =
        pillarTotals.values.fold(0.0, (sum, val) => sum + val);
    if (total == 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Row(
              children: Pillar.values
                  .where((p) => (pillarTotals[p] ?? 0) > 0)
                  .map((pillar) {
                final ratio = (pillarTotals[pillar] ?? 0) / total;
                return Expanded(
                  flex: (ratio * 1000).round(),
                  child: Container(color: pillar.color),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...Pillar.values.map((pillar) {
          final amount = pillarTotals[pillar] ?? 0;
          if (amount == 0) return const SizedBox.shrink();
          final pct = (amount / total * 100).toStringAsFixed(0);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: pillar.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${pillar.label} (${pillar.japanese})',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '$pct%  ${formatAmount(amount)}',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
