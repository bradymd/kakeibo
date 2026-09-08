import 'package:flutter/material.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';

/// Day-of-month progress: one small block per day, filled for days
/// already passed, with the payday's block highlighted amber. Kept
/// from the original dashboard's day-of-month progress
/// (`lib/widgets/budget_bar.dart`) rather than replaced with a
/// continuous gradient bar — the individual blocks are the point.
class ToyDayBlocks extends StatelessWidget {
  const ToyDayBlocks({
    super.key,
    required this.dayOfMonth,
    required this.daysInMonth,
    this.paydayDayOfMonth,
    this.blockHeight = 20,
  });

  final int dayOfMonth;
  final int daysInMonth;
  final int? paydayDayOfMonth;
  final double blockHeight;

  static const _gap = 2.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalGaps = (daysInMonth - 1) * _gap;
        final blockWidth = (constraints.maxWidth - totalGaps) / daysInMonth;
        return Row(
          children: List.generate(daysInMonth, (i) {
            final filled = i < dayOfMonth;
            final isPayday = paydayDayOfMonth != null && i == paydayDayOfMonth! - 1;
            final Color blockColor;
            if (isPayday) {
              blockColor = filled ? ToyColors.amberInk : ToyColors.amberBg;
            } else {
              blockColor = filled ? ToyColors.brand : const Color(0xFFF1E3E8);
            }
            return Container(
              width: blockWidth,
              height: blockHeight,
              margin: EdgeInsets.only(right: i < daysInMonth - 1 ? _gap : 0),
              decoration: BoxDecoration(
                color: blockColor,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
