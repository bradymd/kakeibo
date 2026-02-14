import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:kakeibo/widgets/sparkle_button.dart';

enum ImportType { fixedCosts, income }

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key, required this.importType});

  final ImportType importType;

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  String? _selectedMonthId;

  @override
  Widget build(BuildContext context) {
    final currentMonthId = ref.watch(currentMonthIdProvider);
    final allMonthsAsync = ref.watch(kakeiboMonthsProvider);
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    final isFixedCosts = widget.importType == ImportType.fixedCosts;
    final title = isFixedCosts ? 'Import Fixed Costs' : 'Import Income';

    String fmt(double amount) =>
        CurrencyFormatter.format(amount, currency: currency);

    return KakeiboScaffold(
      title: title,
      showBackButton: true,
      showMenuButton: false,
      body: allMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allMonths) {
          // Filter to months that have relevant data and aren't the current month
          final candidates = allMonths.where((m) {
            if (m.id == currentMonthId) return false;
            return isFixedCosts
                ? m.fixedExpenses.isNotEmpty
                : m.incomeSources.isNotEmpty;
          }).toList()
            ..sort((a, b) {
              // Sort newest first
              final cmp = b.year.compareTo(a.year);
              return cmp != 0 ? cmp : b.month.compareTo(a.month);
            });

          if (candidates.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  isFixedCosts
                      ? 'No other months with fixed costs to import from.'
                      : 'No other months with income sources to import from.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Find selected month data
          final selectedMonth = _selectedMonthId != null
              ? candidates
                  .where((m) => m.id == _selectedMonthId)
                  .firstOrNull
              : null;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                isFixedCosts
                    ? 'Select a month to import fixed costs from:'
                    : 'Select a month to import income sources from:',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 12),

              // Month dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedMonthId,
                decoration: InputDecoration(
                  labelText: 'Month',
                  prefixIcon: const Icon(Icons.calendar_month_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: candidates.map((m) {
                  final display =
                      MonthHelpers.formatMonthDisplay(m.year, m.month);
                  final count = isFixedCosts
                      ? m.fixedExpenses.length
                      : m.incomeSources.length;
                  final itemWord = isFixedCosts ? 'costs' : 'sources';
                  return DropdownMenuItem(
                    value: m.id,
                    child: Text('$display ($count $itemWord)'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedMonthId = v),
              ),
              const SizedBox(height: 20),

              // Preview of items
              if (selectedMonth != null) ...[
                Text('Items to import:', style: AppTextStyles.subheading),
                const SizedBox(height: 8),

                if (isFixedCosts)
                  ...selectedMonth.fixedExpenses.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(e.category,
                                      style: AppTextStyles.bodyBold),
                                  if (e.name.isNotEmpty)
                                    Text(e.name,
                                        style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Text(fmt(e.amount),
                                style: AppTextStyles.bodyBold),
                          ],
                        ),
                      ))
                else
                  ...selectedMonth.incomeSources.map((s) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(s.name,
                                  style: AppTextStyles.bodyBold),
                            ),
                            Text(fmt(s.amount),
                                style: AppTextStyles.bodyBold),
                          ],
                        ),
                      )),

                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTextStyles.bodyBold),
                    Text(
                      fmt(isFixedCosts
                          ? selectedMonth.fixedExpenses
                              .fold(0.0, (sum, e) => sum + e.amount)
                          : selectedMonth.incomeSources
                              .fold(0.0, (sum, s) => sum + s.amount)),
                      style: AppTextStyles.currencySmall.copyWith(
                        color: isFixedCosts
                            ? AppColors.vividPurple
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SparkleButton(
                  label: isFixedCosts
                      ? 'Import Fixed Costs'
                      : 'Import Income',
                  icon: Icons.download_rounded,
                  onPressed: () async {
                    final notifier =
                        ref.read(kakeiboMonthsProvider.notifier);
                    if (isFixedCosts) {
                      for (final e in selectedMonth.fixedExpenses) {
                        await notifier.addFixedExpense(
                          monthId: currentMonthId,
                          name: e.name,
                          amount: e.amount,
                          category: e.category,
                          dueDay: e.dueDay,
                        );
                      }
                    } else {
                      for (final s in selectedMonth.incomeSources) {
                        await notifier.addIncomeSource(
                          monthId: currentMonthId,
                          name: s.name,
                          amount: s.amount,
                        );
                      }
                    }
                    if (context.mounted) context.pop();
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
