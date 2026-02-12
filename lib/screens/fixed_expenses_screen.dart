import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/month_calculations_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/currency_input.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:kakeibo/widgets/sparkle_button.dart';

/// Built-in categories that always appear and can't be deleted.
const _defaultCategories = [
  'Housing',
  'Utilities',
  'Insurance',
  'Subscriptions',
  'Debt Payments',
  'Transport',
  'Childcare',
  'Other',
];

/// Normalise a category name: trim whitespace and title-case the first letter.
String _normalise(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

class FixedExpensesScreen extends ConsumerStatefulWidget {
  const FixedExpensesScreen({super.key});

  @override
  ConsumerState<FixedExpensesScreen> createState() =>
      _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends ConsumerState<FixedExpensesScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Other';

  /// Custom categories the user has added this session (not yet saved to an expense).
  final _sessionCategories = <String>{};

  @override
  void initState() {
    super.initState();
    // Add listeners to text controllers to trigger validation
    _nameController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Build the full category list: defaults + custom (from DB and session).
  List<String> _allCategories(List<String> usedCategories) {
    final merged = <String>{
      ..._defaultCategories,
      ...usedCategories,
      ..._sessionCategories,
    };
    final custom = merged.difference(_defaultCategories.toSet()).toList()
      ..sort();
    return [..._defaultCategories, ...custom];
  }

  /// Which categories are currently assigned to an expense and can't be deleted.
  Set<String> _inUseCategories(List<String> usedCategories) {
    return {..._defaultCategories, ...usedCategories};
  }

  @override
  Widget build(BuildContext context) {
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final fixedTotal = ref.watch(fixedExpensesTotalProvider);
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    String fmt(double amount) =>
        CurrencyFormatter.format(amount, currency: currency);

    return KakeiboScaffold(
      title: 'Fixed Costs',
      subtitle: 'Monthly bills & commitments',
      showBackButton: true,
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      body: monthAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (month) {
          final usedCategories =
              month.fixedExpenses.map((e) => e.category).toList();
          final categories = _allCategories(usedCategories);
          final inUse = _inUseCategories(usedCategories);

          // Ensure current selection is in the list.
          if (!categories.contains(_category)) {
            categories.add(_category);
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.softPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Fixed Costs', style: AppTextStyles.bodyBold),
                    Text(fmt(fixedTotal),
                        style: AppTextStyles.currencySmall),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Existing fixed expenses
              ...month.fixedExpenses.map((expense) => Dismissible(
                    key: Key(expense.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_rounded,
                          color: Colors.white),
                    ),
                    onDismissed: (_) {
                      ref
                          .read(kakeiboMonthsProvider.notifier)
                          .deleteFixedExpense(expense.id);
                    },
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.softBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_rounded,
                            color: AppColors.vividPurple, size: 20),
                      ),
                      title: Text(expense.name,
                          style: AppTextStyles.bodyBold),
                      subtitle: Text(expense.category,
                          style: AppTextStyles.caption),
                      trailing: Text(fmt(expense.amount),
                          style: AppTextStyles.bodyBold),
                    ),
                  )),

              if (month.fixedExpenses.isNotEmpty)
                const Divider(height: 32),

              // Add new fixed cost
              Text('Add Fixed Cost', style: AppTextStyles.subheading),
              const SizedBox(height: 12),

              // Category dropdown (plain items — no interactive widgets)
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: [
                  ...categories.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      )),
                  const DropdownMenuItem(
                    value: '_new',
                    child: Row(
                      children: [
                        Icon(Icons.add_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('New category\u2026'),
                      ],
                    ),
                  ),
                ],
                onChanged: (v) async {
                  if (v == '_new') {
                    final newCat = await _showNewCategoryDialog();
                    if (newCat != null && newCat.isNotEmpty) {
                      final normalised = _normalise(newCat);
                      setState(() {
                        _sessionCategories.add(normalised);
                        _category = normalised;
                      });
                    }
                  } else if (v != null) {
                    setState(() => _category = v);
                  }
                },
              ),
              const SizedBox(height: 12),

              CurrencyInput(
                controller: _amountController,
                currencySymbol:
                    CurrencyFormatter.symbol(currency: currency),
                label: 'Amount',
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (optional)',
                  hintText: 'Add details if needed',
                  prefixIcon: Icon(Icons.note_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),

              // Custom categories with delete buttons
              ..._customCategoryChips(categories, inUse),

              const SizedBox(height: 16),

              SparkleButton(
                label: 'Add Fixed Cost',
                icon: Icons.add_rounded,
                onPressed: _canAdd
                    ? () async {
                        await ref
                            .read(kakeiboMonthsProvider.notifier)
                            .addFixedExpense(
                              monthId: monthId,
                              name: _nameController.text.trim(),
                              amount: double.tryParse(
                                      _amountController.text) ??
                                  0,
                              category: _category,
                            );
                        _nameController.clear();
                        _amountController.clear();
                        setState(() {
                          _category = 'Other';
                        });
                      }
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Show deletable custom categories as small chips below the dropdown.
  List<Widget> _customCategoryChips(
      List<String> categories, Set<String> inUse) {
    final deletable =
        categories.where((c) => !inUse.contains(c)).toList();
    if (deletable.isEmpty) return [];
    return [
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: deletable.map((c) {
          return Chip(
            label: Text(c, style: const TextStyle(fontSize: 13)),
            deleteIcon: const Icon(Icons.delete_rounded,
                size: 16, color: AppColors.danger),
            onDeleted: () {
              setState(() {
                _sessionCategories.remove(c);
                if (_category == c) _category = 'Other';
              });
            },
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }).toList(),
      ),
    ];
  }

  Future<String?> _showNewCategoryDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'e.g. Council Tax, Gym',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  bool get _canAdd {
    return (double.tryParse(_amountController.text) ?? 0) > 0;
  }
}
