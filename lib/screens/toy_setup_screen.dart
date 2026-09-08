import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/month_calculations_provider.dart';
import 'package:kakeibo/providers/payday_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-redesign Start of Month screen (README §4c). New
/// screen, preview-only for now.
class ToySetupScreen extends ConsumerStatefulWidget {
  const ToySetupScreen({super.key});

  @override
  ConsumerState<ToySetupScreen> createState() => _ToySetupScreenState();
}

class _ToySetupScreenState extends ConsumerState<ToySetupScreen> {
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
        if (month.income > 0 && month.incomeSources.isEmpty) {
          final monthId = ref.read(currentMonthIdProvider);
          ref
              .read(kakeiboMonthsProvider.notifier)
              .addIncomeSource(monthId: monthId, name: 'Income', amount: month.income);
        }
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
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';
    final fixedTotal = ref.watch(fixedExpensesTotalProvider);
    final paydayAsync = ref.watch(currentPaydayProvider);

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final displayMonth = MonthHelpers.formatMonthDisplay(year, month);

    String fmt(double amount) => CurrencyFormatter.format(amount, currency: currency);

    return ToyScaffold(
      title: '月のはじめ',
      subtitle: 'Start of Month ・ $displayMonth',
      showBackButton: true,
      trailing: const ToyMenuButton(),
      body: monthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: ToyColors.brand)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (currentMonth) {
          final totalIncome = currentMonth.income;
          final savings = double.tryParse(_savingsController.text) ?? 0;
          final available = totalIncome - fixedTotal - savings;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              ToyMetrics.screenPaddingH,
              16,
              ToyMetrics.screenPaddingH,
              24,
            ),
            children: [
              _SummaryCard(
                title: '収入 Your Income this month',
                titleColor: ToyColors.success,
                items: currentMonth.incomeSources.map((s) => (s.name, fmt(s.amount))).toList(),
                total: fmt(totalIncome),
                totalColor: ToyColors.success,
                onTap: () => context.push('/toy-income'),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              _SummaryCard(
                title: '固定費 Fixed Costs',
                titleColor: const Color(0xFF6B34B0),
                items: currentMonth.fixedExpenses
                    .map((e) => (e.name.isNotEmpty ? e.name : e.category, fmt(e.amount)))
                    .toList(),
                total: fmt(fixedTotal),
                totalColor: const Color(0xFF6B34B0),
                onTap: () => context.push('/toy-fixed-expenses'),
                maxItems: 3,
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              paydayAsync.when(
                data: (payday) => payday == null
                    ? _paydayHint(context)
                    : _PaydayCard(monthId: monthId, year: year, month: month, payday: payday),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => _paydayHint(context),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              Container(
                padding: const EdgeInsets.all(ToyMetrics.cardPadding),
                decoration: BoxDecoration(
                  color: ToyColors.mint,
                  borderRadius: BorderRadius.circular(ToyMetrics.cardRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '貯金目標 Your savings goal this month',
                      style: ToyTextStyles.cardTitle(fontSize: 14.5, color: ToyColors.successDark),
                    ),
                    const SizedBox(height: 12),
                    if (_isEditingSavings)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                              decoration: BoxDecoration(
                                color: ToyColors.card,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: TextField(
                                controller: _savingsController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: ToyTextStyles.rowAmount(fontSize: 22, color: ToyColors.success),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                  prefixText: '${CurrencyFormatter.symbol(currency: currency)} ',
                                  hintText: '0.00',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ToyCapsuleButton(
                            label: 'Save',
                            fillColor: ToyPillarColors.needsFill,
                            shadowColor: ToyColors.success,
                            textColor: const Color(0xFF08301F),
                            onTap: () async {
                              await ref.read(kakeiboMonthsProvider.notifier).setupMonth(
                                    monthId: monthId,
                                    income: totalIncome,
                                    savingsGoal: savings,
                                  );
                              setState(() => _isEditingSavings = false);
                            },
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                              decoration: BoxDecoration(
                                color: ToyColors.card,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                fmt(savings),
                                style: ToyTextStyles.rowAmount(fontSize: 22, color: ToyColors.success),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ToyCapsuleButton(
                            label: 'Edit',
                            fillColor: ToyPillarColors.needsFill,
                            shadowColor: ToyColors.success,
                            textColor: const Color(0xFF08301F),
                            onTap: () => setState(() => _isEditingSavings = true),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              ToyCard(
                child: Column(
                  children: [
                    Text(
                      'AVAILABLE TO SPEND',
                      style: ToyTextStyles.microLabel(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt(available),
                      style: ToyTextStyles.hero(
                        fontSize: 40,
                        color: available >= 0 ? ToyColors.brand : ToyColors.danger,
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

  Widget _paydayHint(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/toy-payday-settings'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ToyColors.amberBg,
          borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_rounded, color: ToyColors.amberInk, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Do you have a regular payday? Set it up in Settings.',
                style: ToyTextStyles.label(fontSize: 11.5, color: ToyColors.amberInk),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: ToyColors.amberInk, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.titleColor,
    required this.items,
    required this.total,
    required this.totalColor,
    required this.onTap,
    this.maxItems,
  });

  final String title;
  final Color titleColor;
  final List<(String, String)> items;
  final String total;
  final Color totalColor;
  final VoidCallback onTap;
  final int? maxItems;

  @override
  Widget build(BuildContext context) {
    final shown = maxItems != null && items.length > maxItems! ? items.take(maxItems!).toList() : items;
    final overflow = items.length - shown.length;

    return GestureDetector(
      onTap: onTap,
      child: ToyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: ToyTextStyles.cardTitle(fontSize: 14.5, color: titleColor))),
                const Icon(Icons.chevron_right_rounded, color: ToyColors.chevron),
              ],
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final item in shown)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.$1, style: ToyTextStyles.label(fontSize: 12.5, fontWeight: FontWeight.w600, color: ToyColors.ink2))),
                      Text(item.$2, style: ToyTextStyles.rowTitle(fontSize: 13, color: ToyColors.ink)),
                    ],
                  ),
                ),
              if (overflow > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text('+ $overflow more', style: ToyTextStyles.label(fontSize: 11.5, color: ToyColors.placeholder)),
                ),
              const DashedDivider(),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: ToyTextStyles.rowTitle(fontSize: 14)),
                  Text(total, style: ToyTextStyles.cardTitle(fontSize: 14, color: totalColor)),
                ],
              ),
            ] else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('No items yet', style: ToyTextStyles.label(fontSize: 12)),
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
    required this.payday,
  });

  final String monthId;
  final int year;
  final int month;
  final DateTime payday;

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

  Future<void> _loadOverride() async {
    final override = await ref.read(settingsProvider.notifier).getPaydayOverride(widget.monthId);
    if (mounted) setState(() => _override = override);
  }

  Future<void> _pickDate() async {
    final firstDay = DateTime(widget.year, widget.month, 1);
    final lastDay = DateTime(widget.year, widget.month + 1, 0);
    final initial = _override != null
        ? DateTime.tryParse(_override!) ?? firstDay
        : widget.payday;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDay) || initial.isAfter(lastDay) ? firstDay : initial,
      firstDate: firstDay,
      lastDate: lastDay,
    );
    if (picked != null && mounted) {
      final iso = picked.toIso8601String().split('T').first;
      await ref.read(settingsProvider.notifier).setPaydayOverride(widget.monthId, iso);
      setState(() => _override = iso);
      ref.invalidate(currentPaydayProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasOverride = _override != null;
    final displayDate = hasOverride ? DateTime.tryParse(_override!) : widget.payday;

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.all(ToyMetrics.cardPadding),
        decoration: BoxDecoration(
          color: ToyColors.amberBg,
          borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('給料日 Payday', style: ToyTextStyles.cardTitle(fontSize: 13.5, color: ToyColors.amberInk)),
                  const SizedBox(height: 4),
                  if (displayDate != null)
                    Text(
                      DateFormat('EEEE, MMM d').format(displayDate),
                      style: ToyTextStyles.rowAmount(fontSize: 15, color: ToyColors.amberInk),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    hasOverride ? 'Overridden for this month' : 'Override for this month',
                    style: ToyTextStyles.label(fontSize: 11, color: const Color(0xFFA57A3C)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: ToyColors.amberInk),
          ],
        ),
      ),
    );
  }
}
