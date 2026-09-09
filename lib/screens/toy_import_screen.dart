import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/models/import_type.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-redesign Import screen (README §4i). Import logic
/// reused verbatim from `import_screen.dart`, with one change the
/// README specifically calls for: per-item opt-out via checkboxes,
/// where the current flow imports everything from the chosen month.
class ToyImportScreen extends ConsumerStatefulWidget {
  const ToyImportScreen({super.key, required this.importType});

  final ImportType importType;

  @override
  ConsumerState<ToyImportScreen> createState() => _ToyImportScreenState();
}

class _ToyImportScreenState extends ConsumerState<ToyImportScreen> {
  String? _selectedMonthId;

  /// ids of items the user has deselected (checkbox unchecked). Empty
  /// means "everything selected", matching the default select-all state.
  final Set<String> _deselected = {};

  @override
  Widget build(BuildContext context) {
    final currentMonthId = ref.watch(currentMonthIdProvider);
    final allMonthsAsync = ref.watch(kakeiboMonthsProvider);
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    final isFixedCosts = widget.importType == ImportType.fixedCosts;
    final title = isFixedCosts ? '固定費をコピー Import Fixed Costs' : '収入をコピー Import Income';

    String fmt(double amount) => CurrencyFormatter.format(amount, currency: currency);

    return ToyScaffold(
      title: title,
      showBackButton: true,
      body: allMonthsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: ToyColors.brand)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allMonths) {
          final candidates = allMonths.where((m) {
            if (m.id == currentMonthId) return false;
            return isFixedCosts ? m.fixedExpenses.isNotEmpty : m.incomeSources.isNotEmpty;
          }).toList()
            ..sort((a, b) {
              final cmp = b.year.compareTo(a.year);
              return cmp != 0 ? cmp : b.month.compareTo(a.month);
            });

          if (candidates.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  isFixedCosts
                      ? 'No other months with fixed costs to import from.'
                      : 'No other months with income sources to import from.',
                  style: ToyTextStyles.body(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          _selectedMonthId ??= candidates.first.id;
          final selectedMonth = candidates.where((m) => m.id == _selectedMonthId).firstOrNull;

          final items = selectedMonth == null
              ? const <(String, String, double)>[]
              : isFixedCosts
                  ? selectedMonth.fixedExpenses
                      .map((e) => (e.id, e.name.isNotEmpty ? '${e.category} · ${e.name}' : e.category, e.amount))
                      .toList()
                  : selectedMonth.incomeSources.map((s) => (s.id, s.name, s.amount)).toList();

          final selectedItems = items.where((i) => !_deselected.contains(i.$1)).toList();
          final selectedTotal = selectedItems.fold(0.0, (sum, i) => sum + i.$3);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              ToyMetrics.screenPaddingH,
              16,
              ToyMetrics.screenPaddingH,
              24,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'コピー元 COPY FROM',
                  style: ToyTextStyles.microLabel(fontSize: 11, color: ToyColors.muted2),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final month in candidates) ...[
                      _MonthCard(
                        month: month,
                        selected: month.id == _selectedMonthId,
                        isFixedCosts: isFixedCosts,
                        formatAmount: fmt,
                        onTap: () => setState(() {
                          _selectedMonthId = month.id;
                          _deselected.clear();
                        }),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'コピーする項目 ITEMS TO COPY',
                    style: ToyTextStyles.microLabel(fontSize: 11, color: ToyColors.muted2),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _deselected.isEmpty
                          ? _deselected.addAll(items.map((i) => i.$1))
                          : _deselected.clear();
                    }),
                    child: Text(
                      _deselected.isEmpty ? 'Deselect all' : 'Select all',
                      style: ToyTextStyles.label(fontSize: 11.5, fontWeight: FontWeight.w800, color: ToyColors.brand),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ToyCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0) const DashedDivider(),
                      _ItemRow(
                        title: items[i].$2,
                        amountText: fmt(items[i].$3),
                        checked: !_deselected.contains(items[i].$1),
                        onChanged: (checked) => setState(() {
                          if (checked) {
                            _deselected.remove(items[i].$1);
                          } else {
                            _deselected.add(items[i].$1);
                          }
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: ToyMetrics.cardGap),
              ToyPrimaryButton(
                label: selectedItems.isEmpty
                    ? 'Select items to copy'
                    : 'Copy ${selectedItems.length} ${selectedItems.length == 1 ? 'item' : 'items'} ・ ${fmt(selectedTotal)}',
                onTap: selectedItems.isEmpty || selectedMonth == null
                    ? null
                    : () async {
                        final notifier = ref.read(kakeiboMonthsProvider.notifier);
                        if (isFixedCosts) {
                          for (final e in selectedMonth.fixedExpenses) {
                            if (_deselected.contains(e.id)) continue;
                            await notifier.addFixedExpense(
                              monthId: currentMonthId,
                              name: e.name,
                              amount: e.amount,
                              category: e.category,
                              dueDay: e.dueDay,
                            );
                          }
                        } else {
                          for (final s in selectedMonth.incomeSources) {
                            if (_deselected.contains(s.id)) continue;
                            await notifier.addIncomeSource(
                              monthId: currentMonthId,
                              name: s.name,
                              amount: s.amount,
                            );
                          }
                        }
                        if (context.mounted) context.pop();
                      },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.selected,
    required this.isFixedCosts,
    required this.formatAmount,
    required this.onTap,
  });

  final KakeiboMonth month;
  final bool selected;
  final bool isFixedCosts;
  final String Function(double) formatAmount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = isFixedCosts ? month.fixedExpenses.length : month.incomeSources.length;
    final total = isFixedCosts
        ? month.fixedExpenses.fold(0.0, (sum, e) => sum + e.amount)
        : month.incomeSources.fold(0.0, (sum, s) => sum + s.amount);
    final label = MonthHelpers.formatMonthDisplay(month.year, month.month);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ToyColors.card,
          borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
          border: selected ? Border.all(color: ToyColors.brand, width: 3) : null,
          boxShadow: ToyShadows.small(color: ToyColors.divider, offset: 3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: ToyTextStyles.rowTitle(fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: ToyTextStyles.label(fontSize: 11, color: ToyColors.muted2),
            ),
            Text(formatAmount(total), style: ToyTextStyles.rowAmount(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.title,
    required this.amountText,
    required this.checked,
    required this.onChanged,
  });

  final String title;
  final String amountText;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: checked ? ToyPillarColors.needsFill : const Color(0xFFF1E3E8),
                borderRadius: BorderRadius.circular(ToyMetrics.checkboxRadius),
              ),
              child: checked
                  ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFF08301F))
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: ToyTextStyles.rowTitle(
                  fontSize: 13.5,
                  color: checked ? ToyColors.ink : ToyColors.placeholder,
                ),
              ),
            ),
            Text(
              amountText,
              style: ToyTextStyles.rowAmount(
                fontSize: 14,
                color: checked ? ToyColors.ink : ToyColors.placeholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
