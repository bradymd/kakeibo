// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kakeibo_month.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KakeiboMonthImpl _$$KakeiboMonthImplFromJson(Map<String, dynamic> json) =>
    _$KakeiboMonthImpl(
      id: json['id'] as String,
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      income: (json['income'] as num?)?.toDouble() ?? 0,
      incomeSources:
          (json['incomeSources'] as List<dynamic>?)
              ?.map((e) => IncomeSource.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fixedExpenses:
          (json['fixedExpenses'] as List<dynamic>?)
              ?.map((e) => FixedExpense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      savingsGoal: (json['savingsGoal'] as num?)?.toDouble() ?? 0,
      expenses:
          (json['expenses'] as List<dynamic>?)
              ?.map((e) => KakeiboExpense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reflection: json['reflection'] == null
          ? const Reflection()
          : Reflection.fromJson(json['reflection'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$KakeiboMonthImplToJson(_$KakeiboMonthImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'month': instance.month,
      'income': instance.income,
      'incomeSources': instance.incomeSources,
      'fixedExpenses': instance.fixedExpenses,
      'savingsGoal': instance.savingsGoal,
      'expenses': instance.expenses,
      'reflection': instance.reflection,
    };

_$IncomeSourceImpl _$$IncomeSourceImplFromJson(Map<String, dynamic> json) =>
    _$IncomeSourceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );

Map<String, dynamic> _$$IncomeSourceImplToJson(_$IncomeSourceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
    };

_$KakeiboExpenseImpl _$$KakeiboExpenseImplFromJson(Map<String, dynamic> json) =>
    _$KakeiboExpenseImpl(
      id: json['id'] as String,
      date: json['date'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      pillar: $enumDecode(_$PillarEnumMap, json['pillar']),
      notes: json['notes'] as String? ?? '',
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$KakeiboExpenseImplToJson(
  _$KakeiboExpenseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date,
  'description': instance.description,
  'amount': instance.amount,
  'pillar': _$PillarEnumMap[instance.pillar]!,
  'notes': instance.notes,
  'createdAt': instance.createdAt,
};

const _$PillarEnumMap = {
  Pillar.needs: 'needs',
  Pillar.wants: 'wants',
  Pillar.culture: 'culture',
  Pillar.unexpected: 'unexpected',
};

_$FixedExpenseImpl _$$FixedExpenseImplFromJson(Map<String, dynamic> json) =>
    _$FixedExpenseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String? ?? 'Other',
      dueDay: (json['dueDay'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$FixedExpenseImplToJson(_$FixedExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'category': instance.category,
      'dueDay': instance.dueDay,
    };

_$ReflectionImpl _$$ReflectionImplFromJson(Map<String, dynamic> json) =>
    _$ReflectionImpl(
      actualSaved: (json['actualSaved'] as num?)?.toDouble() ?? 0,
      howSaved: json['howSaved'] as String? ?? '',
      improvements: json['improvements'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      accountBalance: (json['accountBalance'] as num?)?.toDouble() ?? 0,
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$$ReflectionImplToJson(_$ReflectionImpl instance) =>
    <String, dynamic>{
      'actualSaved': instance.actualSaved,
      'howSaved': instance.howSaved,
      'improvements': instance.improvements,
      'notes': instance.notes,
      'accountBalance': instance.accountBalance,
      'completed': instance.completed,
    };
