import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/widgets/currency_input.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:kakeibo/widgets/sparkle_button.dart';

/// Built-in categories that always appear.
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

String _normalise(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}

class AddFixedExpenseScreen extends ConsumerStatefulWidget {
  const AddFixedExpenseScreen({super.key, this.editFixedExpenseId});

  final String? editFixedExpenseId;

  @override
  ConsumerState<AddFixedExpenseScreen> createState() =>
      _AddFixedExpenseScreenState();
}

class _AddFixedExpenseScreenState
    extends ConsumerState<AddFixedExpenseScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Other';
  int? _dueDay;
  FixedExpense? _editing;

  final _sessionCategories = <String>{};

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));

    if (widget.editFixedExpenseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final monthAsync = ref.read(currentMonthProvider);
        monthAsync.whenData((month) {
          final expense = month.fixedExpenses
              .where((e) => e.id == widget.editFixedExpenseId)
              .firstOrNull;
          if (expense != null) {
            setState(() {
              _editing = expense;
              _nameController.text = expense.name;
              _amountController.text = expense.amount.toStringAsFixed(2);
              _category = expense.category;
              _dueDay = expense.dueDay;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';
    final monthId = ref.watch(currentMonthIdProvider);
    final monthAsync = ref.watch(currentMonthProvider);
    final isEditing = _editing != null;

    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final usedCategories = monthAsync.whenOrNull(
            data: (m) =>
                m.fixedExpenses.map((e) => e.category).toList()) ??
        [];
    final categories = _allCategories(usedCategories);
    if (!categories.contains(_category)) {
      categories.add(_category);
    }

    return KakeiboScaffold(
      title: isEditing ? 'Edit Fixed Cost' : 'Add Fixed Cost',
      subtitle: isEditing ? _editing!.name.isNotEmpty ? _editing!.name : _editing!.category : null,
      showBackButton: true,
      showMenuButton: false,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Category
          DropdownButtonFormField<String>(
            initialValue: _category,
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
          const SizedBox(height: 16),

          // Amount
          CurrencyInput(
            controller: _amountController,
            currencySymbol:
                CurrencyFormatter.symbol(currency: currency),
            label: 'Amount',
            prefixColor: Colors.grey.shade600,
          ),
          const SizedBox(height: 16),

          // Name (optional)
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name (optional)',
              hintText: 'Add details if needed',
              prefixIcon: Icon(Icons.note_rounded),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),

          // Due day dropdown
          DropdownButtonFormField<int?>(
            initialValue: _dueDay,
            decoration: const InputDecoration(
              labelText: 'Due day of month (optional)',
              prefixIcon: Icon(Icons.calendar_today_rounded),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('No due date'),
              ),
              ...List.generate(daysInMonth, (i) {
                final day = i + 1;
                return DropdownMenuItem<int?>(
                  value: day,
                  child: Text(_ordinal(day)),
                );
              }),
            ],
            onChanged: (v) => setState(() => _dueDay = v),
          ),
          const SizedBox(height: 24),

          // Save button
          SparkleButton(
            label: isEditing ? 'Update Fixed Cost' : 'Add Fixed Cost',
            icon: Icons.check_rounded,
            onPressed: _canSave
                ? () async {
                    final amount =
                        double.tryParse(_amountController.text) ?? 0;
                    if (isEditing) {
                      await ref
                          .read(kakeiboMonthsProvider.notifier)
                          .updateFixedExpense(
                            _editing!.copyWith(
                              name: _nameController.text.trim(),
                              amount: amount,
                              category: _category,
                              dueDay: _dueDay,
                            ),
                          );
                    } else {
                      await ref
                          .read(kakeiboMonthsProvider.notifier)
                          .addFixedExpense(
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
                      TextButton(
                        onPressed: () => ctx.pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => ctx.pop(true),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref
                      .read(kakeiboMonthsProvider.notifier)
                      .deleteFixedExpense(_editing!.id);
                  if (context.mounted) context.pop();
                }
              },
              icon: const Icon(Icons.delete_rounded, color: Colors.red),
              label: const Text('Delete Fixed Cost',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
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

  bool get _canSave {
    return (double.tryParse(_amountController.text) ?? 0) > 0;
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
