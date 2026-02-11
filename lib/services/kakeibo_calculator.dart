import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/pillar.dart';

class KakeiboCalculator {
  const KakeiboCalculator._();

  static double fixedExpensesTotal(KakeiboMonth month) {
    return month.fixedExpenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  static double availableBudget(KakeiboMonth month) {
    return month.income - fixedExpensesTotal(month) - month.savingsGoal;
  }

  static Map<Pillar, double> pillarTotals(List<KakeiboExpense> expenses) {
    return {
      for (final pillar in Pillar.values)
        pillar: expenses
            .where((e) => e.pillar == pillar)
            .fold(0.0, (sum, e) => sum + e.amount),
    };
  }

  static int pillarCount(List<KakeiboExpense> expenses, Pillar pillar) {
    return expenses.where((e) => e.pillar == pillar).length;
  }

  static double totalSpent(List<KakeiboExpense> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  static double remaining(KakeiboMonth month) {
    return availableBudget(month) - totalSpent(month.expenses);
  }

  static double projectedSavings(KakeiboMonth month) {
    return month.savingsGoal + remaining(month);
  }

  static bool isOnTrack(KakeiboMonth month) {
    return projectedSavings(month) >= month.savingsGoal;
  }

  static double idealPillarBudget(KakeiboMonth month) {
    final budget = availableBudget(month);
    return budget > 0 ? budget / 4 : 0;
  }
}
