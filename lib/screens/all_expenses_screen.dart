import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/month_calculations_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_gradients.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/cherry_blossom_decoration.dart';
import 'package:kakeibo/widgets/empty_state.dart';
import 'package:kakeibo/widgets/expense_tile.dart';
import 'package:kakeibo/widgets/month_navigator.dart';

class AllExpensesScreen extends ConsumerStatefulWidget {
  const AllExpensesScreen({super.key});

  @override
  ConsumerState<AllExpensesScreen> createState() => _AllExpensesScreenState();
}

class _AllExpensesScreenState extends ConsumerState<AllExpensesScreen> {
  Pillar? _filterPillar;

  @override
  Widget build(BuildContext context) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final displayMonth = MonthHelpers.formatMonthDisplay(year, month);

    String fmt(double amount) =>
        CurrencyFormatter.format(amount, currency: currency);

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.header),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: CherryBlossomDecoration(opacity: 0.08),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expenses',
                                    style: AppTextStyles.heading
                                        .copyWith(color: Colors.white),
                                  ),
                                  Text(
                                    'Total: ${fmt(totalSpent)}',
                                    style: AppTextStyles.caption
                                        .copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        MonthNavigator(
                          displayText: displayMonth,
                          onPrevious: () {
                            ref
                                .read(currentMonthIdProvider.notifier)
                                .state =
                                MonthHelpers.getPrevMonthId(monthId);
                          },
                          onNext: () {
                            ref
                                .read(currentMonthIdProvider.notifier)
                                .state =
                                MonthHelpers.getNextMonthId(monthId);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pillar filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterPillar == null,
                  onSelected: (_) => setState(() => _filterPillar = null),
                  selectedColor: AppColors.hotPink.withValues(alpha: 0.15),
                  checkmarkColor: AppColors.hotPink,
                ),
                const SizedBox(width: 8),
                ...Pillar.values.map((pillar) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(pillar.label),
                        avatar: Icon(pillar.icon,
                            size: 16, color: pillar.color),
                        selected: _filterPillar == pillar,
                        onSelected: (_) =>
                            setState(() => _filterPillar = pillar),
                        selectedColor:
                            pillar.color.withValues(alpha: 0.15),
                        checkmarkColor: pillar.color,
                      ),
                    )),
              ],
            ),
          ),

          // Expense list
          Expanded(
            child: monthAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (currentMonth) {
                var expenses = [...currentMonth.expenses]
                  ..sort((a, b) => b.date.compareTo(a.date));

                if (_filterPillar != null) {
                  expenses = expenses
                      .where((e) => e.pillar == _filterPillar)
                      .toList();
                }

                if (expenses.isEmpty) {
                  return EmptyState(
                    message: _filterPillar != null
                        ? 'No ${_filterPillar!.label.toLowerCase()} expenses'
                        : 'No expenses yet',
                    subtitle: 'Tap + to add your first expense',
                    icon: Icons.receipt_long_rounded,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ExpenseTile(
                      expense: expense,
                      formattedAmount: fmt(expense.amount),
                      onTap: () => context
                          .push('/edit-expense/${expense.id}'),
                      onDelete: () {
                        ref
                            .read(kakeiboMonthsProvider.notifier)
                            .deleteExpense(expense.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-expense'),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
