import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/database/database_provider.dart';
import 'package:kakeibo/providers/database_provider.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-redesign Search screen (README §4f). Search logic
/// reused verbatim from `search_screen.dart` — grouped by month with a
/// per-month subtotal, which the README calls out as the main reason
/// to group results at all.
class ToySearchScreen extends ConsumerStatefulWidget {
  const ToySearchScreen({super.key});

  @override
  ConsumerState<ToySearchScreen> createState() => _ToySearchScreenState();
}

class _ToySearchScreenState extends ConsumerState<ToySearchScreen> {
  final _controller = TextEditingController();
  List<ExpenseSearchResult> _expenses = [];
  List<FixedExpenseSearchResult> _fixedExpenses = [];
  List<IncomeSearchResult> _incomeSources = [];
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final term = _controller.text.trim();
    if (term.isEmpty) {
      setState(() {
        _expenses = [];
        _fixedExpenses = [];
        _incomeSources = [];
        _hasSearched = false;
      });
      return;
    }

    final db = ref.read(databaseProvider);
    final results = await Future.wait([
      db.searchExpenses(term),
      db.searchFixedExpenses(term),
      db.searchIncomeSources(term),
    ]);

    if (mounted) {
      setState(() {
        _expenses = results[0] as List<ExpenseSearchResult>;
        _fixedExpenses = results[1] as List<FixedExpenseSearchResult>;
        _incomeSources = results[2] as List<IncomeSearchResult>;
        _hasSearched = true;
      });
    }
  }

  void _navigateToEditExpense(ExpenseSearchResult result) {
    ref.read(currentMonthIdProvider.notifier).state = result.monthId;
    context.push('/toy-edit-expense/${result.expense.id}');
  }

  void _navigateToEditFixedExpense(FixedExpenseSearchResult result) {
    ref.read(currentMonthIdProvider.notifier).state = result.monthId;
    context.push('/edit-fixed-expense/${result.fixedExpense.id}');
  }

  void _navigateToEditIncome(IncomeSearchResult result) {
    ref.read(currentMonthIdProvider.notifier).state = result.monthId;
    context.push('/edit-income/${result.incomeSource.id}');
  }

  int get _totalResults => _expenses.length + _fixedExpenses.length + _incomeSources.length;

  double get _totalAmount =>
      _expenses.fold(0.0, (sum, r) => sum + r.expense.amount) +
      _fixedExpenses.fold(0.0, (sum, r) => sum + r.fixedExpense.amount) +
      _incomeSources.fold(0.0, (sum, r) => sum + r.incomeSource.amount);

  int get _monthCount {
    final keys = <String>{};
    for (final r in _expenses) {
      keys.add(r.monthId);
    }
    for (final r in _fixedExpenses) {
      keys.add(r.monthId);
    }
    for (final r in _incomeSources) {
      keys.add(r.monthId);
    }
    return keys.length;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';
    String fmt(double amount) => CurrencyFormatter.format(amount, currency: currency);

    return ToyScaffold(
      title: '検索 Search',
      showBackButton: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ToyMetrics.screenPaddingH,
              12,
              ToyMetrics.screenPaddingH,
              8,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: ToyColors.card,
                borderRadius: BorderRadius.circular(ToyMetrics.capsuleFilterRadius),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: ToyTextStyles.rowTitle(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search expenses, fixed costs, income…',
                  hintStyle: ToyTextStyles.rowTitle(fontSize: 14, color: ToyColors.placeholder),
                  prefixIcon: const Icon(Icons.search_rounded, color: ToyColors.muted2, size: 20),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: ToyColors.muted2, size: 18),
                          onPressed: () {
                            _controller.clear();
                            _search();
                          },
                        )
                      : null,
                  isDense: true,
                ),
                textInputAction: TextInputAction.search,
                onChanged: (_) => _search(),
              ),
            ),
          ),
          if (_hasSearched)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ToyMetrics.screenPaddingH,
                4,
                ToyMetrics.screenPaddingH,
                8,
              ),
              child: Text(
                '$_totalResults results in $_monthCount ${_monthCount == 1 ? 'month' : 'months'} ・ ${fmt(_totalAmount)} total',
                style: ToyTextStyles.label(fontSize: 11.5, fontWeight: FontWeight.w800),
              ),
            ),
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Text(
                      'Search across every month.',
                      style: ToyTextStyles.body(),
                    ),
                  )
                : _totalResults == 0
                    ? Center(
                        child: Text('No results found', style: ToyTextStyles.body()),
                      )
                    : _buildResultsByMonth(fmt),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsByMonth(String Function(double) fmt) {
    // Group all three result types by monthId, sorted newest first.
    final monthIds = <String>{};
    for (final r in _expenses) {
      monthIds.add(r.monthId);
    }
    for (final r in _fixedExpenses) {
      monthIds.add(r.monthId);
    }
    for (final r in _incomeSources) {
      monthIds.add(r.monthId);
    }
    final sortedMonths = monthIds.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        ToyMetrics.screenPaddingH,
        0,
        ToyMetrics.screenPaddingH,
        ToyMetrics.listBottomPadding,
      ),
      children: [
        for (final monthId in sortedMonths) ...[
          _monthGroup(monthId, fmt),
          const SizedBox(height: ToyMetrics.cardGap),
        ],
      ],
    );
  }

  Widget _monthGroup(String monthId, String Function(double) fmt) {
    final expenses = _expenses.where((r) => r.monthId == monthId).toList();
    final fixedExpenses = _fixedExpenses.where((r) => r.monthId == monthId).toList();
    final incomeSources = _incomeSources.where((r) => r.monthId == monthId).toList();

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final monthLabel = MonthHelpers.formatMonthDisplay(year, month);
    final subtotal = expenses.fold(0.0, (sum, r) => sum + r.expense.amount) +
        fixedExpenses.fold(0.0, (sum, r) => sum + r.fixedExpense.amount) +
        incomeSources.fold(0.0, (sum, r) => sum + r.incomeSource.amount);

    final rows = <Widget>[];
    for (final r in expenses) {
      rows.add(ToyRow(
        title: r.expense.description,
        meta: '${r.expense.pillar.label} ${r.expense.pillar.japanese}',
        amountText: fmt(r.expense.amount),
        leading: ToyPillarDot(color: r.expense.pillar.toyFill),
        onTap: () => _navigateToEditExpense(r),
      ));
    }
    for (final r in fixedExpenses) {
      final label = r.fixedExpense.name.isNotEmpty
          ? '${r.fixedExpense.category} · ${r.fixedExpense.name}'
          : r.fixedExpense.category;
      rows.add(ToyRow(
        title: label,
        meta: 'Fixed cost',
        amountText: fmt(r.fixedExpense.amount),
        onTap: () => _navigateToEditFixedExpense(r),
      ));
    }
    for (final r in incomeSources) {
      rows.add(ToyRow(
        title: r.incomeSource.name,
        meta: 'Income',
        amountText: fmt(r.incomeSource.amount),
        amountColor: ToyColors.success,
        onTap: () => _navigateToEditIncome(r),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(monthLabel, style: ToyTextStyles.cardTitle(fontSize: 13)),
            Text(
              fmt(subtotal),
              style: ToyTextStyles.label(fontSize: 11.5, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ToyCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const DashedDivider(),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
