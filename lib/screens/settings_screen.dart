import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/providers/database_provider.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/backup_service.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/theme/app_text_styles.dart';
import 'package:kakeibo/widgets/kakeibo_scaffold.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final db = ref.read(databaseProvider);
      await db.close();

      final zipPath = await BackupService.createBackup();

      ref.invalidate(databaseProvider);

      final isMobile = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
      if (isMobile) {
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 100, 100);
        await Share.shareXFiles([XFile(zipPath)],
            sharePositionOrigin: origin);
      } else {
        // Desktop: copy to Downloads
        final downloads = await getDownloadsDirectory();
        if (downloads != null) {
          final dest =
              p.join(downloads.path, p.basename(zipPath));
          await File(zipPath).copy(dest);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Backup saved to $dest')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreFromFile(String zipPath) async {
    setState(() => _isRestoring = true);
    try {
      final db = ref.read(databaseProvider);
      await db.close();

      final success = await BackupService.restoreFromBackup(zipPath);

      ref.invalidate(databaseProvider);
      ref.invalidate(kakeiboMonthsProvider);
      ref.invalidate(settingsProvider);

      if (mounted) {
        if (success) {
          context.go('/');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup restored successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Invalid backup file — ZIP must contain kakeibo.sqlite')),
          );
        }
      }
    } catch (e) {
      ref.invalidate(databaseProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _pickAndRestore() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
            'This will replace all current data with the backup. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _restoreFromFile(path);
  }

  Future<void> _restoreAutoBackup() async {
    final path = await BackupService.getAutoBackupPath();
    if (path == null) return;

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Auto-Backup?'),
        content: const Text(
            'This will replace all current data with the last auto-backup. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _restoreFromFile(path);
  }

  @override
  Widget build(BuildContext context) {
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

              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: const Icon(Icons.favorite_rounded,
                    color: AppColors.hotPink, size: 20),
                title: Text('Support', style: AppTextStyles.bodyBold),
                subtitle: Text('Help support Kakeibo development',
                    style: AppTextStyles.caption),
                trailing: const Icon(Icons.open_in_new_rounded,
                    size: 18, color: AppColors.textMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => launchUrl(
                  Uri.parse('https://bradymd.github.io/kakeibo/'),
                  mode: LaunchMode.externalApplication,
                ),
              ),

              const SizedBox(height: 24),

              // Backup & Restore
              Text('Backup & Restore', style: AppTextStyles.subheading),
              const SizedBox(height: 8),

              // Auto-backup info card
              FutureBuilder<AutoBackupInfo?>(
                future: BackupService.getAutoBackupInfo(),
                builder: (context, snapshot) {
                  final info = snapshot.data;
                  if (info == null) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.softBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.backup_rounded,
                            color: AppColors.vividPurple, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Auto-Backup',
                                  style: AppTextStyles.bodyBold),
                              Text(
                                _formatTimestamp(info.timestamp),
                                style: AppTextStyles.caption,
                              ),
                              Text(
                                _formatSize(info.sizeBytes),
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _isRestoring ? null : _restoreAutoBackup,
                          child: const Text('Restore'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: _isBackingUp
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded,
                        color: AppColors.success, size: 20),
                title: Text('Create Backup', style: AppTextStyles.bodyBold),
                subtitle: Text('Save a backup of all your data',
                    style: AppTextStyles.caption),
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.textMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: _isBackingUp ? null : _createBackup,
              ),

              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: _isRestoring
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.restore_rounded,
                        color: AppColors.warning, size: 20),
                title:
                    Text('Restore from File', style: AppTextStyles.bodyBold),
                subtitle: Text('Restore data from a backup ZIP file',
                    style: AppTextStyles.caption),
                trailing: const Icon(Icons.chevron_right_rounded,
                    size: 18, color: AppColors.textMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: _isRestoring ? null : _pickAndRestore,
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

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
