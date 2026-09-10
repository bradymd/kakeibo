import 'package:kakeibo/models/kakeibo_month.dart';

/// The Spend screen's category filter, as a proper tri-state rather than a
/// bare `String?` -- a nullable string can't distinguish "no filter" from
/// "filter to uncategorised" when uncategorised expenses are *themselves*
/// stored as an empty-string category. An earlier fix tried to paper over
/// that with a reserved sentinel string, but a sentinel still lives in the
/// same value domain as real (free-text) category names, so it could in
/// principle collide with something a user actually types. This type makes
/// "no filter" / "a named category" / "uncategorised" three distinct,
/// unconfusable states instead.
sealed class CategoryFilter {
  const CategoryFilter();

  static const all = _AllCategories();
  static const uncategorised = _Uncategorised();
  factory CategoryFilter.named(String category) = _NamedCategory;

  /// Matches any of several named categories at once -- used for the
  /// breakdown screen's "Other" bucket (categories beyond the top five
  /// shown as individual slices), so tapping it can actually show which
  /// expenses it's made of instead of being a dead end.
  factory CategoryFilter.anyOf(Set<String> categories) = _AnyOfCategories;

  /// Joins/splits multiple category names for the `categories` query param.
  /// Not a plain comma: category names are free text and can contain
  /// commas themselves, and go_router's queryParameters fully URI-decodes
  /// the value before this class ever sees it -- so a comma that was part
  /// of a name and a comma used as the separator become indistinguishable
  /// by the time this runs, no matter how the individual names were
  /// percent-encoded beforehand. U+241D is a control-picture symbol with
  /// no normal keyboard input, effectively never appearing in a real
  /// category name, so it survives as an unambiguous separator instead.
  static const _multiCategorySeparator = '␝';

  /// Builds the `/expenses?categories=...` query value for [names] -- the
  /// counterpart to fromQueryParameters' anyOf parsing. Callers should
  /// still wrap the result in Uri.encodeComponent when building the full
  /// URL (this only joins; it doesn't escape).
  static String encodeCategoryNames(Iterable<String> names) =>
      names.join(_multiCategorySeparator);

  /// Parses the `/expenses` route's query params into a filter, or null for
  /// "no filter" (the Spend screen's default). `uncategorised=1` takes
  /// precedence over everything else if a caller ever sent it alongside
  /// other params; `categories` (for the "Other" bucket) takes precedence
  /// over a single `category`. Pulled out as its own testable function
  /// rather than left inline in the route builder, since GoRouter route
  /// builders aren't directly unit-testable.
  static CategoryFilter? fromQueryParameters(Map<String, String> params) {
    if (params['uncategorised'] == '1') return uncategorised;
    final categories = params['categories'];
    if (categories != null && categories.isNotEmpty) {
      final names = categories
          .split(_multiCategorySeparator)
          .where((c) => c.isNotEmpty)
          .toSet();
      if (names.isNotEmpty) return CategoryFilter.anyOf(names);
    }
    final category = params['category'];
    if (category != null && category.isNotEmpty) return CategoryFilter.named(category);
    return null;
  }

  /// Whether [expense]'s category matches this filter.
  bool matches(KakeiboExpense expense);

  /// Display label for the applied-filter pill, e.g. "Category: Groceries"
  /// or "Category: Uncategorised". Not defined for [all], since that state
  /// never shows a pill.
  String get pillLabel;
}

class _AllCategories extends CategoryFilter {
  const _AllCategories();
  @override
  bool matches(KakeiboExpense expense) => true;
  @override
  String get pillLabel => throw StateError('CategoryFilter.all has no pill label');
}

class _Uncategorised extends CategoryFilter {
  const _Uncategorised();
  @override
  bool matches(KakeiboExpense expense) => expense.category.isEmpty;
  @override
  String get pillLabel => 'Category: Uncategorised';
}

class _NamedCategory extends CategoryFilter {
  const _NamedCategory(this.name);
  final String name;
  @override
  bool matches(KakeiboExpense expense) => expense.category == name;
  @override
  String get pillLabel => 'Category: $name';
}

class _AnyOfCategories extends CategoryFilter {
  const _AnyOfCategories(this.categories);
  final Set<String> categories;
  @override
  bool matches(KakeiboExpense expense) => categories.contains(expense.category);
  @override
  String get pillLabel =>
      'Category: Other (${categories.length} ${categories.length == 1 ? 'category' : 'categories'})';
}

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
