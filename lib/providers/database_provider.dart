import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/database/database_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
