import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AutoBackupInfo {
  final DateTime timestamp;
  final int sizeBytes;
  const AutoBackupInfo({required this.timestamp, required this.sizeBytes});
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
    if (encoded == null) throw StateError('Failed to encode ZIP');

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
    if (encoded == null) return;

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

  /// Restores from a backup ZIP file. Returns true on success.
  /// The caller must close the database before calling this,
  /// and invalidate providers after.
  static Future<bool> restoreFromBackup(String zipPath) async {
    final zipFile = File(zipPath);
    if (!await zipFile.exists()) return false;

    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Validate: ZIP must contain kakeibo.sqlite
    final dbEntry = archive.findFile(_dbFileName);
    if (dbEntry == null) return false;

    final dbPath = await _dbPath();
    await File(dbPath).writeAsBytes(dbEntry.content as List<int>);
    return true;
  }
}
