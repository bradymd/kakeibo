import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/month_calculations_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/services/swipe_nav.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';

class FixedExpensesScreen extends ConsumerWidget {
  const FixedExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final fixedTotal = ref.watch(fixedExpensesTotalProvider);
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final monthName = DateFormat('MMMM').format(DateTime(year, month));

    String fmt(double amount) =>
        CurrencyFormatter.format(amount, currency: currency);

    return KakeiboScaffold(
      title: 'Fixed Costs',
      subtitle: 'Monthly bills & commitments',
      showHomeButton: true,
      centerTitle: true,
      onBack: () => context.go('/'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-fixed-expense'),
        backgroundColor: AppColors.hotPink,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 300) {
            // Swipe right → back to Home (slides in from left)
            SwipeNav.go(context, '/', SlideDirection.left);
          }
        },
        behavior: HitTestBehavior.translucent,
        child: monthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (currentMonth) {
          final verb = currentMonth.reflection.completed ? 'were' : 'are';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Total line
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.vividPurple.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Your total fixed costs for $monthName $verb ${fmt(fixedTotal)}',
                  style: AppTextStyles.subheading.copyWith(
                    color: AppColors.vividPurple,
                  ),
                ),
              ),

              // Existing fixed expenses
              if (currentMonth.fixedExpenses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No fixed costs yet. Tap + to add one!',
                      style: AppTextStyles.caption,
                    ),
                  ),
                )
              else
                ...currentMonth.fixedExpenses.map((expense) => InkWell(
                      onTap: () => context.push(
                          '/edit-fixed-expense/${expense.id}'),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.category,
                                    style: AppTextStyles.bodyBold,
                                  ),
                                  if (expense.name.isNotEmpty)
                                    Text(expense.name,
                                        style: AppTextStyles.caption),
                                  if (expense.dueDay != null)
                                    Text(
                                      'Due: ${_ordinal(expense.dueDay!)} of the month',
                                      style:
                                          AppTextStyles.caption.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(fmt(expense.amount),
                                style: AppTextStyles.bodyBold),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right_rounded,
                                color: Colors.grey.shade400, size: 20),
                          ],
                        ),
                      ),
                    )),

              // Import prompt — only show when empty
              if (currentMonth.fixedExpenses.isEmpty) ...[
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
                                      context.push('/import-fixed-costs'),
                                  child: Text(
                                    'import',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.vividPurple,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.vividPurple,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(
                                  text:
                                      ' fixed costs from previously populated months.'),
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
      ),
    );
  }

  static String _ordinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    return switch (day % 10) {
      1 => '${day}st',
      2 => '${day}nd',
      3 => '${day}rd',
      _ => '${day}th',
    };
  }
}
