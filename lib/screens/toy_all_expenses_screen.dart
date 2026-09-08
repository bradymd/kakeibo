import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/services/swipe_nav.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-redesign Spend screen (README §3a). New screen, reached
/// only via the preview route added in `lib/app.dart` for now — see
/// `toy_home_screen.dart` for the same caveat.
///
/// Reuses `currentMonthProvider` directly rather than
/// `recentExpensesProvider` (which caps at 5) since this screen shows
/// every expense in the month.
class ToyAllExpensesScreen extends ConsumerStatefulWidget {
  const ToyAllExpensesScreen({super.key, this.initialPillar});

  /// Pillar to pre-filter to, e.g. when arriving from a tapped capsule
  /// on the dashboard. Null shows all pillars (the default).
  final Pillar? initialPillar;

  @override
  ConsumerState<ToyAllExpensesScreen> createState() => _ToyAllExpensesScreenState();
}

class _ToyAllExpensesScreenState extends ConsumerState<ToyAllExpensesScreen> {
  Pillar? _filterPillar;

  @override
  void initState() {
    super.initState();
    _filterPillar = widget.initialPillar;
  }

  @override
  Widget build(BuildContext context) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

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
        var expenses = [...currentMonth.expenses]
          ..sort((a, b) {
            final cmp = b.date.compareTo(a.date);
            return cmp != 0 ? cmp : b.createdAt.compareTo(a.createdAt);
          });

        if (_filterPillar != null) {
          expenses = expenses.where((e) => e.pillar == _filterPillar).toList();
        }

        final filteredTotal = expenses.fold(0.0, (sum, e) => sum + e.amount);

        return ToyScaffold(
          title: '支出 Spent',
          subtitle: displayMonth,
          headlineFigure:
              '${fmt(filteredTotal)}   ${expenses.length} ${expenses.length == 1 ? 'entry' : 'entries'}',
          tab: ToyTabDestination.spend,
          tabPathOverrides: const {
            ToyTabDestination.month: '/toy-dashboard',
            ToyTabDestination.fixed: '/toy-fixed-expenses',
            ToyTabDestination.income: '/toy-income',
          },
          trailing: const ToyMenuButton(),
          floatingActionButton: ToyFab(onTap: () => context.push('/toy-add-expense')),
          body: GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity > 300) {
                SwipeNav.go(context, '/toy-dashboard', SlideDirection.right);
              } else if (velocity < -300) {
                SwipeNav.go(context, '/toy-fixed-expenses', SlideDirection.left);
              }
            },
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
                Expanded(
                  child: expenses.isEmpty
                      ? _EmptyState(filtered: _filterPillar != null)
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
                                    onDismissed: (_) => ref
                                        .read(kakeiboMonthsProvider.notifier)
                                        .deleteExpense(expenses[i].id),
                                    child: ToyRow(
                                      title: expenses[i].description,
                                      meta:
                                          '${expenses[i].pillar.label} ${expenses[i].pillar.japanese} ・ ${DateFormat('d MMM').format(DateTime.parse(expenses[i].date))}',
                                      amountText: fmt(expenses[i].amount),
                                      leading: ToyPillarDot(color: expenses[i].pillar.toyFill),
                                      onTap: () => context.push('/toy-edit-expense/${expenses[i].id}'),
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
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filtered});

  final bool filtered;

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
          ],
        ),
      ),
    );
  }
}
