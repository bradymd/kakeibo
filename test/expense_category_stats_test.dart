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

  group('CategoryFilter', () {
    final named = _exp(1, category: 'Groceries');
    final other = _exp(1, category: 'Dining');
    final uncategorised = _exp(1);

    test('all matches everything, including uncategorised', () {
      expect(CategoryFilter.all.matches(named), isTrue);
      expect(CategoryFilter.all.matches(uncategorised), isTrue);
    });

    test('uncategorised matches only empty-category expenses', () {
      expect(CategoryFilter.uncategorised.matches(uncategorised), isTrue);
      expect(CategoryFilter.uncategorised.matches(named), isFalse);
    });

    test('named matches only that exact category', () {
      final filter = CategoryFilter.named('Groceries');
      expect(filter.matches(named), isTrue);
      expect(filter.matches(other), isFalse);
      expect(filter.matches(uncategorised), isFalse);
    });

    test('named does not match uncategorised even for an empty-string name', () {
      // Guards the exact bug this type replaced: a category filter must
      // never accidentally match "no category" unless it's the dedicated
      // .uncategorised state.
      final filter = CategoryFilter.named('');
      expect(filter.matches(uncategorised), isTrue); // '' == '' is correct here
      // ...but this is why .named('') should never be constructed from a
      // route in practice -- app.dart only builds .named(x) when x is
      // non-empty, falling back to null (no filter) otherwise. Documented
      // via this test rather than left implicit.
    });

    test('uncategorised.pillLabel reads "Category: Uncategorised"', () {
      expect(CategoryFilter.uncategorised.pillLabel, 'Category: Uncategorised');
    });

    test('named(x).pillLabel reads "Category: x"', () {
      expect(CategoryFilter.named('Groceries').pillLabel, 'Category: Groceries');
    });

    test('all.pillLabel throws -- it should never be shown as an applied filter', () {
      expect(() => CategoryFilter.all.pillLabel, throwsStateError);
    });
  });

  group('CategoryFilter.fromQueryParameters', () {
    test('no params -> no filter', () {
      expect(CategoryFilter.fromQueryParameters({}), isNull);
    });

    test('category=X -> named(X)', () {
      final filter = CategoryFilter.fromQueryParameters({'category': 'Groceries'});
      expect(filter, isA<CategoryFilter>());
      expect(filter!.matches(_exp(1, category: 'Groceries')), isTrue);
      expect(filter.matches(_exp(1, category: 'Dining')), isFalse);
    });

    test('category= (empty string) -> no filter, not an accidental uncategorised match', () {
      // The route-level guard against the exact ambiguity CategoryFilter
      // was introduced to fix: an empty category query param must not
      // silently become "filter to uncategorised".
      expect(CategoryFilter.fromQueryParameters({'category': ''}), isNull);
    });

    test('uncategorised=1 -> uncategorised, regardless of category', () {
      final filter = CategoryFilter.fromQueryParameters({'uncategorised': '1'});
      expect(filter!.matches(_exp(1)), isTrue);
      expect(filter.matches(_exp(1, category: 'Groceries')), isFalse);
    });

    test('uncategorised=1 takes precedence over a category param sent alongside it', () {
      final filter = CategoryFilter.fromQueryParameters({
        'uncategorised': '1',
        'category': 'Groceries',
      });
      expect(filter!.matches(_exp(1)), isTrue);
    });

    test('uncategorised=0 or any other value is not treated as the flag', () {
      expect(CategoryFilter.fromQueryParameters({'uncategorised': '0'}), isNull);
      expect(CategoryFilter.fromQueryParameters({'uncategorised': 'true'}), isNull);
    });
  });
}
