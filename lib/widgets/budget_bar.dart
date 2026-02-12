import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';

/// Format zero as compact (e.g. "£0" not "£0.00").
String _fmtZero(String Function(double) formatAmount) {
  return formatAmount(0).replaceFirst('.00', '');
}

/// Consistent colours used in both the bar segments and the key.
class _BarColors {
  static const savings = Color(0xFF10B981);    // green — matches AppColors.success
  static const spent = Color(0xFFFF2D78);      // hot pink — matches AppColors.hotPink
  static const remaining = Color(0xFF818CF8);  // indigo
}

class BudgetBar extends StatelessWidget {
  const BudgetBar({
    super.key,
    required this.totalIncome,
    required this.fixedCostsTotal,
    required this.disposableIncome,
    required this.savingsGoal,
    required this.availableBudget,
    required this.totalSpent,
    required this.formatAmount,
    required this.dayOfMonth,
    required this.daysInMonth,
  });

  final double totalIncome;
  final double fixedCostsTotal;
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

    // Calculate overflow into savings
    final overflowIntoSavings = totalSpent > availableBudget
        ? totalSpent - availableBudget
        : 0.0;

    // Actual savings shrinks as it's consumed by overspending
    final actualSavings = max(savingsGoal - overflowIntoSavings, 0.0);

    // The savings segment shrinks as spending eats into it
    final actualSavingsRatio = (actualSavings / disposableIncome).clamp(0.0, 1.0);
    final availableRatio = 1.0 - actualSavingsRatio;

    // How much of the available budget has been spent
    final spentOfAvailable = availableBudget > 0
        ? (totalSpent / availableBudget).clamp(0.0, double.infinity)
        : 0.0;

    final availableRemaining = availableBudget - totalSpent;
    final isOverBudget = availableRemaining < 0;
    // When overspent past available budget, show remaining relative to
    // disposable income — savings goal was aspirational, not real debt.
    final remaining = isOverBudget
        ? disposableIncome - totalSpent
        : availableRemaining;
    final trulyOverdrawn = totalSpent > disposableIncome;

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
          // Income breakdown
          Row(
            children: [
              const Icon(Icons.trending_up_rounded,
                  color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Income (収入)', style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                )),
              ),
              Text(formatAmount(totalIncome), style: AppTextStyles.body.copyWith(
                color: AppColors.success,
              )),
            ],
          ),
          const SizedBox(height: 6),

          // Fixed costs breakdown
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded,
                  color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Fixed Costs (固定費)', style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                )),
              ),
              Text(formatAmount(fixedCostsTotal), style: AppTextStyles.body.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              )),
            ],
          ),
          const SizedBox(height: 10),

          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 10),

          // Money to budget
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.vividPurple, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Money to budget (予算)',
                    style: AppTextStyles.label),
              ),
              Text(formatAmount(disposableIncome), style: AppTextStyles.bodyBold),
            ],
          ),
          const SizedBox(height: 14),

          // The stacked bar — always show all three segments as a gauge
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    flex: max((actualSavingsRatio * 1000).round(), 80),
                    child: _SavingsSegment(
                      actualSavings: actualSavings,
                      formatAmount: formatAmount,
                    ),
                  ),
                  Expanded(
                    flex: max((availableRatio * 1000).round(), 160),
                    child: _AvailableSegment(
                      spentRatio: spentOfAvailable.clamp(0.0, 1.0),
                      totalSpent: totalSpent,
                      remaining: remaining,
                      formatAmount: formatAmount,
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
            label: 'Savings goal (貯金目標)',
            amount: formatAmount(savingsGoal),
            amountColor: _BarColors.savings,
            strikethrough: isOverBudget,
            revisedAmount: isOverBudget ? formatAmount(actualSavings) : null,
            revisedColor: _BarColors.savings,
          ),
          const SizedBox(height: 4),
          _KeyRow(
            color: _BarColors.spent,
            label: 'You have spent (支出)',
            amount: formatAmount(totalSpent),
            amountColor: _BarColors.spent,
          ),
          const SizedBox(height: 4),
          _KeyRow(
            color: _BarColors.remaining,
            label: 'Money remaining (残高)',
            amount: formatAmount(remaining),
            amountColor: _BarColors.remaining,
          ),

          // Summary line
          const SizedBox(height: 10),
          if (!isOverBudget)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _BarColors.remaining.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                savingsGoal > 0
                    ? 'To meet your savings goal of ${formatAmount(savingsGoal)}, you have ${formatAmount(remaining)} remaining'
                    : 'You have ${formatAmount(remaining)} left to spend or save',
                style: AppTextStyles.subheading.copyWith(
                  color: _BarColors.remaining,
                ),
              ),
            )
          else if (!trulyOverdrawn)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _BarColors.spent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                savingsGoal > 0
                    ? 'You have ${formatAmount(remaining)} left to spend or save'
                    : "You didn't meet your savings goal",
                style: AppTextStyles.subheading.copyWith(
                  color: _BarColors.spent,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _BarColors.spent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "You are overspent by ${formatAmount(totalSpent - disposableIncome)}",
                style: AppTextStyles.subheading.copyWith(
                  color: _BarColors.spent,
                ),
              ),
            ),

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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final gap = 2.0;
                    final totalGaps = (daysInMonth - 1) * gap;
                    final blockWidth = (constraints.maxWidth - totalGaps) / daysInMonth;
                    return Row(
                      children: List.generate(daysInMonth, (i) {
                        final filled = i < dayOfMonth;
                        return Container(
                          width: blockWidth,
                          height: 24,
                          margin: EdgeInsets.only(right: i < daysInMonth - 1 ? gap : 0),
                          decoration: BoxDecoration(
                            color: filled
                                ? AppColors.vividPurple
                                : AppColors.vividPurple.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Savings segment — green background that physically shrinks as savings are consumed.
/// The segment width represents the actual remaining savings.
class _SavingsSegment extends StatelessWidget {
  const _SavingsSegment({
    required this.actualSavings,
    required this.formatAmount,
  });
  final double actualSavings;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white, width: 2)),
      ),
      child: Container(
        color: _BarColors.savings,
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: actualSavings > 0
              ? Text(formatAmount(actualSavings), style: _barLabel)
              : Text(_fmtZero(formatAmount), style: _barLabel),
        ),
      ),
    );
  }
}

/// Available segment — two sub-parts side by side:
/// [  Spent (pink)  |  Left (indigo)  ]
/// Shows £0 or negative amounts when amounts are tiny.
class _AvailableSegment extends StatelessWidget {
  const _AvailableSegment({
    required this.spentRatio,
    required this.totalSpent,
    required this.remaining,
    required this.formatAmount,
  });
  final double spentRatio;
  final double totalSpent;
  final double remaining;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final spentFlex = max((spentRatio * 1000).round(), 80);
    final leftFlex = max(((1.0 - spentRatio) * 1000).round(), 80);

    return Row(
      children: [
        Expanded(
          flex: spentFlex,
          child: Container(
            decoration: const BoxDecoration(
              color: _BarColors.spent,
              border: Border(right: BorderSide(color: Colors.white, width: 1)),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: totalSpent > 0
                  ? Text(formatAmount(totalSpent), style: _barLabel)
                  : Text(_fmtZero(formatAmount), style: _barLabel),
            ),
          ),
        ),
        Expanded(
          flex: leftFlex,
          child: Container(
            color: _BarColors.remaining,
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatAmount(remaining),
                style: _barLabel,
              ),
            ),
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
