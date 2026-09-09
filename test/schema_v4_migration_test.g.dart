// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema_v4_migration_test.dart';

// ignore_for_file: type=lint
class $V4KakeiboMonthsTable extends V4KakeiboMonths
    with TableInfo<$V4KakeiboMonthsTable, V4KakeiboMonthRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $V4KakeiboMonthsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _incomeMeta = const VerificationMeta('income');
  @override
  late final GeneratedColumn<double> income = GeneratedColumn<double>(
    'income',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _savingsGoalMeta = const VerificationMeta(
    'savingsGoal',
  );
  @override
  late final GeneratedColumn<double> savingsGoal = GeneratedColumn<double>(
    'savings_goal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reflectionJsonMeta = const VerificationMeta(
    'reflectionJson',
  );
  @override
  late final GeneratedColumn<String> reflectionJson = GeneratedColumn<String>(
    'reflection_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    year,
    month,
    income,
    savingsGoal,
    reflectionJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kakeibo_months';
  @override
  VerificationContext validateIntegrity(
    Insertable<V4KakeiboMonthRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('income')) {
      context.handle(
        _incomeMeta,
        income.isAcceptableOrUnknown(data['income']!, _incomeMeta),
      );
    }
    if (data.containsKey('savings_goal')) {
      context.handle(
        _savingsGoalMeta,
        savingsGoal.isAcceptableOrUnknown(
          data['savings_goal']!,
          _savingsGoalMeta,
        ),
      );
    }
    if (data.containsKey('reflection_json')) {
      context.handle(
        _reflectionJsonMeta,
        reflectionJson.isAcceptableOrUnknown(
          data['reflection_json']!,
          _reflectionJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  V4KakeiboMonthRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return V4KakeiboMonthRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      )!,
      income: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}income'],
      )!,
      savingsGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}savings_goal'],
      )!,
      reflectionJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection_json'],
      )!,
    );
  }

  @override
  $V4KakeiboMonthsTable createAlias(String alias) {
    return $V4KakeiboMonthsTable(attachedDatabase, alias);
  }
}

class V4KakeiboMonthRow extends DataClass
    implements Insertable<V4KakeiboMonthRow> {
  final String id;
  final int year;
  final int month;
  final double income;
  final double savingsGoal;
  final String reflectionJson;
  const V4KakeiboMonthRow({
    required this.id,
    required this.year,
    required this.month,
    required this.income,
    required this.savingsGoal,
    required this.reflectionJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['income'] = Variable<double>(income);
    map['savings_goal'] = Variable<double>(savingsGoal);
    map['reflection_json'] = Variable<String>(reflectionJson);
    return map;
  }

  V4KakeiboMonthsCompanion toCompanion(bool nullToAbsent) {
    return V4KakeiboMonthsCompanion(
      id: Value(id),
      year: Value(year),
      month: Value(month),
      income: Value(income),
      savingsGoal: Value(savingsGoal),
      reflectionJson: Value(reflectionJson),
    );
  }

  factory V4KakeiboMonthRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return V4KakeiboMonthRow(
      id: serializer.fromJson<String>(json['id']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      income: serializer.fromJson<double>(json['income']),
      savingsGoal: serializer.fromJson<double>(json['savingsGoal']),
      reflectionJson: serializer.fromJson<String>(json['reflectionJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'income': serializer.toJson<double>(income),
      'savingsGoal': serializer.toJson<double>(savingsGoal),
      'reflectionJson': serializer.toJson<String>(reflectionJson),
    };
  }

  V4KakeiboMonthRow copyWith({
    String? id,
    int? year,
    int? month,
    double? income,
    double? savingsGoal,
    String? reflectionJson,
  }) => V4KakeiboMonthRow(
    id: id ?? this.id,
    year: year ?? this.year,
    month: month ?? this.month,
    income: income ?? this.income,
    savingsGoal: savingsGoal ?? this.savingsGoal,
    reflectionJson: reflectionJson ?? this.reflectionJson,
  );
  V4KakeiboMonthRow copyWithCompanion(V4KakeiboMonthsCompanion data) {
    return V4KakeiboMonthRow(
      id: data.id.present ? data.id.value : this.id,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      income: data.income.present ? data.income.value : this.income,
      savingsGoal: data.savingsGoal.present
          ? data.savingsGoal.value
          : this.savingsGoal,
      reflectionJson: data.reflectionJson.present
          ? data.reflectionJson.value
          : this.reflectionJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('V4KakeiboMonthRow(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('income: $income, ')
          ..write('savingsGoal: $savingsGoal, ')
          ..write('reflectionJson: $reflectionJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, year, month, income, savingsGoal, reflectionJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is V4KakeiboMonthRow &&
          other.id == this.id &&
          other.year == this.year &&
          other.month == this.month &&
          other.income == this.income &&
          other.savingsGoal == this.savingsGoal &&
          other.reflectionJson == this.reflectionJson);
}

class V4KakeiboMonthsCompanion extends UpdateCompanion<V4KakeiboMonthRow> {
  final Value<String> id;
  final Value<int> year;
  final Value<int> month;
  final Value<double> income;
  final Value<double> savingsGoal;
  final Value<String> reflectionJson;
  final Value<int> rowid;
  const V4KakeiboMonthsCompanion({
    this.id = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.income = const Value.absent(),
    this.savingsGoal = const Value.absent(),
    this.reflectionJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  V4KakeiboMonthsCompanion.insert({
    required String id,
    required int year,
    required int month,
    this.income = const Value.absent(),
    this.savingsGoal = const Value.absent(),
    this.reflectionJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       year = Value(year),
       month = Value(month);
  static Insertable<V4KakeiboMonthRow> custom({
    Expression<String>? id,
    Expression<int>? year,
    Expression<int>? month,
    Expression<double>? income,
    Expression<double>? savingsGoal,
    Expression<String>? reflectionJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (income != null) 'income': income,
      if (savingsGoal != null) 'savings_goal': savingsGoal,
      if (reflectionJson != null) 'reflection_json': reflectionJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  V4KakeiboMonthsCompanion copyWith({
    Value<String>? id,
    Value<int>? year,
    Value<int>? month,
    Value<double>? income,
    Value<double>? savingsGoal,
    Value<String>? reflectionJson,
    Value<int>? rowid,
  }) {
    return V4KakeiboMonthsCompanion(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      income: income ?? this.income,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      reflectionJson: reflectionJson ?? this.reflectionJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (income.present) {
      map['income'] = Variable<double>(income.value);
    }
    if (savingsGoal.present) {
      map['savings_goal'] = Variable<double>(savingsGoal.value);
    }
    if (reflectionJson.present) {
      map['reflection_json'] = Variable<String>(reflectionJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('V4KakeiboMonthsCompanion(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('income: $income, ')
          ..write('savingsGoal: $savingsGoal, ')
          ..write('reflectionJson: $reflectionJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $V4ExpensesTable extends V4Expenses
    with TableInfo<$V4ExpensesTable, V4ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $V4ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthIdMeta = const VerificationMeta(
    'monthId',
  );
  @override
  late final GeneratedColumn<String> monthId = GeneratedColumn<String>(
    'month_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES kakeibo_months (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pillarMeta = const VerificationMeta('pillar');
  @override
  late final GeneratedColumn<String> pillar = GeneratedColumn<String>(
    'pillar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    monthId,
    date,
    description,
    amount,
    pillar,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<V4ExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('month_id')) {
      context.handle(
        _monthIdMeta,
        monthId.isAcceptableOrUnknown(data['month_id']!, _monthIdMeta),
      );
    } else if (isInserting) {
      context.missing(_monthIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('pillar')) {
      context.handle(
        _pillarMeta,
        pillar.isAcceptableOrUnknown(data['pillar']!, _pillarMeta),
      );
    } else if (isInserting) {
      context.missing(_pillarMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  V4ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return V4ExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      monthId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      pillar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pillar'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $V4ExpensesTable createAlias(String alias) {
    return $V4ExpensesTable(attachedDatabase, alias);
  }
}

class V4ExpenseRow extends DataClass implements Insertable<V4ExpenseRow> {
  final String id;
  final String monthId;
  final String date;
  final String description;
  final double amount;
  final String pillar;
  final String notes;
  final int createdAt;
  const V4ExpenseRow({
    required this.id,
    required this.monthId,
    required this.date,
    required this.description,
    required this.amount,
    required this.pillar,
    required this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['month_id'] = Variable<String>(monthId);
    map['date'] = Variable<String>(date);
    map['description'] = Variable<String>(description);
    map['amount'] = Variable<double>(amount);
    map['pillar'] = Variable<String>(pillar);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  V4ExpensesCompanion toCompanion(bool nullToAbsent) {
    return V4ExpensesCompanion(
      id: Value(id),
      monthId: Value(monthId),
      date: Value(date),
      description: Value(description),
      amount: Value(amount),
      pillar: Value(pillar),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory V4ExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return V4ExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      monthId: serializer.fromJson<String>(json['monthId']),
      date: serializer.fromJson<String>(json['date']),
      description: serializer.fromJson<String>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      pillar: serializer.fromJson<String>(json['pillar']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'monthId': serializer.toJson<String>(monthId),
      'date': serializer.toJson<String>(date),
      'description': serializer.toJson<String>(description),
      'amount': serializer.toJson<double>(amount),
      'pillar': serializer.toJson<String>(pillar),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  V4ExpenseRow copyWith({
    String? id,
    String? monthId,
    String? date,
    String? description,
    double? amount,
    String? pillar,
    String? notes,
    int? createdAt,
  }) => V4ExpenseRow(
    id: id ?? this.id,
    monthId: monthId ?? this.monthId,
    date: date ?? this.date,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    pillar: pillar ?? this.pillar,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  V4ExpenseRow copyWithCompanion(V4ExpensesCompanion data) {
    return V4ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      monthId: data.monthId.present ? data.monthId.value : this.monthId,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      pillar: data.pillar.present ? data.pillar.value : this.pillar,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('V4ExpenseRow(')
          ..write('id: $id, ')
          ..write('monthId: $monthId, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('pillar: $pillar, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    monthId,
    date,
    description,
    amount,
    pillar,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is V4ExpenseRow &&
          other.id == this.id &&
          other.monthId == this.monthId &&
          other.date == this.date &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.pillar == this.pillar &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class V4ExpensesCompanion extends UpdateCompanion<V4ExpenseRow> {
  final Value<String> id;
  final Value<String> monthId;
  final Value<String> date;
  final Value<String> description;
  final Value<double> amount;
  final Value<String> pillar;
  final Value<String> notes;
  final Value<int> createdAt;
  final Value<int> rowid;
  const V4ExpensesCompanion({
    this.id = const Value.absent(),
    this.monthId = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.pillar = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  V4ExpensesCompanion.insert({
    required String id,
    required String monthId,
    required String date,
    required String description,
    required double amount,
    required String pillar,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       monthId = Value(monthId),
       date = Value(date),
       description = Value(description),
       amount = Value(amount),
       pillar = Value(pillar);
  static Insertable<V4ExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? monthId,
    Expression<String>? date,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<String>? pillar,
    Expression<String>? notes,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthId != null) 'month_id': monthId,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (pillar != null) 'pillar': pillar,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  V4ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? monthId,
    Value<String>? date,
    Value<String>? description,
    Value<double>? amount,
    Value<String>? pillar,
    Value<String>? notes,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return V4ExpensesCompanion(
      id: id ?? this.id,
      monthId: monthId ?? this.monthId,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      pillar: pillar ?? this.pillar,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (monthId.present) {
      map['month_id'] = Variable<String>(monthId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (pillar.present) {
      map['pillar'] = Variable<String>(pillar.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('V4ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('monthId: $monthId, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('pillar: $pillar, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $V4FixedExpensesTable extends V4FixedExpenses
    with TableInfo<$V4FixedExpensesTable, V4FixedExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $V4FixedExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthIdMeta = const VerificationMeta(
    'monthId',
  );
  @override
  late final GeneratedColumn<String> monthId = GeneratedColumn<String>(
    'month_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES kakeibo_months (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    monthId,
    name,
    amount,
    category,
    dueDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fixed_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<V4FixedExpenseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('month_id')) {
      context.handle(
        _monthIdMeta,
        monthId.isAcceptableOrUnknown(data['month_id']!, _monthIdMeta),
      );
    } else if (isInserting) {
      context.missing(_monthIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  V4FixedExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return V4FixedExpenseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      monthId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      ),
    );
  }

  @override
  $V4FixedExpensesTable createAlias(String alias) {
    return $V4FixedExpensesTable(attachedDatabase, alias);
  }
}

class V4FixedExpenseRow extends DataClass
    implements Insertable<V4FixedExpenseRow> {
  final String id;
  final String monthId;
  final String name;
  final double amount;
  final String category;
  final int? dueDay;
  const V4FixedExpenseRow({
    required this.id,
    required this.monthId,
    required this.name,
    required this.amount,
    required this.category,
    this.dueDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['month_id'] = Variable<String>(monthId);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || dueDay != null) {
      map['due_day'] = Variable<int>(dueDay);
    }
    return map;
  }

  V4FixedExpensesCompanion toCompanion(bool nullToAbsent) {
    return V4FixedExpensesCompanion(
      id: Value(id),
      monthId: Value(monthId),
      name: Value(name),
      amount: Value(amount),
      category: Value(category),
      dueDay: dueDay == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDay),
    );
  }

  factory V4FixedExpenseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return V4FixedExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      monthId: serializer.fromJson<String>(json['monthId']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      dueDay: serializer.fromJson<int?>(json['dueDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'monthId': serializer.toJson<String>(monthId),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'dueDay': serializer.toJson<int?>(dueDay),
    };
  }

  V4FixedExpenseRow copyWith({
    String? id,
    String? monthId,
    String? name,
    double? amount,
    String? category,
    Value<int?> dueDay = const Value.absent(),
  }) => V4FixedExpenseRow(
    id: id ?? this.id,
    monthId: monthId ?? this.monthId,
    name: name ?? this.name,
    amount: amount ?? this.amount,
    category: category ?? this.category,
    dueDay: dueDay.present ? dueDay.value : this.dueDay,
  );
  V4FixedExpenseRow copyWithCompanion(V4FixedExpensesCompanion data) {
    return V4FixedExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      monthId: data.monthId.present ? data.monthId.value : this.monthId,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('V4FixedExpenseRow(')
          ..write('id: $id, ')
          ..write('monthId: $monthId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('dueDay: $dueDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, monthId, name, amount, category, dueDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is V4FixedExpenseRow &&
          other.id == this.id &&
          other.monthId == this.monthId &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.dueDay == this.dueDay);
}

class V4FixedExpensesCompanion extends UpdateCompanion<V4FixedExpenseRow> {
  final Value<String> id;
  final Value<String> monthId;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> category;
  final Value<int?> dueDay;
  final Value<int> rowid;
  const V4FixedExpensesCompanion({
    this.id = const Value.absent(),
    this.monthId = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  V4FixedExpensesCompanion.insert({
    required String id,
    required String monthId,
    required String name,
    required double amount,
    this.category = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       monthId = Value(monthId),
       name = Value(name),
       amount = Value(amount);
  static Insertable<V4FixedExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? monthId,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<int>? dueDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthId != null) 'month_id': monthId,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (dueDay != null) 'due_day': dueDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  V4FixedExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? monthId,
    Value<String>? name,
    Value<double>? amount,
    Value<String>? category,
    Value<int?>? dueDay,
    Value<int>? rowid,
  }) {
    return V4FixedExpensesCompanion(
      id: id ?? this.id,
      monthId: monthId ?? this.monthId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      dueDay: dueDay ?? this.dueDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (monthId.present) {
      map['month_id'] = Variable<String>(monthId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('V4FixedExpensesCompanion(')
          ..write('id: $id, ')
          ..write('monthId: $monthId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('dueDay: $dueDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $V4IncomeSourcesTable extends V4IncomeSources
    with TableInfo<$V4IncomeSourcesTable, V4IncomeSourceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $V4IncomeSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthIdMeta = const VerificationMeta(
    'monthId',
  );
  @override
  late final GeneratedColumn<String> monthId = GeneratedColumn<String>(
    'month_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES kakeibo_months (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, monthId, name, amount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'income_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<V4IncomeSourceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('month_id')) {
      context.handle(
        _monthIdMeta,
        monthId.isAcceptableOrUnknown(data['month_id']!, _monthIdMeta),
      );
    } else if (isInserting) {
      context.missing(_monthIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  V4IncomeSourceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return V4IncomeSourceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      monthId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $V4IncomeSourcesTable createAlias(String alias) {
    return $V4IncomeSourcesTable(attachedDatabase, alias);
  }
}

class V4IncomeSourceRow extends DataClass
    implements Insertable<V4IncomeSourceRow> {
  final String id;
  final String monthId;
  final String name;
  final double amount;
  const V4IncomeSourceRow({
    required this.id,
    required this.monthId,
    required this.name,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['month_id'] = Variable<String>(monthId);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    return map;
  }

  V4IncomeSourcesCompanion toCompanion(bool nullToAbsent) {
    return V4IncomeSourcesCompanion(
      id: Value(id),
      monthId: Value(monthId),
      name: Value(name),
      amount: Value(amount),
    );
  }

  factory V4IncomeSourceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return V4IncomeSourceRow(
      id: serializer.fromJson<String>(json['id']),
      monthId: serializer.fromJson<String>(json['monthId']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'monthId': serializer.toJson<String>(monthId),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
    };
  }

  V4IncomeSourceRow copyWith({
    String? id,
    String? monthId,
    String? name,
    double? amount,
  }) => V4IncomeSourceRow(
    id: id ?? this.id,
    monthId: monthId ?? this.monthId,
    name: name ?? this.name,
    amount: amount ?? this.amount,
  );
  V4IncomeSourceRow copyWithCompanion(V4IncomeSourcesCompanion data) {
    return V4IncomeSourceRow(
      id: data.id.present ? data.id.value : this.id,
      monthId: data.monthId.present ? data.monthId.value : this.monthId,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('V4IncomeSourceRow(')
          ..write('id: $id, ')
          ..write('monthId: $monthId, ')
          ..write('name: $name, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, monthId, name, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is V4IncomeSourceRow &&
          other.id == this.id &&
          other.monthId == this.monthId &&
          other.name == this.name &&
          other.amount == this.amount);
}

class V4IncomeSourcesCompanion extends UpdateCompanion<V4IncomeSourceRow> {
  final Value<String> id;
  final Value<String> monthId;
  final Value<String> name;
  final Value<double> amount;
  final Value<int> rowid;
  const V4IncomeSourcesCompanion({
    this.id = const Value.absent(),
    this.monthId = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  V4IncomeSourcesCompanion.insert({
    required String id,
    required String monthId,
    required String name,
    required double amount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       monthId = Value(monthId),
       name = Value(name),
       amount = Value(amount);
  static Insertable<V4IncomeSourceRow> custom({
    Expression<String>? id,
    Expression<String>? monthId,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthId != null) 'month_id': monthId,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  V4IncomeSourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? monthId,
    Value<String>? name,
    Value<double>? amount,
    Value<int>? rowid,
  }) {
    return V4IncomeSourcesCompanion(
      id: id ?? this.id,
      monthId: monthId ?? this.monthId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (monthId.present) {
      map['month_id'] = Variable<String>(monthId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('V4IncomeSourcesCompanion(')
          ..write('id: $id, ')
          ..write('monthId: $monthId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $V4AppSettingsTable extends V4AppSettings
    with TableInfo<$V4AppSettingsTable, V4AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $V4AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<V4AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  V4AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return V4AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $V4AppSettingsTable createAlias(String alias) {
    return $V4AppSettingsTable(attachedDatabase, alias);
  }
}

class V4AppSettingRow extends DataClass implements Insertable<V4AppSettingRow> {
  final String key;
  final String value;
  const V4AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  V4AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return V4AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory V4AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return V4AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  V4AppSettingRow copyWith({String? key, String? value}) =>
      V4AppSettingRow(key: key ?? this.key, value: value ?? this.value);
  V4AppSettingRow copyWithCompanion(V4AppSettingsCompanion data) {
    return V4AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('V4AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is V4AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class V4AppSettingsCompanion extends UpdateCompanion<V4AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const V4AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  V4AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<V4AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  V4AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return V4AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('V4AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$_V4Database extends GeneratedDatabase {
  _$_V4Database(QueryExecutor e) : super(e);
  $_V4DatabaseManager get managers => $_V4DatabaseManager(this);
  late final $V4KakeiboMonthsTable v4KakeiboMonths = $V4KakeiboMonthsTable(
    this,
  );
  late final $V4ExpensesTable v4Expenses = $V4ExpensesTable(this);
  late final $V4FixedExpensesTable v4FixedExpenses = $V4FixedExpensesTable(
    this,
  );
  late final $V4IncomeSourcesTable v4IncomeSources = $V4IncomeSourcesTable(
    this,
  );
  late final $V4AppSettingsTable v4AppSettings = $V4AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    v4KakeiboMonths,
    v4Expenses,
    v4FixedExpenses,
    v4IncomeSources,
    v4AppSettings,
  ];
}

typedef $$V4KakeiboMonthsTableCreateCompanionBuilder =
    V4KakeiboMonthsCompanion Function({
      required String id,
      required int year,
      required int month,
      Value<double> income,
      Value<double> savingsGoal,
      Value<String> reflectionJson,
      Value<int> rowid,
    });
typedef $$V4KakeiboMonthsTableUpdateCompanionBuilder =
    V4KakeiboMonthsCompanion Function({
      Value<String> id,
      Value<int> year,
      Value<int> month,
      Value<double> income,
      Value<double> savingsGoal,
      Value<String> reflectionJson,
      Value<int> rowid,
    });

final class $$V4KakeiboMonthsTableReferences
    extends
        BaseReferences<
          _$_V4Database,
          $V4KakeiboMonthsTable,
          V4KakeiboMonthRow
        > {
  $$V4KakeiboMonthsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$V4ExpensesTable, List<V4ExpenseRow>>
  _v4ExpensesRefsTable(_$_V4Database db) => MultiTypedResultKey.fromTable(
    db.v4Expenses,
    aliasName: $_aliasNameGenerator(
      db.v4KakeiboMonths.id,
      db.v4Expenses.monthId,
    ),
  );

  $$V4ExpensesTableProcessedTableManager get v4ExpensesRefs {
    final manager = $$V4ExpensesTableTableManager(
      $_db,
      $_db.v4Expenses,
    ).filter((f) => f.monthId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_v4ExpensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$V4FixedExpensesTable, List<V4FixedExpenseRow>>
  _v4FixedExpensesRefsTable(_$_V4Database db) => MultiTypedResultKey.fromTable(
    db.v4FixedExpenses,
    aliasName: $_aliasNameGenerator(
      db.v4KakeiboMonths.id,
      db.v4FixedExpenses.monthId,
    ),
  );

  $$V4FixedExpensesTableProcessedTableManager get v4FixedExpensesRefs {
    final manager = $$V4FixedExpensesTableTableManager(
      $_db,
      $_db.v4FixedExpenses,
    ).filter((f) => f.monthId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _v4FixedExpensesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$V4IncomeSourcesTable, List<V4IncomeSourceRow>>
  _v4IncomeSourcesRefsTable(_$_V4Database db) => MultiTypedResultKey.fromTable(
    db.v4IncomeSources,
    aliasName: $_aliasNameGenerator(
      db.v4KakeiboMonths.id,
      db.v4IncomeSources.monthId,
    ),
  );

  $$V4IncomeSourcesTableProcessedTableManager get v4IncomeSourcesRefs {
    final manager = $$V4IncomeSourcesTableTableManager(
      $_db,
      $_db.v4IncomeSources,
    ).filter((f) => f.monthId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _v4IncomeSourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$V4KakeiboMonthsTableFilterComposer
    extends Composer<_$_V4Database, $V4KakeiboMonthsTable> {
  $$V4KakeiboMonthsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get income => $composableBuilder(
    column: $table.income,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get savingsGoal => $composableBuilder(
    column: $table.savingsGoal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflectionJson => $composableBuilder(
    column: $table.reflectionJson,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> v4ExpensesRefs(
    Expression<bool> Function($$V4ExpensesTableFilterComposer f) f,
  ) {
    final $$V4ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.v4Expenses,
      getReferencedColumn: (t) => t.monthId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.v4Expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> v4FixedExpensesRefs(
    Expression<bool> Function($$V4FixedExpensesTableFilterComposer f) f,
  ) {
    final $$V4FixedExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.v4FixedExpenses,
      getReferencedColumn: (t) => t.monthId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4FixedExpensesTableFilterComposer(
            $db: $db,
            $table: $db.v4FixedExpenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> v4IncomeSourcesRefs(
    Expression<bool> Function($$V4IncomeSourcesTableFilterComposer f) f,
  ) {
    final $$V4IncomeSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.v4IncomeSources,
      getReferencedColumn: (t) => t.monthId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4IncomeSourcesTableFilterComposer(
            $db: $db,
            $table: $db.v4IncomeSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$V4KakeiboMonthsTableOrderingComposer
    extends Composer<_$_V4Database, $V4KakeiboMonthsTable> {
  $$V4KakeiboMonthsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get income => $composableBuilder(
    column: $table.income,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get savingsGoal => $composableBuilder(
    column: $table.savingsGoal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflectionJson => $composableBuilder(
    column: $table.reflectionJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$V4KakeiboMonthsTableAnnotationComposer
    extends Composer<_$_V4Database, $V4KakeiboMonthsTable> {
  $$V4KakeiboMonthsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<double> get income =>
      $composableBuilder(column: $table.income, builder: (column) => column);

  GeneratedColumn<double> get savingsGoal => $composableBuilder(
    column: $table.savingsGoal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reflectionJson => $composableBuilder(
    column: $table.reflectionJson,
    builder: (column) => column,
  );

  Expression<T> v4ExpensesRefs<T extends Object>(
    Expression<T> Function($$V4ExpensesTableAnnotationComposer a) f,
  ) {
    final $$V4ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.v4Expenses,
      getReferencedColumn: (t) => t.monthId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.v4Expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> v4FixedExpensesRefs<T extends Object>(
    Expression<T> Function($$V4FixedExpensesTableAnnotationComposer a) f,
  ) {
    final $$V4FixedExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.v4FixedExpenses,
      getReferencedColumn: (t) => t.monthId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4FixedExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.v4FixedExpenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> v4IncomeSourcesRefs<T extends Object>(
    Expression<T> Function($$V4IncomeSourcesTableAnnotationComposer a) f,
  ) {
    final $$V4IncomeSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.v4IncomeSources,
      getReferencedColumn: (t) => t.monthId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4IncomeSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.v4IncomeSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$V4KakeiboMonthsTableTableManager
    extends
        RootTableManager<
          _$_V4Database,
          $V4KakeiboMonthsTable,
          V4KakeiboMonthRow,
          $$V4KakeiboMonthsTableFilterComposer,
          $$V4KakeiboMonthsTableOrderingComposer,
          $$V4KakeiboMonthsTableAnnotationComposer,
          $$V4KakeiboMonthsTableCreateCompanionBuilder,
          $$V4KakeiboMonthsTableUpdateCompanionBuilder,
          (V4KakeiboMonthRow, $$V4KakeiboMonthsTableReferences),
          V4KakeiboMonthRow,
          PrefetchHooks Function({
            bool v4ExpensesRefs,
            bool v4FixedExpensesRefs,
            bool v4IncomeSourcesRefs,
          })
        > {
  $$V4KakeiboMonthsTableTableManager(
    _$_V4Database db,
    $V4KakeiboMonthsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$V4KakeiboMonthsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$V4KakeiboMonthsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$V4KakeiboMonthsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> month = const Value.absent(),
                Value<double> income = const Value.absent(),
                Value<double> savingsGoal = const Value.absent(),
                Value<String> reflectionJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => V4KakeiboMonthsCompanion(
                id: id,
                year: year,
                month: month,
                income: income,
                savingsGoal: savingsGoal,
                reflectionJson: reflectionJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int year,
                required int month,
                Value<double> income = const Value.absent(),
                Value<double> savingsGoal = const Value.absent(),
                Value<String> reflectionJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => V4KakeiboMonthsCompanion.insert(
                id: id,
                year: year,
                month: month,
                income: income,
                savingsGoal: savingsGoal,
                reflectionJson: reflectionJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$V4KakeiboMonthsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                v4ExpensesRefs = false,
                v4FixedExpensesRefs = false,
                v4IncomeSourcesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (v4ExpensesRefs) db.v4Expenses,
                    if (v4FixedExpensesRefs) db.v4FixedExpenses,
                    if (v4IncomeSourcesRefs) db.v4IncomeSources,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (v4ExpensesRefs)
                        await $_getPrefetchedData<
                          V4KakeiboMonthRow,
                          $V4KakeiboMonthsTable,
                          V4ExpenseRow
                        >(
                          currentTable: table,
                          referencedTable: $$V4KakeiboMonthsTableReferences
                              ._v4ExpensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$V4KakeiboMonthsTableReferences(
                                db,
                                table,
                                p0,
                              ).v4ExpensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.monthId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (v4FixedExpensesRefs)
                        await $_getPrefetchedData<
                          V4KakeiboMonthRow,
                          $V4KakeiboMonthsTable,
                          V4FixedExpenseRow
                        >(
                          currentTable: table,
                          referencedTable: $$V4KakeiboMonthsTableReferences
                              ._v4FixedExpensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$V4KakeiboMonthsTableReferences(
                                db,
                                table,
                                p0,
                              ).v4FixedExpensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.monthId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (v4IncomeSourcesRefs)
                        await $_getPrefetchedData<
                          V4KakeiboMonthRow,
                          $V4KakeiboMonthsTable,
                          V4IncomeSourceRow
                        >(
                          currentTable: table,
                          referencedTable: $$V4KakeiboMonthsTableReferences
                              ._v4IncomeSourcesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$V4KakeiboMonthsTableReferences(
                                db,
                                table,
                                p0,
                              ).v4IncomeSourcesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.monthId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$V4KakeiboMonthsTableProcessedTableManager =
    ProcessedTableManager<
      _$_V4Database,
      $V4KakeiboMonthsTable,
      V4KakeiboMonthRow,
      $$V4KakeiboMonthsTableFilterComposer,
      $$V4KakeiboMonthsTableOrderingComposer,
      $$V4KakeiboMonthsTableAnnotationComposer,
      $$V4KakeiboMonthsTableCreateCompanionBuilder,
      $$V4KakeiboMonthsTableUpdateCompanionBuilder,
      (V4KakeiboMonthRow, $$V4KakeiboMonthsTableReferences),
      V4KakeiboMonthRow,
      PrefetchHooks Function({
        bool v4ExpensesRefs,
        bool v4FixedExpensesRefs,
        bool v4IncomeSourcesRefs,
      })
    >;
typedef $$V4ExpensesTableCreateCompanionBuilder =
    V4ExpensesCompanion Function({
      required String id,
      required String monthId,
      required String date,
      required String description,
      required double amount,
      required String pillar,
      Value<String> notes,
      Value<int> createdAt,
      Value<int> rowid,
    });
typedef $$V4ExpensesTableUpdateCompanionBuilder =
    V4ExpensesCompanion Function({
      Value<String> id,
      Value<String> monthId,
      Value<String> date,
      Value<String> description,
      Value<double> amount,
      Value<String> pillar,
      Value<String> notes,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$V4ExpensesTableReferences
    extends BaseReferences<_$_V4Database, $V4ExpensesTable, V4ExpenseRow> {
  $$V4ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $V4KakeiboMonthsTable _monthIdTable(_$_V4Database db) =>
      db.v4KakeiboMonths.createAlias(
        $_aliasNameGenerator(db.v4Expenses.monthId, db.v4KakeiboMonths.id),
      );

  $$V4KakeiboMonthsTableProcessedTableManager get monthId {
    final $_column = $_itemColumn<String>('month_id')!;

    final manager = $$V4KakeiboMonthsTableTableManager(
      $_db,
      $_db.v4KakeiboMonths,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_monthIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$V4ExpensesTableFilterComposer
    extends Composer<_$_V4Database, $V4ExpensesTable> {
  $$V4ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pillar => $composableBuilder(
    column: $table.pillar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$V4KakeiboMonthsTableFilterComposer get monthId {
    final $$V4KakeiboMonthsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monthId,
      referencedTable: $db.v4KakeiboMonths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4KakeiboMonthsTableFilterComposer(
            $db: $db,
            $table: $db.v4KakeiboMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$V4ExpensesTableOrderingComposer
    extends Composer<_$_V4Database, $V4ExpensesTable> {
  $$V4ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pillar => $composableBuilder(
    column: $table.pillar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$V4KakeiboMonthsTableOrderingComposer get monthId {
    final $$V4KakeiboMonthsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monthId,
      referencedTable: $db.v4KakeiboMonths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4KakeiboMonthsTableOrderingComposer(
            $db: $db,
            $table: $db.v4KakeiboMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$V4ExpensesTableAnnotationComposer
    extends Composer<_$_V4Database, $V4ExpensesTable> {
  $$V4ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get pillar =>
      $composableBuilder(column: $table.pillar, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$V4KakeiboMonthsTableAnnotationComposer get monthId {
    final $$V4KakeiboMonthsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monthId,
      referencedTable: $db.v4KakeiboMonths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4KakeiboMonthsTableAnnotationComposer(
            $db: $db,
            $table: $db.v4KakeiboMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$V4ExpensesTableTableManager
    extends
        RootTableManager<
          _$_V4Database,
          $V4ExpensesTable,
          V4ExpenseRow,
          $$V4ExpensesTableFilterComposer,
          $$V4ExpensesTableOrderingComposer,
          $$V4ExpensesTableAnnotationComposer,
          $$V4ExpensesTableCreateCompanionBuilder,
          $$V4ExpensesTableUpdateCompanionBuilder,
          (V4ExpenseRow, $$V4ExpensesTableReferences),
          V4ExpenseRow,
          PrefetchHooks Function({bool monthId})
        > {
  $$V4ExpensesTableTableManager(_$_V4Database db, $V4ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$V4ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$V4ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$V4ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> monthId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> pillar = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => V4ExpensesCompanion(
                id: id,
                monthId: monthId,
                date: date,
                description: description,
                amount: amount,
                pillar: pillar,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String monthId,
                required String date,
                required String description,
                required double amount,
                required String pillar,
                Value<String> notes = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => V4ExpensesCompanion.insert(
                id: id,
                monthId: monthId,
                date: date,
                description: description,
                amount: amount,
                pillar: pillar,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$V4ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({monthId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (monthId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.monthId,
                                referencedTable: $$V4ExpensesTableReferences
                                    ._monthIdTable(db),
                                referencedColumn: $$V4ExpensesTableReferences
                                    ._monthIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$V4ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$_V4Database,
      $V4ExpensesTable,
      V4ExpenseRow,
      $$V4ExpensesTableFilterComposer,
      $$V4ExpensesTableOrderingComposer,
      $$V4ExpensesTableAnnotationComposer,
      $$V4ExpensesTableCreateCompanionBuilder,
      $$V4ExpensesTableUpdateCompanionBuilder,
      (V4ExpenseRow, $$V4ExpensesTableReferences),
      V4ExpenseRow,
      PrefetchHooks Function({bool monthId})
    >;
typedef $$V4FixedExpensesTableCreateCompanionBuilder =
    V4FixedExpensesCompanion Function({
      required String id,
      required String monthId,
      required String name,
      required double amount,
      Value<String> category,
      Value<int?> dueDay,
      Value<int> rowid,
    });
typedef $$V4FixedExpensesTableUpdateCompanionBuilder =
    V4FixedExpensesCompanion Function({
      Value<String> id,
      Value<String> monthId,
      Value<String> name,
      Value<double> amount,
      Value<String> category,
      Value<int?> dueDay,
      Value<int> rowid,
    });

final class $$V4FixedExpensesTableReferences
    extends
        BaseReferences<
          _$_V4Database,
          $V4FixedExpensesTable,
          V4FixedExpenseRow
        > {
  $$V4FixedExpensesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $V4KakeiboMonthsTable _monthIdTable(_$_V4Database db) =>
      db.v4KakeiboMonths.createAlias(
        $_aliasNameGenerator(db.v4FixedExpenses.monthId, db.v4KakeiboMonths.id),
      );

  $$V4KakeiboMonthsTableProcessedTableManager get monthId {
    final $_column = $_itemColumn<String>('month_id')!;

    final manager = $$V4KakeiboMonthsTableTableManager(
      $_db,
      $_db.v4KakeiboMonths,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_monthIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$V4FixedExpensesTableFilterComposer
    extends Composer<_$_V4Database, $V4FixedExpensesTable> {
  $$V4FixedExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  $$V4KakeiboMonthsTableFilterComposer get monthId {
    final $$V4KakeiboMonthsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monthId,
      referencedTable: $db.v4KakeiboMonths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4KakeiboMonthsTableFilterComposer(
            $db: $db,
            $table: $db.v4KakeiboMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$V4FixedExpensesTableOrderingComposer
    extends Composer<_$_V4Database, $V4FixedExpensesTable> {
  $$V4FixedExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  $$V4KakeiboMonthsTableOrderingComposer get monthId {
    final $$V4KakeiboMonthsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monthId,
      referencedTable: $db.v4KakeiboMonths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4KakeiboMonthsTableOrderingComposer(
            $db: $db,
            $table: $db.v4KakeiboMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$V4FixedExpensesTableAnnotationComposer
    extends Composer<_$_V4Database, $V4FixedExpensesTable> {
  $$V4FixedExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  $$V4KakeiboMonthsTableAnnotationComposer get monthId {
    final $$V4KakeiboMonthsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monthId,
      referencedTable: $db.v4KakeiboMonths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4KakeiboMonthsTableAnnotationComposer(
            $db: $db,
            $table: $db.v4KakeiboMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$V4FixedExpensesTableTableManager
    extends
        RootTableManager<
          _$_V4Database,
          $V4FixedExpensesTable,
          V4FixedExpenseRow,
          $$V4FixedExpensesTableFilterComposer,
          $$V4FixedExpensesTableOrderingComposer,
          $$V4FixedExpensesTableAnnotationComposer,
          $$V4FixedExpensesTableCreateCompanionBuilder,
          $$V4FixedExpensesTableUpdateCompanionBuilder,
          (V4FixedExpenseRow, $$V4FixedExpensesTableReferences),
          V4FixedExpenseRow,
          PrefetchHooks Function({bool monthId})
        > {
  $$V4FixedExpensesTableTableManager(
    _$_V4Database db,
    $V4FixedExpensesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$V4FixedExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$V4FixedExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$V4FixedExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> monthId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => V4FixedExpensesCompanion(
                id: id,
                monthId: monthId,
                name: name,
                amount: amount,
                category: category,
                dueDay: dueDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String monthId,
                required String name,
                required double amount,
                Value<String> category = const Value.absent(),
                Value<int?> dueDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => V4FixedExpensesCompanion.insert(
                id: id,
                monthId: monthId,
                name: name,
                amount: amount,
                category: category,
                dueDay: dueDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$V4FixedExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({monthId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (monthId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.monthId,
                                referencedTable:
                                    $$V4FixedExpensesTableReferences
                                        ._monthIdTable(db),
                                referencedColumn:
                                    $$V4FixedExpensesTableReferences
                                        ._monthIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$V4FixedExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$_V4Database,
      $V4FixedExpensesTable,
      V4FixedExpenseRow,
      $$V4FixedExpensesTableFilterComposer,
      $$V4FixedExpensesTableOrderingComposer,
      $$V4FixedExpensesTableAnnotationComposer,
      $$V4FixedExpensesTableCreateCompanionBuilder,
      $$V4FixedExpensesTableUpdateCompanionBuilder,
      (V4FixedExpenseRow, $$V4FixedExpensesTableReferences),
      V4FixedExpenseRow,
      PrefetchHooks Function({bool monthId})
    >;
typedef $$V4IncomeSourcesTableCreateCompanionBuilder =
    V4IncomeSourcesCompanion Function({
      required String id,
      required String monthId,
      required String name,
      required double amount,
      Value<int> rowid,
    });
typedef $$V4IncomeSourcesTableUpdateCompanionBuilder =
    V4IncomeSourcesCompanion Function({
      Value<String> id,
      Value<String> monthId,
      Value<String> name,
      Value<double> amount,
      Value<int> rowid,
    });

final class $$V4IncomeSourcesTableReferences
    extends
        BaseReferences<
          _$_V4Database,
          $V4IncomeSourcesTable,
          V4IncomeSourceRow
        > {
  $$V4IncomeSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $V4KakeiboMonthsTable _monthIdTable(_$_V4Database db) =>
      db.v4KakeiboMonths.createAlias(
        $_aliasNameGenerator(db.v4IncomeSources.monthId, db.v4KakeiboMonths.id),
      );

  $$V4KakeiboMonthsTableProcessedTableManager get monthId {
    final $_column = $_itemColumn<String>('month_id')!;

    final manager = $$V4KakeiboMonthsTableTableManager(
      $_db,
      $_db.v4KakeiboMonths,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_monthIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$V4IncomeSourcesTableFilterComposer
    extends Composer<_$_V4Database, $V4IncomeSourcesTable> {
  $$V4IncomeSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$V4KakeiboMonthsTableFilterComposer get monthId {
    final $$V4KakeiboMonthsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monthId,
      referencedTable: $db.v4KakeiboMonths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4KakeiboMonthsTableFilterComposer(
            $db: $db,
            $table: $db.v4KakeiboMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$V4IncomeSourcesTableOrderingComposer
    extends Composer<_$_V4Database, $V4IncomeSourcesTable> {
  $$V4IncomeSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$V4KakeiboMonthsTableOrderingComposer get monthId {
    final $$V4KakeiboMonthsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monthId,
      referencedTable: $db.v4KakeiboMonths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4KakeiboMonthsTableOrderingComposer(
            $db: $db,
            $table: $db.v4KakeiboMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$V4IncomeSourcesTableAnnotationComposer
    extends Composer<_$_V4Database, $V4IncomeSourcesTable> {
  $$V4IncomeSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$V4KakeiboMonthsTableAnnotationComposer get monthId {
    final $$V4KakeiboMonthsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.monthId,
      referencedTable: $db.v4KakeiboMonths,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$V4KakeiboMonthsTableAnnotationComposer(
            $db: $db,
            $table: $db.v4KakeiboMonths,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$V4IncomeSourcesTableTableManager
    extends
        RootTableManager<
          _$_V4Database,
          $V4IncomeSourcesTable,
          V4IncomeSourceRow,
          $$V4IncomeSourcesTableFilterComposer,
          $$V4IncomeSourcesTableOrderingComposer,
          $$V4IncomeSourcesTableAnnotationComposer,
          $$V4IncomeSourcesTableCreateCompanionBuilder,
          $$V4IncomeSourcesTableUpdateCompanionBuilder,
          (V4IncomeSourceRow, $$V4IncomeSourcesTableReferences),
          V4IncomeSourceRow,
          PrefetchHooks Function({bool monthId})
        > {
  $$V4IncomeSourcesTableTableManager(
    _$_V4Database db,
    $V4IncomeSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$V4IncomeSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$V4IncomeSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$V4IncomeSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> monthId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => V4IncomeSourcesCompanion(
                id: id,
                monthId: monthId,
                name: name,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String monthId,
                required String name,
                required double amount,
                Value<int> rowid = const Value.absent(),
              }) => V4IncomeSourcesCompanion.insert(
                id: id,
                monthId: monthId,
                name: name,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$V4IncomeSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({monthId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (monthId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.monthId,
                                referencedTable:
                                    $$V4IncomeSourcesTableReferences
                                        ._monthIdTable(db),
                                referencedColumn:
                                    $$V4IncomeSourcesTableReferences
                                        ._monthIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$V4IncomeSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$_V4Database,
      $V4IncomeSourcesTable,
      V4IncomeSourceRow,
      $$V4IncomeSourcesTableFilterComposer,
      $$V4IncomeSourcesTableOrderingComposer,
      $$V4IncomeSourcesTableAnnotationComposer,
      $$V4IncomeSourcesTableCreateCompanionBuilder,
      $$V4IncomeSourcesTableUpdateCompanionBuilder,
      (V4IncomeSourceRow, $$V4IncomeSourcesTableReferences),
      V4IncomeSourceRow,
      PrefetchHooks Function({bool monthId})
    >;
typedef $$V4AppSettingsTableCreateCompanionBuilder =
    V4AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$V4AppSettingsTableUpdateCompanionBuilder =
    V4AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$V4AppSettingsTableFilterComposer
    extends Composer<_$_V4Database, $V4AppSettingsTable> {
  $$V4AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$V4AppSettingsTableOrderingComposer
    extends Composer<_$_V4Database, $V4AppSettingsTable> {
  $$V4AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$V4AppSettingsTableAnnotationComposer
    extends Composer<_$_V4Database, $V4AppSettingsTable> {
  $$V4AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$V4AppSettingsTableTableManager
    extends
        RootTableManager<
          _$_V4Database,
          $V4AppSettingsTable,
          V4AppSettingRow,
          $$V4AppSettingsTableFilterComposer,
          $$V4AppSettingsTableOrderingComposer,
          $$V4AppSettingsTableAnnotationComposer,
          $$V4AppSettingsTableCreateCompanionBuilder,
          $$V4AppSettingsTableUpdateCompanionBuilder,
          (
            V4AppSettingRow,
            BaseReferences<_$_V4Database, $V4AppSettingsTable, V4AppSettingRow>,
          ),
          V4AppSettingRow,
          PrefetchHooks Function()
        > {
  $$V4AppSettingsTableTableManager(_$_V4Database db, $V4AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$V4AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$V4AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$V4AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  V4AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => V4AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$V4AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$_V4Database,
      $V4AppSettingsTable,
      V4AppSettingRow,
      $$V4AppSettingsTableFilterComposer,
      $$V4AppSettingsTableOrderingComposer,
      $$V4AppSettingsTableAnnotationComposer,
      $$V4AppSettingsTableCreateCompanionBuilder,
      $$V4AppSettingsTableUpdateCompanionBuilder,
      (
        V4AppSettingRow,
        BaseReferences<_$_V4Database, $V4AppSettingsTable, V4AppSettingRow>,
      ),
      V4AppSettingRow,
      PrefetchHooks Function()
    >;

class $_V4DatabaseManager {
  final _$_V4Database _db;
  $_V4DatabaseManager(this._db);
  $$V4KakeiboMonthsTableTableManager get v4KakeiboMonths =>
      $$V4KakeiboMonthsTableTableManager(_db, _db.v4KakeiboMonths);
  $$V4ExpensesTableTableManager get v4Expenses =>
      $$V4ExpensesTableTableManager(_db, _db.v4Expenses);
  $$V4FixedExpensesTableTableManager get v4FixedExpenses =>
      $$V4FixedExpensesTableTableManager(_db, _db.v4FixedExpenses);
  $$V4IncomeSourcesTableTableManager get v4IncomeSources =>
      $$V4IncomeSourcesTableTableManager(_db, _db.v4IncomeSources);
  $$V4AppSettingsTableTableManager get v4AppSettings =>
      $$V4AppSettingsTableTableManager(_db, _db.v4AppSettings);
}
