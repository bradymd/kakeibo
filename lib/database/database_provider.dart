import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:kakeibo/models/kakeibo_month.dart' as models;
import 'package:kakeibo/models/pillar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database_provider.g.dart';

@DataClassName('KakeiboMonthRow')
class KakeiboMonths extends Table {
  TextColumn get id => text()();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  RealColumn get income => real().withDefault(const Constant(0))();
  RealColumn get savingsGoal => real().withDefault(const Constant(0))();
  TextColumn get reflectionJson =>
      text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExpenseRow')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get monthId => text().references(KakeiboMonths, #id)();
  TextColumn get date => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get pillar => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('FixedExpenseRow')
class FixedExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get monthId => text().references(KakeiboMonths, #id)();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get category =>
      text().withDefault(const Constant('other'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('IncomeSourceRow')
class IncomeSources extends Table {
  TextColumn get id => text()();
  TextColumn get monthId => text().references(KakeiboMonths, #id)();
  TextColumn get name => text()();
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [KakeiboMonths, Expenses, FixedExpenses, IncomeSources, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(incomeSources);
          }
        },
      );

  // --- Month operations ---

  Future<models.KakeiboMonth?> getMonth(String id) async {
    final row =
        await (select(kakeiboMonths)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
    if (row == null) return null;
    return _monthFromRow(
        row, await _getExpenses(id), await _getFixed(id), await _getIncomeSources(id));
  }

  Future<List<models.KakeiboMonth>> getAllMonths() async {
    final rows = await select(kakeiboMonths).get();
    final result = <models.KakeiboMonth>[];
    for (final row in rows) {
      result.add(_monthFromRow(
          row,
          await _getExpenses(row.id),
          await _getFixed(row.id),
          await _getIncomeSources(row.id)));
    }
    return result;
  }

  Future<void> upsertMonth(models.KakeiboMonth month) async {
    await into(kakeiboMonths).insertOnConflictUpdate(
      KakeiboMonthsCompanion.insert(
        id: month.id,
        year: month.year,
        month: month.month,
        income: Value(month.income),
        savingsGoal: Value(month.savingsGoal),
        reflectionJson: Value(jsonEncode(month.reflection.toJson())),
      ),
    );
  }

  // --- Expense operations ---

  Future<List<models.KakeiboExpense>> _getExpenses(String monthId) async {
    final rows = await (select(expenses)
          ..where((t) => t.monthId.equals(monthId)))
        .get();
    return rows.map(_expenseFromRow).toList();
  }

  Future<void> insertExpense(String monthId, models.KakeiboExpense exp) async {
    await into(expenses).insertOnConflictUpdate(
      ExpensesCompanion.insert(
        id: exp.id,
        monthId: monthId,
        date: exp.date,
        description: exp.description,
        amount: exp.amount,
        pillar: exp.pillar.name,
        notes: Value(exp.notes),
      ),
    );
  }

  Future<void> updateExpense(models.KakeiboExpense exp) async {
    await (update(expenses)..where((t) => t.id.equals(exp.id))).write(
      ExpensesCompanion(
        date: Value(exp.date),
        description: Value(exp.description),
        amount: Value(exp.amount),
        pillar: Value(exp.pillar.name),
        notes: Value(exp.notes),
      ),
    );
  }

  Future<void> deleteExpense(String id) async {
    await (delete(expenses)..where((t) => t.id.equals(id))).go();
  }

  // --- Fixed expense operations ---

  Future<List<models.FixedExpense>> _getFixed(String monthId) async {
    final rows = await (select(fixedExpenses)
          ..where((t) => t.monthId.equals(monthId)))
        .get();
    return rows.map(_fixedFromRow).toList();
  }

  Future<void> insertFixedExpense(
      String monthId, models.FixedExpense exp) async {
    await into(fixedExpenses).insertOnConflictUpdate(
      FixedExpensesCompanion.insert(
        id: exp.id,
        monthId: monthId,
        name: exp.name,
        amount: exp.amount,
        category: Value(exp.category),
      ),
    );
  }

  Future<void> deleteFixedExpense(String id) async {
    await (delete(fixedExpenses)..where((t) => t.id.equals(id))).go();
  }

  // --- Income source operations ---

  Future<List<models.IncomeSource>> _getIncomeSources(String monthId) async {
    final rows = await (select(incomeSources)
          ..where((t) => t.monthId.equals(monthId)))
        .get();
    return rows
        .map((r) => models.IncomeSource(id: r.id, name: r.name, amount: r.amount))
        .toList();
  }

  Future<void> insertIncomeSource(
      String monthId, models.IncomeSource src) async {
    await into(incomeSources).insertOnConflictUpdate(
      IncomeSourcesCompanion.insert(
        id: src.id,
        monthId: monthId,
        name: src.name,
        amount: src.amount,
      ),
    );
  }

  Future<void> deleteIncomeSource(String id) async {
    await (delete(incomeSources)..where((t) => t.id.equals(id))).go();
  }

  // --- Settings ---

  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  // --- Helpers ---

  models.KakeiboMonth _monthFromRow(
    KakeiboMonthRow row,
    List<models.KakeiboExpense> exps,
    List<models.FixedExpense> fixed,
    List<models.IncomeSource> incomes,
  ) {
    models.Reflection reflection;
    try {
      reflection = models.Reflection.fromJson(
          jsonDecode(row.reflectionJson) as Map<String, dynamic>);
    } catch (_) {
      reflection = const models.Reflection();
    }
    return models.KakeiboMonth(
      id: row.id,
      year: row.year,
      month: row.month,
      income: row.income,
      savingsGoal: row.savingsGoal,
      incomeSources: incomes,
      fixedExpenses: fixed,
      expenses: exps,
      reflection: reflection,
    );
  }

  models.KakeiboExpense _expenseFromRow(ExpenseRow row) {
    return models.KakeiboExpense(
      id: row.id,
      date: row.date,
      description: row.description,
      amount: row.amount,
      pillar: Pillar.values.firstWhere(
        (p) => p.name == row.pillar,
        orElse: () => Pillar.needs,
      ),
      notes: row.notes,
    );
  }

  models.FixedExpense _fixedFromRow(FixedExpenseRow row) {
    // Normalise old enum-style lowercase categories (e.g. "other" -> "Other")
    final cat = row.category;
    final normalisedCat = cat.isNotEmpty
        ? cat[0].toUpperCase() + cat.substring(1)
        : 'Other';
    return models.FixedExpense(
      id: row.id,
      name: row.name,
      amount: row.amount,
      category: normalisedCat,
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kakeibo.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
