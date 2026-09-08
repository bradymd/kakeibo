import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
/// Reuses the app's existing providers unchanged; the only addition is
/// `dailyAllowanceProvider` in `month_calculations_provider.dart`.
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

    return ToyScaffold(
      title: '家計簿ガチャ',
      subtitle: daysUntilPayday != null
          ? '${displayMonth.toUpperCase()} ・ $daysUntilPayday ${daysUntilPayday == 1 ? 'day' : 'days'} to payday'
          : displayMonth.toUpperCase(),
      tab: ToyTabDestination.month,
      disabledTabs: isSetup
          ? const {}
          : const {ToyTabDestination.spend, ToyTabDestination.reflect},
      trailing: const ToyMenuButton(),
      floatingActionButton:
          isSetup ? ToyFab(onTap: () => context.push('/add-expense')) : null,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > 300) {
            SwipeNav.go(context, '/expenses', SlideDirection.left);
          } else if (velocity < -300) {
            SwipeNav.go(context, '/fixed-expenses', SlideDirection.right);
          }
        },
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

            final availableBudget = ref.watch(availableBudgetProvider);
            final totalSpent = ref.watch(totalSpentProvider);
            final disposableIncome = ref.watch(disposableIncomeProvider);
            final pillarTotals = ref.watch(pillarTotalsProvider);
            final dailyAllowance = ref.watch(dailyAllowanceProvider);
            final idealPillarBudget = ref.watch(idealPillarBudgetProvider);

            final now = DateTime.now();
            final daysInMonth = DateTime(year, month + 1, 0).day;
            final dayOfMonth = (year == now.year && month == now.month)
                ? now.day
                : (now.isAfter(DateTime(year, month + 1, 0)) ? daysInMonth : 1);
            final goesLeft = daysInMonth - dayOfMonth;

            final remaining = availableBudget - totalSpent;
            final isOverBudget = remaining < 0;

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
                    dailyAllowance: fmt(dailyAllowance),
                    remainingInMachine: fmt(isOverBudget ? 0 : remaining),
                    isOverBudget: isOverBudget,
                    overspendAmount: isOverBudget ? fmt(-remaining) : null,
                    savingsGoal: currentMonth.savingsGoal,
                    disposableIncome: disposableIncome,
                    availableBudget: availableBudget,
                    totalSpent: totalSpent,
                    formatAmount: fmt,
                  ),
                  const SizedBox(height: ToyMetrics.cardGap),
                  _CapsuleDomeCard(
                    pillarTotals: pillarTotals,
                    totalSpent: totalSpent,
                    formatAmount: fmt,
                    dayOfMonth: dayOfMonth,
                    daysInMonth: daysInMonth,
                    goesLeft: goesLeft,
                  ),
                  if (showWolfStrip) ...[
                    const SizedBox(height: ToyMetrics.cardGap),
                    _WolfStrip(overAmount: fmt(wantsOverPace)),
                  ],
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
    required this.dailyAllowance,
    required this.remainingInMachine,
    required this.isOverBudget,
    required this.overspendAmount,
    required this.savingsGoal,
    required this.disposableIncome,
    required this.availableBudget,
    required this.totalSpent,
    required this.formatAmount,
  });

  final String dailyAllowance;
  final String remainingInMachine;
  final bool isOverBudget;
  final String? overspendAmount;
  final double savingsGoal;
  final double disposableIncome;
  final double availableBudget;
  final double totalSpent;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    return ToyCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isOverBudget ? const Color(0xFFFFD6DE) : ToyColors.goldSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOverBudget ? '一回 = 一日 ・ OUT OF GOES' : '一回 = 一日 ・ ONE GO, ONE DAY',
              style: ToyTextStyles.label(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isOverBudget ? const Color(0xFF8E1F3C) : ToyColors.goldInk,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isOverBudget ? '£0.00' : dailyAllowance,
            style: ToyTextStyles.hero(
              fontSize: 52,
              color: isOverBudget ? ToyColors.danger : ToyColors.brand,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isOverBudget
                ? 'You overspent by $overspendAmount'
                : "today's allowance ・ $remainingInMachine left in the machine",
            textAlign: TextAlign.center,
            style: ToyTextStyles.label(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: ToyColors.muted2,
            ),
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

class _CapsuleDomeCard extends StatelessWidget {
  const _CapsuleDomeCard({
    required this.pillarTotals,
    required this.totalSpent,
    required this.formatAmount,
    required this.dayOfMonth,
    required this.daysInMonth,
    required this.goesLeft,
  });

  final Map<Pillar, double> pillarTotals;
  final double totalSpent;
  final String Function(double) formatAmount;
  final int dayOfMonth;
  final int daysInMonth;
  final int goesLeft;

  @override
  Widget build(BuildContext context) {
    final monthProgress = daysInMonth > 0 ? dayOfMonth / daysInMonth : 0.0;

    return ToyCard(
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('四つの柱 ・ カプセル', style: ToyTextStyles.cardTitle()),
              ),
              Text(
                '${formatAmount(totalSpent)} spent',
                style: ToyTextStyles.label(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
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
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Stack(
                children: [
                  const ColoredBox(color: Color(0xFFF1E3E8)),
                  FractionallySizedBox(
                    widthFactor: monthProgress.clamp(0.0, 1.0),
                    child: CustomPaint(painter: const _MonthProgressPainter()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
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
        ],
      ),
    );
  }
}

/// `repeating-linear-gradient(135deg,#FFD24C 0 8px,#FFC01F 8px 16px)`
/// month-progress fill.
class _MonthProgressPainter extends CustomPainter {
  const _MonthProgressPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = ToyColors.gold);
    final dark = Paint()..color = const Color(0xFFFFC01F);
    final diagonal = size.width + size.height;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(135 * 3.1415926535 / 180);
    canvas.translate(-diagonal, -diagonal);
    for (double x = 0; x < diagonal * 2; x += 16) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 8, diagonal * 2), dark);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MonthProgressPainter oldDelegate) => false;
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
