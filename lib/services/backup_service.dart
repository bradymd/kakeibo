import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

class AutoBackupInfo {
  final DateTime timestamp;
  final int sizeBytes;
  const AutoBackupInfo({required this.timestamp, required this.sizeBytes});
}

/// Why a restore attempt did or didn't succeed — lets the caller show
/// a more specific message than a single generic failure.
enum RestoreResult {
  success,
  zipMissingDatabase,
  corruptDatabase,
  unexpectedSchema,
  ioError,
}

class BackupService {
  BackupService._();

  static const _dbFileName = 'kakeibo.sqlite';
  static const _autoBackupFileName = 'kakeibo_autobackup.zip';

  /// Returns the path to the database file.
  static Future<String> _dbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _dbFileName);
  }

  /// Creates a manual backup ZIP in a temp directory. Returns the ZIP path.
  static Future<String> createBackup() async {
    final dbPath = await _dbPath();
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      throw StateError('Database file not found');
    }

    final bytes = await dbFile.readAsBytes();
    final archive = Archive();
    archive.addFile(ArchiveFile(_dbFileName, bytes.length, bytes));
    final encoded = ZipEncoder().encode(archive);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final zipPath = p.join(tempDir.path, 'kakeibo_backup_$timestamp.zip');
    await File(zipPath).writeAsBytes(encoded);
    return zipPath;
  }

  /// Guards against two concurrent auto-backup runs. main.dart's cold-start
  /// call and AutoBackupManager's own init()/resume-triggered call could
  /// previously both fire close together and race each other writing the
  /// same _autoBackupFileName -- whichever write "won" was undefined, and
  /// a torn/interleaved write was possible. A second call while one is
  /// already running now awaits the in-flight one instead of racing it.
  static Future<void>? _autoBackupInFlight;

  /// Creates/overwrites the rolling auto-backup ZIP in app docs directory.
  /// Skips silently if no database exists yet.
  static Future<void> createAutoBackup() {
    return _autoBackupInFlight ??= _createAutoBackupUnguarded().whenComplete(() {
      _autoBackupInFlight = null;
    });
  }

  static Future<void> _createAutoBackupUnguarded() async {
    final dbPath = await _dbPath();
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) return;

    // Read a SQLite-consistent snapshot via VACUUM INTO rather than copying
    // the live file's raw bytes: the live database stays open (Drift's own
    // NativeDatabase connection) the whole time this runs, so a plain
    // readAsBytes() could race an in-flight write and capture a torn/
    // inconsistent file, especially in WAL mode where the main .sqlite file
    // doesn't always hold the latest committed data on its own. VACUUM INTO
    // is SQLite's own documented mechanism for copying a *live* database --
    // it does not mutate the source and produces a transactionally
    // consistent snapshot -- and doesn't require closing or locking out the
    // live connection, unlike manual backup's approach, which does close
    // the live db first. (Confirmed against SQLite's own docs, not assumed:
    // https://www.sqlite.org/lang_vacuum.html#vacuum_with_an_into_clause,
    // https://www.sqlite.org/isolation.html#isolation_between_database_connections)
    final tempDir = await getTemporaryDirectory();
    final snapshotPath = p.join(
      tempDir.path,
      'kakeibo_autobackup_snapshot_${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    final snapshotFile = File(snapshotPath);
    // The final zip is published via a sibling temp file in the SAME app
    // documents directory, then renamed over the real path, rather than
    // writeAsBytes()'d directly onto the existing kakeibo_autobackup.zip.
    // writeAsBytes() on an existing path truncates it before writing the
    // new content -- an app termination, power loss, or I/O failure during
    // that write would destroy the previous good rolling backup and leave
    // a partial/corrupt zip behind, with nothing to fall back on. The
    // VACUUM INTO snapshot above is consistent, but that only protects the
    // *database read*; it says nothing about this final publish step.
    // Keeping the temp file in the same directory (not getTemporaryDirectory(),
    // which may be a different filesystem) means File.rename can be the
    // actual atomic replacement boundary, and its own contract removes an
    // existing destination file first: https://api.flutter.dev/flutter/dart-io/File/rename.html
    String? pendingZipPath;
    try {
      final db = sqlite3.sqlite3.open(dbPath, mode: sqlite3.OpenMode.readOnly);
      try {
        db.execute("VACUUM INTO '${snapshotPath.replaceAll("'", "''")}'");
      } finally {
        db.dispose();
      }

      final bytes = await snapshotFile.readAsBytes();
      final archive = Archive();
      archive.addFile(ArchiveFile(_dbFileName, bytes.length, bytes));
      final encoded = ZipEncoder().encode(archive);

      final dir = await getApplicationDocumentsDirectory();
      final zipPath = p.join(dir.path, _autoBackupFileName);
      pendingZipPath = p.join(
        dir.path,
        '.kakeibo_autobackup_pending_${DateTime.now().microsecondsSinceEpoch}.zip',
      );
      final pendingFile = await File(pendingZipPath).open(mode: FileMode.write);
      try {
        await pendingFile.writeFrom(encoded);
        await pendingFile.flush();
      } finally {
        await pendingFile.close();
      }
      await File(pendingZipPath).rename(zipPath);
      pendingZipPath = null; // renamed away; nothing left to clean up
    } finally {
      if (await snapshotFile.exists()) await snapshotFile.delete();
      if (pendingZipPath != null && await File(pendingZipPath).exists()) {
        await File(pendingZipPath).delete();
      }
    }
  }

  /// Returns info about the auto-backup file, or null if none exists.
  static Future<AutoBackupInfo?> getAutoBackupInfo() async {
    final path = await getAutoBackupPath();
    if (path == null) return null;
    final file = File(path);
    final stat = await file.stat();
    return AutoBackupInfo(
      timestamp: stat.modified,
      sizeBytes: stat.size,
    );
  }

  /// Returns the auto-backup file path if it exists, null otherwise.
  static Future<String?> getAutoBackupPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _autoBackupFileName);
    if (await File(path).exists()) return path;
    return null;
  }

  /// Table that must exist in a valid Kakeibo database — see
  /// `lib/database/database_provider.dart`'s `KakeiboMonths` table.
  static const _expectedTable = 'kakeibo_months';

  /// Restores from a backup ZIP file. The caller must close the
  /// database before calling this, and invalidate providers after —
  /// only on [RestoreResult.success]; on any other result the live
  /// database file is left untouched.
  ///
  /// Unlike the original implementation, this never writes the
  /// candidate bytes directly over the live database file. The
  /// candidate is extracted to a temp file first, opened read-only and
  /// checked for SQLite integrity and the schema this app actually
  /// expects; only if both pass does it replace the live file — and
  /// even then, the current live file is preserved alongside it first,
  /// so a bad restore is always recoverable.
  static Future<RestoreResult> restoreFromBackup(String zipPath) async {
    final zipFile = File(zipPath);
    if (!await zipFile.exists()) return RestoreResult.ioError;

    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final dbEntry = archive.findFile(_dbFileName);
    if (dbEntry == null) return RestoreResult.zipMissingDatabase;

    final tempDir = await getTemporaryDirectory();
    final candidatePath = p.join(
      tempDir.path,
      'kakeibo_restore_candidate_${DateTime.now().millisecondsSinceEpoch}.sqlite',
    );
    final candidateFile = File(candidatePath);
    try {
      await candidateFile.writeAsBytes(dbEntry.content as List<int>);

      final validity = _validateCandidate(candidatePath);
      if (validity != RestoreResult.success) return validity;

      final dbPath = await _dbPath();
      final liveFile = File(dbPath);
      if (await liveFile.exists()) {
        // Keep a copy of what was live immediately before the
        // overwrite, independent of any auto-backup — this is the
        // last line of defence if the restore turns out to be wrong
        // in a way validation didn't catch.
        final preRestorePath = p.join(
          tempDir.path,
          'kakeibo_pre_restore_${DateTime.now().millisecondsSinceEpoch}.sqlite',
        );
        await liveFile.copy(preRestorePath);
      }

      await candidateFile.copy(dbPath);
      return RestoreResult.success;
    } catch (_) {
      return RestoreResult.ioError;
    } finally {
      if (await candidateFile.exists()) await candidateFile.delete();
    }
  }

  /// Opens [path] read-only and checks it's a well-formed SQLite
  /// database with the table this app's schema actually uses. Runs
  /// synchronously (sqlite3's API is sync) but only against a small
  /// temp file, not the live database.
  static RestoreResult _validateCandidate(String path) {
    sqlite3.Database? db;
    try {
      db = sqlite3.sqlite3.open(path, mode: sqlite3.OpenMode.readOnly);

      final integrity = db.select('PRAGMA integrity_check');
      final ok = integrity.isNotEmpty && integrity.first.values.first == 'ok';
      if (!ok) return RestoreResult.corruptDatabase;

      final tables = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [_expectedTable],
      );
      if (tables.isEmpty) return RestoreResult.unexpectedSchema;

      return RestoreResult.success;
    } on sqlite3.SqliteException {
      return RestoreResult.corruptDatabase;
    } finally {
      db?.dispose();
    }
  }
}
