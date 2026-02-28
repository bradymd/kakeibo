import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/app.dart';
import 'package:kakeibo/database/database_provider.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/services/backup_service.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/services/payday_calculator.dart';

Future<String> _resolveInitialMonth() async {
  final calendarId = MonthHelpers.getCurrentMonthId();
  final nextId = MonthHelpers.getNextMonthId(calendarId);
  final db = AppDatabase();
  try {
    // If next month already has data, go there
    if (await db.monthHasData(nextId)) return nextId;

    // If payday is set and today >= this month's payday, go to next month
    final presetStr = await db.getSetting('paydayPreset') ?? 'none';
    final preset = PaydayCalculator.parsePreset(presetStr);
    if (preset != PaydayPreset.none) {
      final (:year, :month) = MonthHelpers.parseMonthId(calendarId);
      final overrideStr = await db.getSetting('paydayOverride_$calendarId');
      final payday = overrideStr != null
          ? DateTime.tryParse(overrideStr)
          : PaydayCalculator.suggestedPayday(year, month, preset);
      if (payday != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final paydayDate = DateTime(payday.year, payday.month, payday.day);
        if (!today.isBefore(paydayDate)) return nextId;
      }
    }
    return calendarId;
  } finally {
    await db.close();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final initialMonth = await _resolveInitialMonth();

  // Fire-and-forget auto-backup on cold start
  BackupService.createAutoBackup().catchError((_) {});

  runApp(
    ProviderScope(
      overrides: [
        currentMonthIdProvider.overrideWith((ref) => initialMonth),
      ],
      child: const KakeiboApp(),
    ),
  );
}
