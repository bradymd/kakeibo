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
import 'package:kakeibo/providers/payday_provider.dart';
import 'package:kakeibo/services/payday_calculator.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:intl/intl.dart';

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
      showBackButton: true,
      centerTitle: true,
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

              // Payday card (or hint if not configured)
              if (ref.watch(paydayPresetProvider) == PaydayPreset.none)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: GestureDetector(
                    onTap: () => context.push('/payday-settings'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.paydayAmber.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_rounded,
                              color: AppColors.paydayAmber, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Do you have a regular payday? Set it up in Settings.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.paydayAmber,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.paydayAmber, size: 18),
                        ],
                      ),
                    ),
                  ),
                )
              else
                _PaydayCard(monthId: monthId, year: year, month: month),

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

class _PaydayCard extends ConsumerStatefulWidget {
  const _PaydayCard({
    required this.monthId,
    required this.year,
    required this.month,
  });

  final String monthId;
  final int year;
  final int month;

  @override
  ConsumerState<_PaydayCard> createState() => _PaydayCardState();
}

class _PaydayCardState extends ConsumerState<_PaydayCard> {
  String? _override;

  @override
  void initState() {
    super.initState();
    _loadOverride();
  }

  @override
  void didUpdateWidget(covariant _PaydayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.monthId != widget.monthId) {
      _loadOverride();
    }
  }

  Future<void> _loadOverride() async {
    final override = await ref
        .read(settingsProvider.notifier)
        .getPaydayOverride(widget.monthId);
    if (mounted) setState(() => _override = override);
  }

  Future<void> _pickDate() async {
    final firstDay = DateTime(widget.year, widget.month, 1);
    final lastDay = DateTime(widget.year, widget.month + 1, 0);
    final initial = _override != null
        ? DateTime.tryParse(_override!) ?? firstDay
        : PaydayCalculator.suggestedPayday(
              widget.year, widget.month, ref.read(paydayPresetProvider)) ??
            firstDay;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDay) || initial.isAfter(lastDay)
          ? firstDay
          : initial,
      firstDate: firstDay,
      lastDate: lastDay,
    );
    if (picked != null && mounted) {
      final iso = picked.toIso8601String().split('T').first;
      await ref
          .read(settingsProvider.notifier)
          .setPaydayOverride(widget.monthId, iso);
      setState(() => _override = iso);
      ref.invalidate(currentPaydayProvider);
    }
  }

  Future<void> _resetOverride() async {
    await ref
        .read(settingsProvider.notifier)
        .setPaydayOverride(widget.monthId, null);
    setState(() => _override = null);
    ref.invalidate(currentPaydayProvider);
  }

  @override
  Widget build(BuildContext context) {
    final preset = ref.watch(paydayPresetProvider);
    if (preset == PaydayPreset.none) return const SizedBox.shrink();

    final suggested = PaydayCalculator.suggestedPayday(
        widget.year, widget.month, preset);
    final hasOverride = _override != null;
    final displayDate = hasOverride
        ? DateTime.tryParse(_override!)
        : suggested;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.paydayAmber.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.paydayAmber.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_rounded, color: AppColors.paydayAmber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Payday',
                    style: AppTextStyles.subheading
                        .copyWith(color: AppColors.paydayAmber),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (displayDate != null)
              Text(
                DateFormat('EEEE, MMM d').format(displayDate),
                style: AppTextStyles.currencySmall.copyWith(
                  color: AppColors.paydayAmber,
                ),
              ),
            if (hasOverride)
              Text(
                'Overridden for this month',
                style: AppTextStyles.caption.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: _pickDate,
                  child: Text(hasOverride ? 'Change' : 'Override for this month'),
                ),
                if (hasOverride)
                  TextButton(
                    onPressed: _resetOverride,
                    child: const Text('Reset'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
