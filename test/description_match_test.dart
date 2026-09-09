import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/database/database_provider.dart';
import 'package:kakeibo/models/kakeibo_month.dart' as models;
import 'package:kakeibo/models/pillar.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;

/// Drives AppDatabase.forTesting directly (same-isolate NativeDatabase, no
/// widget rendering) to verify findDescriptionMatch's case-insensitive
/// starts-with, most-recent-wins matching used for Add Expense's ghost-text
/// completion.
///
/// Uses AppDatabase.forTesting rather than the real AppDatabase() because
/// the latter opens its connection via NativeDatabase.createInBackground,
/// which spawns a separate isolate -- the sqlite3_open FFI override below
/// (needed since plain `flutter test` has no bundled libsqlite3) doesn't
/// propagate into that isolate, so the background-isolate route fails with
/// "cannot open shared object file" even with the override in place.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux) {
    sqlite3_open.open.overrideFor(
      sqlite3_open.OperatingSystem.linux,
      () {
        const candidates = [
          '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
          '/usr/lib/libsqlite3.so.0',
          '/lib/x86_64-linux-gnu/libsqlite3.so.0',
        ];
        for (final path in candidates) {
          if (File(path).existsSync()) return DynamicLibrary.open(path);
        }
        return DynamicLibrary.open('libsqlite3.so');
      },
    );
  }

  late Directory tempDir;
  late AppDatabase db;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('kakeibo_desc_match_test');
    final file = File('${tempDir.path}/test.sqlite');
    db = AppDatabase.forTesting(NativeDatabase(file));
    await db.upsertMonth(const models.KakeiboMonth(id: '2026-08', year: 2026, month: 8));
    await db.upsertMonth(const models.KakeiboMonth(id: '2026-09', year: 2026, month: 9));
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  models.KakeiboExpense exp(
    String id,
    String description, {
    String category = '',
    required int createdAt,
  }) =>
      models.KakeiboExpense(
        id: id,
        date: '2026-09-01',
        description: description,
        amount: 10,
        pillar: Pillar.needs,
        category: category,
        createdAt: createdAt,
      );

  test('matches case-insensitively and returns the last-used category', () async {
    await db.insertExpense('2026-08', exp('a', 'Tesco', category: 'Groceries', createdAt: 100));
    final match = await db.findDescriptionMatch('tesco');
    expect(match, isNotNull);
    expect(match!.description, 'Tesco');
    expect(match.category, 'Groceries');
  });

  test('most recently created match wins over an older, equally-valid one', () async {
    await db.insertExpense('2026-08', exp('a', 'Tesco', category: 'Groceries', createdAt: 100));
    await db.insertExpense('2026-09', exp('b', 'Tesco', category: 'Groceries', createdAt: 300));
    await db.insertExpense('2026-08', exp('c', "Ted's Garage", category: 'Transport', createdAt: 200));

    final match = await db.findDescriptionMatch('Te');
    expect(match, isNotNull);
    // "Tesco" (createdAt 300) is more recent than "Ted's Garage" (200).
    expect(match!.description, 'Tesco');
    expect(match.category, 'Groceries');
  });

  test('searches across all months, not just one', () async {
    await db.insertExpense('2026-08', exp('a', 'Tesco', category: 'Groceries', createdAt: 100));
    final match = await db.findDescriptionMatch('Tes');
    expect(match, isNotNull);
    expect(match!.description, 'Tesco');
  });

  test('returns null for no match', () async {
    await db.insertExpense('2026-08', exp('a', 'Tesco', category: 'Groceries', createdAt: 100));
    final match = await db.findDescriptionMatch('Zzz');
    expect(match, isNull);
  });

  test('returns null for a blank prefix', () async {
    await db.insertExpense('2026-08', exp('a', 'Tesco', category: 'Groceries', createdAt: 100));
    expect(await db.findDescriptionMatch(''), isNull);
    expect(await db.findDescriptionMatch('   '), isNull);
  });

  test('category is empty string when the matched expense had none', () async {
    await db.insertExpense('2026-08', exp('a', 'Tesco', createdAt: 100));
    final match = await db.findDescriptionMatch('Tesco');
    expect(match, isNotNull);
    expect(match!.category, '');
  });
}
