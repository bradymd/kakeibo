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
      'two concurrent createAutoBackup() calls perform exactly ONE real '
      'backup run, not two racing ones', () async {
    createLiveDatabase('concurrent-marker');

    // Watch the temp dir for the snapshot files createAutoBackup()
    // creates internally (kakeibo_autobackup_snapshot_*.sqlite) -- this is
    // the actual decisive, behavior-distinguishing assertion. The old,
    // unguarded implementation didn't create a temp snapshot file at all
    // (it read the live file's bytes directly), so this test would have
    // been meaningless against it; the new implementation's whole point is
    // that two overlapping calls should trigger exactly one VACUUM INTO
    // snapshot, not one per call. Without the in-flight guard, firing two
    // calls without awaiting either first would create two independent
    // snapshot files (and, on some platforms/timings, race writing the
    // same final zip path).
    final snapshotCreations = <String>[];
    final watchSub = tempDir.watch(events: FileSystemEvent.create).listen((e) {
      // VACUUM INTO creates a `-journal` sidecar alongside the real
      // snapshot file -- filter it out, or a single genuine snapshot run
      // looks like two file-creation events.
      if (e.path.contains('kakeibo_autobackup_snapshot_') &&
          !e.path.endsWith('-journal')) {
        snapshotCreations.add(e.path);
      }
    });

    // Fire both without awaiting either first -- this is exactly the
    // shape of the original bug (main.dart's call and
    // AutoBackupManager's call landing close together).
    final first = BackupService.createAutoBackup();
    final second = BackupService.createAutoBackup();
    expect(identical(first, second), isTrue,
        reason: 'a second call while one is already in flight must return '
            'the SAME future as the first, proving it is sharing that run '
            'rather than starting an independent one');

    await Future.wait([first, second]);
    // Let the filesystem watcher's queued events flush.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await watchSub.cancel();

    expect(snapshotCreations.length, 1,
        reason: 'two overlapping createAutoBackup() calls must perform '
            'exactly one real backup run (one VACUUM INTO snapshot), not '
            'one per call. Saw: $snapshotCreations');

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
}
