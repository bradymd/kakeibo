import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/payday_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/services/payday_calculator.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';

class PaydaySettingsScreen extends ConsumerWidget {
  const PaydaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(paydayPresetProvider);
    final monthId = ref.watch(currentMonthIdProvider);
    final (:year, :month) = MonthHelpers.parseMonthId(monthId);

    return KakeiboScaffold(
      title: 'Payday',
      showBackButton: true,
      centerTitle: true,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'When do you get paid?',
            style: AppTextStyles.subheading,
          ),
          const SizedBox(height: 4),
          Text(
            'This adjusts the day counter on your dashboard to count from payday instead of the calendar month.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),
          ...PaydayPreset.values.map((p) {
            final example =
                PaydayCalculator.presetExample(year, month, p);
            return RadioListTile<PaydayPreset>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                PaydayCalculator.presetLabel(p),
                style: AppTextStyles.bodyBold,
              ),
              subtitle: example != null
                  ? Text('e.g. $example', style: AppTextStyles.caption)
                  : null,
              value: p,
              groupValue: preset,
              activeColor: AppColors.paydayAmber,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .setPaydayPreset(PaydayCalculator.presetToString(value));
                }
              },
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.paydayAmber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.paydayAmber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can override the date for a specific month in Start of Month.',
                    style: AppTextStyles.caption,
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
