import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/database/database_provider.dart';
import 'package:kakeibo/providers/database_provider.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
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
    context.push('/edit-expense/${result.expense.id}');
  }

  void _navigateToEditFixedExpense(FixedExpenseSearchResult result) {
    ref.read(currentMonthIdProvider.notifier).state = result.monthId;
    context.push('/edit-fixed-expense/${result.fixedExpense.id}');
  }

  void _navigateToEditIncome(IncomeSearchResult result) {
    ref.read(currentMonthIdProvider.notifier).state = result.monthId;
    context.push('/edit-income/${result.incomeSource.id}');
  }

  String _monthLabel(int year, int month) {
    return MonthHelpers.formatMonthDisplay(year, month);
  }

  int get _totalResults =>
      _expenses.length + _fixedExpenses.length + _incomeSources.length;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    return KakeiboScaffold(
      title: 'Search',
      showHomeButton: true,
      centerTitle: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search expenses, fixed costs, income...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _controller.clear();
                          _search();
                        },
                      )
                    : null,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (_) => _search(),
            ),
          ),
          if (_hasSearched && _totalResults == 0)
            Expanded(
              child: Center(
                child: Text(
                  'No results found',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (_expenses.isNotEmpty) ...[
                    _sectionHeader(
                        'Expenses', _expenses.length, Icons.receipt_long_rounded),
                    ..._expenses.map((r) => _expenseTile(r, currency)),
                    const SizedBox(height: 16),
                  ],
                  if (_fixedExpenses.isNotEmpty) ...[
                    _sectionHeader('Fixed Costs', _fixedExpenses.length,
                        Icons.push_pin_rounded),
                    ..._fixedExpenses.map((r) => _fixedExpenseTile(r, currency)),
                    const SizedBox(height: 16),
                  ],
                  if (_incomeSources.isNotEmpty) ...[
                    _sectionHeader('Income', _incomeSources.length,
                        Icons.trending_up_rounded),
                    ..._incomeSources.map((r) => _incomeTile(r, currency)),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.subheading),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.hotPink.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.hotPink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseTile(ExpenseSearchResult r, String currency) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: r.expense.pillar.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(r.expense.pillar.icon,
            color: r.expense.pillar.color, size: 20),
      ),
      title: Text(r.expense.description, style: AppTextStyles.bodyBold),
      subtitle: Text(
        '${CurrencyFormatter.format(r.expense.amount, currency: currency)} · ${_monthLabel(r.year, r.month)}',
        style: AppTextStyles.caption,
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          size: 18, color: AppColors.textMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () => _navigateToEditExpense(r),
    );
  }

  Widget _fixedExpenseTile(FixedExpenseSearchResult r, String currency) {
    final label = r.fixedExpense.name.isNotEmpty
        ? '${r.fixedExpense.category} · ${r.fixedExpense.name}'
        : r.fixedExpense.category;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.vividPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.push_pin_rounded,
            color: AppColors.vividPurple, size: 20),
      ),
      title: Text(label, style: AppTextStyles.bodyBold),
      subtitle: Text(
        '${CurrencyFormatter.format(r.fixedExpense.amount, currency: currency)} · ${_monthLabel(r.year, r.month)}',
        style: AppTextStyles.caption,
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          size: 18, color: AppColors.textMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () => _navigateToEditFixedExpense(r),
    );
  }

  Widget _incomeTile(IncomeSearchResult r, String currency) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.trending_up_rounded,
            color: AppColors.success, size: 20),
      ),
      title: Text(r.incomeSource.name, style: AppTextStyles.bodyBold),
      subtitle: Text(
        '${CurrencyFormatter.format(r.incomeSource.amount, currency: currency)} · ${_monthLabel(r.year, r.month)}',
        style: AppTextStyles.caption,
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          size: 18, color: AppColors.textMuted),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () => _navigateToEditIncome(r),
    );
  }
}
