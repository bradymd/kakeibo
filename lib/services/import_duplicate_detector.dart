import 'package:kakeibo/models/kakeibo_month.dart';

/// Detects fixed-cost/income items on the "copy from another month" screen
/// that already exist in the destination month, so a repeat copy doesn't
/// silently create duplicates -- per Codex's review in the shared design
/// discussion: the copy operation is additive (every selected item is
/// inserted with a new ID; nothing is merged or replaced), so re-running it
/// against the same source month creates real duplicate fixed costs/income
/// sources, not just a visual annoyance.
///
/// v1 identity, as specified: fixed cost = normalized name + category +
/// amount + due day; income source = normalized name + amount.
/// "Normalized" means trimmed and case-insensitive, so "Netflix " and
/// "netflix" are treated as the same thing.
class ImportDuplicateDetector {
  const ImportDuplicateDetector._();

  static String _normalize(String s) => s.trim().toLowerCase();

  /// IDs (from [candidates]) that already appear to exist in
  /// [existingFixedExpenses], by the v1 identity above.
  static Set<String> alreadyPresentFixedExpenseIds({
    required List<FixedExpense> candidates,
    required List<FixedExpense> existingFixedExpenses,
  }) {
    final existingKeys = existingFixedExpenses.map(_fixedExpenseKey).toSet();
    return candidates
        .where((c) => existingKeys.contains(_fixedExpenseKey(c)))
        .map((c) => c.id)
        .toSet();
  }

  /// IDs (from [candidates]) that already appear to exist in
  /// [existingIncomeSources], by the v1 identity above.
  static Set<String> alreadyPresentIncomeSourceIds({
    required List<IncomeSource> candidates,
    required List<IncomeSource> existingIncomeSources,
  }) {
    final existingKeys = existingIncomeSources.map(_incomeSourceKey).toSet();
    return candidates
        .where((c) => existingKeys.contains(_incomeSourceKey(c)))
        .map((c) => c.id)
        .toSet();
  }

  static (String, String, double, int?) _fixedExpenseKey(FixedExpense e) =>
      (_normalize(e.name), _normalize(e.category), e.amount, e.dueDay);

  static (String, double) _incomeSourceKey(IncomeSource s) =>
      (_normalize(s.name), s.amount);
}
