import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';

/// Consistent colours used in both the bar segments and the key.
class _BarColors {
  static const savings = Color(0xFF10B981);    // green — matches AppColors.success
  static const spent = Color(0xFFFF2D78);      // hot pink — matches AppColors.hotPink
  static const remaining = Color(0xFF818CF8);  // indigo
}

class BudgetBar extends StatelessWidget {
  const BudgetBar({
    super.key,
    required this.disposableIncome,
    required this.savingsGoal,
    required this.availableBudget,
    required this.totalSpent,
    required this.formatAmount,
    required this.dayOfMonth,
    required this.daysInMonth,
  });

  final double disposableIncome;
  final double savingsGoal;
  final double availableBudget;
  final double totalSpent;
  final String Function(double) formatAmount;
  final int dayOfMonth;
  final int daysInMonth;

  @override
  Widget build(BuildContext context) {
    if (disposableIncome <= 0) return const SizedBox.shrink();

    final savingsRatio = (savingsGoal / disposableIncome).clamp(0.0, 1.0);
    final availableRatio = 1.0 - savingsRatio;

    final spentOfAvailable = availableBudget > 0
        ? (totalSpent / availableBudget).clamp(0.0, double.infinity)
        : 0.0;

    final overflowIntoSavings = totalSpent > availableBudget
        ? totalSpent - availableBudget
        : 0.0;
    final savingsEaten = savingsGoal > 0
        ? (overflowIntoSavings / savingsGoal).clamp(0.0, 1.0)
        : 0.0;

    final remaining = availableBudget - totalSpent;
    final isOverBudget = remaining < 0;
    final actualSavings = max(savingsGoal - overflowIntoSavings, 0.0);

    final daysToGo = daysInMonth - dayOfMonth;
    final dayProgress = (dayOfMonth / daysInMonth).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.vividPurple, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Money to budget with this month',
                    style: AppTextStyles.label),
              ),
              Text(formatAmount(disposableIncome), style: AppTextStyles.bodyBold),
            ],
          ),
          Text(
            '(After fixed costs)',
            style: AppTextStyles.caption.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 14),

          // The stacked bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  if (savingsRatio > 0)
                    Expanded(
                      flex: (savingsRatio * 1000).round(),
                      child: _SavingsSegment(eatenRatio: savingsEaten),
                    ),
                  if (availableRatio > 0)
                    Expanded(
                      flex: (availableRatio * 1000).round(),
                      child: _AvailableSegment(
                        spentRatio: spentOfAvailable.clamp(0.0, 1.0),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Key — three rows with consistent spacing
          // Savings: revised amount stays green (it's still their savings)
          _KeyRow(
            color: _BarColors.savings,
            label: 'Savings goal',
            amount: formatAmount(savingsGoal),
            amountColor: _BarColors.savings,
            strikethrough: isOverBudget,
            revisedAmount: isOverBudget ? formatAmount(actualSavings) : null,
            revisedColor: _BarColors.savings,
          ),
          const SizedBox(height: 4),
          _KeyRow(
            color: _BarColors.spent,
            label: 'You have spent',
            amount: formatAmount(totalSpent),
            amountColor: _BarColors.spent,
          ),
          const SizedBox(height: 4),
          // Money remaining:
          //   - Positive while within spending budget
          //   - £0 while eating into savings
          //   - Negative only after savings fully gone (truly overdrawn)
          ..() {
            final trulyOverdrawn = totalSpent > disposableIncome;
            final double moneyRemaining = remaining >= 0
                ? remaining
                : trulyOverdrawn
                    ? disposableIncome - totalSpent // negative
                    : 0.0;
            return [
              _KeyRow(
                color: _BarColors.remaining,
                label: 'Money remaining',
                amount: formatAmount(moneyRemaining),
                amountColor: _BarColors.remaining,
              ),
              const SizedBox(height: 10),
              if (!isOverBudget)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _BarColors.remaining.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'You have ${formatAmount(remaining)} left',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _BarColors.remaining,
                    ),
                  ),
                )
              else if (!trulyOverdrawn)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _BarColors.spent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "You didn't meet your savings goal",
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _BarColors.spent,
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: _BarColors.spent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "You didn't meet your goal and you are overspent by ${formatAmount(totalSpent - disposableIncome)}",
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _BarColors.spent,
                    ),
                  ),
                ),
            ];
          }(),

          // Day-of-month progress
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.vividPurple.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day $dayOfMonth of $daysInMonth',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.vividPurple,
                      ),
                    ),
                    Text(
                      daysToGo == 0
                          ? 'Last day of the month'
                          : '$daysToGo ${daysToGo == 1 ? 'day' : 'days'} to go',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 6,
                    child: LinearProgressIndicator(
                      value: dayProgress,
                      backgroundColor:
                          AppColors.vividPurple.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.vividPurple),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Savings segment — green background, with the SAME spent colour creeping from
/// the right when overspending eats into it. "Save" label hides once mostly eaten.
class _SavingsSegment extends StatelessWidget {
  const _SavingsSegment({required this.eatenRatio});
  final double eatenRatio;

  @override
  Widget build(BuildContext context) {
    // When fully eaten, the whole segment is the spent colour.
    if (eatenRatio >= 1.0) {
      return Container(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: Colors.white, width: 2)),
        ),
        child: Container(color: _BarColors.spent),
      );
    }

    final saveFlex = ((1.0 - eatenRatio) * 1000).round();
    final eatenFlex = (eatenRatio * 1000).round();

    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white, width: 2)),
      ),
      child: Row(
        children: [
          // Healthy savings portion
          if (saveFlex > 0)
            Expanded(
              flex: saveFlex,
              child: Container(
                color: _BarColors.savings,
                alignment: Alignment.center,
                child: eatenRatio <= 0.6
                    ? const Text('Save', style: _barLabel)
                    : null,
              ),
            ),
          // Eaten portion — exact same spent colour as the available segment
          if (eatenFlex > 0)
            Expanded(
              flex: eatenFlex,
              child: Container(color: _BarColors.spent),
            ),
        ],
      ),
    );
  }
}

/// Available segment — two sub-parts side by side:
/// [  Spent (pink)  |  Left (indigo)  ]
/// Same colours as the key. Each label centred in its own portion.
class _AvailableSegment extends StatelessWidget {
  const _AvailableSegment({required this.spentRatio});
  final double spentRatio;

  @override
  Widget build(BuildContext context) {
    final spentFlex = (spentRatio * 1000).round();
    final leftFlex = ((1.0 - spentRatio) * 1000).round();

    return Row(
      children: [
        if (spentFlex > 0)
          Expanded(
            flex: spentFlex,
            child: Container(
              color: _BarColors.spent,
              alignment: Alignment.center,
              child: spentRatio >= 0.12
                  ? const Text('Spent', style: _barLabel)
                  : null,
            ),
          ),
        if (leftFlex > 0)
          Expanded(
            flex: leftFlex,
            child: Container(
              color: _BarColors.remaining,
              alignment: Alignment.center,
              child: spentRatio <= 0.88
                  ? const Text('Left', style: _barLabel)
                  : null,
            ),
          ),
      ],
    );
  }
}

const _barLabel = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);

/// A single row in the key.
///
/// When [strikethrough] is true the [amount] is shown struck-through
/// and [revisedAmount] is shown next to it in [revisedColor].
class _KeyRow extends StatelessWidget {
  const _KeyRow({
    required this.color,
    required this.label,
    required this.amount,
    this.amountColor,
    this.strikethrough = false,
    this.revisedAmount,
    this.revisedColor,
  });

  final Color color;
  final String label;
  final String amount;
  final Color? amountColor;
  final bool strikethrough;
  final String? revisedAmount;
  final Color? revisedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (strikethrough && revisedAmount != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amount,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    revisedAmount!,
                    style: AppTextStyles.bodyBold.copyWith(
                      fontSize: 13,
                      color: revisedColor ?? _BarColors.spent,
                    ),
                  ),
                ],
              )
            else
              Text(
                amount,
                style: AppTextStyles.bodyBold.copyWith(
                  fontSize: 13,
                  color: amountColor,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
