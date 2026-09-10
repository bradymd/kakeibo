import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/month_calculations_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/expense_category_stats.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/services/swipe_nav.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_category_summary_card.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-redesign Spend screen (README §3a).
///
/// Reuses `currentMonthProvider` directly rather than
/// `recentExpensesProvider` (which caps at 5) since this screen shows
/// every expense in the month.
class ToyAllExpensesScreen extends ConsumerStatefulWidget {
  const ToyAllExpensesScreen({super.key, this.initialPillar, this.initialCategoryFilter});

  /// Pillar to pre-filter to, e.g. when arriving from a tapped capsule
  /// on the dashboard. Null shows all pillars (the default).
  final Pillar? initialPillar;

  /// Category filter to pre-apply, e.g. when arriving from the category
  /// breakdown screen (either a named category or "uncategorised"). Null
  /// shows all categories (the default). Shown back to the user as a
  /// dismissible applied-filter pill rather than a second filter carousel
  /// (per Codex's recommendation).
  final CategoryFilter? initialCategoryFilter;

  @override
  ConsumerState<ToyAllExpensesScreen> createState() => _ToyAllExpensesScreenState();
}

class _ToyAllExpensesScreenState extends ConsumerState<ToyAllExpensesScreen> {
  Pillar? _filterPillar;
  CategoryFilter? _filterCategory;

  /// IDs whose Dismissible has already finished its dismiss animation but
  /// whose delete is still in flight (deleteExpense awaits a db write
  /// before invalidating the provider that supplies `expenses`). Filtered
  /// out of the displayed list immediately, before the first `await`, so
  /// Dismissible never rebuilds with the same key still present -- doing
  /// that violates its contract ("A dismissed Dismissible widget is still
  /// part of the tree") and Flutter paints its debug ErrorWidget (small
  /// yellow text on dark red) for however long the delete takes.
  final _pendingDeletionIds = <String>{};

  @override
  void initState() {
    super.initState();
    _filterPillar = widget.initialPillar;
    _filterCategory = widget.initialCategoryFilter;
  }

  @override
  Widget build(BuildContext context) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';
    final availableBudget = ref.watch(availableBudgetProvider);

    String fmt(double amount) => CurrencyFormatter.format(amount, currency: currency);

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final displayMonth = MonthHelpers.formatMonthDisplay(year, month);

    return monthAsync.when(
      loading: () => Scaffold(
        backgroundColor: ToyColors.bg,
        body: const Center(child: CircularProgressIndicator(color: ToyColors.brand)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: ToyColors.bg,
        body: Center(child: Text('Error: $e')),
      ),
      data: (currentMonth) {
        var expenses = currentMonth.expenses
            .where((e) => !_pendingDeletionIds.contains(e.id))
            .toList()
          ..sort((a, b) {
            final cmp = b.date.compareTo(a.date);
            return cmp != 0 ? cmp : b.createdAt.compareTo(a.createdAt);
          });

        if (_filterPillar != null) {
          expenses = expenses.where((e) => e.pillar == _filterPillar).toList();
        }

        // Snapshot for the summary card/threshold check -- taken before the
        // category filter below so the card's "N of M categorised" always
        // reflects the pillar-filtered set, not a further-narrowed one.
        final categoryEligible = expenses;

        final filterCategory = _filterCategory;
        if (filterCategory != null) {
          expenses = expenses.where(filterCategory.matches).toList();
        }

        final showCategorySummary = _filterCategory == null &&
            ExpenseCategoryStats.meetsSummaryThreshold(categoryEligible);

        return ToyScaffold(
          title: '支出 Spent',
          subtitle: '$displayMonth ・ ${expenses.length} ${expenses.length == 1 ? 'entry' : 'entries'}',
          tab: ToyTabDestination.spend,
          trailing: const ToyMenuButton(),
          floatingActionButton: ToyFab(onTap: () => context.push('/add-expense')),
          body: GestureDetector(
            onHorizontalDragEnd: (details) => SwipeNav.handleTabSwipe(
              context,
              ToyTabDestination.spend,
              details.primaryVelocity ?? 0,
            ),
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                ToyCapsuleFilterRow(
                  children: [
                    ToyCapsuleFilter(
                      label: 'すべて All',
                      selected: _filterPillar == null,
                      textColor: ToyColors.ink,
                      onTap: () => setState(() => _filterPillar = null),
                    ),
                    for (final pillar in Pillar.values)
                      ToyCapsuleFilter(
                        label: '${pillar.japanese} ${pillar.label}',
                        selected: _filterPillar == pillar,
                        textColor: pillar.toyFilterInk,
                        // Tapping the already-selected pillar is a no-op —
                        // only 'All' clears the filter (README §3a).
                        onTap: () => setState(() => _filterPillar = pillar),
                      ),
                  ],
                ),
                if (_filterCategory != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ToyMetrics.screenPaddingH,
                      8,
                      ToyMetrics.screenPaddingH,
                      0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _AppliedFilterPill(
                        label: _filterCategory!.pillLabel,
                        onClear: () => setState(() => _filterCategory = null),
                      ),
                    ),
                  ),
                if (showCategorySummary)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ToyMetrics.screenPaddingH,
                      10,
                      ToyMetrics.screenPaddingH,
                      0,
                    ),
                    child: ToyCategorySummaryCard(
                      stats: ExpenseCategoryStats.aggregate(categoryEligible),
                      categorisedCount: ExpenseCategoryStats.categorisedCount(categoryEligible),
                      totalCount: categoryEligible.length,
                      formatAmount: fmt,
                      onTap: () => context.push('/category-breakdown'),
                    ),
                  ),
                Expanded(
                  child: expenses.isEmpty
                      ? _EmptyState(
                          filtered: _filterPillar != null,
                          availableBudgetText: fmt(availableBudget),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            ToyMetrics.screenPaddingH,
                            0,
                            ToyMetrics.screenPaddingH,
                            ToyMetrics.listBottomPadding,
                          ),
                          child: ToyCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                for (var i = 0; i < expenses.length; i++) ...[
                                  if (i > 0) const DashedDivider(),
                                  Dismissible(
                                    key: Key(expenses[i].id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      color: ToyColors.danger,
                                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                                    ),
                                    confirmDismiss: (_) => _confirmDelete(context, expenses[i].description),
                                    onDismissed: (_) => _deleteExpense(expenses[i].id),
                                    child: ToyRow(
                                      title: expenses[i].description,
                                      meta:
                                          '${expenses[i].pillar.label} ${expenses[i].pillar.japanese} ・ ${DateFormat('d MMM').format(DateTime.parse(expenses[i].date))}'
                                          '${expenses[i].category.isEmpty ? '' : ' ・ ${expenses[i].category}'}',
                                      amountText: fmt(expenses[i].amount),
                                      leading: ToyPillarDot(color: expenses[i].pillar.toyFill),
                                      onTap: () => context.push('/edit-expense/${expenses[i].id}'),
                                    ),
                                  ),
                                ],
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    '← swipe a row to delete',
                                    style: ToyTextStyles.label(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: ToyColors.placeholder,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String description) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete expense?'),
        content: Text('Are you sure you want to delete "$description"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: ToyColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Called from Dismissible.onDismissed, which requires the dismissed
  /// widget to be gone from the tree by the time this returns -- filtering
  /// `id` out of the build()-time `expenses` list via setState here does
  /// that synchronously, before the `await` below ever runs. See
  /// _pendingDeletionIds' doc comment for the bug this fixes.
  Future<void> _deleteExpense(String id) async {
    setState(() => _pendingDeletionIds.add(id));
    try {
      await ref.read(kakeiboMonthsProvider.notifier).deleteExpense(id);
      // Left in _pendingDeletionIds even after success: the provider
      // reload triggered by deleteExpense is itself async and not
      // awaited here, so clearing the ID immediately could momentarily
      // reintroduce the row before that reload lands. It naturally stops
      // mattering once fresh data no longer contains this id at all.
    } catch (_) {
      if (mounted) {
        setState(() => _pendingDeletionIds.remove(id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete expense. Please try again.')),
        );
      }
    }
  }
}

/// A single compact "applied filter" pill shown below the pillar row when
/// arriving with a category pre-filter (e.g. from the breakdown screen's
/// tap-to-filter). Per Codex: never a second full carousel, just one pill
/// with a clear (x) affordance.
class _AppliedFilterPill extends StatelessWidget {
  const _AppliedFilterPill({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClear,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        decoration: BoxDecoration(
          color: ToyColors.brand.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: ToyTextStyles.label(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: ToyColors.brand,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.close_rounded, size: 15, color: ToyColors.brand),
          ],
        ),
      ),
    );
  }
}

/// README §5c — no expenses yet. The budget-total line only applies
/// when genuinely nothing has been logged this month (unfiltered); a
/// pillar filter finding zero matches doesn't mean the month is empty,
/// so it keeps the shorter copy.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered, required this.availableBudgetText});

  final bool filtered;
  final String availableBudgetText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 172,
              height: 172,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0EA),
                shape: BoxShape.circle,
              ),
              child: Text(
                '？',
                style: ToyTextStyles.hero(fontSize: 40, color: const Color(0xFFE9C3D2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              filtered ? 'No expenses in this pillar yet.' : 'No expenses yet. Tap ＋ to add one!',
              style: ToyTextStyles.cardTitle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            if (!filtered) ...[
              const SizedBox(height: 8),
              Text(
                'You have $availableBudgetText to budget this month.',
                style: ToyTextStyles.body(),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
