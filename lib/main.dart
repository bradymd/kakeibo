import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/app.dart';
import 'package:kakeibo/services/backup_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Fire-and-forget auto-backup on cold start
  BackupService.createAutoBackup().catchError((_) {});

  runApp(
    const ProviderScope(
      child: KakeiboApp(),
    ),
  );
}
