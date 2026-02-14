import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/widgets/currency_input.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:kakeibo/widgets/sparkle_button.dart';

class AddIncomeScreen extends ConsumerStatefulWidget {
  const AddIncomeScreen({super.key, this.editIncomeId});

  final String? editIncomeId;

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  IncomeSource? _editing;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));

    if (widget.editIncomeId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final monthAsync = ref.read(currentMonthProvider);
        monthAsync.whenData((month) {
          final source = month.incomeSources
              .where((s) => s.id == widget.editIncomeId)
              .firstOrNull;
          if (source != null) {
            setState(() {
              _editing = source;
              _nameController.text = source.name;
              _amountController.text = source.amount.toStringAsFixed(2);
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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';
    final monthId = ref.watch(currentMonthIdProvider);
    final isEditing = _editing != null;

    return KakeiboScaffold(
      title: isEditing ? 'Edit Income' : 'Add Income',
      subtitle: isEditing ? _editing!.name : null,
      showBackButton: true,
      showMenuButton: false,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Salary, Pension, Freelance',
              prefixIcon: Icon(Icons.trending_up_rounded),
            ),
            textCapitalization: TextCapitalization.sentences,
            autofocus: !isEditing,
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
          const SizedBox(height: 24),

          // Save button
          SparkleButton(
            label: isEditing ? 'Update Income' : 'Add Income',
            icon: Icons.check_rounded,
            onPressed: _canSave
                ? () async {
                    final amount =
                        double.tryParse(_amountController.text) ?? 0;
                    if (isEditing) {
                      await ref
                          .read(kakeiboMonthsProvider.notifier)
                          .updateIncomeSource(
                            _editing!.copyWith(
                              name: _nameController.text.trim(),
                              amount: amount,
                            ),
                            monthId,
                          );
                    } else {
                      await ref
                          .read(kakeiboMonthsProvider.notifier)
                          .addIncomeSource(
                            monthId: monthId,
                            name: _nameController.text.trim(),
                            amount: amount,
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
                    title: const Text('Delete income source?'),
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
                      .deleteIncomeSource(_editing!.id, monthId);
                  if (context.mounted) context.pop();
                }
              },
              icon: const Icon(Icons.delete_rounded, color: Colors.red),
              label: const Text('Delete Income Source',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ],
      ),
    );
  }

  bool get _canSave {
    return _nameController.text.trim().isNotEmpty &&
        (double.tryParse(_amountController.text) ?? 0) > 0;
  }
}
