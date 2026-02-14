import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/utils/date_utils.dart';
import 'package:kakeibo/widgets/currency_input.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:kakeibo/widgets/pillar_selector.dart';
import 'package:kakeibo/widgets/sparkle_button.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.editExpenseId});

  final String? editExpenseId;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  Pillar _selectedPillar = Pillar.needs;
  String _date = todayIso();
  KakeiboExpense? _editing;

  @override
  void initState() {
    super.initState();
    // Add listeners to text controllers to trigger validation
    _descController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));

    if (widget.editExpenseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final monthAsync = ref.read(currentMonthProvider);
        monthAsync.whenData((month) {
          final expense = month.expenses
              .where((e) => e.id == widget.editExpenseId)
              .firstOrNull;
          if (expense != null) {
            setState(() {
              _editing = expense;
              _descController.text = expense.description;
              _amountController.text = expense.amount.toStringAsFixed(2);
              _notesController.text = expense.notes;
              _selectedPillar = expense.pillar;
              _date = expense.date;
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';
    final monthId = ref.watch(currentMonthIdProvider);
    final isEditing = _editing != null;

    return KakeiboScaffold(
      title: isEditing ? 'Edit Expense' : 'Add Expense',
      subtitle: isEditing ? _editing!.description : null,
      showBackButton: true,
      showMenuButton: false,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Description
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'What did you spend on?',
              prefixIcon: Icon(Icons.description_rounded),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),

          // Amount
          CurrencyInput(
            controller: _amountController,
            currencySymbol: CurrencyFormatter.symbol(currency: currency),
            label: 'Amount',
          ),
          const SizedBox(height: 16),

          // Date
          ListTile(
            leading: const Icon(Icons.calendar_today_rounded),
            title: Text('Date', style: AppTextStyles.label),
            subtitle: Text(_date, style: AppTextStyles.body),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.tryParse(_date) ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _date =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                });
              }
            },
          ),
          const SizedBox(height: 20),

          // Pillar selector
          Text('Please assign this expense to one of the four pillars',
              style: AppTextStyles.bodyBold),
          const SizedBox(height: 8),
          PillarSelector(
            selected: _selectedPillar,
            onChanged: (p) => setState(() => _selectedPillar = p),
          ),
          const SizedBox(height: 16),

          // Notes
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Any additional notes...',
              prefixIcon: Icon(Icons.note_rounded),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),

          SparkleButton(
            label: isEditing ? 'Update Expense' : 'Add Expense',
            icon: Icons.check_rounded,
            onPressed: _canSave
                ? () async {
                    final amount =
                        double.tryParse(_amountController.text) ?? 0;
                    if (isEditing) {
                      await ref
                          .read(kakeiboMonthsProvider.notifier)
                          .updateExpense(
                            _editing!.copyWith(
                              description: _descController.text.trim(),
                              amount: amount,
                              pillar: _selectedPillar,
                              date: _date,
                              notes: _notesController.text.trim(),
                            ),
                          );
                    } else {
                      await ref
                          .read(kakeiboMonthsProvider.notifier)
                          .addExpense(
                            monthId: monthId,
                            date: _date,
                            description: _descController.text.trim(),
                            amount: amount,
                            pillarName: _selectedPillar.name,
                            notes: _notesController.text.trim(),
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
                    title: const Text('Delete expense?'),
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
                      .deleteExpense(_editing!.id);
                  if (context.mounted) context.pop();
                }
              },
              icon: const Icon(Icons.delete_rounded, color: Colors.red),
              label: const Text('Delete Expense',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
  }

  bool get _canSave {
    final desc = _descController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    return desc.isNotEmpty && amount > 0;
  }
}
