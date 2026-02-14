import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constants/fixed_expense_categories.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';

class RenameCategoriesScreen extends ConsumerStatefulWidget {
  const RenameCategoriesScreen({super.key});

  @override
  ConsumerState<RenameCategoriesScreen> createState() =>
      _RenameCategoriesScreenState();
}

class _RenameCategoriesScreenState
    extends ConsumerState<RenameCategoriesScreen> {
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
        title: const Text('Rename Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'New name',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: rename to an existing category to merge them',
              style: AppTextStyles.caption.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Text('Or pick a default:', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: defaultFixedExpenseCategories.map((cat) {
                return ActionChip(
                  label: Text(cat, style: const TextStyle(fontSize: 12)),
                  onPressed: () => Navigator.pop(ctx, cat),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == oldName) return;

    final normalised = newName[0].toUpperCase() + newName.substring(1);
    await ref
        .read(kakeiboMonthsProvider.notifier)
        .renameFixedExpenseCategory(oldName, normalised);
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final defaults = defaultFixedExpenseCategories.toSet();
    final allCats = _categories ?? [];
    final defaultCats = allCats.where((c) => defaults.contains(c)).toList();
    final customCats = allCats.where((c) => !defaults.contains(c)).toList();

    return KakeiboScaffold(
      title: 'Fixed Cost Categories',
      showHomeButton: true,
      centerTitle: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : allCats.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No fixed cost categories yet.\nAdd some fixed costs first.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (customCats.isNotEmpty) ...[
                      Text('Custom Categories', style: AppTextStyles.subheading),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to rename across all months',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 12),
                      ...customCats.map((cat) => ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.vividPurple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.label_rounded,
                                  color: AppColors.vividPurple, size: 20),
                            ),
                            title: Text(cat, style: AppTextStyles.bodyBold),
                            trailing: const Icon(Icons.edit_rounded,
                                size: 18, color: AppColors.textMuted),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onTap: () => _showRenameDialog(cat),
                          )),
                      const SizedBox(height: 24),
                    ],
                    if (defaultCats.isNotEmpty) ...[
                      Text('Default Categories',
                          style: AppTextStyles.subheading),
                      const SizedBox(height: 4),
                      Text(
                        'Built-in categories cannot be renamed',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 12),
                      ...defaultCats.map((cat) => ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.label_rounded,
                                  color: AppColors.textMuted, size: 20),
                            ),
                            title: Text(cat,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.textMuted,
                                )),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          )),
                    ],
                  ],
                ),
    );
  }
}
