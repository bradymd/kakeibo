import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/constants/fixed_expense_categories.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

String _normalise(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

/// The gachapon-restyled Add/Edit Fixed Cost screen. Logic reused verbatim
/// from `add_fixed_expense_screen.dart` (category dropdown-turned-chips,
/// due-day picker, delete flow) -- only the presentation changes, matching
/// the layout established by `toy_add_expense_screen.dart`.
class ToyAddFixedExpenseScreen extends ConsumerStatefulWidget {
  const ToyAddFixedExpenseScreen({super.key, this.editFixedExpenseId});

  final String? editFixedExpenseId;

  @override
  ConsumerState<ToyAddFixedExpenseScreen> createState() =>
      _ToyAddFixedExpenseScreenState();
}

class _ToyAddFixedExpenseScreenState
    extends ConsumerState<ToyAddFixedExpenseScreen> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  String _category = 'Other';
  int? _dueDay;
  FixedExpense? _editing;
  bool _fieldsPopulated = false;
  final _sessionCategories = <String>{};

  bool get _isEditRoute => widget.editFixedExpenseId != null;

  bool _amountTouched = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      if (_amountController.text.isNotEmpty) _amountTouched = true;
      setState(() {});
    });
  }

  void _populateFromExpense(FixedExpense expense) {
    if (_fieldsPopulated) return;
    _fieldsPopulated = true;
    _editing = expense;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _nameController.text = expense.name;
    _category = expense.category;
    _dueDay = expense.dueDay;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave => (double.tryParse(_amountController.text) ?? 0) > 0;

  bool get _hasUnsavedChanges {
    if (_editing == null) {
      return _amountController.text.isNotEmpty ||
          _nameController.text.trim().isNotEmpty;
    }
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount != _editing!.amount ||
        _nameController.text.trim() != _editing!.name ||
        _category != _editing!.category ||
        _dueDay != _editing!.dueDay;
  }

  Future<void> _handleBack(BuildContext context) async {
    if (_hasUnsavedChanges) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: ToyColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Discard this fixed cost?'),
          content: const Text('Your changes haven\'t been saved.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep editing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: ToyColors.danger),
              child: const Text('Discard'),
            ),
          ],
        ),
      );
      if (discard != true) return;
    }
    if (context.mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/fixed-expenses');
      }
    }
  }

  List<String> _allCategories(List<String> usedCategories) {
    final merged = <String>{
      ...defaultFixedExpenseCategories,
      ...usedCategories,
      ..._sessionCategories,
    };
    final custom = merged.difference(defaultFixedExpenseCategories.toSet()).toList()
      ..sort();
    return [...defaultFixedExpenseCategories, ...custom];
  }

  Future<void> _showNewCategoryDialog() async {
    final controller = TextEditingController();
    final newCat = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ToyColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('New Category', style: ToyTextStyles.cardTitle(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          style: ToyTextStyles.rowTitle(fontSize: 14),
          decoration: const InputDecoration(hintText: 'e.g. Council Tax, Gym'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (newCat != null && newCat.isNotEmpty) {
      final normalised = _normalise(newCat);
      setState(() {
        _sessionCategories.add(normalised);
        _category = normalised;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';
    final monthId = ref.watch(currentMonthIdProvider);

    if (_isEditRoute && !_fieldsPopulated) {
      final monthAsync = ref.watch(currentMonthProvider);
      return monthAsync.when(
        loading: () => const Scaffold(
          backgroundColor: ToyColors.bg,
          body: Center(child: CircularProgressIndicator(color: ToyColors.brand)),
        ),
        error: (e, _) => Scaffold(
          backgroundColor: ToyColors.bg,
          body: Center(child: Text('Error: $e')),
        ),
        data: (month) {
          final expense = month.fixedExpenses
              .where((e) => e.id == widget.editFixedExpenseId)
              .firstOrNull;
          if (expense == null) {
            return ToyScaffold(
              title: '見つかりません Not found',
              showBackButton: true,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'This fixed cost could not be found. It may have been deleted.',
                    style: ToyTextStyles.body(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _populateFromExpense(expense));
          });
          return const Scaffold(
            backgroundColor: ToyColors.bg,
            body: Center(child: CircularProgressIndicator(color: ToyColors.brand)),
          );
        },
      );
    }

    final monthAsync = ref.watch(currentMonthProvider);
    final isEditing = _editing != null;
    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final usedCategories = monthAsync.whenOrNull(
          data: (m) => m.fixedExpenses.map((e) => e.category).toList(),
        ) ??
        [];
    final categories = _allCategories(usedCategories);
    if (!categories.contains(_category)) categories.add(_category);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack(context);
      },
      child: ToyScaffold(
        title: isEditing ? '固定費をへんこう' : '固定費をいれる',
        subtitle: isEditing ? 'Edit fixed cost' : 'Add fixed cost',
        showBackButton: true,
        onBack: () => _handleBack(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            ToyMetrics.screenPaddingH,
            16,
            ToyMetrics.screenPaddingH,
            24,
          ),
          child: Column(
            children: [
              ToyCard(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: TextField(
                  controller: _amountController,
                  autofocus: !isEditing,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: ToyTextStyles.hero(fontSize: 46),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    prefixText: '${CurrencyFormatter.symbol(currency: currency)} ',
                    prefixStyle: ToyTextStyles.hero(fontSize: 46),
                    hintText: '0.00',
                    hintStyle: ToyTextStyles.hero(fontSize: 46, color: ToyColors.placeholder),
                  ),
                ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'カテゴリー Category',
                  style: ToyTextStyles.label(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ToyColors.muted2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final cat in categories)
                    ToyCapsuleButton(
                      label: cat,
                      fillColor: _category == cat ? ToyColors.brand : ToyColors.card,
                      shadowColor: _category == cat ? ToyColors.brandDark : ToyColors.divider,
                      textColor: _category == cat ? Colors.white : ToyColors.ink,
                      onTap: () => setState(() => _category = cat),
                    ),
                  ToyCapsuleButton(
                    label: '+ New',
                    fillColor: ToyColors.bg,
                    shadowColor: ToyColors.divider,
                    textColor: ToyColors.muted,
                    onTap: _showNewCategoryDialog,
                  ),
                ],
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              _FieldPill(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Name (optional)',
                    hintStyle: ToyTextStyles.rowTitle(fontSize: 13, color: ToyColors.placeholder),
                    isDense: true,
                  ),
                  style: ToyTextStyles.rowTitle(fontSize: 13),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '支払日 Due day (optional)',
                  style: ToyTextStyles.label(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ToyColors.muted2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _FieldPill(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _dueDay,
                    hint: Text('No due date', style: ToyTextStyles.rowTitle(fontSize: 13, color: ToyColors.placeholder)),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('No due date', style: ToyTextStyles.rowTitle(fontSize: 13)),
                      ),
                      for (var day = 1; day <= daysInMonth; day++)
                        DropdownMenuItem<int?>(
                          value: day,
                          child: Text(_ordinal(day), style: ToyTextStyles.rowTitle(fontSize: 13)),
                        ),
                    ],
                    onChanged: (v) => setState(() => _dueDay = v),
                  ),
                ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              ToyPrimaryButton(
                label: isEditing ? 'へんこう ・ Update fixed cost' : 'いれる ・ Save fixed cost',
                onTap: _canSave
                    ? () async {
                        final amount = double.tryParse(_amountController.text) ?? 0;
                        if (isEditing) {
                          await ref.read(kakeiboMonthsProvider.notifier).updateFixedExpense(
                                _editing!.copyWith(
                                  name: _nameController.text.trim(),
                                  amount: amount,
                                  category: _category,
                                  dueDay: _dueDay,
                                ),
                              );
                        } else {
                          await ref.read(kakeiboMonthsProvider.notifier).addFixedExpense(
                                monthId: monthId,
                                name: _nameController.text.trim(),
                                amount: amount,
                                category: _category,
                                dueDay: _dueDay,
                              );
                        }
                        if (context.mounted) context.pop();
                      }
                    : null,
              ),
              if (!_canSave && _amountTouched) ...[
                const SizedBox(height: 8),
                Text(
                  'Enter an amount to save',
                  style: ToyTextStyles.label(fontSize: 11.5, color: ToyColors.danger),
                  textAlign: TextAlign.center,
                ),
              ],
              if (isEditing) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete fixed cost?'),
                        content: const Text('This cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => ctx.pop(false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => ctx.pop(true),
                            style: TextButton.styleFrom(foregroundColor: ToyColors.danger),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(kakeiboMonthsProvider.notifier).deleteFixedExpense(_editing!.id);
                      if (context.mounted) context.pop();
                    }
                  },
                  icon: const Icon(Icons.delete_rounded, color: ToyColors.danger),
                  label: Text('Delete Fixed Cost', style: ToyTextStyles.rowTitle(color: ToyColors.danger)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _ordinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    return switch (day % 10) {
      1 => '${day}st',
      2 => '${day}nd',
      3 => '${day}rd',
      _ => '${day}th',
    };
  }
}

class _FieldPill extends StatelessWidget {
  const _FieldPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ToyColors.card,
        borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
      ),
      child: child,
    );
  }
}
