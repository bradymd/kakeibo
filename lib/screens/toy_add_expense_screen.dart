import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/database/database_provider.dart' show DescriptionMatch;
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/utils/currency_input_formatters.dart';
import 'package:kakeibo/utils/date_utils.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_description_field.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';
import 'package:intl/intl.dart';

/// The gachapon-redesign Add Expense screen (README §4a).
///
/// Reordered from the current screen: amount leads. Tapping the amount
/// field brings up the OS numeric keyboard (not a persistent custom
/// keypad — the always-visible calculator-style keypad the README
/// specified was rejected on review as unfamiliar). Pillar defaults to
/// Needs and is a required single-select before saving.
class ToyAddExpenseScreen extends ConsumerStatefulWidget {
  const ToyAddExpenseScreen({super.key, this.editExpenseId});

  final String? editExpenseId;

  @override
  ConsumerState<ToyAddExpenseScreen> createState() =>
      _ToyAddExpenseScreenState();
}

class _ToyAddExpenseScreenState extends ConsumerState<ToyAddExpenseScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  Pillar? _selectedPillar = Pillar.needs;
  String _date = todayIso();
  KakeiboExpense? _editing;
  bool _fieldsPopulated = false;

  /// Live description-autocomplete suggestion, rendered as a separate row
  /// below the Description/Date fields rather than inline -- see
  /// toy_description_field.dart for why.
  DescriptionMatch? _descriptionMatch;

  /// Whether this route was reached in edit intent, independent of
  /// whether the expense data has actually loaded yet. Reading the
  /// month provider once in initState (the original screen's approach)
  /// meant a still-loading provider left `_editing` null forever and
  /// the screen silently fell through to "add" — saving would then
  /// create a duplicate instead of updating the original. Tracking
  /// intent separately from load state lets the build method show an
  /// explicit loading/not-found state instead.
  bool get _isEditRoute => widget.editExpenseId != null;

  /// Whether the amount field has ever had content, so the "enter an
  /// amount" hint doesn't greet a still-blank form as if it were an
  /// error — it only appears once the user has started and the amount
  /// is still invalid (e.g. cleared back to empty).
  bool _amountTouched = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      if (_amountController.text.isNotEmpty) _amountTouched = true;
      setState(() {});
    });
  }

  /// Populates the form from the loaded expense the first time it
  /// becomes available. Called from build() (via ref.watch, not a
  /// one-shot ref.read) so a slow-loading provider is retried on every
  /// rebuild rather than only checked once.
  void _populateFromExpense(KakeiboExpense expense) {
    if (_fieldsPopulated) return;
    _fieldsPopulated = true;
    _editing = expense;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _selectedPillar = expense.pillar;
    _descController.text = expense.description;
    _categoryController.text = expense.category;
    _notesController.text = expense.notes;
    _date = expense.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      (double.tryParse(_amountController.text) ?? 0) > 0 &&
      _selectedPillar != null;

  /// Whether backing out now would lose something. Adding new: any
  /// amount or description typed in counts. Editing: only actual
  /// changes from the loaded expense count — backing out of an
  /// untouched edit shouldn't warn.
  bool get _hasUnsavedChanges {
    if (_editing == null) {
      return _amountController.text.isNotEmpty ||
          _descController.text.trim().isNotEmpty;
    }
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount != _editing!.amount ||
        _descController.text.trim() != _editing!.description ||
        _categoryController.text.trim() != _editing!.category ||
        _notesController.text.trim() != _editing!.notes ||
        _selectedPillar != _editing!.pillar ||
        _date != _editing!.date;
  }

  Future<void> _handleBack(BuildContext context) async {
    if (_hasUnsavedChanges) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: ToyColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text('Discard this expense?'),
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
        context.go('/');
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
          final expense =
              month.expenses.where((e) => e.id == widget.editExpenseId).firstOrNull;
          if (expense == null) {
            return ToyScaffold(
              title: '見つかりません Not found',
              showBackButton: true,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'This expense could not be found. It may have been deleted.',
                    style: ToyTextStyles.body(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          // Populate then rebuild once more with fields ready — avoids
          // mutating state mid-build by scheduling the setState for
          // right after this frame.
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

    final isEditing = _editing != null;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack(context);
      },
      child: ToyScaffold(
        title: isEditing ? '支出をへんこう' : '支出をいれる',
        subtitle: isEditing ? 'Edit expense' : 'Add expense',
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
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                child: TextField(
                  controller: _amountController,
                  autofocus: !isEditing,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: currencyInputFormatters,
                  textAlign: TextAlign.center,
                  style: ToyTextStyles.hero(fontSize: 46),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    prefixText:
                        '${CurrencyFormatter.symbol(currency: currency)} ',
                    prefixStyle: ToyTextStyles.hero(fontSize: 46),
                    hintText: '0.00',
                    hintStyle: ToyTextStyles.hero(
                      fontSize: 46,
                      color: ToyColors.placeholder,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '柱 Pillar',
                  style: ToyTextStyles.label(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ToyColors.muted2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ToyPillarCapsuleGrid(
                children: [
                  for (final pillar in Pillar.values)
                    ToyPillarCapsule(
                      pillar: pillar,
                      label: '${pillar.japanese} ${pillar.label}',
                      labelFontSize: 12.5,
                      selected: _selectedPillar == pillar,
                      onTap: () => setState(() => _selectedPillar = pillar),
                    ),
                ],
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _FieldPill(
                      child: ToyDescriptionField(
                        controller: _descController,
                        findMatch: (prefix) => ref
                            .read(kakeiboMonthsProvider.notifier)
                            .findDescriptionMatch(prefix),
                        onMatchChanged: (match) =>
                            setState(() => _descriptionMatch = match),
                        onChanged: () => setState(() {}),
                      ),
                    ),
                  ),
                  const SizedBox(width: ToyMetrics.gridTileGap),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.tryParse(_date) ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(
                            () => _date =
                                '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
                          );
                        }
                      },
                      child: _FieldPill(
                        child: Text(
                          DateFormat('d MMM').format(DateTime.parse(_date)),
                          style: ToyTextStyles.rowTitle(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.topCenter,
                child: _descriptionMatch == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _DescriptionSuggestionRow(
                          match: _descriptionMatch!,
                          onAccept: () {
                            final match = _descriptionMatch!;
                            _descController.value = TextEditingValue(
                              text: match.description,
                              selection: TextSelection.collapsed(
                                offset: match.description.length,
                              ),
                            );
                            // Never overwrite a category the user already
                            // chose or typed themselves.
                            if (_categoryController.text.trim().isEmpty &&
                                match.category.isNotEmpty) {
                              _categoryController.text = match.category;
                            }
                            setState(() => _descriptionMatch = null);
                          },
                        ),
                      ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              _CategoryField(
                controller: _categoryController,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              _FieldPill(
                child: TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Notes (optional)',
                    hintStyle: ToyTextStyles.rowTitle(
                      fontSize: 13,
                      color: ToyColors.placeholder,
                    ),
                    isDense: true,
                  ),
                  style: ToyTextStyles.rowTitle(fontSize: 13),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              ToyPrimaryButton(
                label: isEditing
                    ? 'へんこう ・ Update expense'
                    : 'いれる ・ Save expense',
                onTap: _canSave
                    ? () async {
                        final amount =
                            double.tryParse(_amountController.text) ?? 0;
                        final category = _categoryController.text.trim();
                        final notifier =
                            ref.read(kakeiboMonthsProvider.notifier);
                        if (category.isNotEmpty) {
                          await notifier
                              .addExpenseCategorySuggestion(category);
                        }
                        if (isEditing) {
                          await notifier.updateExpense(
                            _editing!.copyWith(
                              description: _descController.text.trim(),
                              amount: amount,
                              pillar: _selectedPillar!,
                              date: _date,
                              notes: _notesController.text.trim(),
                              category: category,
                            ),
                          );
                        } else {
                          await notifier.addExpense(
                            monthId: monthId,
                            date: _date,
                            description: _descController.text.trim(),
                            amount: amount,
                            pillarName: _selectedPillar!.name,
                            notes: _notesController.text.trim(),
                            category: category,
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
                  style: ToyTextStyles.label(
                    fontSize: 11.5,
                    color: ToyColors.danger,
                  ),
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
                              foregroundColor: ToyColors.danger,
                            ),
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
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: ToyColors.danger,
                  ),
                  label: Text(
                    'Delete Expense',
                    style: ToyTextStyles.rowTitle(color: ToyColors.danger),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Optional Category field, its own line between Description and Notes.
/// Purely free-text -- typing a name that isn't an existing suggestion is
/// fine and just adds a new one on save. Chips below the field are tappable
/// shortcuts into the same controller, not a constraint on what can be
/// typed.
class _CategoryField extends ConsumerWidget {
  const _CategoryField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(expenseCategorySuggestionsProvider);
    final suggestions = suggestionsAsync.valueOrNull ?? const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldPill(
          child: TextField(
            controller: controller,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Category (optional)',
              hintStyle: ToyTextStyles.rowTitle(
                fontSize: 13,
                color: ToyColors.placeholder,
              ),
              isDense: true,
            ),
            style: ToyTextStyles.rowTitle(fontSize: 13),
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          // Wraps onto as many lines as needed -- a horizontally scrolling
          // single line (the original approach) had no visual hint that
          // more categories existed once there were enough to overflow the
          // screen width, so a later chip could sit off-screen with no
          // affordance to reach it.
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final cat in suggestions)
                ToyCapsuleButton(
                  label: cat,
                  fillColor: controller.text.trim() == cat ? ToyColors.brand : ToyColors.bg,
                  shadowColor:
                      controller.text.trim() == cat ? ToyColors.brand : ToyColors.divider,
                  textColor: controller.text.trim() == cat ? Colors.white : ToyColors.ink,
                  onTap: () {
                    controller.text = controller.text.trim() == cat ? '' : cat;
                    onChanged();
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// The description-autocomplete suggestion, shown as a compact full-width
/// row below the Description/Date fields once a real match is current --
/// e.g. "↳ Tesco · Groceries [Use]". A real in-flow widget (not an
/// overlay), so it can't be clipped by the keyboard or a route transition,
/// and it's a genuine tap target rather than a font-matched illusion.
class _DescriptionSuggestionRow extends StatelessWidget {
  const _DescriptionSuggestionRow({required this.match, required this.onAccept});

  final DescriptionMatch match;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final label = match.category.isEmpty
        ? match.description
        : '${match.description} · ${match.category}';
    return Semantics(
      button: true,
      label: 'Use $label',
      child: Material(
        color: ToyColors.bg,
        borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
        child: InkWell(
          onTap: onAccept,
          borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Text('↳ ', style: ToyTextStyles.label(fontSize: 13, color: ToyColors.muted2)),
                Expanded(
                  child: Text(
                    label,
                    style: ToyTextStyles.rowTitle(fontSize: 12.5, color: ToyColors.muted),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(
                  'Use',
                  style: ToyTextStyles.label(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ToyColors.brand,
                  ),
                ),
              ],
            ),
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
