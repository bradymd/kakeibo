import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/expense_category_stats.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_category_summary_card.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// Dedicated Spend category breakdown screen, reached from the "Categories"
/// summary card. Donut + vertical legend per Codex's recommendation: total
/// in the centre; name/amount/percentage/count per row; descending by
/// amount; top five slices plus Other; Uncategorised muted grey by default.
/// Tapping a row filters back into Spend with an applied-filter pill.
class ToyCategoryBreakdownScreen extends ConsumerWidget {
  const ToyCategoryBreakdownScreen({super.key});

  static const _maxSlices = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthAsync = ref.watch(currentMonthProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';
    String fmt(double amount) => CurrencyFormatter.format(amount, currency: currency);

    return monthAsync.when(
      loading: () => const Scaffold(
        backgroundColor: ToyColors.bg,
        body: Center(child: CircularProgressIndicator(color: ToyColors.brand)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: ToyColors.bg,
        body: Center(child: Text('Error: $e')),
      ),
      data: (month) {
        final all = ExpenseCategoryStats.aggregate(month.expenses);
        final named = all.where((s) => s.name.isNotEmpty).toList();
        final uncategorised = all.where((s) => s.name.isEmpty).firstOrNull;
        final total = all.fold(0.0, (sum, s) => sum + s.total);

        final topFive = named.take(_maxSlices).toList();
        final restTotal =
            named.skip(_maxSlices).fold(0.0, (sum, s) => sum + s.total);
        final restCount = named.skip(_maxSlices).fold(0, (sum, s) => sum + s.count);

        // Slices for the donut: top five, an "Other" bucket for the rest
        // of the named categories, then Uncategorised last and muted.
        final sliceStats = [
          ...topFive,
          if (restTotal > 0)
            CategoryStat(name: 'Other', total: restTotal, count: restCount),
        ];

        return ToyScaffold(
          title: 'カテゴリー内訳 Category breakdown',
          showBackButton: true,
          body: month.expenses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No expenses yet this month.',
                      style: ToyTextStyles.body(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    ToyMetrics.screenPaddingH,
                    16,
                    ToyMetrics.screenPaddingH,
                    24,
                  ),
                  child: Column(
                    children: [
                      ToyCard(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 180,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(180, 180),
                                    painter: _DonutPainter(
                                      slices: sliceStats,
                                      uncategorised: uncategorised,
                                      total: total,
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        fmt(total),
                                        style: ToyTextStyles.hero(fontSize: 22),
                                      ),
                                      Text(
                                        'total spent',
                                        style: ToyTextStyles.label(
                                          fontSize: 11,
                                          color: ToyColors.muted2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: ToyMetrics.cardGap),
                      ToyCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < topFive.length; i++) ...[
                              if (i > 0) const DashedDivider(),
                              _LegendRow(
                                color: categoryColor(i),
                                stat: topFive[i],
                                total: total,
                                formatAmount: fmt,
                                onTap: () => context.push(
                                  '/expenses?category=${Uri.encodeComponent(topFive[i].name)}',
                                ),
                              ),
                            ],
                            if (restTotal > 0) ...[
                              const DashedDivider(),
                              _LegendRow(
                                color: ToyColors.muted2,
                                stat: CategoryStat(
                                  name: 'Other',
                                  total: restTotal,
                                  count: restCount,
                                ),
                                total: total,
                                formatAmount: fmt,
                                onTap: null,
                              ),
                            ],
                            if (uncategorised != null) ...[
                              const DashedDivider(),
                              _LegendRow(
                                color: const Color(0xFFD8CDD2),
                                stat: uncategorised,
                                total: total,
                                formatAmount: fmt,
                                muted: true,
                                onTap: () => context.push(
                                  '/expenses?category=${Uri.encodeComponent(kUncategorisedFilterValue)}',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.stat,
    required this.total,
    required this.formatAmount,
    required this.onTap,
    this.muted = false,
  });

  final Color color;
  final CategoryStat stat;
  final double total;
  final String Function(double) formatAmount;
  final VoidCallback? onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (stat.total / total * 100).round() : 0;
    final label = stat.name.isEmpty ? 'Uncategorised' : stat.name;
    return Semantics(
      label: '$label, ${formatAmount(stat.total)}, $pct percent, ${stat.count} ${stat.count == 1 ? 'expense' : 'expenses'}',
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: ToyTextStyles.rowTitle(
                    fontSize: 13.5,
                    color: muted ? ToyColors.muted2 : ToyColors.ink,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: ToyTextStyles.label(fontSize: 11.5, color: ToyColors.muted2),
              ),
              const SizedBox(width: 8),
              Text(
                formatAmount(stat.total),
                style: ToyTextStyles.rowTitle(
                  fontSize: 13.5,
                  color: muted ? ToyColors.muted2 : ToyColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.uncategorised, required this.total});

  final List<CategoryStat> slices;
  final CategoryStat? uncategorised;
  final double total;

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 22.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    var startAngle = -1.5707963267948966; // -90deg, 12 o'clock
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    void drawSlice(double amount, Color color) {
      final sweep = (amount / total) * 6.283185307179586;
      paint.color = color;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    for (var i = 0; i < slices.length; i++) {
      drawSlice(slices[i].total, slices[i].name == 'Other' ? ToyColors.muted2 : categoryColor(i));
    }
    if (uncategorised != null) {
      drawSlice(uncategorised!.total, const Color(0xFFD8CDD2));
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.total != total;
}
