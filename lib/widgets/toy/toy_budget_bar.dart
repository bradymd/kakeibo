import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// The dashboard's three-segment budget bar (README §2b): savings goal
/// (green) / spent (pink) / remaining (gold), 16px, single inline
/// legend beneath — "one representation only", no duplicate colour key
/// and no restating sentence.
///
/// Ratio math mirrors the existing `BudgetBar` widget exactly (see
/// `lib/widgets/budget_bar.dart`): the savings segment physically
/// shrinks as overspending eats into it, and a fourth hatched "over
/// budget" segment appears once spending exceeds the available budget
/// (README §5a).
class ToyBudgetBar extends StatelessWidget {
  const ToyBudgetBar({
    super.key,
    required this.savingsGoal,
    required this.disposableIncome,
    required this.availableBudget,
    required this.totalSpent,
    required this.formatAmount,
  });

  final double savingsGoal;
  final double disposableIncome;
  final double availableBudget;
  final double totalSpent;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    if (disposableIncome <= 0) return const SizedBox.shrink();

    final overflowIntoSavings =
        totalSpent > availableBudget ? totalSpent - availableBudget : 0.0;
    final actualSavings = max(savingsGoal - overflowIntoSavings, 0.0);
    final actualSavingsRatio = (actualSavings / disposableIncome).clamp(0.0, 1.0);
    final availableRatio = 1.0 - actualSavingsRatio;

    final spentOfAvailable = availableBudget > 0
        ? (totalSpent / availableBudget).clamp(0.0, double.infinity)
        : 0.0;
    final availableRemaining = availableBudget - totalSpent;
    final isOverBudget = availableRemaining < 0;
    final remaining = isOverBudget ? 0.0 : availableRemaining;
    final overspendAmount = isOverBudget ? -availableRemaining : 0.0;

    // When overspent, the "available" band splits three ways instead of
    // two: spent-up-to-budget / (nothing left) / overspend hatch. We
    // fold the "remaining" segment down to zero width in that case and
    // add a fourth hatched segment sized to the overspend, taken out of
    // the savings band's flex so the bar never exceeds 100%.
    final overspendRatio = isOverBudget && disposableIncome > 0
        ? (overspendAmount / disposableIncome).clamp(0.0, 1.0)
        : 0.0;
    final savingsFlex = max(
      ((actualSavingsRatio - overspendRatio).clamp(0.0, 1.0) * 1000).round(),
      overspendRatio > 0 ? 0 : 60,
    );
    final availableFlex = max((availableRatio * 1000).round(), 100);
    final overspendFlex = (overspendRatio * 1000).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 16,
            child: Row(
              children: [
                if (savingsFlex > 0)
                  Expanded(
                    flex: savingsFlex,
                    child: const ColoredBox(color: ToyPillarColors.needsFill),
                  ),
                Expanded(
                  flex: availableFlex,
                  child: _AvailableSegment(spentRatio: spentOfAvailable.clamp(0.0, 1.0)),
                ),
                if (overspendFlex > 0)
                  Expanded(
                    flex: overspendFlex,
                    child: CustomPaint(painter: const OverspendHatchPainter()),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _LegendItem(color: ToyPillarColors.needsFill, label: 'Savings ${formatAmount(actualSavings)}'),
            _LegendItem(color: ToyColors.brand, label: 'Spent ${formatAmount(totalSpent)}'),
            _LegendItem(
              color: ToyColors.gold,
              label: isOverBudget
                  ? 'Over by ${formatAmount(overspendAmount)}'
                  : 'Left ${formatAmount(remaining)}',
            ),
          ],
        ),
      ],
    );
  }
}

class _AvailableSegment extends StatelessWidget {
  const _AvailableSegment({required this.spentRatio});

  final double spentRatio;

  @override
  Widget build(BuildContext context) {
    final spentFlex = max((spentRatio * 1000).round(), 40);
    final leftFlex = max(((1.0 - spentRatio) * 1000).round(), 40);
    return Row(
      children: [
        Expanded(flex: spentFlex, child: const ColoredBox(color: ToyColors.brand)),
        Expanded(flex: leftFlex, child: const ColoredBox(color: ToyColors.gold)),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 5),
        Text(label, style: ToyTextStyles.label(fontSize: 10.5, fontWeight: FontWeight.w700, color: ToyColors.muted)),
      ],
    );
  }
}
