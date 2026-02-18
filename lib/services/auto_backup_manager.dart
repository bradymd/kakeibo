import 'package:flutter/widgets.dart';
import 'package:kakeibo/database/database_provider.dart';
import 'package:kakeibo/services/backup_service.dart';

/// Manages automatic daily backups while the app is open.
/// Runs on init and when the app resumes from background.
class AutoBackupManager with WidgetsBindingObserver {
  AutoBackupManager(this._db);

  final AppDatabase _db;
  static const _settingKey = 'last_auto_backup';
  static const _intervalMs = 24 * 60 * 60 * 1000; // 24 hours

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _runIfNeeded();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runIfNeeded();
    }
  }

  void _runIfNeeded() async {
    try {
      final lastStr = await _db.getSetting(_settingKey);
      final lastMs = lastStr != null ? int.tryParse(lastStr) ?? 0 : 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastMs < _intervalMs) return;

      await BackupService.createAutoBackup();
      await _db.setSetting(_settingKey, now.toString());
    } catch (_) {
      // Fire-and-forget — suppress errors
    }
  }
}
