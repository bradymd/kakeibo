// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kakeibo_month.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

KakeiboMonth _$KakeiboMonthFromJson(Map<String, dynamic> json) {
  return _KakeiboMonth.fromJson(json);
}

/// @nodoc
mixin _$KakeiboMonth {
  String get id => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  double get income => throw _privateConstructorUsedError;
  List<IncomeSource> get incomeSources => throw _privateConstructorUsedError;
  List<FixedExpense> get fixedExpenses => throw _privateConstructorUsedError;
  double get savingsGoal => throw _privateConstructorUsedError;
  List<KakeiboExpense> get expenses => throw _privateConstructorUsedError;
  Reflection get reflection => throw _privateConstructorUsedError;

  /// Serializes this KakeiboMonth to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KakeiboMonth
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KakeiboMonthCopyWith<KakeiboMonth> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KakeiboMonthCopyWith<$Res> {
  factory $KakeiboMonthCopyWith(
    KakeiboMonth value,
    $Res Function(KakeiboMonth) then,
  ) = _$KakeiboMonthCopyWithImpl<$Res, KakeiboMonth>;
  @useResult
  $Res call({
    String id,
    int year,
    int month,
    double income,
    List<IncomeSource> incomeSources,
    List<FixedExpense> fixedExpenses,
    double savingsGoal,
    List<KakeiboExpense> expenses,
    Reflection reflection,
  });

  $ReflectionCopyWith<$Res> get reflection;
}

/// @nodoc
class _$KakeiboMonthCopyWithImpl<$Res, $Val extends KakeiboMonth>
    implements $KakeiboMonthCopyWith<$Res> {
  _$KakeiboMonthCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KakeiboMonth
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? year = null,
    Object? month = null,
    Object? income = null,
    Object? incomeSources = null,
    Object? fixedExpenses = null,
    Object? savingsGoal = null,
    Object? expenses = null,
    Object? reflection = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as int,
            income: null == income
                ? _value.income
                : income // ignore: cast_nullable_to_non_nullable
                      as double,
            incomeSources: null == incomeSources
                ? _value.incomeSources
                : incomeSources // ignore: cast_nullable_to_non_nullable
                      as List<IncomeSource>,
            fixedExpenses: null == fixedExpenses
                ? _value.fixedExpenses
                : fixedExpenses // ignore: cast_nullable_to_non_nullable
                      as List<FixedExpense>,
            savingsGoal: null == savingsGoal
                ? _value.savingsGoal
                : savingsGoal // ignore: cast_nullable_to_non_nullable
                      as double,
            expenses: null == expenses
                ? _value.expenses
                : expenses // ignore: cast_nullable_to_non_nullable
                      as List<KakeiboExpense>,
            reflection: null == reflection
                ? _value.reflection
                : reflection // ignore: cast_nullable_to_non_nullable
                      as Reflection,
          )
          as $Val,
    );
  }

  /// Create a copy of KakeiboMonth
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReflectionCopyWith<$Res> get reflection {
    return $ReflectionCopyWith<$Res>(_value.reflection, (value) {
      return _then(_value.copyWith(reflection: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$KakeiboMonthImplCopyWith<$Res>
    implements $KakeiboMonthCopyWith<$Res> {
  factory _$$KakeiboMonthImplCopyWith(
    _$KakeiboMonthImpl value,
    $Res Function(_$KakeiboMonthImpl) then,
  ) = __$$KakeiboMonthImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int year,
    int month,
    double income,
    List<IncomeSource> incomeSources,
    List<FixedExpense> fixedExpenses,
    double savingsGoal,
    List<KakeiboExpense> expenses,
    Reflection reflection,
  });

  @override
  $ReflectionCopyWith<$Res> get reflection;
}

/// @nodoc
class __$$KakeiboMonthImplCopyWithImpl<$Res>
    extends _$KakeiboMonthCopyWithImpl<$Res, _$KakeiboMonthImpl>
    implements _$$KakeiboMonthImplCopyWith<$Res> {
  __$$KakeiboMonthImplCopyWithImpl(
    _$KakeiboMonthImpl _value,
    $Res Function(_$KakeiboMonthImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KakeiboMonth
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? year = null,
    Object? month = null,
    Object? income = null,
    Object? incomeSources = null,
    Object? fixedExpenses = null,
    Object? savingsGoal = null,
    Object? expenses = null,
    Object? reflection = null,
  }) {
    return _then(
      _$KakeiboMonthImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        month: null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as int,
        income: null == income
            ? _value.income
            : income // ignore: cast_nullable_to_non_nullable
                  as double,
        incomeSources: null == incomeSources
            ? _value._incomeSources
            : incomeSources // ignore: cast_nullable_to_non_nullable
                  as List<IncomeSource>,
        fixedExpenses: null == fixedExpenses
            ? _value._fixedExpenses
            : fixedExpenses // ignore: cast_nullable_to_non_nullable
                  as List<FixedExpense>,
        savingsGoal: null == savingsGoal
            ? _value.savingsGoal
            : savingsGoal // ignore: cast_nullable_to_non_nullable
                  as double,
        expenses: null == expenses
            ? _value._expenses
            : expenses // ignore: cast_nullable_to_non_nullable
                  as List<KakeiboExpense>,
        reflection: null == reflection
            ? _value.reflection
            : reflection // ignore: cast_nullable_to_non_nullable
                  as Reflection,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KakeiboMonthImpl implements _KakeiboMonth {
  const _$KakeiboMonthImpl({
    required this.id,
    required this.year,
    required this.month,
    this.income = 0,
    final List<IncomeSource> incomeSources = const [],
    final List<FixedExpense> fixedExpenses = const [],
    this.savingsGoal = 0,
    final List<KakeiboExpense> expenses = const [],
    this.reflection = const Reflection(),
  }) : _incomeSources = incomeSources,
       _fixedExpenses = fixedExpenses,
       _expenses = expenses;

  factory _$KakeiboMonthImpl.fromJson(Map<String, dynamic> json) =>
      _$$KakeiboMonthImplFromJson(json);

  @override
  final String id;
  @override
  final int year;
  @override
  final int month;
  @override
  @JsonKey()
  final double income;
  final List<IncomeSource> _incomeSources;
  @override
  @JsonKey()
  List<IncomeSource> get incomeSources {
    if (_incomeSources is EqualUnmodifiableListView) return _incomeSources;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_incomeSources);
  }

  final List<FixedExpense> _fixedExpenses;
  @override
  @JsonKey()
  List<FixedExpense> get fixedExpenses {
    if (_fixedExpenses is EqualUnmodifiableListView) return _fixedExpenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_fixedExpenses);
  }

  @override
  @JsonKey()
  final double savingsGoal;
  final List<KakeiboExpense> _expenses;
  @override
  @JsonKey()
  List<KakeiboExpense> get expenses {
    if (_expenses is EqualUnmodifiableListView) return _expenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expenses);
  }

  @override
  @JsonKey()
  final Reflection reflection;

  @override
  String toString() {
    return 'KakeiboMonth(id: $id, year: $year, month: $month, income: $income, incomeSources: $incomeSources, fixedExpenses: $fixedExpenses, savingsGoal: $savingsGoal, expenses: $expenses, reflection: $reflection)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KakeiboMonthImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.income, income) || other.income == income) &&
            const DeepCollectionEquality().equals(
              other._incomeSources,
              _incomeSources,
            ) &&
            const DeepCollectionEquality().equals(
              other._fixedExpenses,
              _fixedExpenses,
            ) &&
            (identical(other.savingsGoal, savingsGoal) ||
                other.savingsGoal == savingsGoal) &&
            const DeepCollectionEquality().equals(other._expenses, _expenses) &&
            (identical(other.reflection, reflection) ||
                other.reflection == reflection));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    year,
    month,
    income,
    const DeepCollectionEquality().hash(_incomeSources),
    const DeepCollectionEquality().hash(_fixedExpenses),
    savingsGoal,
    const DeepCollectionEquality().hash(_expenses),
    reflection,
  );

  /// Create a copy of KakeiboMonth
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KakeiboMonthImplCopyWith<_$KakeiboMonthImpl> get copyWith =>
      __$$KakeiboMonthImplCopyWithImpl<_$KakeiboMonthImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KakeiboMonthImplToJson(this);
  }
}

abstract class _KakeiboMonth implements KakeiboMonth {
  const factory _KakeiboMonth({
    required final String id,
    required final int year,
    required final int month,
    final double income,
    final List<IncomeSource> incomeSources,
    final List<FixedExpense> fixedExpenses,
    final double savingsGoal,
    final List<KakeiboExpense> expenses,
    final Reflection reflection,
  }) = _$KakeiboMonthImpl;

  factory _KakeiboMonth.fromJson(Map<String, dynamic> json) =
      _$KakeiboMonthImpl.fromJson;

  @override
  String get id;
  @override
  int get year;
  @override
  int get month;
  @override
  double get income;
  @override
  List<IncomeSource> get incomeSources;
  @override
  List<FixedExpense> get fixedExpenses;
  @override
  double get savingsGoal;
  @override
  List<KakeiboExpense> get expenses;
  @override
  Reflection get reflection;

  /// Create a copy of KakeiboMonth
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KakeiboMonthImplCopyWith<_$KakeiboMonthImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IncomeSource _$IncomeSourceFromJson(Map<String, dynamic> json) {
  return _IncomeSource.fromJson(json);
}

/// @nodoc
mixin _$IncomeSource {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;

  /// Serializes this IncomeSource to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of IncomeSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IncomeSourceCopyWith<IncomeSource> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeSourceCopyWith<$Res> {
  factory $IncomeSourceCopyWith(
    IncomeSource value,
    $Res Function(IncomeSource) then,
  ) = _$IncomeSourceCopyWithImpl<$Res, IncomeSource>;
  @useResult
  $Res call({String id, String name, double amount});
}

/// @nodoc
class _$IncomeSourceCopyWithImpl<$Res, $Val extends IncomeSource>
    implements $IncomeSourceCopyWith<$Res> {
  _$IncomeSourceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IncomeSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? amount = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IncomeSourceImplCopyWith<$Res>
    implements $IncomeSourceCopyWith<$Res> {
  factory _$$IncomeSourceImplCopyWith(
    _$IncomeSourceImpl value,
    $Res Function(_$IncomeSourceImpl) then,
  ) = __$$IncomeSourceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, double amount});
}

/// @nodoc
class __$$IncomeSourceImplCopyWithImpl<$Res>
    extends _$IncomeSourceCopyWithImpl<$Res, _$IncomeSourceImpl>
    implements _$$IncomeSourceImplCopyWith<$Res> {
  __$$IncomeSourceImplCopyWithImpl(
    _$IncomeSourceImpl _value,
    $Res Function(_$IncomeSourceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IncomeSource
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null, Object? amount = null}) {
    return _then(
      _$IncomeSourceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$IncomeSourceImpl implements _IncomeSource {
  const _$IncomeSourceImpl({
    required this.id,
    required this.name,
    required this.amount,
  });

  factory _$IncomeSourceImpl.fromJson(Map<String, dynamic> json) =>
      _$$IncomeSourceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double amount;

  @override
  String toString() {
    return 'IncomeSource(id: $id, name: $name, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeSourceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, amount);

  /// Create a copy of IncomeSource
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomeSourceImplCopyWith<_$IncomeSourceImpl> get copyWith =>
      __$$IncomeSourceImplCopyWithImpl<_$IncomeSourceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IncomeSourceImplToJson(this);
  }
}

abstract class _IncomeSource implements IncomeSource {
  const factory _IncomeSource({
    required final String id,
    required final String name,
    required final double amount,
  }) = _$IncomeSourceImpl;

  factory _IncomeSource.fromJson(Map<String, dynamic> json) =
      _$IncomeSourceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get amount;

  /// Create a copy of IncomeSource
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IncomeSourceImplCopyWith<_$IncomeSourceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KakeiboExpense _$KakeiboExpenseFromJson(Map<String, dynamic> json) {
  return _KakeiboExpense.fromJson(json);
}

/// @nodoc
mixin _$KakeiboExpense {
  String get id => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  Pillar get pillar => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;

  /// Serializes this KakeiboExpense to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KakeiboExpense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KakeiboExpenseCopyWith<KakeiboExpense> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KakeiboExpenseCopyWith<$Res> {
  factory $KakeiboExpenseCopyWith(
    KakeiboExpense value,
    $Res Function(KakeiboExpense) then,
  ) = _$KakeiboExpenseCopyWithImpl<$Res, KakeiboExpense>;
  @useResult
  $Res call({
    String id,
    String date,
    String description,
    double amount,
    Pillar pillar,
    String notes,
  });
}

/// @nodoc
class _$KakeiboExpenseCopyWithImpl<$Res, $Val extends KakeiboExpense>
    implements $KakeiboExpenseCopyWith<$Res> {
  _$KakeiboExpenseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KakeiboExpense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? description = null,
    Object? amount = null,
    Object? pillar = null,
    Object? notes = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            pillar: null == pillar
                ? _value.pillar
                : pillar // ignore: cast_nullable_to_non_nullable
                      as Pillar,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KakeiboExpenseImplCopyWith<$Res>
    implements $KakeiboExpenseCopyWith<$Res> {
  factory _$$KakeiboExpenseImplCopyWith(
    _$KakeiboExpenseImpl value,
    $Res Function(_$KakeiboExpenseImpl) then,
  ) = __$$KakeiboExpenseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String date,
    String description,
    double amount,
    Pillar pillar,
    String notes,
  });
}

/// @nodoc
class __$$KakeiboExpenseImplCopyWithImpl<$Res>
    extends _$KakeiboExpenseCopyWithImpl<$Res, _$KakeiboExpenseImpl>
    implements _$$KakeiboExpenseImplCopyWith<$Res> {
  __$$KakeiboExpenseImplCopyWithImpl(
    _$KakeiboExpenseImpl _value,
    $Res Function(_$KakeiboExpenseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KakeiboExpense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? description = null,
    Object? amount = null,
    Object? pillar = null,
    Object? notes = null,
  }) {
    return _then(
      _$KakeiboExpenseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        pillar: null == pillar
            ? _value.pillar
            : pillar // ignore: cast_nullable_to_non_nullable
                  as Pillar,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KakeiboExpenseImpl implements _KakeiboExpense {
  const _$KakeiboExpenseImpl({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.pillar,
    this.notes = '',
  });

  factory _$KakeiboExpenseImpl.fromJson(Map<String, dynamic> json) =>
      _$$KakeiboExpenseImplFromJson(json);

  @override
  final String id;
  @override
  final String date;
  @override
  final String description;
  @override
  final double amount;
  @override
  final Pillar pillar;
  @override
  @JsonKey()
  final String notes;

  @override
  String toString() {
    return 'KakeiboExpense(id: $id, date: $date, description: $description, amount: $amount, pillar: $pillar, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KakeiboExpenseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.pillar, pillar) || other.pillar == pillar) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, date, description, amount, pillar, notes);

  /// Create a copy of KakeiboExpense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KakeiboExpenseImplCopyWith<_$KakeiboExpenseImpl> get copyWith =>
      __$$KakeiboExpenseImplCopyWithImpl<_$KakeiboExpenseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$KakeiboExpenseImplToJson(this);
  }
}

abstract class _KakeiboExpense implements KakeiboExpense {
  const factory _KakeiboExpense({
    required final String id,
    required final String date,
    required final String description,
    required final double amount,
    required final Pillar pillar,
    final String notes,
  }) = _$KakeiboExpenseImpl;

  factory _KakeiboExpense.fromJson(Map<String, dynamic> json) =
      _$KakeiboExpenseImpl.fromJson;

  @override
  String get id;
  @override
  String get date;
  @override
  String get description;
  @override
  double get amount;
  @override
  Pillar get pillar;
  @override
  String get notes;

  /// Create a copy of KakeiboExpense
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KakeiboExpenseImplCopyWith<_$KakeiboExpenseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FixedExpense _$FixedExpenseFromJson(Map<String, dynamic> json) {
  return _FixedExpense.fromJson(json);
}

/// @nodoc
mixin _$FixedExpense {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int? get dueDay => throw _privateConstructorUsedError;

  /// Serializes this FixedExpense to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FixedExpense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FixedExpenseCopyWith<FixedExpense> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FixedExpenseCopyWith<$Res> {
  factory $FixedExpenseCopyWith(
    FixedExpense value,
    $Res Function(FixedExpense) then,
  ) = _$FixedExpenseCopyWithImpl<$Res, FixedExpense>;
  @useResult
  $Res call({
    String id,
    String name,
    double amount,
    String category,
    int? dueDay,
  });
}

/// @nodoc
class _$FixedExpenseCopyWithImpl<$Res, $Val extends FixedExpense>
    implements $FixedExpenseCopyWith<$Res> {
  _$FixedExpenseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FixedExpense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amount = null,
    Object? category = null,
    Object? dueDay = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            dueDay: freezed == dueDay
                ? _value.dueDay
                : dueDay // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FixedExpenseImplCopyWith<$Res>
    implements $FixedExpenseCopyWith<$Res> {
  factory _$$FixedExpenseImplCopyWith(
    _$FixedExpenseImpl value,
    $Res Function(_$FixedExpenseImpl) then,
  ) = __$$FixedExpenseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    double amount,
    String category,
    int? dueDay,
  });
}

/// @nodoc
class __$$FixedExpenseImplCopyWithImpl<$Res>
    extends _$FixedExpenseCopyWithImpl<$Res, _$FixedExpenseImpl>
    implements _$$FixedExpenseImplCopyWith<$Res> {
  __$$FixedExpenseImplCopyWithImpl(
    _$FixedExpenseImpl _value,
    $Res Function(_$FixedExpenseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FixedExpense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amount = null,
    Object? category = null,
    Object? dueDay = freezed,
  }) {
    return _then(
      _$FixedExpenseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        dueDay: freezed == dueDay
            ? _value.dueDay
            : dueDay // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FixedExpenseImpl implements _FixedExpense {
  const _$FixedExpenseImpl({
    required this.id,
    required this.name,
    required this.amount,
    this.category = 'Other',
    this.dueDay,
  });

  factory _$FixedExpenseImpl.fromJson(Map<String, dynamic> json) =>
      _$$FixedExpenseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double amount;
  @override
  @JsonKey()
  final String category;
  @override
  final int? dueDay;

  @override
  String toString() {
    return 'FixedExpense(id: $id, name: $name, amount: $amount, category: $category, dueDay: $dueDay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FixedExpenseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.dueDay, dueDay) || other.dueDay == dueDay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, amount, category, dueDay);

  /// Create a copy of FixedExpense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FixedExpenseImplCopyWith<_$FixedExpenseImpl> get copyWith =>
      __$$FixedExpenseImplCopyWithImpl<_$FixedExpenseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FixedExpenseImplToJson(this);
  }
}

abstract class _FixedExpense implements FixedExpense {
  const factory _FixedExpense({
    required final String id,
    required final String name,
    required final double amount,
    final String category,
    final int? dueDay,
  }) = _$FixedExpenseImpl;

  factory _FixedExpense.fromJson(Map<String, dynamic> json) =
      _$FixedExpenseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get amount;
  @override
  String get category;
  @override
  int? get dueDay;

  /// Create a copy of FixedExpense
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FixedExpenseImplCopyWith<_$FixedExpenseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Reflection _$ReflectionFromJson(Map<String, dynamic> json) {
  return _Reflection.fromJson(json);
}

/// @nodoc
mixin _$Reflection {
  double get actualSaved => throw _privateConstructorUsedError;
  String get howSaved => throw _privateConstructorUsedError;
  String get improvements => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  double get accountBalance => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;

  /// Serializes this Reflection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reflection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReflectionCopyWith<Reflection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReflectionCopyWith<$Res> {
  factory $ReflectionCopyWith(
    Reflection value,
    $Res Function(Reflection) then,
  ) = _$ReflectionCopyWithImpl<$Res, Reflection>;
  @useResult
  $Res call({
    double actualSaved,
    String howSaved,
    String improvements,
    String notes,
    double accountBalance,
    bool completed,
  });
}

/// @nodoc
class _$ReflectionCopyWithImpl<$Res, $Val extends Reflection>
    implements $ReflectionCopyWith<$Res> {
  _$ReflectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reflection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actualSaved = null,
    Object? howSaved = null,
    Object? improvements = null,
    Object? notes = null,
    Object? accountBalance = null,
    Object? completed = null,
  }) {
    return _then(
      _value.copyWith(
            actualSaved: null == actualSaved
                ? _value.actualSaved
                : actualSaved // ignore: cast_nullable_to_non_nullable
                      as double,
            howSaved: null == howSaved
                ? _value.howSaved
                : howSaved // ignore: cast_nullable_to_non_nullable
                      as String,
            improvements: null == improvements
                ? _value.improvements
                : improvements // ignore: cast_nullable_to_non_nullable
                      as String,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            accountBalance: null == accountBalance
                ? _value.accountBalance
                : accountBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReflectionImplCopyWith<$Res>
    implements $ReflectionCopyWith<$Res> {
  factory _$$ReflectionImplCopyWith(
    _$ReflectionImpl value,
    $Res Function(_$ReflectionImpl) then,
  ) = __$$ReflectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double actualSaved,
    String howSaved,
    String improvements,
    String notes,
    double accountBalance,
    bool completed,
  });
}

/// @nodoc
class __$$ReflectionImplCopyWithImpl<$Res>
    extends _$ReflectionCopyWithImpl<$Res, _$ReflectionImpl>
    implements _$$ReflectionImplCopyWith<$Res> {
  __$$ReflectionImplCopyWithImpl(
    _$ReflectionImpl _value,
    $Res Function(_$ReflectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Reflection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actualSaved = null,
    Object? howSaved = null,
    Object? improvements = null,
    Object? notes = null,
    Object? accountBalance = null,
    Object? completed = null,
  }) {
    return _then(
      _$ReflectionImpl(
        actualSaved: null == actualSaved
            ? _value.actualSaved
            : actualSaved // ignore: cast_nullable_to_non_nullable
                  as double,
        howSaved: null == howSaved
            ? _value.howSaved
            : howSaved // ignore: cast_nullable_to_non_nullable
                  as String,
        improvements: null == improvements
            ? _value.improvements
            : improvements // ignore: cast_nullable_to_non_nullable
                  as String,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        accountBalance: null == accountBalance
            ? _value.accountBalance
            : accountBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReflectionImpl implements _Reflection {
  const _$ReflectionImpl({
    this.actualSaved = 0,
    this.howSaved = '',
    this.improvements = '',
    this.notes = '',
    this.accountBalance = 0,
    this.completed = false,
  });

  factory _$ReflectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReflectionImplFromJson(json);

  @override
  @JsonKey()
  final double actualSaved;
  @override
  @JsonKey()
  final String howSaved;
  @override
  @JsonKey()
  final String improvements;
  @override
  @JsonKey()
  final String notes;
  @override
  @JsonKey()
  final double accountBalance;
  @override
  @JsonKey()
  final bool completed;

  @override
  String toString() {
    return 'Reflection(actualSaved: $actualSaved, howSaved: $howSaved, improvements: $improvements, notes: $notes, accountBalance: $accountBalance, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReflectionImpl &&
            (identical(other.actualSaved, actualSaved) ||
                other.actualSaved == actualSaved) &&
            (identical(other.howSaved, howSaved) ||
                other.howSaved == howSaved) &&
            (identical(other.improvements, improvements) ||
                other.improvements == improvements) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.accountBalance, accountBalance) ||
                other.accountBalance == accountBalance) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    actualSaved,
    howSaved,
    improvements,
    notes,
    accountBalance,
    completed,
  );

  /// Create a copy of Reflection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReflectionImplCopyWith<_$ReflectionImpl> get copyWith =>
      __$$ReflectionImplCopyWithImpl<_$ReflectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReflectionImplToJson(this);
  }
}

abstract class _Reflection implements Reflection {
  const factory _Reflection({
    final double actualSaved,
    final String howSaved,
    final String improvements,
    final String notes,
    final double accountBalance,
    final bool completed,
  }) = _$ReflectionImpl;

  factory _Reflection.fromJson(Map<String, dynamic> json) =
      _$ReflectionImpl.fromJson;

  @override
  double get actualSaved;
  @override
  String get howSaved;
  @override
  String get improvements;
  @override
  String get notes;
  @override
  double get accountBalance;
  @override
  bool get completed;

  /// Create a copy of Reflection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReflectionImplCopyWith<_$ReflectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
