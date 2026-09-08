import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constants/fixed_expense_categories.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-restyled Rename Categories tool. Not part of the
/// handoff's 15-screen spec — it's a tool tucked under Settings, so
/// this follows the same design tokens rather than any specific README
/// section. Rename/merge logic reused verbatim from
/// `rename_categories_screen.dart`.
class ToyRenameCategoriesScreen extends ConsumerStatefulWidget {
  const ToyRenameCategoriesScreen({super.key});

  @override
  ConsumerState<ToyRenameCategoriesScreen> createState() => _ToyRenameCategoriesScreenState();
}

class _ToyRenameCategoriesScreenState extends ConsumerState<ToyRenameCategoriesScreen> {
  List<String>? _categories;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final notifier = ref.read(kakeiboMonthsProvider.notifier);
    final cats = await notifier.getAllFixedExpenseCategories();
    if (mounted) {
      setState(() {
        _categories = cats;
        _loading = false;
      });
    }
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
            const SizedBox(height: 16),
            Text('Or pick a default:', style: ToyTextStyles.label(fontSize: 11.5)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: defaultFixedExpenseCategories.map((cat) {
                return ToyCapsuleButton(
                  label: cat,
                  fillColor: ToyColors.bg,
                  shadowColor: ToyColors.divider,
                  textColor: ToyColors.ink,
                  onTap: () => Navigator.pop(ctx, cat),
                );
              }).toList(),
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

    final normalised = newName[0].toUpperCase() + newName.substring(1);
    await ref.read(kakeiboMonthsProvider.notifier).renameFixedExpenseCategory(oldName, normalised);
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final defaults = defaultFixedExpenseCategories.toSet();
    final allCats = _categories ?? [];
    final defaultCats = allCats.where((c) => defaults.contains(c)).toList();
    final customCats = allCats.where((c) => !defaults.contains(c)).toList();

    return ToyScaffold(
      title: '固定費カテゴリー Fixed Cost Categories',
      showBackButton: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: ToyColors.brand))
          : allCats.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No fixed cost categories yet.\nAdd some fixed costs first.',
                      style: ToyTextStyles.body(),
                      textAlign: TextAlign.center,
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
                          'Tap to rename across all months',
                          style: ToyTextStyles.label(fontSize: 11, color: ToyColors.muted2),
                        ),
                      ),
                      ToyCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < customCats.length; i++) ...[
                              if (i > 0) const DashedDivider(),
                              ToySettingsRow(
                                label: customCats[i],
                                leading: _labelIcon(active: true),
                                onTap: () => _showRenameDialog(customCats[i]),
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
                          'Built-in categories cannot be renamed',
                          style: ToyTextStyles.label(fontSize: 11, color: ToyColors.muted2),
                        ),
                      ),
                      ToyCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < defaultCats.length; i++) ...[
                              if (i > 0) const DashedDivider(),
                              ToySettingsRow(
                                label: defaultCats[i],
                                leading: _labelIcon(active: false),
                                showChevron: false,
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
