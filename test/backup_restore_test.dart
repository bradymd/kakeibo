import 'dart:ffi';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:sqlite3/open.dart' as sqlite3_open;
import 'package:kakeibo/services/backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // This test VM has no bundled libsqlite3 (that normally comes from
  // sqlite3_flutter_libs at app-run time, not under plain `flutter
  // test`) — point the FFI loader at whichever system copy is present
  // instead, so the test can actually open a real database. Candidate
  // paths cover common distro/snap layouts; if none exist on a given
  // machine, DynamicLibrary.open('libsqlite3.so') as a last resort
  // relies on the system's normal shared-library search path.
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
        final snapMatch = Directory('/snap')
            .listSync()
            .whereType<Directory>()
            .expand((d) => Directory(
                  '${d.path}/usr/lib/x86_64-linux-gnu',
                ).existsSync()
                    ? Directory('${d.path}/usr/lib/x86_64-linux-gnu').listSync()
                    : const <FileSystemEntity>[])
            .whereType<File>()
            .where((f) => f.path.contains('libsqlite3.so'))
            .firstOrNull;
        if (snapMatch != null) return DynamicLibrary.open(snapMatch.path);
        return DynamicLibrary.open('libsqlite3.so');
      },
    );
  }

  late Directory tempDir;
  late Directory appDocsDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('kakeibo_restore_test');
    appDocsDir = Directory.systemTemp.createTempSync('kakeibo_restore_docs');

    // Mock path_provider's platform channel — BackupService calls both
    // getTemporaryDirectory() and getApplicationDocumentsDirectory().
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'getTemporaryDirectory':
          return tempDir.path;
        case 'getApplicationDocumentsDirectory':
          return appDocsDir.path;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
    appDocsDir.deleteSync(recursive: true);
  });

  String zipWithBytes(List<int> dbBytes, {String entryName = 'kakeibo.sqlite'}) {
    final archive = Archive();
    archive.addFile(ArchiveFile(entryName, dbBytes.length, dbBytes));
    final encoded = ZipEncoder().encode(archive);
    final path = '${tempDir.path}/test_backup.zip';
    File(path).writeAsBytesSync(encoded);
    return path;
  }

  test('valid database with expected schema restores successfully', () async {
    final dbPath = '${tempDir.path}/valid.sqlite';
    final db = sqlite3.sqlite3.open(dbPath);
    db.execute('CREATE TABLE kakeibo_months (id TEXT PRIMARY KEY, year INTEGER, month INTEGER)');
    db.dispose();
    final bytes = File(dbPath).readAsBytesSync();

    final zipPath = zipWithBytes(bytes);
    final result = await BackupService.restoreFromBackup(zipPath);
    expect(result, RestoreResult.success);
  });

  test('zip missing kakeibo.sqlite entry is rejected', () async {
    final zipPath = zipWithBytes([1, 2, 3], entryName: 'not_the_right_file.txt');
    final result = await BackupService.restoreFromBackup(zipPath);
    expect(result, RestoreResult.zipMissingDatabase);
  });

  test('corrupt / non-sqlite bytes are rejected', () async {
    final zipPath = zipWithBytes([1, 2, 3, 4, 5, 6, 7, 8]);
    final result = await BackupService.restoreFromBackup(zipPath);
    expect(result, RestoreResult.corruptDatabase);
  });

  test('valid sqlite file but wrong schema is rejected', () async {
    final dbPath = '${tempDir.path}/wrong_schema.sqlite';
    final db = sqlite3.sqlite3.open(dbPath);
    db.execute('CREATE TABLE some_other_app_table (id TEXT)');
    db.dispose();
    final bytes = File(dbPath).readAsBytesSync();

    final zipPath = zipWithBytes(bytes);
    final result = await BackupService.restoreFromBackup(zipPath);
    expect(result, RestoreResult.unexpectedSchema);
  });

  test('live database is preserved before being overwritten by a valid restore', () async {
    // Set up a "live" database with distinguishable content.
    final liveDbPath = '${appDocsDir.path}/kakeibo.sqlite';
    final liveDb = sqlite3.sqlite3.open(liveDbPath);
    liveDb.execute('CREATE TABLE kakeibo_months (id TEXT PRIMARY KEY, year INTEGER, month INTEGER)');
    liveDb.execute("INSERT INTO kakeibo_months VALUES ('live-marker', 2026, 1)");
    liveDb.dispose();

    // A different, also-valid restore candidate.
    final candidatePath = '${tempDir.path}/candidate.sqlite';
    final candidateDb = sqlite3.sqlite3.open(candidatePath);
    candidateDb.execute('CREATE TABLE kakeibo_months (id TEXT PRIMARY KEY, year INTEGER, month INTEGER)');
    candidateDb.execute("INSERT INTO kakeibo_months VALUES ('restored-marker', 2026, 2)");
    candidateDb.dispose();
    final candidateBytes = File(candidatePath).readAsBytesSync();

    final zipPath = zipWithBytes(candidateBytes);
    final result = await BackupService.restoreFromBackup(zipPath);
    expect(result, RestoreResult.success);

    // The live file now has the restored content...
    final restoredDb = sqlite3.sqlite3.open(liveDbPath, mode: sqlite3.OpenMode.readOnly);
    final rows = restoredDb.select('SELECT id FROM kakeibo_months');
    restoredDb.dispose();
    expect(rows.map((r) => r['id']), contains('restored-marker'));

    // ...and a pre-restore copy of the ORIGINAL live content exists
    // somewhere in the temp directory (the safety net).
    final preRestoreFiles = tempDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('kakeibo_pre_restore_'))
        .toList();
    expect(preRestoreFiles, isNotEmpty);
    final preRestoreDb = sqlite3.sqlite3.open(preRestoreFiles.first.path, mode: sqlite3.OpenMode.readOnly);
    final preRows = preRestoreDb.select('SELECT id FROM kakeibo_months');
    preRestoreDb.dispose();
    expect(preRows.map((r) => r['id']), contains('live-marker'));
  });
}
