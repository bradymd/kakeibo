import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/models/kakeibo_month.dart';
import 'package:kakeibo/models/pillar.dart';
import 'package:kakeibo/providers/database_provider.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/utils/id_generator.dart';

final currentMonthIdProvider = StateProvider<String>((ref) {
  return MonthHelpers.getCurrentMonthId();
});

final kakeiboMonthsProvider =
    AsyncNotifierProvider<KakeiboMonthsNotifier, List<KakeiboMonth>>(
        KakeiboMonthsNotifier.new);

final currentMonthProvider = Provider<AsyncValue<KakeiboMonth>>((ref) {
  final monthId = ref.watch(currentMonthIdProvider);
  final monthsAsync = ref.watch(kakeiboMonthsProvider);
  return monthsAsync.whenData((months) {
    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    return months.firstWhere(
      (m) => m.id == monthId,
      orElse: () => KakeiboMonth(id: monthId, year: year, month: month),
    );
  });
});

class KakeiboMonthsNotifier extends AsyncNotifier<List<KakeiboMonth>> {
  @override
  Future<List<KakeiboMonth>> build() async {
    final db = ref.watch(databaseProvider);
    return db.getAllMonths();
  }

  Future<void> upsertMonth(KakeiboMonth month) async {
    final db = ref.read(databaseProvider);
    await db.upsertMonth(month);
    ref.invalidateSelf();
  }

  Future<void> setupMonth({
    required String monthId,
    required double income,
    required double savingsGoal,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getMonth(monthId);
    final (:year, :month) = MonthHelpers.parseMonthId(monthId);
    final updated = (existing ?? KakeiboMonth(id: monthId, year: year, month: month))
        .copyWith(income: income, savingsGoal: savingsGoal);
    await db.upsertMonth(updated);
    ref.invalidateSelf();
  }

  Future<void> addExpense({
    required String monthId,
    required String date,
    required String description,
    required double amount,
    required String pillarName,
    String notes = '',
  }) async {
    final db = ref.read(databaseProvider);
    final pillar = _parsePillar(pillarName);
    final expense = KakeiboExpense(
      id: generateId(),
      date: date,
      description: description,
      amount: amount,
      pillar: pillar,
      notes: notes,
    );
    // Ensure month exists
    final existing = await db.getMonth(monthId);
    if (existing == null) {
      final (:year, :month) = MonthHelpers.parseMonthId(monthId);
      await db.upsertMonth(KakeiboMonth(id: monthId, year: year, month: month));
    }
    await db.insertExpense(monthId, expense);
    ref.invalidateSelf();
  }

  Future<void> updateExpense(KakeiboExpense expense) async {
    final db = ref.read(databaseProvider);
    await db.updateExpense(expense);
    ref.invalidateSelf();
  }

  Future<void> deleteExpense(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteExpense(id);
    ref.invalidateSelf();
  }

  Future<void> addFixedExpense({
    required String monthId,
    required String name,
    required double amount,
    required String category,
    int? dueDay,
  }) async {
    final db = ref.read(databaseProvider);
    final fixed = FixedExpense(
      id: generateId(),
      name: name,
      amount: amount,
      category: category,
      dueDay: dueDay,
    );
    final existing = await db.getMonth(monthId);
    if (existing == null) {
      final (:year, :month) = MonthHelpers.parseMonthId(monthId);
      await db.upsertMonth(KakeiboMonth(id: monthId, year: year, month: month));
    }
    await db.insertFixedExpense(monthId, fixed);
    ref.invalidateSelf();
  }

  Future<void> updateFixedExpense(FixedExpense expense) async {
    final db = ref.read(databaseProvider);
    await db.updateFixedExpense(expense);
    ref.invalidateSelf();
  }

  Future<void> deleteFixedExpense(String id) async {
    final db = ref.read(databaseProvider);
    await db.deleteFixedExpense(id);
    ref.invalidateSelf();
  }

  Future<void> addIncomeSource({
    required String monthId,
    required String name,
    required double amount,
  }) async {
    final db = ref.read(databaseProvider);
    final src = IncomeSource(id: generateId(), name: name, amount: amount);
    final existing = await db.getMonth(monthId);
    if (existing == null) {
      final (:year, :month) = MonthHelpers.parseMonthId(monthId);
      await db.upsertMonth(KakeiboMonth(id: monthId, year: year, month: month));
    }
    await db.insertIncomeSource(monthId, src);
    // Recalculate total income from sources
    await _syncIncomeTotal(monthId);
    ref.invalidateSelf();
  }

  Future<void> updateIncomeSource(IncomeSource source, String monthId) async {
    final db = ref.read(databaseProvider);
    await db.updateIncomeSource(source);
    await _syncIncomeTotal(monthId);
    ref.invalidateSelf();
  }

  Future<void> deleteIncomeSource(String id, String monthId) async {
    final db = ref.read(databaseProvider);
    await db.deleteIncomeSource(id);
    await _syncIncomeTotal(monthId);
    ref.invalidateSelf();
  }

  Future<void> _syncIncomeTotal(String monthId) async {
    final db = ref.read(databaseProvider);
    final month = await db.getMonth(monthId);
    if (month != null) {
      final total = month.incomeSources.fold(0.0, (sum, s) => sum + s.amount);
      await db.upsertMonth(month.copyWith(income: total));
    }
  }

  Future<void> saveReflection({
    required String monthId,
    required Reflection reflection,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.getMonth(monthId);
    if (existing != null) {
      await db.upsertMonth(existing.copyWith(reflection: reflection));
      ref.invalidateSelf();
    }
  }

  static Pillar _parsePillar(String name) {
    return switch (name) {
      'needs' => Pillar.needs,
      'wants' => Pillar.wants,
      'culture' => Pillar.culture,
      'unexpected' => Pillar.unexpected,
      _ => Pillar.needs,
    };
  }

}
