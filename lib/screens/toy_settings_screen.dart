import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakeibo/providers/database_provider.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/payday_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/backup_service.dart';
import 'package:kakeibo/services/currency_formatter.dart';
import 'package:kakeibo/services/payday_calculator.dart';
import 'package:kakeibo/theme/toy/toy_theme.dart';
import 'package:kakeibo/widgets/toy/toy_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// The gachapon-redesign Settings and tools screen (README §4g). All
/// backup/restore/currency/payday logic reused verbatim from
/// `settings_screen.dart` — only the presentation changes.
class ToySettingsScreen extends ConsumerStatefulWidget {
  const ToySettingsScreen({super.key});

  @override
  ConsumerState<ToySettingsScreen> createState() => _ToySettingsScreenState();
}

class _ToySettingsScreenState extends ConsumerState<ToySettingsScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);
    var dbClosed = false;
    try {
      final db = ref.read(databaseProvider);
      await db.close();
      dbClosed = true;

      final zipPath = await BackupService.createBackup();

      final isMobile = !kIsWeb && (Platform.isIOS || Platform.isAndroid);
      if (isMobile) {
        final box = context.findRenderObject() as RenderBox?;
        final origin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 100, 100);
        await Share.shareXFiles([XFile(zipPath)], sharePositionOrigin: origin);
      } else {
        final downloads = await getDownloadsDirectory();
        if (downloads != null) {
          final dest = p.join(downloads.path, p.basename(zipPath));
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
      // Always reopen the database, whether or not the backup itself
      // succeeded — otherwise a failure after close() (e.g. the ZIP
      // encode step throwing) leaves the provider serving a closed
      // connection until the user happens to hit another provider
      // invalidation elsewhere.
      if (dbClosed) ref.invalidate(databaseProvider);
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreFromFile(String zipPath) async {
    setState(() => _isRestoring = true);
    try {
      final db = ref.read(databaseProvider);
      await db.close();

      final result = await BackupService.restoreFromBackup(zipPath);

      // The database file on disk only changed on success — reopening
      // the connection on every outcome is still correct and safe
      // either way, since it just points the provider at whatever file
      // is actually there now.
      ref.invalidate(databaseProvider);
      ref.invalidate(kakeiboMonthsProvider);
      ref.invalidate(settingsProvider);

      if (mounted) {
        if (result == RestoreResult.success) {
          context.go('/');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup restored successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_restoreFailureMessage(result))),
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
        content: const Text('This will replace all current data with the backup. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: ToyColors.danger),
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
        content: const Text('This will replace all current data with the last auto-backup. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: ToyColors.danger),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _restoreFromFile(path);
  }

  Future<void> _pickCurrency() async {
    final currency = ref.read(settingsProvider).whenOrNull(data: (s) => s.currency) ?? 'GBP';
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: ToyColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: CurrencyFormatter.supportedCurrencies.map((entry) {
            final (code, name, symbol) = entry;
            return ListTile(
              title: Text('$symbol  $code — $name', style: ToyTextStyles.rowTitle(fontSize: 14)),
              trailing: code == currency ? const Icon(Icons.check_rounded, color: ToyColors.brand) : null,
              onTap: () => Navigator.pop(ctx, code),
            );
          }).toList(),
        ),
      ),
    );
    if (selected != null) {
      ref.read(settingsProvider.notifier).setCurrency(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final currency = settings.whenOrNull(data: (s) => s.currency) ?? 'GBP';

    return ToyScaffold(
      title: '設定 Settings and Tools',
      showBackButton: true,
      trailing: const ToyMenuButton(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ToyMetrics.screenPaddingH,
          16,
          ToyMetrics.screenPaddingH,
          24,
        ),
        children: [
          const ToySettingsGroupHeading('月 MONTH'),
          ToyCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ToySettingsRow(
                  label: 'Currency',
                  value: '${CurrencyFormatter.symbol(currency: currency)} $currency',
                  onTap: _pickCurrency,
                ),
                const DashedDivider(),
                ToySettingsRow(
                  label: 'Payday',
                  value: PaydayCalculator.presetLabel(ref.watch(paydayPresetProvider)),
                  onTap: () => context.push('/payday-settings'),
                ),
                const DashedDivider(),
                ToySettingsRow(
                  label: 'Rename categories',
                  value: '4 pillars',
                  onTap: () => context.push('/rename-categories'),
                ),
              ],
            ),
          ),
          const SizedBox(height: ToyMetrics.cardGap),
          const ToySettingsGroupHeading('データ DATA'),
          ToyCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                FutureBuilder<AutoBackupInfo?>(
                  future: BackupService.getAutoBackupInfo(),
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    if (info == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        ToySettingsRow(
                          label: 'Auto backup',
                          value: '${_formatTimestamp(info.timestamp)} ・ ${_formatSize(info.sizeBytes)}',
                          showChevron: false,
                          onTap: _isRestoring ? null : _restoreAutoBackup,
                        ),
                        const DashedDivider(),
                      ],
                    );
                  },
                ),
                ToySettingsRow(
                  label: _isBackingUp ? 'Backing up…' : 'Back up now',
                  onTap: _isBackingUp ? null : _createBackup,
                ),
                const DashedDivider(),
                ToySettingsRow(
                  label: _isRestoring ? 'Restoring…' : 'Restore from file',
                  onTap: _isRestoring ? null : _pickAndRestore,
                ),
                const DashedDivider(),
                ToySettingsRow(
                  label: 'Import fixed costs',
                  value: 'From a past month',
                  onTap: () => context.push('/import-fixed-costs'),
                ),
                const DashedDivider(),
                ToySettingsRow(
                  label: 'Search',
                  value: 'Find anything',
                  onTap: () => context.push('/search'),
                ),
              ],
            ),
          ),
          const SizedBox(height: ToyMetrics.cardGap),
          const ToySettingsGroupHeading('アプリ APP'),
          ToyCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ToySettingsRow(
                  label: 'About Kakeibo',
                  onTap: () => context.push('/about'),
                ),
                const DashedDivider(),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final info = snapshot.data;
                    return ToySettingsRow(
                      label: 'Version',
                      value: info != null ? '${info.version} (${info.buildNumber})' : '',
                      showChevron: false,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: ToyMetrics.cardGap),
          Text(
            'Kakeibo stores all data locally on your device. No accounts, no cloud sync, no tracking.',
            style: ToyTextStyles.label(fontSize: 11, color: ToyColors.muted2),
            textAlign: TextAlign.center,
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

  String _restoreFailureMessage(RestoreResult result) {
    return switch (result) {
      RestoreResult.success => '', // unreachable — caller only uses this for failures
      RestoreResult.zipMissingDatabase =>
        'Invalid backup file — ZIP must contain kakeibo.sqlite',
      RestoreResult.corruptDatabase =>
        'This backup file is corrupted and cannot be restored',
      RestoreResult.unexpectedSchema =>
        'This file doesn\'t look like a Kakeibo backup',
      RestoreResult.ioError => 'Could not read this backup file',
    };
  }
}
