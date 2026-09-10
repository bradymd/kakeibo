import 'package:kakeibo/models/kakeibo_month.dart';

/// Sentinel used on the `/expenses?category=` query param and by
/// [ToyAllExpensesScreen]'s filter state to mean "uncategorised only",
/// distinct from both "no filter" (absent/null) and any real category name
/// (which is never empty -- empty string IS how uncategorised is stored,
/// so a plain empty-string check can't tell "filter to uncategorised" apart
/// from "no filter" -- see the fix noted in /tmp/kakeibo-discussion.txt,
/// Codex's implementation-review finding #2).
const kUncategorisedFilterValue = '—uncategorised—';

/// One category's aggregated total within a set of expenses, used by both
/// the Spend summary card and the dedicated breakdown screen so the two
/// stay consistent (per Codex's "shared aggregation model" suggestion).
class CategoryStat {
  const CategoryStat({
    required this.name,
    required this.total,
    required this.count,
  });

  /// Empty string represents "Uncategorised" -- callers decide how to
  /// label/colour that case, this class just carries the data.
  final String name;
  final double total;
  final int count;
}

class ExpenseCategoryStats {
  const ExpenseCategoryStats._();

  /// Aggregates [expenses] by category, descending by total amount.
  /// Uncategorised (empty-string category) is always included if present,
  /// sorted alongside everything else by amount like any other bucket --
  /// callers that want it visually separated (muted grey, listed last)
  /// should special-case `name.isEmpty` when rendering.
  static List<CategoryStat> aggregate(List<KakeiboExpense> expenses) {
    final totals = <String, double>{};
    final counts = <String, int>{};
    for (final e in expenses) {
      final key = e.category;
      totals[key] = (totals[key] ?? 0) + e.amount;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final stats = totals.entries
        .map((entry) => CategoryStat(
              name: entry.key,
              total: entry.value,
              count: counts[entry.key] ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return stats;
  }

  /// How many of [expenses] have a non-empty category.
  static int categorisedCount(List<KakeiboExpense> expenses) =>
      expenses.where((e) => e.category.isNotEmpty).length;

  /// Distinct non-empty category names in use.
  static int distinctCategoryCount(List<KakeiboExpense> expenses) =>
      expenses.map((e) => e.category).where((c) => c.isNotEmpty).toSet().length;

  /// Whether there's enough signal for the summary card to be worth
  /// showing, per Codex's threshold: at least 3 categorised expenses
  /// across at least 2 categories, OR at least 50% coverage. Never
  /// requires complete coverage.
  static bool meetsSummaryThreshold(List<KakeiboExpense> expenses) {
    if (expenses.isEmpty) return false;
    final categorised = categorisedCount(expenses);
    final distinct = distinctCategoryCount(expenses);
    final coverage = categorised / expenses.length;
    return (categorised >= 3 && distinct >= 2) || coverage >= 0.5;
  }
}
