import 'package:flutter/material.dart';
import 'package:kakeibo/services/expense_category_stats.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// A palette cycled across categories in stacked-bar/legend order. Not
/// pillar colours (a category isn't a pillar) -- distinct, muted-toy tones
/// so the bar doesn't visually collide with the pillar filter row above it.
const _kCategoryPalette = [
  Color(0xFF38C39A),
  Color(0xFFE8447C),
  Color(0xFF8B5CF6),
  Color(0xFFF97316),
  Color(0xFF2D9CDB),
];
const _kUncategorisedColor = Color(0xFFD8CDD2);

Color categoryColor(int index) =>
    _kCategoryPalette[index % _kCategoryPalette.length];

/// README/discussion §"Categories カテゴリー" card — a full-width,
/// conditional insight card between the pillar filter row and the
/// transaction list on Spend. Only rendered by the caller once
/// `ExpenseCategoryStats.meetsSummaryThreshold` is true; this widget just
/// renders whatever stats it's given.
///
/// Per Codex's recommendation: a small stacked bar (not a miniature pie --
/// stays legible at phone width), "N of M categorised" always shown so the
/// bar can't imply uncategorised spend was included, and the whole card is
/// one navigation target ("See all" is reinforcement, not a separate tap
/// target).
class ToyCategorySummaryCard extends StatelessWidget {
  const ToyCategorySummaryCard({
    super.key,
    required this.stats,
    required this.categorisedCount,
    required this.totalCount,
    required this.formatAmount,
    required this.onTap,
  });

  final List<CategoryStat> stats;
  final int categorisedCount;
  final int totalCount;
  final String Function(double) formatAmount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final named = stats.where((s) => s.name.isNotEmpty).toList();
    final total = stats.fold(0.0, (sum, s) => sum + s.total);
    final topThree = named.take(3).toList();
    final remaining = named.length - topThree.length;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ToyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'カテゴリー Categories',
                    style: ToyTextStyles.cardTitle(fontSize: 15),
                  ),
                ),
                Text(
                  'See all',
                  style: ToyTextStyles.label(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: ToyColors.brand,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 18, color: ToyColors.brand),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$categorisedCount of $totalCount categorised',
                    style: ToyTextStyles.label(fontSize: 12, color: ToyColors.muted2),
                  ),
                ),
                Text(
                  formatAmount(total),
                  style: ToyTextStyles.label(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ToyColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _StackedBar(stats: stats, total: total),
            if (topThree.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 4,
                children: [
                  for (var i = 0; i < topThree.length; i++)
                    Text(
                      '${i > 0 ? ' • ' : ''}${topThree[i].name} ${formatAmount(topThree[i].total)}',
                      style: ToyTextStyles.label(fontSize: 11.5, color: ToyColors.muted),
                    ),
                  if (remaining > 0)
                    Text(
                      ' • $remaining more',
                      style: ToyTextStyles.label(fontSize: 11.5, color: ToyColors.muted2),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({required this.stats, required this.total});

  final List<CategoryStat> stats;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();
    var namedIndex = 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            for (final stat in stats)
              Expanded(
                flex: (stat.total / total * 1000).round().clamp(1, 1000),
                child: Container(
                  color: stat.name.isEmpty
                      ? _kUncategorisedColor
                      : categoryColor(namedIndex++),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
