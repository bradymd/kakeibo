import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// The dashboard's three-segment budget bar (README §2b): savings goal
/// (green) / spent (pink) / remaining (gold). Each segment carries its
/// own formatted amount directly inside it, matching the original
/// `BudgetBar` (`lib/widgets/budget_bar.dart`) — not a separate legend.
///
/// Sizing deliberately follows the original's approach exactly:
/// `Expanded`/`flex` (a relative proportion Flutter's Row always fits
/// into the available width, never overflowing, however small the
/// screen) with a generous minimum flex per segment, plus `FittedBox`
/// inside each label as the safety net for genuinely extreme ratios.
///
/// An earlier version of this widget computed literal pixel widths
/// itself and "borrowed" space between segments — that math assumed
/// there was always enough total width to borrow from, which silently
/// overflowed (and Flutter clips overflow, so the text just vanished)
/// at real phone widths. `Expanded`/`flex` can't make that mistake: the
/// framework does the division, and it always sums to the real width.
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

    final overflowIntoSavings = totalSpent > availableBudget ? totalSpent - availableBudget : 0.0;
    final actualSavings = max(savingsGoal - overflowIntoSavings, 0.0);
    final actualSavingsRatio = (actualSavings / disposableIncome).clamp(0.0, 1.0);

    final availableRemaining = availableBudget - totalSpent;
    final isOverBudget = availableRemaining < 0;
    final remaining = isOverBudget ? 0.0 : availableRemaining;
    final overspendAmount = isOverBudget ? -availableRemaining : 0.0;

    final overspendRatio =
        isOverBudget && disposableIncome > 0 ? (overspendAmount / disposableIncome).clamp(0.0, 1.0) : 0.0;

    // Spend shown in the "Spent" segment is capped at the available
    // budget — anything past that is the separate "Over" segment's
    // money, not both at once. Without this cap, the full totalSpent
    // label and the Over label double-count the same overspend amount
    // (and it also implicitly reduced the Goal segment via
    // overflowIntoSavings above), so the labels summed to more than
    // disposableIncome.
    final spentWithinBudget = isOverBudget ? availableBudget : totalSpent;
    final spentOfDisposable =
        disposableIncome > 0 ? (spentWithinBudget / disposableIncome).clamp(0.0, 1.0) : 0.0;
    final leftOfDisposable = disposableIncome > 0 ? (remaining / disposableIncome).clamp(0.0, 1.0) : 0.0;
    final savingsShareRatio = (actualSavingsRatio - overspendRatio).clamp(0.0, 1.0);

    final savingsLabel = 'Goal ${formatAmount(actualSavings)}';
    final spentLabel = 'Spent ${formatAmount(spentWithinBudget)}';
    final leftLabel = isOverBudget ? null : 'Left ${formatAmount(remaining)}';
    final overLabel = isOverBudget ? 'Over ${formatAmount(overspendAmount)}' : null;

    // Minimum flex units (of 1000) guarantee every segment stays wide
    // enough for its own two/three-word label in the common case;
    // FittedBox still protects the genuinely extreme case (e.g. four
    // segments at once on a very narrow screen).
    const minFlex = 220;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            if (savingsShareRatio > 0)
              Expanded(
                flex: max((savingsShareRatio * 1000).round(), minFlex),
                child: _Segment(color: ToyPillarColors.needsFill, label: savingsLabel),
              ),
            Expanded(
              flex: max((spentOfDisposable * 1000).round(), minFlex),
              child: _Segment(color: ToyColors.brand, label: spentLabel),
            ),
            if (leftLabel != null)
              Expanded(
                flex: max((leftOfDisposable * 1000).round(), minFlex),
                child: _Segment(color: ToyColors.gold, label: leftLabel),
              ),
            if (overLabel != null)
              Expanded(
                flex: max((overspendRatio * 1000).round(), minFlex),
                child: _HatchedSegment(label: overLabel),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: const Border(right: BorderSide(color: Colors.white, width: 1)),
      ),
      child: _SegmentLabel(label),
    );
  }
}

class _HatchedSegment extends StatelessWidget {
  const _HatchedSegment({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: const OverspendHatchPainter()),
        _SegmentLabel(label),
      ],
    );
  }
}

/// A segment's own amount, centred, shrinking to fit if the segment is
/// ever too narrow for it at full size — the same `FittedBox` safety
/// net the original `BudgetBar` uses, so text is squeezed, never lost.
class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
