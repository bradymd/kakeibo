import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/providers/database_provider.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/models/import_type.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/import_duplicate_detector.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/services/toggle_deviation_set.dart';
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

  /// ids the user has explicitly toggled away from their *computed*
  /// default state. The default is: unchecked if the item looks like it
  /// already exists in the destination month (see
  /// ImportDuplicateDetector), checked otherwise. This is a set of
  /// deviations from that default, not a plain "is it checked" flag --
  /// re-checking a flagged duplicate is an explicit opt-in the user can
  /// make (Codex: don't force recategorisation/exclusion, just default
  /// away from the obvious repeat-copy trap), and it needs to be
  /// distinguishable from a duplicate-looking item nobody has touched.
  final Set<String> _toggled = {};

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
          final destinationMonth = allMonths.where((m) => m.id == currentMonthId).firstOrNull;

          // Items already present in the destination month, by the v1
          // identity in ImportDuplicateDetector -- default these
          // unchecked so re-running a copy doesn't silently duplicate
          // them, while still letting the user explicitly opt back in.
          final alreadyPresentIds = selectedMonth == null || destinationMonth == null
              ? const <String>{}
              : isFixedCosts
                  ? ImportDuplicateDetector.alreadyPresentFixedExpenseIds(
                      candidates: selectedMonth.fixedExpenses,
                      existingFixedExpenses: destinationMonth.fixedExpenses,
                    )
                  : ImportDuplicateDetector.alreadyPresentIncomeSourceIds(
                      candidates: selectedMonth.incomeSources,
                      existingIncomeSources: destinationMonth.incomeSources,
                    );

          final items = selectedMonth == null
              ? const <(String, String, double, bool)>[]
              : isFixedCosts
                  ? selectedMonth.fixedExpenses
                      .map((e) => (
                            e.id,
                            e.name.isNotEmpty ? '${e.category} · ${e.name}' : e.category,
                            e.amount,
                            alreadyPresentIds.contains(e.id),
                          ))
                      .toList()
                  : selectedMonth.incomeSources
                      .map((s) => (s.id, s.name, s.amount, alreadyPresentIds.contains(s.id)))
                      .toList();

          // Checked = default (unchecked if flagged as a duplicate, checked
          // otherwise) XOR whether the user has explicitly toggled it. See
          // ToggleDeviationSet's own doc comment for why this needs to be
          // relative to each item's default rather than a plain checked set.
          bool isChecked(String id, bool isDuplicate) => ToggleDeviationSet.isChecked(
                id: id,
                defaultChecked: !isDuplicate,
                toggled: _toggled,
              );

          final defaultCheckedItems =
              items.map((i) => (i.$1, !i.$4)).toList();

          final selectedItems =
              items.where((i) => isChecked(i.$1, i.$4)).toList();
          final selectedTotal = selectedItems.fold(0.0, (sum, i) => sum + i.$3);
          // Selected items that are also flagged duplicates -- i.e. the
          // user has explicitly overridden the "already added" default.
          // Surfaced on the button and gated behind a confirmation dialog
          // rather than left as a silent checkbox tap, per Codex's review.
          final selectedDuplicates = selectedItems.where((i) => i.$4).toList();

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
                          _toggled.clear();
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
                      final allChecked = ToggleDeviationSet.allChecked(
                        toggled: _toggled,
                        items: defaultCheckedItems,
                      );
                      _toggled
                        ..clear()
                        ..addAll(ToggleDeviationSet.applyBulkTarget(
                          targetChecked: !allChecked,
                          items: defaultCheckedItems,
                        ));
                    }),
                    child: Text(
                      ToggleDeviationSet.allChecked(toggled: _toggled, items: defaultCheckedItems)
                          ? 'Deselect all'
                          : 'Select all',
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
                        alreadyPresent: items[i].$4,
                        checked: isChecked(items[i].$1, items[i].$4),
                        onChanged: (checked) => setState(() {
                          if (checked == isChecked(items[i].$1, items[i].$4)) return;
                          if (_toggled.contains(items[i].$1)) {
                            _toggled.remove(items[i].$1);
                          } else {
                            _toggled.add(items[i].$1);
                          }
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              if (destinationMonth != null &&
                  (isFixedCosts
                      ? destinationMonth.fixedExpenses.isNotEmpty
                      : destinationMonth.incomeSources.isNotEmpty)) ...[
                const SizedBox(height: 10),
                Text(
                  'Selected items will be added. Your existing entries will stay.',
                  style: ToyTextStyles.label(fontSize: 11, color: ToyColors.muted2),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: ToyMetrics.cardGap),
              ToyPrimaryButton(
                label: selectedItems.isEmpty
                    ? 'Select items to copy'
                    : selectedDuplicates.isEmpty
                        ? 'Copy ${selectedItems.length} ${selectedItems.length == 1 ? 'item' : 'items'} ・ ${fmt(selectedTotal)}'
                        : 'Copy ${selectedItems.length} ${selectedItems.length == 1 ? 'item' : 'items'} ・ '
                            'includes ${selectedDuplicates.length} ${selectedDuplicates.length == 1 ? 'duplicate' : 'duplicates'}',
                onTap: selectedItems.isEmpty || selectedMonth == null
                    ? null
                    : () async {
                        // Re-read the destination from the database itself
                        // at submit time, not the build-time provider
                        // snapshot: ref.read(kakeiboMonthsProvider) only
                        // returns whatever Riverpod already has cached --
                        // during a seamless refresh that can still be the
                        // exact stale value we're trying not to trust, so
                        // it does not actually guarantee freshness. An
                        // earlier copy made from this same open screen (or
                        // elsewhere) must still be caught here even though
                        // it wouldn't force this provider to re-fetch.
                        final KakeiboMonth? freshDestination;
                        try {
                          freshDestination =
                              await ref.read(databaseProvider).getMonth(currentMonthId);
                        } catch (_) {
                          // Fail closed: if we can't confirm the current
                          // state, don't risk a silent duplicate copy.
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not verify existing entries. Try again.'),
                              ),
                            );
                          }
                          return;
                        }
                        if (!context.mounted) return;

                        final freshDuplicateIds = freshDestination == null
                            ? const <String>{}
                            : isFixedCosts
                                ? ImportDuplicateDetector.alreadyPresentFixedExpenseIds(
                                    candidates: selectedMonth.fixedExpenses,
                                    existingFixedExpenses: freshDestination.fixedExpenses,
                                  )
                                : ImportDuplicateDetector.alreadyPresentIncomeSourceIds(
                                    candidates: selectedMonth.incomeSources,
                                    existingIncomeSources: freshDestination.incomeSources,
                                  );

                        final aboutToDuplicate = isFixedCosts
                            ? selectedMonth.fixedExpenses
                                .where((e) =>
                                    isChecked(e.id, alreadyPresentIds.contains(e.id)) &&
                                    freshDuplicateIds.contains(e.id))
                                .map((e) => e.name.isNotEmpty ? e.name : e.category)
                                .toList()
                            : selectedMonth.incomeSources
                                .where((s) =>
                                    isChecked(s.id, alreadyPresentIds.contains(s.id)) &&
                                    freshDuplicateIds.contains(s.id))
                                .map((s) => s.name)
                                .toList();

                        if (aboutToDuplicate.isNotEmpty) {
                          final confirmed = await _confirmDuplicateCopy(context, aboutToDuplicate);
                          if (!confirmed) return;
                        }

                        final notifier = ref.read(kakeiboMonthsProvider.notifier);
                        if (isFixedCosts) {
                          for (final e in selectedMonth.fixedExpenses) {
                            if (!isChecked(e.id, alreadyPresentIds.contains(e.id))) continue;
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
                            if (!isChecked(s.id, alreadyPresentIds.contains(s.id))) continue;
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

/// Confirmation dialog shown when the user is about to copy one or more
/// items that (per a fresh re-check against the destination month, not
/// just the snapshot the screen built with) already exist there. Cancel is
/// the safe default -- per Codex's review, an additive operation that can
/// silently distort totals deserves a second, plain-language boundary
/// beyond just an unchecked-by-default checkbox.
Future<bool> _confirmDuplicateCopy(BuildContext context, List<String> names) async {
  const maxNamed = 3;
  final named = names.take(maxNamed).join(', ');
  final remaining = names.length - maxNamed;
  final body = names.length == 1
      ? '${names.first} already exists in this month. Copy it again?'
      : remaining > 0
          ? '$named and $remaining more already exist in this month. Copy them again?'
          : '$named already exist in this month. Copy them again?';

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Copy duplicates?'),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(foregroundColor: ToyColors.amberInk),
          child: const Text('Copy anyway'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
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
    required this.alreadyPresent,
    required this.onChanged,
  });

  final String title;
  final String amountText;
  final bool checked;

  /// Whether this item looks like it already exists in the destination
  /// month (see ImportDuplicateDetector). Rendered as a conspicuous amber
  /// badge, not a small muted caption -- per Codex's review, an 11px grey
  /// line of prose had already failed as a safety affordance once (an
  /// owner selected and copied a flagged duplicate without registering
  /// the warning). The checkbox still works normally; explicitly checking
  /// a flagged item is still allowed (Codex: don't hard-block a legitimate
  /// intentional duplicate), but the badge's label switches to make that
  /// consequence explicit rather than letting the row look ordinary.
  final bool alreadyPresent;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ToyTextStyles.rowTitle(
                      fontSize: 13.5,
                      color: checked ? ToyColors.ink : ToyColors.placeholder,
                    ),
                  ),
                  if (alreadyPresent) ...[
                    const SizedBox(height: 3),
                    _AlreadyPresentBadge(willAdd: checked),
                  ],
                ],
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

/// The visible warning shown on a row ImportDuplicateDetector has flagged.
/// `willAdd: false` (the default, unchecked state) reads "Already added";
/// `willAdd: true` (the user has explicitly re-checked it) switches to
/// "Will add duplicate" so the consequence of the override stays visible
/// rather than the row quietly reverting to looking like a normal item.
class _AlreadyPresentBadge extends StatelessWidget {
  const _AlreadyPresentBadge({required this.willAdd});

  final bool willAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ToyColors.amberBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            willAdd ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            size: 12,
            color: ToyColors.amberInk,
          ),
          const SizedBox(width: 4),
          Text(
            willAdd ? 'Will add duplicate' : 'Already added',
            style: ToyTextStyles.label(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: ToyColors.amberInk,
            ),
          ),
        ],
      ),
    );
  }
}
