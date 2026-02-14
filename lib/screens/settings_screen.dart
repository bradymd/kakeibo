import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currency =
        settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    return KakeiboScaffold(
      title: 'Settings and Tools',
      showHomeButton: true,
      centerTitle: true,
      onBack: () => context.go('/'),
      body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Currency picker
              Text('Currency', style: AppTextStyles.subheading),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: currency,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Text(
                      CurrencyFormatter.symbol(currency: currency),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.hotPink,
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                ),
                items: CurrencyFormatter.supportedCurrencies.map((entry) {
                  final (code, name, symbol) = entry;
                  return DropdownMenuItem(
                    value: code,
                    child: Text('$symbol  $code – $name'),
                  );
                }).toList(),
                onChanged: (code) {
                  if (code != null) {
                    ref.read(settingsProvider.notifier).setCurrency(code);
                  }
                },
              ),

              const SizedBox(height: 24),

              // Tools
              Text('Tools', style: AppTextStyles.subheading),
              const SizedBox(height: 4),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.search_rounded,
                    color: AppColors.hotPink, size: 20),
                title: Text('Search', style: AppTextStyles.bodyBold),
                subtitle: Text('Find expenses, fixed costs and income',
                    style: AppTextStyles.caption),
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.textMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => context.push('/search'),
              ),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.edit_rounded,
                    color: AppColors.vividPurple, size: 20),
                title: Text('Rename Categories', style: AppTextStyles.bodyBold),
                subtitle: Text('Bulk-rename fixed cost categories',
                    style: AppTextStyles.caption),
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.textMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => context.push('/rename-categories'),
              ),

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
                    Text('家計簿 Kakeibo',
                        style: AppTextStyles.japaneseLarge),
                    const SizedBox(height: 4),
                    Text(
                      'The Japanese art of mindful budgeting',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final info = snapshot.data;
                        final version = info != null
                            ? 'Version ${info.version} (${info.buildNumber})'
                            : '';
                        return Text(
                          version,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
