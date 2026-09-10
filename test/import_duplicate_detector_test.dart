import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/services/import_duplicate_detector.dart';

FixedExpense _fixed(String id, String name, double amount, {String category = 'Other', int? dueDay}) =>
    FixedExpense(id: id, name: name, amount: amount, category: category, dueDay: dueDay);

IncomeSource _income(String id, String name, double amount) =>
    IncomeSource(id: id, name: name, amount: amount);

void main() {
  group('ImportDuplicateDetector.alreadyPresentFixedExpenseIds', () {
    test('flags an exact match by name/category/amount/dueDay', () {
      final candidates = [_fixed('c1', 'Netflix', 15.99, category: 'Subscriptions', dueDay: 5)];
      final existing = [_fixed('e1', 'Netflix', 15.99, category: 'Subscriptions', dueDay: 5)];
      expect(
        ImportDuplicateDetector.alreadyPresentFixedExpenseIds(
          candidates: candidates,
          existingFixedExpenses: existing,
        ),
        {'c1'},
      );
    });

    test('is case-insensitive and trims whitespace on the name and category', () {
      final candidates = [_fixed('c1', ' Netflix ', 15.99, category: ' Subscriptions ', dueDay: 5)];
      final existing = [_fixed('e1', 'netflix', 15.99, category: 'subscriptions', dueDay: 5)];
      expect(
        ImportDuplicateDetector.alreadyPresentFixedExpenseIds(
          candidates: candidates,
          existingFixedExpenses: existing,
        ),
        {'c1'},
      );
    });

    test('does not flag when amount differs', () {
      final candidates = [_fixed('c1', 'Netflix', 15.99, dueDay: 5)];
      final existing = [_fixed('e1', 'Netflix', 12.99, dueDay: 5)];
      expect(
        ImportDuplicateDetector.alreadyPresentFixedExpenseIds(
          candidates: candidates,
          existingFixedExpenses: existing,
        ),
        isEmpty,
      );
    });

    test('does not flag when dueDay differs', () {
      final candidates = [_fixed('c1', 'Netflix', 15.99, dueDay: 5)];
      final existing = [_fixed('e1', 'Netflix', 15.99, dueDay: 12)];
      expect(
        ImportDuplicateDetector.alreadyPresentFixedExpenseIds(
          candidates: candidates,
          existingFixedExpenses: existing,
        ),
        isEmpty,
      );
    });

    test('does not flag when category differs', () {
      final candidates = [_fixed('c1', 'Netflix', 15.99, category: 'Entertainment', dueDay: 5)];
      final existing = [_fixed('e1', 'Netflix', 15.99, category: 'Subscriptions', dueDay: 5)];
      expect(
        ImportDuplicateDetector.alreadyPresentFixedExpenseIds(
          candidates: candidates,
          existingFixedExpenses: existing,
        ),
        isEmpty,
      );
    });

    test('only flags the candidates that actually match, not the whole list', () {
      final candidates = [
        _fixed('c1', 'Netflix', 15.99, dueDay: 5),
        _fixed('c2', 'Rent', 900.0, dueDay: 1),
      ];
      final existing = [_fixed('e1', 'Netflix', 15.99, dueDay: 5)];
      expect(
        ImportDuplicateDetector.alreadyPresentFixedExpenseIds(
          candidates: candidates,
          existingFixedExpenses: existing,
        ),
        {'c1'},
      );
    });

    test('empty existing list flags nothing', () {
      final candidates = [_fixed('c1', 'Netflix', 15.99, dueDay: 5)];
      expect(
        ImportDuplicateDetector.alreadyPresentFixedExpenseIds(
          candidates: candidates,
          existingFixedExpenses: const [],
        ),
        isEmpty,
      );
    });
  });

  group('ImportDuplicateDetector.alreadyPresentIncomeSourceIds', () {
    test('flags an exact match by name/amount', () {
      final candidates = [_income('c1', 'Salary', 3000.0)];
      final existing = [_income('e1', 'Salary', 3000.0)];
      expect(
        ImportDuplicateDetector.alreadyPresentIncomeSourceIds(
          candidates: candidates,
          existingIncomeSources: existing,
        ),
        {'c1'},
      );
    });

    test('is case-insensitive and trims whitespace on the name', () {
      final candidates = [_income('c1', ' Salary ', 3000.0)];
      final existing = [_income('e1', 'salary', 3000.0)];
      expect(
        ImportDuplicateDetector.alreadyPresentIncomeSourceIds(
          candidates: candidates,
          existingIncomeSources: existing,
        ),
        {'c1'},
      );
    });

    test('does not flag when amount differs', () {
      final candidates = [_income('c1', 'Salary', 3000.0)];
      final existing = [_income('e1', 'Salary', 3200.0)];
      expect(
        ImportDuplicateDetector.alreadyPresentIncomeSourceIds(
          candidates: candidates,
          existingIncomeSources: existing,
        ),
        isEmpty,
      );
    });
  });
}
