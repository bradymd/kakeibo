import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/month_calculations_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/currency_input.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _savingsController = TextEditingController();
  final _incomeNameController = TextEditingController();
  final _incomeAmountController = TextEditingController();
  bool _isEditingSavings = false;
  bool _isAddingIncome = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to text controllers to trigger validation
    _incomeNameController.addListener(() => setState(() {}));
    _incomeAmountController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final monthAsync = ref.read(currentMonthProvider);
      monthAsync.whenData((month) {
        // Migrate legacy income: if income exists but no sources, create one
        if (month.income > 0 && month.incomeSources.isEmpty) {
          final monthId = ref.read(currentMonthIdProvider);
          ref.read(kakeiboMonthsProvider.notifier).addIncomeSource(
                monthId: monthId,
                name: 'Income',
                amount: month.income,
              );
        }
      });
    });
  }

  @override
  void dispose() {
    _savingsController.dispose();
    _incomeNameController.dispose();
    _incomeAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';
    final fixedTotal = ref.watch(fixedExpensesTotalProvider);

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final displayMonth = MonthHelpers.formatMonthDisplay(year, month);

    String fmt(double amount) =>
        CurrencyFormatter.format(amount, currency: currency);

    return KakeiboScaffold(
      title: 'Start of Month',
      subtitle: displayMonth,
      showBackButton: true,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      body: monthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (currentMonth) {
          final totalIncome = currentMonth.income;
          final savings = _isEditingSavings
              ? (double.tryParse(_savingsController.text) ?? 0)
              : currentMonth.savingsGoal;
          final available = totalIncome - fixedTotal - savings;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Q1: Income sources
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softPink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q1: How much money do you have?',
                      style: AppTextStyles.subheading,
                    ),
                    Text(
                      'Add your income sources (salary, pensions, etc.)',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 12),

                    // Existing income sources
                    ...currentMonth.incomeSources.map((source) => Dismissible(
                          key: Key(source.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete_rounded,
                                color: Colors.white),
                          ),
                          onDismissed: (_) {
                            ref
                                .read(kakeiboMonthsProvider.notifier)
                                .deleteIncomeSource(source.id, monthId);
                          },
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8),
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.attach_money_rounded,
                                  color: AppColors.success, size: 18),
                            ),
                            title: Text(source.name,
                                style: AppTextStyles.bodyBold),
                            trailing: Text(fmt(source.amount),
                                style: AppTextStyles.bodyBold),
                          ),
                        )),

                    // Total
                    if (currentMonth.incomeSources.isNotEmpty) ...[
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Income',
                              style: AppTextStyles.bodyBold),
                          Text(
                            fmt(totalIncome),
                            style: AppTextStyles.currencySmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Add new income source
                    if (_isAddingIncome)
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _incomeNameController,
                              decoration: const InputDecoration(
                                hintText: 'e.g. Salary, Pension',
                                isDense: true,
                              ),
                              textCapitalization:
                                  TextCapitalization.sentences,
                              autofocus: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: CurrencyInput(
                              controller: _incomeAmountController,
                              currencySymbol: CurrencyFormatter.symbol(
                                  currency: currency),
                              hint: '0.00',
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _canAddIncome
                                ? () async {
                                    await ref
                                        .read(
                                            kakeiboMonthsProvider.notifier)
                                        .addIncomeSource(
                                          monthId: monthId,
                                          name: _incomeNameController.text
                                              .trim(),
                                          amount: double.tryParse(
                                                  _incomeAmountController
                                                      .text) ??
                                              0,
                                        );
                                    _incomeNameController.clear();
                                    _incomeAmountController.clear();
                                    setState(
                                        () => _isAddingIncome = false);
                                  }
                                : null,
                            icon:
                                const Icon(Icons.check_rounded, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.hotPink,
                              disabledBackgroundColor:
                                  Colors.grey.shade300,
                            ),
                          ),
                        ],
                      )
                    else
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton.filled(
                          onPressed: () =>
                              setState(() => _isAddingIncome = true),
                          icon: const Icon(Icons.add_rounded, size: 24),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.hotPink,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Fixed expenses
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            color: AppColors.vividPurple),
                        const SizedBox(width: 8),
                        Text('Fixed Costs',
                            style: AppTextStyles.subheading),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () =>
                              context.push('/fixed-expenses'),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    if (currentMonth.fixedExpenses.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...currentMonth.fixedExpenses.map((expense) =>
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    expense.name.isNotEmpty
                                        ? expense.name
                                        : expense.category,
                                    style: AppTextStyles.body,
                                  ),
                                ),
                                Text(fmt(expense.amount),
                                    style: AppTextStyles.bodyBold),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(kakeiboMonthsProvider
                                            .notifier)
                                        .deleteFixedExpense(expense.id);
                                  },
                                  child: const Icon(
                                    Icons.delete_rounded,
                                    color: AppColors.danger,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total',
                              style: AppTextStyles.bodyBold),
                          Text(fmt(fixedTotal),
                              style: AppTextStyles.bodyBold),
                        ],
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8),
                        child: Text(
                          'No fixed costs yet',
                          style: AppTextStyles.caption,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Q2: Savings goal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q2: How much do you want to save?',
                      style: AppTextStyles.subheading.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isEditingSavings)
                      Row(
                        children: [
                          Expanded(
                            child: CurrencyInput(
                              controller: _savingsController,
                              currencySymbol:
                                  CurrencyFormatter.symbol(currency: currency),
                              hint: '0.00',
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: () async {
                              await ref
                                  .read(kakeiboMonthsProvider.notifier)
                                  .setupMonth(
                                    monthId: monthId,
                                    income: totalIncome,
                                    savingsGoal: savings,
                                  );
                              setState(() => _isEditingSavings = false);
                            },
                            icon: const Icon(Icons.check_rounded, size: 20),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.success,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          const Icon(Icons.savings_rounded,
                              color: AppColors.success),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              fmt(currentMonth.savingsGoal),
                              style: AppTextStyles.currencySmall.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _savingsController.text =
                                  currentMonth.savingsGoal > 0
                                      ? currentMonth.savingsGoal
                                          .toStringAsFixed(2)
                                      : '';
                              setState(() => _isEditingSavings = true);
                            },
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Available budget preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: available >= 0
                      ? const LinearGradient(
                          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)])
                      : const LinearGradient(
                          colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text('Available to Spend', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      fmt(available),
                      style: AppTextStyles.currency.copyWith(
                        color: available >= 0
                            ? const Color(0xFF818CF8)
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool get _canAddIncome {
    return _incomeNameController.text.trim().isNotEmpty &&
        (double.tryParse(_incomeAmountController.text) ?? 0) > 0;
  }
}
