import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/database/database_provider.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;

part 'schema_v4_migration_test.g.dart';

/// A frozen copy of the schema exactly as it existed at commit e805107~1
/// (the last commit before the v4 -> v5 category migration was added) --
/// confirmed via `git show e805107~1:lib/database/database_provider.dart`
/// rather than reconstructed from memory. Used to build a real schema-4
/// database file, populated with representative data across every table,
/// which is then opened with the CURRENT AppDatabase to exercise the
/// actual onUpgrade migration path end-to-end -- not a re-implementation
/// of it.
@DataClassName('V4KakeiboMonthRow')
class V4KakeiboMonths extends Table {
  TextColumn get id => text()();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  RealColumn get income => real().withDefault(const Constant(0))();
  RealColumn get savingsGoal => real().withDefault(const Constant(0))();
  TextColumn get reflectionJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'kakeibo_months';
}

@DataClassName('V4ExpenseRow')
class V4Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get monthId => text().references(V4KakeiboMonths, #id)();
  TextColumn get date => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get pillar => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'expenses';
}

@DataClassName('V4FixedExpenseRow')
class V4FixedExpenses extends Table {
  TextColumn get id => text()();
  TextColumn get monthId => text().references(V4KakeiboMonths, #id)();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get category => text().withDefault(const Constant('other'))();
  IntColumn get dueDay => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'fixed_expenses';
}

@DataClassName('V4IncomeSourceRow')
class V4IncomeSources extends Table {
  TextColumn get id => text()();
  TextColumn get monthId => text().references(V4KakeiboMonths, #id)();
  TextColumn get name => text()();
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String get tableName => 'income_sources';
}

@DataClassName('V4AppSettingRow')
class V4AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};

  @override
  String get tableName => 'app_settings';
}

@DriftDatabase(tables: [
  V4KakeiboMonths,
  V4Expenses,
  V4FixedExpenses,
  V4IncomeSources,
  V4AppSettings,
])
class _V4Database extends _$_V4Database {
  _V4Database(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) => m.createAll());
}

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
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('kakeibo_v4_migration_test');
    dbFile = File('${tempDir.path}/v4.sqlite');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('a real schema-4 database upgrades to v5 with every value intact', () async {
    // --- Build a real v4 database file and populate every table. ---
    final v4db = _V4Database(NativeDatabase(dbFile));
    await v4db.into(v4db.v4KakeiboMonths).insert(
          V4KakeiboMonthsCompanion.insert(
            id: '2026-08',
            year: 2026,
            month: 8,
            income: const Value(3357.0),
            savingsGoal: const Value(500.0),
            reflectionJson: const Value(
              '{"actualSaved":450.0,"howSaved":"Stuck to the plan","improvements":"","notes":"","accountBalance":0.0,"completed":true}',
            ),
          ),
        );
    await v4db.into(v4db.v4Expenses).insert(
          V4ExpensesCompanion.insert(
            id: 'exp-1',
            monthId: '2026-08',
            date: '2026-08-15',
            description: 'Tesco',
            amount: 34.5,
            pillar: 'needs',
            notes: const Value('Weekly shop'),
            createdAt: const Value(1755000000000),
          ),
        );
    await v4db.into(v4db.v4FixedExpenses).insert(
          V4FixedExpensesCompanion.insert(
            id: 'fixed-1',
            monthId: '2026-08',
            name: 'Rent',
            amount: 900.0,
            category: const Value('Housing'),
            dueDay: const Value(1),
          ),
        );
    await v4db.into(v4db.v4IncomeSources).insert(
          V4IncomeSourcesCompanion.insert(
            id: 'income-1',
            monthId: '2026-08',
            name: 'Salary',
            amount: 3357.0,
          ),
        );
    await v4db.into(v4db.v4AppSettings).insert(
          V4AppSettingsCompanion.insert(key: 'currency', value: 'GBP'),
        );
    await v4db.close();

    // --- Open that same file with the CURRENT AppDatabase (schema 5). ---
    // This runs the real onUpgrade migration code, not a re-implementation
    // of it.
    final upgraded = AppDatabase.forTesting(NativeDatabase(dbFile));

    final month = await upgraded.getMonth('2026-08');
    expect(month, isNotNull);
    expect(month!.income, 3357.0);
    expect(month.savingsGoal, 500.0);
    expect(month.reflection.howSaved, 'Stuck to the plan');
    expect(month.reflection.actualSaved, 450.0);
    expect(month.reflection.completed, isTrue);

    expect(month.expenses, hasLength(1));
    final expense = month.expenses.single;
    expect(expense.description, 'Tesco');
    expect(expense.amount, 34.5);
    expect(expense.notes, 'Weekly shop');
    expect(expense.createdAt, 1755000000000);
    // The new column: absent in the v4 row, must come through as the
    // model's "not categorised" representation, never a crash or a
    // stray literal null/placeholder string.
    expect(expense.category, '');

    expect(month.fixedExpenses, hasLength(1));
    final fixed = month.fixedExpenses.single;
    expect(fixed.name, 'Rent');
    expect(fixed.amount, 900.0);
    expect(fixed.category, 'Housing');
    expect(fixed.dueDay, 1);

    expect(month.incomeSources, hasLength(1));
    expect(month.incomeSources.single.name, 'Salary');
    expect(month.incomeSources.single.amount, 3357.0);

    expect(await upgraded.getSetting('currency'), 'GBP');

    // The new v5 table must exist and be usable -- and per the seeding
    // logic added alongside the migration, populated with the defaults
    // (mirrors getExpenseCategorySuggestions' lazy-backfill behaviour,
    // exercised here via the real migration path instead).
    final suggestions = await upgraded.getExpenseCategorySuggestions();
    expect(suggestions, isNotEmpty);
    expect(suggestions, contains('Groceries'));

    // A category can be set on an existing (migrated) expense going
    // forward, proving the new column is genuinely writable post-upgrade.
    await upgraded.updateExpense(expense.copyWith(category: 'Groceries'));
    final reloaded = await upgraded.getMonth('2026-08');
    expect(reloaded!.expenses.single.category, 'Groceries');

    await upgraded.close();
  });
}
