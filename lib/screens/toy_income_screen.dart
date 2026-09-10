import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/payday_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/services/payday_calculator.dart';
import 'package:kakeibo/services/swipe_nav.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-redesign Income screen (README §4e). Deliberately the
/// same shape as Fixed Costs — both are tab-bar destinations, one of
/// the four things tracked during the month.
class ToyIncomeScreen extends ConsumerWidget {
  const ToyIncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';
    final paydayPreset = ref.watch(paydayPresetProvider);
    final payday = ref.watch(currentPaydayProvider).valueOrNull;

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final displayMonth = MonthHelpers.formatMonthDisplay(year, month);

    String fmt(double amount) => CurrencyFormatter.format(amount, currency: currency);

    return monthAsync.when(
      loading: () => Scaffold(
        backgroundColor: ToyColors.bg,
        body: const Center(child: CircularProgressIndicator(color: ToyColors.brand)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: ToyColors.bg,
        body: Center(child: Text('Error: $e')),
      ),
      data: (currentMonth) {
        final sources = currentMonth.incomeSources;
        final totalIncome = currentMonth.income;

        return ToyScaffold(
          title: '収入 Income',
          subtitle: '$displayMonth ・ ${sources.length} ${sources.length == 1 ? 'source' : 'sources'}',
          headlineFigure: fmt(totalIncome),
          tab: ToyTabDestination.income,
          trailing: const ToyMenuButton(),
          floatingActionButton: ToyFab(onTap: () => context.push('/add-income')),
          body: GestureDetector(
            onHorizontalDragEnd: (details) => SwipeNav.handleTabSwipe(
              context,
              ToyTabDestination.income,
              details.primaryVelocity ?? 0,
            ),
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                ToyMetrics.screenPaddingH,
                12,
                ToyMetrics.screenPaddingH,
                ToyMetrics.listBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sources.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'No income sources yet.\nAdd one below, or bring forward a\nprevious month\'s setup.',
                              style: ToyTextStyles.body(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: ToyMetrics.cardGap),
                            ToyCapsuleButton(
                              label: '先月からコピー ・ Copy from another month',
                              onTap: () => context.push('/import-income'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    ToyCard(
                      child: Column(
                        children: [
                          for (var i = 0; i < sources.length; i++) ...[
                            if (i > 0) const SizedBox(height: 14),
                            _SourceRow(
                              name: sources[i].name,
                              amountText: fmt(sources[i].amount),
                              ratio: totalIncome > 0 ? (sources[i].amount / totalIncome).clamp(0.0, 1.0) : 0.0,
                              sharePercent: totalIncome > 0 ? ((sources[i].amount / totalIncome) * 100).round() : 0,
                              paydayText: payday != null ? 'paid ${DateFormat('d MMM').format(payday)}' : null,
                              onTap: () => context.push('/edit-income/${sources[i].id}'),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: ToyMetrics.cardGap),
                    ToyLinkRow(
                      label: 'Copy from another month',
                      onTap: () => context.push('/import-income'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Income feeds "Money to budget" on Start of Month.',
                    style: ToyTextStyles.label(fontSize: 11, color: ToyColors.muted2),
                    textAlign: TextAlign.center,
                  ),
                  if (paydayPreset == PaydayPreset.none) ...[
                    const SizedBox(height: ToyMetrics.cardGap),
                    GestureDetector(
                      onTap: () => context.push('/payday-settings'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: ToyColors.amberBg,
                          borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
                        ),
                        child: Text(
                          'If you have a regular and significant source of income you can define a payday.',
                          style: ToyTextStyles.label(fontSize: 11.5, color: ToyColors.amberInk),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.name,
    required this.amountText,
    required this.ratio,
    required this.sharePercent,
    required this.paydayText,
    required this.onTap,
  });

  final String name;
  final String amountText;
  final double ratio;
  final int sharePercent;
  final String? paydayText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: ToyTextStyles.rowTitle(fontSize: 14))),
              Text(amountText, style: ToyTextStyles.rowAmount(fontSize: 16, color: ToyColors.success)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.5),
            child: SizedBox(
              height: 9,
              child: Stack(
                children: [
                  const ColoredBox(color: Color(0xFFEFE3E8)),
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: const ColoredBox(color: ToyPillarColors.needsFill),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              '$sharePercent% of this month\'s income',
              ?paydayText,
            ].join(' ・ '),
            style: ToyTextStyles.label(fontSize: 11, fontWeight: FontWeight.w500, color: ToyColors.muted2),
          ),
        ],
      ),
    );
  }
}
