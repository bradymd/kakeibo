import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/month_calculations_provider.dart';
import 'package:kakeibo/providers/payday_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/services/swipe_nav.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_budget_bar.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-redesign dashboard (README §2b). New screen, not yet
/// wired into the router — see `ROLLBACK_AND_DATA.md` / handoff README
/// "Suggested order of work": get sign-off on this one screen before
/// migrating the rest.
///
/// Reuses the app's existing providers unchanged.
class ToyHomeScreen extends ConsumerWidget {
  const ToyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final isSetup = ref.watch(isMonthSetupProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    String fmt(double amount) => CurrencyFormatter.format(amount, currency: currency);

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final displayMonth = MonthHelpers.formatMonthDisplay(year, month);

    final daysUntilPayday = ref.watch(daysUntilPaydayProvider);
    final payday = ref.watch(currentPaydayProvider).valueOrNull;

    // Over-budget header switch (README §5a). availableBudgetProvider/
    // totalSpentProvider default to 0 before setup, so this is safely
    // false (not over budget) on the not-set-up and loading paths.
    final headerAvailableBudget = ref.watch(availableBudgetProvider);
    final headerTotalSpent = ref.watch(totalSpentProvider);
    final headerIsOverBudget = headerTotalSpent > headerAvailableBudget;
    final headerFinancialProgress = ref.watch(financialProgressProvider);

    String headerSubtitle;
    if (headerIsOverBudget) {
      final overspend = headerTotalSpent - headerAvailableBudget;
      final daysLeft = headerFinancialProgress != null
          ? headerFinancialProgress.total - headerFinancialProgress.day
          : (daysUntilPayday ?? 0);
      headerSubtitle =
          'You overspent by ${fmt(overspend)} with $daysLeft ${daysLeft == 1 ? 'day' : 'days'} left';
    } else if (daysUntilPayday != null) {
      headerSubtitle = '$daysUntilPayday ${daysUntilPayday == 1 ? 'day' : 'days'} to payday';
    } else {
      headerSubtitle = '';
    }

    return ToyScaffold(
      title: '家計簿 Kakeibo',
      subtitle: headerSubtitle.isEmpty ? null : headerSubtitle,
      subtitleColor: headerIsOverBudget ? ToyColors.dangerHeaderSubtitle : null,
      headerColor: headerIsOverBudget ? ToyColors.dangerHeader : ToyColors.brand,
      headerBottom: Center(
        child: ToyMonthNavigator(
          displayText: displayMonth,
          onPrevious: () => ref.read(currentMonthIdProvider.notifier).state =
              MonthHelpers.getPrevMonthId(monthId),
          onNext: () => ref.read(currentMonthIdProvider.notifier).state =
              MonthHelpers.getNextMonthId(monthId),
        ),
      ),
      tab: ToyTabDestination.month,
      disabledTabs: isSetup
          ? const {}
          : const {ToyTabDestination.spend, ToyTabDestination.income},
      trailing: const ToyMenuButton(),
      floatingActionButton:
          isSetup ? ToyFab(onTap: () => context.push('/add-expense')) : null,
      body: GestureDetector(
        onHorizontalDragEnd: (details) => SwipeNav.handleTabSwipe(
          context,
          ToyTabDestination.month,
          details.primaryVelocity ?? 0,
        ),
        behavior: HitTestBehavior.translucent,
        child: monthAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: ToyColors.brand),
          ),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (currentMonth) {
            if (!isSetup) {
              return _NotSetUpState(displayMonth: displayMonth);
            }

            // Reuse the values already computed above the header switch
            // rather than re-watching the same providers.
            final availableBudget = headerAvailableBudget;
            final totalSpent = headerTotalSpent;
            final disposableIncome = ref.watch(disposableIncomeProvider);
            final fixedCostsTotal = ref.watch(fixedExpensesTotalProvider);
            final pillarTotals = ref.watch(pillarTotalsProvider);
            final idealPillarBudget = ref.watch(idealPillarBudgetProvider);
            final recentExpenses = ref.watch(recentExpensesProvider);

            // Payday-aware progress when a preset is configured — the
            // financial month runs previous payday to this payday, not
            // the calendar month (matches the original BudgetBar and
            // what Payday Settings' own copy promises). Falls back to
            // calendar days when no payday is set.
            final financialProgress = headerFinancialProgress;
            final now = DateTime.now();
            final calendarDaysInMonth = DateTime(year, month + 1, 0).day;
            final calendarDayOfMonth = (year == now.year && month == now.month)
                ? now.day
                : (now.isAfter(DateTime(year, month + 1, 0)) ? calendarDaysInMonth : 1);
            final dayOfMonth = financialProgress?.day ?? calendarDayOfMonth;
            final daysInMonth = financialProgress?.total ?? calendarDaysInMonth;
            final goesLeft = daysInMonth - dayOfMonth;

            final isOverBudget = headerIsOverBudget;

            // "Running hot": Wants is meaningfully ahead of its even
            // per-pillar share of the budget (README §2b wolf strip).
            final wantsSpent = pillarTotals[Pillar.wants] ?? 0;
            final wantsOverPace =
                idealPillarBudget > 0 ? wantsSpent - idealPillarBudget : 0.0;
            final showWolfStrip = !isOverBudget && wantsOverPace > 0;

            return RefreshIndicator(
              color: ToyColors.brand,
              onRefresh: () async => ref.invalidate(kakeiboMonthsProvider),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  ToyMetrics.screenPaddingH,
                  16,
                  ToyMetrics.screenPaddingH,
                  ToyMetrics.listBottomPadding,
                ),
                children: [
                  _AllowanceCard(
                    totalIncome: currentMonth.income,
                    fixedCostsTotal: fixedCostsTotal,
                    savingsGoal: currentMonth.savingsGoal,
                    disposableIncome: disposableIncome,
                    availableBudget: availableBudget,
                    totalSpent: totalSpent,
                    formatAmount: fmt,
                  ),
                  const SizedBox(height: ToyMetrics.cardGap),
                  _CapsuleDomeCard(
                    pillarTotals: pillarTotals,
                    formatAmount: fmt,
                    dayOfMonth: dayOfMonth,
                    daysInMonth: daysInMonth,
                    goesLeft: goesLeft,
                    paydayDayOfMonth: payday?.day,
                  ),
                  if (isOverBudget) ...[
                    const SizedBox(height: ToyMetrics.cardGap),
                    _OverBudgetVerdictCard(
                      savingsGoalText: fmt(currentMonth.savingsGoal),
                      pillarTotals: pillarTotals,
                      formatAmount: fmt,
                    ),
                  ] else if (showWolfStrip) ...[
                    const SizedBox(height: ToyMetrics.cardGap),
                    _WolfStrip(overAmount: fmt(wantsOverPace)),
                  ],
                  const SizedBox(height: ToyMetrics.cardGap),
                  _RecentExpensesCard(
                    expenses: recentExpenses,
                    formatAmount: fmt,
                    hasAnyExpenses: currentMonth.expenses.isNotEmpty,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AllowanceCard extends StatelessWidget {
  const _AllowanceCard({
    required this.totalIncome,
    required this.fixedCostsTotal,
    required this.savingsGoal,
    required this.disposableIncome,
    required this.availableBudget,
    required this.totalSpent,
    required this.formatAmount,
  });

  final double totalIncome;
  final double fixedCostsTotal;
  final double savingsGoal;
  final double disposableIncome;
  final double availableBudget;
  final double totalSpent;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    return ToyCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(
            icon: Icons.trending_up_rounded,
            iconColor: ToyColors.success,
            label: 'Income (収入)',
            amount: formatAmount(totalIncome),
            amountColor: ToyColors.success,
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            icon: Icons.receipt_long_rounded,
            iconColor: ToyColors.danger,
            label: 'Fixed Costs (固定費)',
            amount: formatAmount(fixedCostsTotal),
            amountColor: ToyColors.danger,
          ),
          const SizedBox(height: 10),
          const DashedDivider(),
          const SizedBox(height: 10),
          _SummaryRow(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: ToyColors.brand,
            label: 'Money to budget (予算)',
            amount: formatAmount(disposableIncome),
            amountColor: ToyColors.ink,
            bold: true,
          ),
          const SizedBox(height: 14),
          ToyBudgetBar(
            savingsGoal: savingsGoal,
            disposableIncome: disposableIncome,
            availableBudget: availableBudget,
            totalSpent: totalSpent,
            formatAmount: formatAmount,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.amountColor,
    this.bold = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String amount;
  final Color amountColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: bold ? 20 : 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: ToyTextStyles.label(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: bold ? ToyColors.ink : ToyColors.muted2,
            ),
          ),
        ),
        Text(
          amount,
          style: bold
              ? ToyTextStyles.rowAmount(fontSize: 15, color: amountColor)
              : ToyTextStyles.body(fontSize: 12.5, fontWeight: FontWeight.w600, color: amountColor),
        ),
      ],
    );
  }
}

class _CapsuleDomeCard extends StatelessWidget {
  const _CapsuleDomeCard({
    required this.pillarTotals,
    required this.formatAmount,
    required this.dayOfMonth,
    required this.daysInMonth,
    required this.goesLeft,
    this.paydayDayOfMonth,
  });

  final Map<Pillar, double> pillarTotals;
  final String Function(double) formatAmount;
  final int dayOfMonth;
  final int daysInMonth;
  final int goesLeft;
  final int? paydayDayOfMonth;

  @override
  Widget build(BuildContext context) {
    return ToyCard(
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('四つの柱 Four Pillars', style: ToyTextStyles.cardTitle()),
          const SizedBox(height: 12),
          CapsuleDomeBackground(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: ToyPillarCapsuleGrid(
                children: [
                  for (final pillar in Pillar.values)
                    ToyPillarCapsule(
                      pillar: pillar,
                      label: '${pillar.japanese} ${pillar.label}',
                      amountText: formatAmount(pillarTotals[pillar] ?? 0),
                      labelFontSize: 10.5,
                      // A tab switch, not a push — same as tapping the
                      // Spend tab yourself, just pre-filtered. Keeps
                      // this consistent with every other tab move (no
                      // stack depth created, so no back arrow needed).
                      onTap: () => context.go('/expenses?pillar=${pillar.name}'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day $dayOfMonth of $daysInMonth',
                style: ToyTextStyles.label(fontSize: 10.5, fontWeight: FontWeight.w700),
              ),
              Text(
                'あと$goesLeft回 ・ $goesLeft goes left',
                style: ToyTextStyles.label(fontSize: 10.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ToyDayBlocks(
            dayOfMonth: dayOfMonth,
            daysInMonth: daysInMonth,
            paydayDayOfMonth: paydayDayOfMonth,
          ),
        ],
      ),
    );
  }
}

/// Full over-budget verdict card (README §5a): the wolf strip becomes a
/// dedicated card once spending has actually exceeded the available
/// budget (not just running hot ahead of pace). Reassures that the
/// savings goal is still intact, then shows where the money went.
class _OverBudgetVerdictCard extends StatelessWidget {
  const _OverBudgetVerdictCard({
    required this.savingsGoalText,
    required this.pillarTotals,
    required this.formatAmount,
  });

  final String savingsGoalText;
  final Map<Pillar, double> pillarTotals;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final sorted = Pillar.values.toList()
      ..sort((a, b) => (pillarTotals[b] ?? 0).compareTo(pillarTotals[a] ?? 0));
    final maxSpent = pillarTotals.values.fold(0.0, (a, b) => a > b ? a : b);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(ToyMetrics.cardPadding),
          decoration: BoxDecoration(
            color: ToyColors.wolfCard,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            children: [
              Image.asset('assets/images/wolf.png', width: 104, height: 104),
              const SizedBox(height: 8),
              Text('浪費家', style: ToyTextStyles.verdict(color: ToyColors.wolfPink)),
              Text(
                'Spender',
                style: ToyTextStyles.label(fontSize: 11, color: const Color(0xFFC9A9B5)),
              ),
              const SizedBox(height: 10),
              Text(
                'The savings goal is still safe if you stop here. Anything more comes out of the $savingsGoalText.',
                style: ToyTextStyles.body(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEFDCE2),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: ToyMetrics.cardGap),
        ToyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Where it went', style: ToyTextStyles.cardTitle(fontSize: 14.5)),
              const SizedBox(height: 12),
              for (var i = 0; i < sorted.length; i++) ...[
                _WhereItWentRow(
                  pillar: sorted[i],
                  amount: pillarTotals[sorted[i]] ?? 0,
                  ratio: maxSpent > 0 ? ((pillarTotals[sorted[i]] ?? 0) / maxSpent).clamp(0.0, 1.0) : 0.0,
                  worst: i == 0,
                  formatAmount: formatAmount,
                ),
                if (i != sorted.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WhereItWentRow extends StatelessWidget {
  const _WhereItWentRow({
    required this.pillar,
    required this.amount,
    required this.ratio,
    required this.worst,
    required this.formatAmount,
  });

  final Pillar pillar;
  final double amount;
  final double ratio;
  final bool worst;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final barColor = worst ? ToyColors.danger : pillar.toyFill;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${pillar.label} ${pillar.japanese}',
                style: ToyTextStyles.label(fontSize: 11.5, fontWeight: FontWeight.w700, color: barColor),
              ),
            ),
            Text(
              formatAmount(amount),
              style: ToyTextStyles.label(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: worst ? ToyColors.danger : ToyColors.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 9,
            child: Stack(
              children: [
                const ColoredBox(color: Color(0xFFEFE3E8)),
                FractionallySizedBox(widthFactor: ratio, child: ColoredBox(color: barColor)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WolfStrip extends StatelessWidget {
  const _WolfStrip({required this.overAmount});

  final String overAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ToyColors.amberBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Image.asset('assets/images/wolf.png', width: 64, height: 64),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Wants is running hot — $overAmount over pace. Slow down and the wolf stays outside.',
              style: ToyTextStyles.body(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: ToyColors.amberInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Recent Expenses — kept from the original dashboard (`home_screen.dart`)
/// so people can still browse their spending at a glance; the handoff
/// README's screen spec didn't carry this section forward, but dropping
/// it was an omission, not a deliberate redesign choice.
class _RecentExpensesCard extends ConsumerWidget {
  const _RecentExpensesCard({
    required this.expenses,
    required this.formatAmount,
    required this.hasAnyExpenses,
  });

  final List<KakeiboExpense> expenses;
  final String Function(double) formatAmount;
  final bool hasAnyExpenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ToyCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Recent Expenses', style: ToyTextStyles.cardTitle(fontSize: 15)),
                ),
                if (hasAnyExpenses)
                  GestureDetector(
                    onTap: () => context.push('/expenses'),
                    child: Text(
                      'See all',
                      style: ToyTextStyles.label(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: ToyColors.brand,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Text(
                'No expenses yet. Tap ＋ to add one!',
                style: ToyTextStyles.body(),
              ),
            )
          else
            for (var i = 0; i < expenses.length; i++) ...[
              if (i > 0) const DashedDivider(),
              ToyRow(
                title: expenses[i].description,
                meta:
                    '${expenses[i].pillar.label} ${expenses[i].pillar.japanese} ・ ${DateFormat('d MMM').format(DateTime.parse(expenses[i].date))}'
                    '${expenses[i].category.isEmpty ? '' : ' ・ ${expenses[i].category}'}',
                amountText: formatAmount(expenses[i].amount),
                leading: ToyPillarDot(color: expenses[i].pillar.toyFill),
                onTap: () => context.push('/edit-expense/${expenses[i].id}'),
              ),
            ],
        ],
      ),
    );
  }
}

class _NotSetUpState extends StatelessWidget {
  const _NotSetUpState({required this.displayMonth});

  final String displayMonth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: CapsuleDomeBackground(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('からっぽ', style: ToyTextStyles.cardTitle(fontSize: 15, color: const Color(0xFF7C93A8))),
                      Text('empty', style: ToyTextStyles.label(fontSize: 12, color: const Color(0xFF7C93A8))),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Set up $displayMonth',
              style: ToyTextStyles.cardTitle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your income and savings goal to get started. Fixed costs can be copied from January.',
              style: ToyTextStyles.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ToyPrimaryButton(
              label: 'はじめる ・ Set Up Month',
              onTap: () => context.push('/setup'),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.push('/import-fixed-costs'),
              child: Text(
                'Copy everything from January',
                style: ToyTextStyles.label(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: ToyColors.brand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
