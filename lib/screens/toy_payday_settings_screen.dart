import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/payday_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/services/payday_calculator.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';

/// The gachapon-restyled Payday settings tool. Not part of the
/// handoff's 15-screen spec (it's a Settings sub-tool), so this follows
/// the shared design tokens. Preset logic reused verbatim from
/// `payday_settings_screen.dart`.
class ToyPaydaySettingsScreen extends ConsumerWidget {
  const ToyPaydaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(paydayPresetProvider);
    final monthId = ref.watch(currentMonthIdProvider);
    final (:year, :month) = MonthHelpers.parseMonthId(monthId);

    return ToyScaffold(
      title: '給料日 Payday',
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ToyMetrics.screenPaddingH,
          16,
          ToyMetrics.screenPaddingH,
          24,
        ),
        children: [
          Text('When do you get paid?', style: ToyTextStyles.cardTitle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'This adjusts the day counter on your dashboard to count from payday instead of the calendar month.',
            style: ToyTextStyles.body(),
          ),
          const SizedBox(height: 16),
          ToyCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < PaydayPreset.values.length; i++) ...[
                  if (i > 0) const DashedDivider(),
                  _PresetRow(
                    preset: PaydayPreset.values[i],
                    selected: PaydayPreset.values[i] == preset,
                    example: PaydayCalculator.presetExample(year, month, PaydayPreset.values[i]),
                    onTap: () => ref
                        .read(settingsProvider.notifier)
                        .setPaydayPreset(PaydayCalculator.presetToString(PaydayPreset.values[i])),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: ToyMetrics.cardGap),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ToyColors.amberBg,
              borderRadius: BorderRadius.circular(ToyMetrics.tileRadius),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: ToyColors.amberInk, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can override the date for a specific month in Start of Month.',
                    style: ToyTextStyles.label(fontSize: 11.5, color: ToyColors.amberInk),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.preset,
    required this.selected,
    required this.example,
    required this.onTap,
  });

  final PaydayPreset preset;
  final bool selected;
  final String? example;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? ToyColors.amberInk : ToyColors.divider,
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ToyColors.amberInk,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PaydayCalculator.presetLabel(preset),
                    style: ToyTextStyles.rowTitle(fontSize: 13.5),
                  ),
                  if (example != null)
                    Text(
                      'e.g. $example',
                      style: ToyTextStyles.label(fontSize: 11, color: ToyColors.muted2),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
