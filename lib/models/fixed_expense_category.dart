enum FixedExpenseCategory {
  housing,
  utilities,
  insurance,
  subscriptions,
  debt,
  other;

  String get label {
    switch (this) {
      case FixedExpenseCategory.housing:
        return 'Housing';
      case FixedExpenseCategory.utilities:
        return 'Utilities';
      case FixedExpenseCategory.insurance:
        return 'Insurance';
      case FixedExpenseCategory.subscriptions:
        return 'Subscriptions';
      case FixedExpenseCategory.debt:
        return 'Debt Payments';
      case FixedExpenseCategory.other:
        return 'Other';
    }
  }
}
