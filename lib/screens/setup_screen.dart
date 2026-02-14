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
  bool _isEditingSavings = false;
  bool _savingsInitialised = false;

  @override
  void initState() {
    super.initState();
    _savingsController.addListener(() => setState(() {}));

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
        // Initialise savings controller from saved value
        if (!_savingsInitialised && month.savingsGoal > 0) {
          _savingsController.text = month.savingsGoal.toStringAsFixed(2);
          _savingsInitialised = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _savingsController.dispose();
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
      showHomeButton: true,
      centerTitle: true,
      onBack: () => context.go('/'),
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
              // Income summary — tap to go to Income page
              _summaryCard(
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.success,
                title: 'Your Income this month',
                items: currentMonth.incomeSources
                    .map((s) => (s.name, fmt(s.amount)))
                    .toList(),
                total: fmt(totalIncome),
                totalColor: AppColors.success,
                emptyText: 'No income sources yet',
                onManage: () => context.push('/income'),
                color: AppColors.softPink,
              ),

              const SizedBox(height: 16),

              // Fixed expenses summary — tap to go to Fixed Costs page
              _summaryCard(
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.vividPurple,
                title: 'Fixed Costs',
                items: currentMonth.fixedExpenses
                    .map((e) => (
                          e.name.isNotEmpty ? e.name : e.category,
                          fmt(e.amount)
                        ))
                    .toList(),
                total: fmt(fixedTotal),
                totalColor: AppColors.vividPurple,
                emptyText: 'No fixed costs yet',
                onManage: () => context.push('/fixed-expenses'),
                color: AppColors.softBlue,
              ),

              const SizedBox(height: 16),

              // Savings goal
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.savings_rounded,
                            color: AppColors.success),
                        const SizedBox(width: 8),
                        Text(
                          'Your savings goal this month',
                          style: AppTextStyles.subheading.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
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
                              label: 'Amount',
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
                          Expanded(
                            child: Text(
                              fmt(savings),
                              style: AppTextStyles.currencySmall.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
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

  /// Reusable summary card for Income and Fixed Costs on the setup page.
  Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<(String, String)> items,
    required String total,
    required Color totalColor,
    required String emptyText,
    required VoidCallback onManage,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onManage,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: AppTextStyles.subheading),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.grey.shade400, size: 24),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(item.$1, style: AppTextStyles.body),
                        ),
                        Text(item.$2, style: AppTextStyles.bodyBold),
                      ],
                    ),
                  )),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTextStyles.bodyBold),
                  Text(
                    total,
                    style: AppTextStyles.currencySmall.copyWith(
                      color: totalColor,
                    ),
                  ),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(emptyText, style: AppTextStyles.caption),
              ),
          ],
        ),
      ),
    );
  }
}
