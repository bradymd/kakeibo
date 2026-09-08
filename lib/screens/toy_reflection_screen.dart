import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/month_calculations_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-redesign End of Month / Reflection screen (README §4b).
/// New screen, preview-only for now.
class ToyReflectionScreen extends ConsumerStatefulWidget {
  const ToyReflectionScreen({super.key});

  @override
  ConsumerState<ToyReflectionScreen> createState() => _ToyReflectionScreenState();
}

class _ToyReflectionScreenState extends ConsumerState<ToyReflectionScreen> {
  final _actualSavedController = TextEditingController();
  final _howSavedController = TextEditingController();
  final _improvementsController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _actualSavedController.dispose();
    _howSavedController.dispose();
    _improvementsController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _initFromMonth(KakeiboMonth month) {
    if (_initialized) return;
    _initialized = true;
    final r = month.reflection;
    if (r.actualSaved > 0) _actualSavedController.text = r.actualSaved.toStringAsFixed(2);
    _howSavedController.text = r.howSaved;
    _improvementsController.text = r.improvements;
    if (r.accountBalance > 0) _balanceController.text = r.accountBalance.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final pillarTotals = ref.watch(pillarTotalsProvider);
    final totalSpent = ref.watch(totalSpentProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final displayMonth = MonthHelpers.formatMonthDisplay(year, month);

    String fmt(double amount) => CurrencyFormatter.format(amount, currency: currency);

    return ToyScaffold(
      title: '反省 End of Month',
      subtitle: displayMonth,
      // Reached from the hamburger menu, not the tab bar — Start of
      // Month and End of Month are the two bookend rituals, paired
      // together in the menu rather than living on the tab bar (which
      // holds the four things tracked during the month).
      showBackButton: true,
      trailing: const ToyMenuButton(),
      body: monthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: ToyColors.brand)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (currentMonth) {
          _initFromMonth(currentMonth);
          final isCompleted = currentMonth.reflection.completed;

          final disposableIncome = ref.watch(disposableIncomeProvider);
          final remaining = ref.watch(remainingProvider);
          final fixedCostsTotal = ref.watch(fixedExpensesTotalProvider);
          final potentialSavings = (remaining >= 0
                  ? currentMonth.savingsGoal
                  : max(0.0, currentMonth.savingsGoal + remaining))
              .toDouble();
          final metGoal = remaining >= 0 && currentMonth.savingsGoal > 0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              ToyMetrics.screenPaddingH,
              16,
              ToyMetrics.screenPaddingH,
              ToyMetrics.listBottomPadding,
            ),
            children: [
              _VerdictCard(
                income: fmt(currentMonth.income),
                fixedCostsTotal: fixedCostsTotal,
                fixedCostsText: fmt(fixedCostsTotal),
                disposableIncomeText: fmt(disposableIncome),
                savingsGoal: currentMonth.savingsGoal,
                savingsGoalText: fmt(currentMonth.savingsGoal),
                metGoal: metGoal,
                remaining: remaining,
                remainingText: fmt(remaining.abs()),
                potentialSavings: potentialSavings,
                potentialSavingsText: fmt(potentialSavings),
                totalSpentOverText: fmt(totalSpent - disposableIncome),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              _BreakdownCard(pillarTotals: pillarTotals, totalSpentText: fmt(totalSpent), formatAmount: fmt),
              const SizedBox(height: ToyMetrics.cardGap),
              _QuestionCard(
                question: 'Q3: How much did you actually save?',
                child: _CurrencyField(
                  controller: _actualSavedController,
                  symbol: CurrencyFormatter.symbol(currency: currency),
                ),
              ),
              const SizedBox(height: 12),
              _QuestionCard(
                question: 'Q4: What strategies helped you save?',
                child: _TextWell(
                  controller: _howSavedController,
                  placeholder: 'What worked well this month...',
                ),
              ),
              const SizedBox(height: 12),
              _QuestionCard(
                question: 'Q5: How can you improve next month?',
                child: _TextWell(
                  controller: _improvementsController,
                  placeholder: 'What would you do differently...',
                ),
              ),
              const SizedBox(height: 12),
              _QuestionCard(
                question: 'Current account balance',
                child: _CurrencyField(
                  controller: _balanceController,
                  symbol: CurrencyFormatter.symbol(currency: currency),
                  color: ToyColors.ink,
                ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              ToyPrimaryButton(
                label: isCompleted ? 'Update Reflection' : 'Complete Reflection',
                onTap: () async {
                  final reflection = Reflection(
                    actualSaved: double.tryParse(_actualSavedController.text) ?? 0,
                    howSaved: _howSavedController.text.trim(),
                    improvements: _improvementsController.text.trim(),
                    accountBalance: double.tryParse(_balanceController.text) ?? 0,
                    completed: true,
                  );
                  await ref
                      .read(kakeiboMonthsProvider.notifier)
                      .saveReflection(monthId: monthId, reflection: reflection);
                  if (context.mounted) {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/toy-dashboard');
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VerdictCard extends StatelessWidget {
  const _VerdictCard({
    required this.income,
    required this.fixedCostsTotal,
    required this.fixedCostsText,
    required this.disposableIncomeText,
    required this.savingsGoal,
    required this.savingsGoalText,
    required this.metGoal,
    required this.remaining,
    required this.remainingText,
    required this.potentialSavings,
    required this.potentialSavingsText,
    required this.totalSpentOverText,
  });

  final String income;
  final double fixedCostsTotal;
  final String fixedCostsText;
  final String disposableIncomeText;
  final double savingsGoal;
  final String savingsGoalText;
  final bool metGoal;
  final double remaining;
  final String remainingText;
  final double potentialSavings;
  final String potentialSavingsText;
  final String totalSpentOverText;

  @override
  Widget build(BuildContext context) {
    return ToyCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Month in Review', style: ToyTextStyles.cardTitle(fontSize: 17)),
                const SizedBox(height: 12),
                _narrative(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: Column(
              children: [
                Text(
                  metGoal ? '節約家' : '浪費家',
                  style: ToyTextStyles.verdict(color: metGoal ? ToyColors.success : ToyColors.wolfPink),
                ),
                Text(
                  metGoal ? 'Saver' : 'Spender',
                  style: ToyTextStyles.label(fontSize: 10.5),
                ),
                const SizedBox(height: 8),
                Image.asset(
                  metGoal ? 'assets/images/pig-overlay.png' : 'assets/images/wolf-overlay.png',
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _narrative() {
    final style = ToyTextStyles.body();
    final spans = <TextSpan>[
      TextSpan(text: 'This month you had an income of '),
      TextSpan(text: income, style: _bold(ToyColors.success)),
      const TextSpan(text: '. '),
    ];
    if (fixedCostsTotal > 0) {
      spans.addAll([
        const TextSpan(text: 'Your fixed costs were '),
        TextSpan(text: fixedCostsText, style: _bold(ToyColors.danger)),
        const TextSpan(text: ', leaving you '),
        TextSpan(text: disposableIncomeText, style: _bold(ToyColors.ink)),
        const TextSpan(text: ' to budget. '),
      ]);
    }
    if (savingsGoal > 0) {
      spans.addAll([
        const TextSpan(text: 'You set a savings goal of '),
        TextSpan(text: savingsGoalText, style: _bold(const Color(0xFF6B34B0))),
        const TextSpan(text: '. '),
      ]);
    } else {
      spans.add(const TextSpan(text: "You didn't set a savings goal. "));
    }
    if (remaining >= 0) {
      if (savingsGoal > 0) {
        spans.addAll([
          const TextSpan(text: 'You met your savings goal and had '),
          TextSpan(text: remainingText, style: _bold(ToyColors.success)),
          const TextSpan(text: ' remaining.'),
        ]);
      } else {
        spans.addAll([
          const TextSpan(text: 'You had '),
          TextSpan(text: remainingText, style: _bold(ToyColors.success)),
          const TextSpan(text: ' left to spend or save.'),
        ]);
      }
    } else if (potentialSavings > 0) {
      spans.addAll([
        const TextSpan(text: 'You managed to save '),
        TextSpan(text: potentialSavingsText, style: _bold(ToyColors.brand)),
        const TextSpan(text: ' of your '),
        TextSpan(text: savingsGoalText, style: _bold(ToyColors.ink)),
        const TextSpan(text: ' savings goal.'),
      ]);
    } else {
      spans.addAll([
        const TextSpan(text: 'You overspent by '),
        TextSpan(text: totalSpentOverText, style: _bold(ToyColors.danger)),
        const TextSpan(text: '.'),
      ]);
    }
    return RichText(text: TextSpan(style: style, children: spans));
  }

  TextStyle _bold(Color color) => ToyTextStyles.body(fontWeight: FontWeight.w800, color: color);
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.pillarTotals,
    required this.totalSpentText,
    required this.formatAmount,
  });

  final Map<Pillar, double> pillarTotals;
  final String totalSpentText;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final maxSpent = pillarTotals.values.fold(0.0, (a, b) => a > b ? a : b);
    return ToyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reflection on your spending this month', style: ToyTextStyles.cardTitle(fontSize: 14.5)),
          Text('Total: $totalSpentText', style: ToyTextStyles.label(fontSize: 11.5)),
          const SizedBox(height: 12),
          for (final pillar in Pillar.values) ...[
            _PillarBar(
              pillar: pillar,
              amount: pillarTotals[pillar] ?? 0,
              ratio: maxSpent > 0 ? ((pillarTotals[pillar] ?? 0) / maxSpent).clamp(0.0, 1.0) : 0.0,
              formatAmount: formatAmount,
            ),
            if (pillar != Pillar.values.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PillarBar extends StatelessWidget {
  const _PillarBar({
    required this.pillar,
    required this.amount,
    required this.ratio,
    required this.formatAmount,
  });

  final Pillar pillar;
  final double amount;
  final double ratio;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${pillar.label} ${pillar.japanese}',
                style: ToyTextStyles.label(fontSize: 11.5, fontWeight: FontWeight.w700, color: pillar.toyFill),
              ),
            ),
            Text(
              formatAmount(amount),
              style: ToyTextStyles.label(fontSize: 11.5, fontWeight: FontWeight.w700),
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
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: ColoredBox(color: pillar.toyFill),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.child});

  final String question;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ToyCard(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: ToyTextStyles.cardTitle(fontSize: 13)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TextWell extends StatelessWidget {
  const _TextWell({required this.controller, required this.placeholder});

  final TextEditingController controller;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: ToyColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
        style: ToyTextStyles.body(fontSize: 12.5, fontWeight: FontWeight.w600, color: ToyColors.ink),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: placeholder,
          hintStyle: ToyTextStyles.body(fontSize: 12.5, color: ToyColors.placeholder),
        ),
      ),
    );
  }
}

class _CurrencyField extends StatelessWidget {
  const _CurrencyField({required this.controller, required this.symbol, this.color = ToyColors.success});

  final TextEditingController controller;
  final String symbol;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: ToyColors.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: ToyTextStyles.rowAmount(fontSize: 17, color: color),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          prefixText: '$symbol ',
          hintText: '0.00',
          hintStyle: ToyTextStyles.body(color: ToyColors.placeholder),
        ),
      ),
    );
  }
}
