import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/services/expense_category_stats.dart';

KakeiboExpense _exp(double amount, {String category = ''}) => KakeiboExpense(
      id: 'e-$amount-$category-${amount.hashCode}',
      date: '2026-09-01',
      description: 'test',
      amount: amount,
      pillar: Pillar.needs,
      category: category,
    );

void main() {
  group('ExpenseCategoryStats.aggregate', () {
    test('groups by category and sorts descending by total', () {
      final expenses = [
        _exp(10, category: 'Coffee'),
        _exp(5, category: 'Coffee'),
        _exp(30, category: 'Groceries'),
        _exp(2), // uncategorised
      ];
      final stats = ExpenseCategoryStats.aggregate(expenses);
      expect(stats.map((s) => s.name).toList(),
          ['Groceries', 'Coffee', '']);
      expect(stats[0].total, 30);
      expect(stats[1].total, 15);
      expect(stats[1].count, 2);
      expect(stats[2].total, 2);
    });

    test('empty input yields empty stats', () {
      expect(ExpenseCategoryStats.aggregate([]), isEmpty);
    });
  });

  group('ExpenseCategoryStats.meetsSummaryThreshold', () {
    test('false when no expenses', () {
      expect(ExpenseCategoryStats.meetsSummaryThreshold([]), isFalse);
    });

    test('false when nothing categorised', () {
      final expenses = [_exp(10), _exp(20), _exp(30)];
      expect(ExpenseCategoryStats.meetsSummaryThreshold(expenses), isFalse);
    });

    test('true at 3 categorised across 2 categories, low coverage', () {
      final expenses = [
        _exp(1, category: 'A'),
        _exp(1, category: 'A'),
        _exp(1, category: 'B'),
        for (var i = 0; i < 10; i++) _exp(1),
      ];
      expect(ExpenseCategoryStats.meetsSummaryThreshold(expenses), isTrue);
    });

    test('false at 3 categorised in only 1 category with low coverage', () {
      final expenses = [
        _exp(1, category: 'A'),
        _exp(1, category: 'A'),
        _exp(1, category: 'A'),
        for (var i = 0; i < 10; i++) _exp(1),
      ];
      expect(ExpenseCategoryStats.meetsSummaryThreshold(expenses), isFalse);
    });

    test('true at 50% coverage even with only 1 category', () {
      final expenses = [
        _exp(1, category: 'A'),
        _exp(1, category: 'A'),
        _exp(1),
        _exp(1),
      ];
      expect(ExpenseCategoryStats.meetsSummaryThreshold(expenses), isTrue);
    });

    test('never requires complete coverage', () {
      final expenses = [
        _exp(1, category: 'A'),
        _exp(1, category: 'B'),
        _exp(1, category: 'C'),
        _exp(1), // one uncategorised is fine
      ];
      expect(ExpenseCategoryStats.meetsSummaryThreshold(expenses), isTrue);
    });
  });

  group('ExpenseCategoryStats.categorisedCount / distinctCategoryCount', () {
    test('counts correctly', () {
      final expenses = [
        _exp(1, category: 'A'),
        _exp(1, category: 'A'),
        _exp(1, category: 'B'),
        _exp(1),
      ];
      expect(ExpenseCategoryStats.categorisedCount(expenses), 3);
      expect(ExpenseCategoryStats.distinctCategoryCount(expenses), 2);
    });
  });
}
