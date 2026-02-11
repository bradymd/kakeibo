import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    return KakeiboScaffold(
      title: 'Settings',
      subtitle: 'Preferences',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Currency picker
          Text('Currency', style: AppTextStyles.subheading),
          const SizedBox(height: 8),
          ...CurrencyFormatter.supportedCurrencies.map((entry) {
            final (code, name, symbol) = entry;
            final isSelected = code == currency;
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.hotPink.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    symbol,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color:
                          isSelected ? AppColors.hotPink : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              title: Text(code, style: AppTextStyles.bodyBold),
              subtitle: Text(name, style: AppTextStyles.caption),
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppColors.hotPink)
                  : null,
              tileColor: isSelected
                  ? AppColors.hotPink.withValues(alpha: 0.05)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                ref.read(settingsProvider.notifier).setCurrency(code);
              },
            );
          }),

          const SizedBox(height: 24),

          // About
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softPink,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('家計簿 Kakeibo', style: AppTextStyles.japaneseLarge),
                const SizedBox(height: 4),
                Text(
                  'The Japanese art of mindful budgeting',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
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
