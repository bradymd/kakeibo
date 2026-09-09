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

  /// Creates/overwrites the rolling auto-backup ZIP in app docs directory.
  /// Skips silently if no database exists yet.
  static Future<void> createAutoBackup() async {
    final dbPath = await _dbPath();
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) return;

    final bytes = await dbFile.readAsBytes();
    final archive = Archive();
    archive.addFile(ArchiveFile(_dbFileName, bytes.length, bytes));
    final encoded = ZipEncoder().encode(archive);

    final dir = await getApplicationDocumentsDirectory();
    final zipPath = p.join(dir.path, _autoBackupFileName);
    await File(zipPath).writeAsBytes(encoded);
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
