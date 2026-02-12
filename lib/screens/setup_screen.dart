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
import 'package:kakeibo/widgets/sparkle_button.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _savingsController = TextEditingController();
  final _incomeNameController = TextEditingController();
  final _incomeAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to text controllers to trigger validation
    _incomeNameController.addListener(() => setState(() {}));
    _incomeAmountController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final monthAsync = ref.read(currentMonthProvider);
      monthAsync.whenData((month) {
        if (month.savingsGoal > 0) {
          _savingsController.text = month.savingsGoal.toStringAsFixed(2);
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
      title: 'Monthly Setup',
      subtitle: displayMonth,
      showBackButton: true,
      body: monthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (currentMonth) {
          final totalIncome = currentMonth.income;
          final savings = double.tryParse(_savingsController.text) ?? 0;
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
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: CurrencyInput(
                            controller: _incomeAmountController,
                            currencySymbol:
                                CurrencyFormatter.symbol(currency: currency),
                            hint: '0.00',
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _canAddIncome
                              ? () async {
                                  await ref
                                      .read(kakeiboMonthsProvider.notifier)
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
                                  setState(() {});
                                }
                              : null,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.hotPink,
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Fixed expenses summary
              if (fixedTotal > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded,
                          color: AppColors.vividPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fixed Costs',
                                style: AppTextStyles.bodyBold),
                            Text(fmt(fixedTotal),
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/fixed-expenses'),
                        child: const Text('Edit'),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Q2: Savings goal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Q2: How much do you want to save?',
                      style: AppTextStyles.subheading,
                    ),
                    Text(
                      'Set your savings target for this month',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 12),
                    CurrencyInput(
                      controller: _savingsController,
                      currencySymbol:
                          CurrencyFormatter.symbol(currency: currency),
                      label: 'Savings Goal',
                      onChanged: (_) => setState(() {}),
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
                          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)])
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
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                    if (available > 0)
                      Text(
                        '${fmt(available / 4)} per pillar',
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SparkleButton(
                label: 'Save Setup',
                icon: Icons.check_rounded,
                onPressed: totalIncome > 0
                    ? () async {
                        await ref
                            .read(kakeiboMonthsProvider.notifier)
                            .setupMonth(
                              monthId: monthId,
                              income: totalIncome,
                              savingsGoal: savings,
                            );
                        if (context.mounted) context.pop();
                      }
                    : null,
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
