import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/services/kakeibo_calculator.dart';

final fixedExpensesTotalProvider = Provider<double>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(data: KakeiboCalculator.fixedExpensesTotal) ?? 0;
});

final availableBudgetProvider = Provider<double>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(data: KakeiboCalculator.availableBudget) ?? 0;
});

final pillarTotalsProvider = Provider<Map<Pillar, double>>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(
          data: (m) => KakeiboCalculator.pillarTotals(m.expenses)) ??
      {for (final p in Pillar.values) p: 0};
});

final totalSpentProvider = Provider<double>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(
          data: (m) => KakeiboCalculator.totalSpent(m.expenses)) ??
      0;
});

final remainingProvider = Provider<double>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(data: KakeiboCalculator.remaining) ?? 0;
});

final projectedSavingsProvider = Provider<double>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(data: KakeiboCalculator.projectedSavings) ?? 0;
});

final isOnTrackProvider = Provider<bool>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(data: KakeiboCalculator.isOnTrack) ?? true;
});

final idealPillarBudgetProvider = Provider<double>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(data: KakeiboCalculator.idealPillarBudget) ?? 0;
});

final recentExpensesProvider = Provider<List<KakeiboExpense>>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(data: (m) {
        final sorted = [...m.expenses]
          ..sort((a, b) {
            final cmp = b.date.compareTo(a.date);
            return cmp != 0 ? cmp : b.createdAt.compareTo(a.createdAt);
          });
        return sorted.take(5).toList();
      }) ??
      [];
});

final isMonthSetupProvider = Provider<bool>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(data: (m) => m.income > 0) ?? false;
});

/// Income minus fixed costs. This is the pot you split between savings and spending.
final disposableIncomeProvider = Provider<double>((ref) {
  final monthAsync = ref.watch(currentMonthProvider);
  return monthAsync.whenOrNull(
          data: (m) => m.income - KakeiboCalculator.fixedExpensesTotal(m)) ??
      0;
});
