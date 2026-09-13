import 'dart:ffi';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:sqlite3/open.dart' as sqlite3_open;
import 'package:kakeibo/services/backup_service.dart';

/// Regression test for the auto-backup race Codex flagged in the
/// pre-TestFlight audit: main.dart used to fire an unconditional,
/// ungated createAutoBackup() on every cold start, and separately
/// AutoBackupManager's own init() could also call createAutoBackup()
/// within the same cold start (if the last recorded backup was already
/// >24h old) -- both writing kakeibo_autobackup.zip concurrently, with no
/// coordination between them. Fixed by: (a) removing main.dart's separate
/// call entirely, since AutoBackupManager is already the interval-gated,
/// single source of truth; (b) adding an in-flight guard in
/// BackupService.createAutoBackup() itself, so any two calls that do
/// still overlap (from any future call site) share one real run instead
/// of racing; (c) an equivalent guard in AutoBackupManager._runIfNeeded()
/// so rapid resume-cycling can't even reach BackupService twice for the
/// same "is a backup due" decision.
///
/// Also covers the second part of that finding: createAutoBackup() used
/// to read the live database's raw bytes directly off disk while
/// Drift's own connection could still be open, which is not guaranteed
/// consistent (especially under WAL mode, where the main .sqlite file on
/// disk doesn't necessarily hold every committed change). It now opens
/// the live file read-only via the sqlite3 package and uses SQLite's own
/// `VACUUM INTO` to produce an atomic, transactionally-consistent
/// snapshot file, which is what actually gets zipped.
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
    tempDir = Directory.systemTemp.createTempSync('kakeibo_autobackup_test');
    appDocsDir = Directory.systemTemp.createTempSync('kakeibo_autobackup_docs');

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

  void createLiveDatabase(String markerValue) {
    final dbPath = '${appDocsDir.path}/kakeibo.sqlite';
    final db = sqlite3.sqlite3.open(dbPath);
    db.execute('CREATE TABLE kakeibo_months (id TEXT PRIMARY KEY, year INTEGER, month INTEGER)');
    db.execute("INSERT INTO kakeibo_months VALUES ('$markerValue', 2026, 1)");
    db.dispose();
  }

  Map<String, dynamic> readAutoBackupZipDbRow() {
    final zipPath = '${appDocsDir.path}/kakeibo_autobackup.zip';
    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);
    final entry = archive.findFile('kakeibo.sqlite');
    expect(entry, isNotNull, reason: 'auto-backup zip must contain kakeibo.sqlite');

    final extractedPath = '${tempDir.path}/extracted_${DateTime.now().microsecondsSinceEpoch}.sqlite';
    File(extractedPath).writeAsBytesSync(entry!.content as List<int>);
    final db = sqlite3.sqlite3.open(extractedPath, mode: sqlite3.OpenMode.readOnly);
    final rows = db.select('SELECT id FROM kakeibo_months');
    db.dispose();
    return {'id': rows.first['id']};
  }

  test('produces a valid auto-backup zip containing the live data', () async {
    createLiveDatabase('single-call-marker');

    await BackupService.createAutoBackup();

    final row = readAutoBackupZipDbRow();
    expect(row['id'], 'single-call-marker');
  });

  test(
      'two concurrent calls share the same in-flight backup', () async {
    createLiveDatabase('concurrent-marker');

    // Fire both without awaiting either first -- this is exactly the
    // shape of the original bug (main.dart's call and
    // AutoBackupManager's call landing close together).
    final first = BackupService.createAutoBackup();
    final second = BackupService.createAutoBackup();

    // This is the actual decisive, behavior-distinguishing assertion --
    // NOT a filesystem-watcher-based one. An earlier version of this test
    // watched the temp dir for VACUUM INTO's snapshot-file creation event
    // instead, but Directory.watch() delivery timing is platform-
    // dependent (observed passing locally on Linux/inotify, then failing
    // on Codemagic's macOS runner with zero events seen at all -- likely
    // FSEvents batching/delivering the notification later than this
    // test's brief wait, compounded by the snapshot file already being
    // deleted in createAutoBackup()'s own `finally` block by the time the
    // watcher got around to firing). identical() on the returned Futures
    // is synchronous, platform-independent, and deterministically proves
    // that a second overlapping public call receives the same in-flight
    // Future rather than invoking the unguarded operation again -- it does
    // not, by itself, prove anything about how many internal VACUUM INTO
    // runs happened (that's an implementation detail this test no longer
    // observes directly; per Codex's review, adding a seam purely to
    // count private calls would be more complexity than this code
    // warrants). The subsequent valid-zip/content assertion below proves
    // that shared operation actually completed successfully.
    expect(identical(first, second), isTrue,
        reason: 'a second call while one is already in flight must return '
            'the SAME future as the first, proving it is sharing that run '
            'rather than starting an independent one');

    await Future.wait([first, second]);

    // The resulting file must be a single, well-formed zip with the
    // correct content -- not a torn/interleaved write from two
    // processes writing the same path at once.
    final row = readAutoBackupZipDbRow();
    expect(row['id'], 'concurrent-marker');
  });

  test(
      'createAutoBackup() does not hold the file open in a way that blocks '
      'a subsequent call once the first has finished', () async {
    createLiveDatabase('first-marker');
    await BackupService.createAutoBackup();
    expect(readAutoBackupZipDbRow()['id'], 'first-marker');

    // Simulate the database changing between two genuinely sequential
    // auto-backup runs (e.g. a day apart) -- the second call must succeed
    // and produce fresh content, not reuse/lock onto the first snapshot.
    final dbPath = '${appDocsDir.path}/kakeibo.sqlite';
    final db = sqlite3.sqlite3.open(dbPath);
    db.execute("UPDATE kakeibo_months SET id = 'second-marker' WHERE id = 'first-marker'");
    db.dispose();

    await BackupService.createAutoBackup();
    expect(readAutoBackupZipDbRow()['id'], 'second-marker');
  });

  test('skips silently when no database exists yet', () async {
    // No createLiveDatabase() call -- appDocsDir/kakeibo.sqlite doesn't exist.
    await BackupService.createAutoBackup();

    final zipPath = '${appDocsDir.path}/kakeibo_autobackup.zip';
    expect(File(zipPath).existsSync(), isFalse);
  });

  test(
      'an existing known-good rolling zip is replaced by a valid new one on '
      'success, with no leftover pending temp file', () async {
    // Per Codex's review: createAutoBackup() publishes the final zip via a
    // sibling temp file in the same app documents directory, then renames
    // it over kakeibo_autobackup.zip, rather than writeAsBytes()-ing
    // directly onto the existing path (which truncates it before writing
    // the replacement -- an interruption partway through that would
    // destroy the previous good backup and leave a partial/corrupt zip
    // with nothing to fall back on).
    createLiveDatabase('old-good-backup');
    await BackupService.createAutoBackup();
    final firstRow = readAutoBackupZipDbRow();
    expect(firstRow['id'], 'old-good-backup');

    final dbPath = '${appDocsDir.path}/kakeibo.sqlite';
    final db = sqlite3.sqlite3.open(dbPath);
    db.execute("UPDATE kakeibo_months SET id = 'new-good-backup' WHERE id = 'old-good-backup'");
    db.dispose();

    await BackupService.createAutoBackup();

    // The rolling zip now reflects the new content, not the old one.
    final secondRow = readAutoBackupZipDbRow();
    expect(secondRow['id'], 'new-good-backup');

    // No pending-publish temp file was left behind in app docs -- the
    // rename either replaced it cleanly, or the finally-block cleanup ran.
    final leftoverPending = appDocsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('kakeibo_autobackup_pending_'))
        .toList();
    expect(leftoverPending, isEmpty,
        reason: 'no .kakeibo_autobackup_pending_*.zip temp file should '
            'remain after a successful publish');
  });
}
