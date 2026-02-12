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
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/empty_state.dart';
import 'package:kakeibo/widgets/expense_tile.dart';
import 'package:kakeibo/widgets/budget_bar.dart';
import 'package:kakeibo/widgets/gradient_card.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:kakeibo/widgets/month_navigator.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final isSetup = ref.watch(isMonthSetupProvider);
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    String fmt(double amount) => CurrencyFormatter.format(amount, currency: currency);

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final displayMonth = MonthHelpers.formatMonthDisplay(year, month);

    return KakeiboScaffold(
      title: '家計簿 Kakeibo',
      actions: [
        MonthNavigator(
          displayText: displayMonth,
          onPrevious: () {
            ref.read(currentMonthIdProvider.notifier).state =
                MonthHelpers.getPrevMonthId(monthId);
          },
          onNext: () {
            ref.read(currentMonthIdProvider.notifier).state =
                MonthHelpers.getNextMonthId(monthId);
          },
        ),
      ],
      floatingActionButton: isSetup
          ? FloatingActionButton(
              onPressed: () => context.push('/add-expense'),
              tooltip: 'Add Expense',
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
      body: monthAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.hotPink),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (currentMonth) {
                if (!isSetup) {
                  return EmptyState(
                    message: 'Set up $displayMonth',
                    subtitle: 'Enter your income and savings goal to get started',
                    actionLabel: 'Set Up Month',
                    icon: Icons.calendar_today_rounded,
                    onAction: () => context.push('/setup'),
                  );
                }

                final availableBudget = ref.watch(availableBudgetProvider);
                final totalSpent = ref.watch(totalSpentProvider);
                final disposableIncome = ref.watch(disposableIncomeProvider);
                final fixedCostsTotal = ref.watch(fixedExpensesTotalProvider);
                final pillarTotals = ref.watch(pillarTotalsProvider);
                final recentExpenses = ref.watch(recentExpensesProvider);

                final now = DateTime.now();
                final daysInMonth = DateTime(year, month + 1, 0).day;
                final dayOfMonth = (year == now.year && month == now.month)
                    ? now.day
                    : (now.isAfter(DateTime(year, month + 1, 0))
                        ? daysInMonth
                        : 1);

                return RefreshIndicator(
                  color: AppColors.hotPink,
                  onRefresh: () async {
                    ref.invalidate(kakeiboMonthsProvider);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Budget bar — at-a-glance money overview
                      BudgetBar(
                        totalIncome: currentMonth.income,
                        fixedCostsTotal: fixedCostsTotal,
                        disposableIncome: disposableIncome,
                        savingsGoal: currentMonth.savingsGoal,
                        availableBudget: availableBudget,
                        totalSpent: totalSpent,
                        formatAmount: fmt,
                        dayOfMonth: dayOfMonth,
                        daysInMonth: daysInMonth,
                      ),

                      const SizedBox(height: 20),

                      // Four Pillars
                      Text('Four Pillars', style: AppTextStyles.subheading),
                      Text('四柱', style: AppTextStyles.japanese),
                      const SizedBox(height: 10),
                      ...Pillar.values.map((pillar) {
                        final spent = pillarTotals[pillar] ?? 0;
                        return GradientCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Icon(pillar.icon,
                                  color: pillar.color, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${pillar.label} (${pillar.japanese})',
                                style: AppTextStyles.bodyBold
                                    .copyWith(color: pillar.color),
                              ),
                              const Spacer(),
                              Text(
                                fmt(spent),
                                style: AppTextStyles.bodyBold.copyWith(
                                  color: pillar.color,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),



                      const SizedBox(height: 20),

                      // Recent expenses
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Expenses',
                              style: AppTextStyles.subheading),
                          if (currentMonth.expenses.isNotEmpty)
                            TextButton(
                              onPressed: () => context.go('/expenses'),
                              child: Text(
                                'See all',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.hotPink,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (recentExpenses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No expenses yet. Tap + to add one!',
                              style: AppTextStyles.caption,
                            ),
                          ),
                        )
                      else
                        ...recentExpenses.map((expense) => ExpenseTile(
                              expense: expense,
                              formattedAmount: fmt(expense.amount),
                              onTap: () => context.push(
                                  '/edit-expense/${expense.id}'),
                              onDelete: () {
                                ref
                                    .read(kakeiboMonthsProvider.notifier)
                                    .deleteExpense(expense.id);
                              },
                            )),
                      const SizedBox(height: 80), // FAB clearance
                    ],
                  ),
                );
              },
            ),
    );
  }
}