import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constants/expense_categories.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// Manage Spend categories: add, rename, delete. Unlike Rename Categories
/// (Fixed Costs), defaults here are NOT locked -- Groceries/Dining/etc. can
/// be renamed or deleted the same as anything the user typed themselves,
/// since they're real rows in ExpenseCategorySuggestions, not a hardcoded
/// list unioned in at display time.
///
/// "Delete" hides the suggestion (see database_provider.dart) -- it never
/// touches historical expenses unless the user explicitly opts into that
/// in the confirmation dialog.
class ToyManageExpenseCategoriesScreen extends ConsumerStatefulWidget {
  const ToyManageExpenseCategoriesScreen({super.key});

  @override
  ConsumerState<ToyManageExpenseCategoriesScreen> createState() =>
      _ToyManageExpenseCategoriesScreenState();
}

class _ToyManageExpenseCategoriesScreenState
    extends ConsumerState<ToyManageExpenseCategoriesScreen> {
  List<String>? _categories;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final notifier = ref.read(kakeiboMonthsProvider.notifier);
    final cats = await notifier.getExpenseCategorySuggestions();
    if (mounted) {
      setState(() {
        _categories = cats;
        _loading = false;
      });
    }
  }

  Future<void> _showAddDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
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
          decoration: const InputDecoration(hintText: 'e.g. Pets, Hobbies'),
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
    if (name == null || name.isEmpty) return;
    await ref.read(kakeiboMonthsProvider.notifier).addExpenseCategorySuggestion(name);
    await _load();
  }

  Future<void> _showRenameDialog(String oldName) async {
    final controller = TextEditingController(text: oldName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ToyColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Rename Category', style: ToyTextStyles.cardTitle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style: ToyTextStyles.rowTitle(fontSize: 14),
              decoration: const InputDecoration(labelText: 'New name'),
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: rename to an existing category to merge them',
              style: ToyTextStyles.label(fontSize: 11, color: ToyColors.muted2),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == oldName) return;

    final alsoUpdateHistorical = await _confirmHistoricalUpdate(
      title: 'Update past expenses too?',
      message:
          'Rename "$oldName" to "$newName" for future use only, or also update '
          'every past expense currently labelled "$oldName"?',
      futureOnlyLabel: 'Future only',
      alsoLabel: 'Also update past expenses',
    );
    if (alsoUpdateHistorical == null) return; // dialog dismissed, abort

    await ref.read(kakeiboMonthsProvider.notifier).renameExpenseCategorySuggestion(
          oldName,
          newName,
          alsoUpdateHistoricalExpenses: alsoUpdateHistorical,
        );
    await _load();
  }

  Future<void> _showDeleteDialog(String name) async {
    final alsoClearHistorical = await _confirmHistoricalUpdate(
      title: 'Delete "$name"?',
      message:
          'This stops "$name" being offered as a suggestion. Past expenses '
          'already labelled "$name" keep that label unless you clear it below.',
      futureOnlyLabel: 'Just remove suggestion',
      alsoLabel: 'Also clear from past expenses',
    );
    if (alsoClearHistorical == null) return;

    await ref.read(kakeiboMonthsProvider.notifier).hideExpenseCategorySuggestion(
          name,
          alsoClearHistoricalExpenses: alsoClearHistorical,
        );
    await _load();
  }

  /// Shared yes/no-with-a-twist dialog for rename/delete: returns true if
  /// the user wants historical expenses touched too, false if future-only,
  /// null if they backed out entirely (Cancel or dismissed).
  Future<bool?> _confirmHistoricalUpdate({
    required String title,
    required String message,
    required String futureOnlyLabel,
    required String alsoLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ToyColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(title, style: ToyTextStyles.cardTitle(fontSize: 16)),
        content: Text(message, style: ToyTextStyles.body()),
        actionsOverflowDirection: VerticalDirection.down,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(futureOnlyLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: ToyColors.danger),
            child: Text(alsoLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaults = defaultExpenseCategories.toSet();
    final allCats = _categories ?? [];
    final defaultCats = allCats.where((c) => defaults.contains(c)).toList();
    final customCats = allCats.where((c) => !defaults.contains(c)).toList();

    return ToyScaffold(
      title: '支出カテゴリー Spend Categories',
      showBackButton: true,
      trailing: IconButton(
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        onPressed: _showAddDialog,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: ToyColors.brand))
          : allCats.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No spend categories yet.',
                          style: ToyTextStyles.body(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ToyPrimaryButton(label: '+ Add a category', onTap: _showAddDialog),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    ToyMetrics.screenPaddingH,
                    16,
                    ToyMetrics.screenPaddingH,
                    24,
                  ),
                  children: [
                    if (customCats.isNotEmpty) ...[
                      const ToySettingsGroupHeading('カスタム CUSTOM'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                        child: Text(
                          'Tap to rename, swipe to delete',
                          style: ToyTextStyles.label(fontSize: 11, color: ToyColors.muted2),
                        ),
                      ),
                      ToyCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < customCats.length; i++) ...[
                              if (i > 0) const DashedDivider(),
                              Dismissible(
                                key: Key(customCats[i]),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: ToyColors.danger,
                                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                                ),
                                confirmDismiss: (_) async {
                                  await _showDeleteDialog(customCats[i]);
                                  return false; // _load() already refreshes the list
                                },
                                child: ToySettingsRow(
                                  label: customCats[i],
                                  leading: _labelIcon(active: true),
                                  onTap: () => _showRenameDialog(customCats[i]),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: ToyMetrics.cardGap),
                    ],
                    if (defaultCats.isNotEmpty) ...[
                      const ToySettingsGroupHeading('デフォルト DEFAULT'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                        child: Text(
                          'Tap to rename, swipe to delete',
                          style: ToyTextStyles.label(fontSize: 11, color: ToyColors.muted2),
                        ),
                      ),
                      ToyCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < defaultCats.length; i++) ...[
                              if (i > 0) const DashedDivider(),
                              Dismissible(
                                key: Key(defaultCats[i]),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: ToyColors.danger,
                                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                                ),
                                confirmDismiss: (_) async {
                                  await _showDeleteDialog(defaultCats[i]);
                                  return false;
                                },
                                child: ToySettingsRow(
                                  label: defaultCats[i],
                                  leading: _labelIcon(active: false),
                                  onTap: () => _showRenameDialog(defaultCats[i]),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _labelIcon({required bool active}) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? ToyColors.brand.withValues(alpha: 0.12) : const Color(0xFFF1E3E8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.label_rounded,
        size: 16,
        color: active ? ToyColors.brand : ToyColors.placeholder,
      ),
    );
  }
}
