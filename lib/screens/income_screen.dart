import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final monthName = DateFormat('MMMM').format(DateTime(year, month));

    String fmt(double amount) =>
        CurrencyFormatter.format(amount, currency: currency);

    return KakeiboScaffold(
      title: 'Income',
      subtitle: 'Your earnings this month',
      showHomeButton: true,
      centerTitle: true,
      onBack: () => context.go('/'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-income'),
        backgroundColor: AppColors.hotPink,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: monthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (currentMonth) {
          final verb = currentMonth.reflection.completed ? 'was' : 'is';
          final totalIncome = currentMonth.income;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Total statement panel
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Your total income for $monthName $verb ${fmt(totalIncome)}',
                  style: AppTextStyles.subheading.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ),

              // Income sources list
              if (currentMonth.incomeSources.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No income sources yet. Tap + to add one!',
                      style: AppTextStyles.caption,
                    ),
                  ),
                )
              else
                ...currentMonth.incomeSources.map((source) => InkWell(
                      onTap: () =>
                          context.push('/edit-income/${source.id}'),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(source.name,
                                  style: AppTextStyles.bodyBold),
                            ),
                            Text(fmt(source.amount),
                                style: AppTextStyles.bodyBold),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right_rounded,
                                color: Colors.grey.shade400, size: 20),
                          ],
                        ),
                      ),
                    )),

              // Import prompt — only show when empty
              if (currentMonth.incomeSources.isEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: AppTextStyles.caption,
                            children: [
                              const TextSpan(text: 'You can '),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.baseline,
                                baseline: TextBaseline.alphabetic,
                                child: GestureDetector(
                                  onTap: () =>
                                      context.push('/import-income'),
                                  child: Text(
                                    'import',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.success,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(
                                  text:
                                      ' income from previously populated months.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // FAB clearance
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }
}
