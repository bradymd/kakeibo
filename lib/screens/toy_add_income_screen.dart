import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/utils/currency_input_formatters.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-restyled Add/Edit Income screen. Logic reused verbatim
/// from `add_income_screen.dart` -- only the presentation changes, matching
/// the layout established by `toy_add_expense_screen.dart`.
class ToyAddIncomeScreen extends ConsumerStatefulWidget {
  const ToyAddIncomeScreen({super.key, this.editIncomeId});

  final String? editIncomeId;

  @override
  ConsumerState<ToyAddIncomeScreen> createState() => _ToyAddIncomeScreenState();
}

class _ToyAddIncomeScreenState extends ConsumerState<ToyAddIncomeScreen> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  IncomeSource? _editing;
  bool _fieldsPopulated = false;

  bool get _isEditRoute => widget.editIncomeId != null;

  bool _amountTouched = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      if (_amountController.text.isNotEmpty) _amountTouched = true;
      setState(() {});
    });
  }

  void _populateFromSource(IncomeSource source) {
    if (_fieldsPopulated) return;
    _fieldsPopulated = true;
    _editing = source;
    _amountController.text = source.amount.toStringAsFixed(2);
    _nameController.text = source.name;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      (double.tryParse(_amountController.text) ?? 0) > 0;

  bool get _hasUnsavedChanges {
    if (_editing == null) {
      return _amountController.text.isNotEmpty || _nameController.text.trim().isNotEmpty;
    }
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount != _editing!.amount || _nameController.text.trim() != _editing!.name;
  }

  Future<void> _handleBack(BuildContext context) async {
    if (_hasUnsavedChanges) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: ToyColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Discard this income source?'),
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
        context.go('/income');
      }
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
          final source =
              month.incomeSources.where((s) => s.id == widget.editIncomeId).firstOrNull;
          if (source == null) {
            return ToyScaffold(
              title: '見つかりません Not found',
              showBackButton: true,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'This income source could not be found. It may have been deleted.',
                    style: ToyTextStyles.body(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _populateFromSource(source));
          });
          return const Scaffold(
            backgroundColor: ToyColors.bg,
            body: Center(child: CircularProgressIndicator(color: ToyColors.brand)),
          );
        },
      );
    }

    final isEditing = _editing != null;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack(context);
      },
      child: ToyScaffold(
        title: isEditing ? '収入をへんこう' : '収入をいれる',
        subtitle: isEditing ? 'Edit income' : 'Add income',
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
                  inputFormatters: currencyInputFormatters,
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
              _FieldPill(
                child: TextField(
                  controller: _nameController,
                  autofocus: false,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Name, e.g. Salary, Pension, Freelance',
                    hintStyle: ToyTextStyles.rowTitle(fontSize: 13, color: ToyColors.placeholder),
                    isDense: true,
                  ),
                  style: ToyTextStyles.rowTitle(fontSize: 13),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              ToyPrimaryButton(
                label: isEditing ? 'へんこう ・ Update income' : 'いれる ・ Save income',
                onTap: _canSave
                    ? () async {
                        final amount = double.tryParse(_amountController.text) ?? 0;
                        if (isEditing) {
                          await ref.read(kakeiboMonthsProvider.notifier).updateIncomeSource(
                                _editing!.copyWith(
                                  name: _nameController.text.trim(),
                                  amount: amount,
                                ),
                                monthId,
                              );
                        } else {
                          await ref.read(kakeiboMonthsProvider.notifier).addIncomeSource(
                                monthId: monthId,
                                name: _nameController.text.trim(),
                                amount: amount,
                              );
                        }
                        if (context.mounted) context.pop();
                      }
                    : null,
              ),
              if (!_canSave && _amountTouched) ...[
                const SizedBox(height: 8),
                Text(
                  _nameController.text.trim().isEmpty
                      ? 'Enter a name and an amount to save'
                      : 'Enter an amount to save',
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
                        title: const Text('Delete income source?'),
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
                      await ref
                          .read(kakeiboMonthsProvider.notifier)
                          .deleteIncomeSource(_editing!.id, monthId);
                      if (context.mounted) context.pop();
                    }
                  },
                  icon: const Icon(Icons.delete_rounded, color: ToyColors.danger),
                  label: Text('Delete Income Source', style: ToyTextStyles.rowTitle(color: ToyColors.danger)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
