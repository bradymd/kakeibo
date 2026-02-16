import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/models/pillar.dart';

part 'kakeibo_month.freezed.dart';
part 'kakeibo_month.g.dart';

@freezed
class KakeiboMonth with _$KakeiboMonth {
  const factory KakeiboMonth({
    required String id,
    required int year,
    required int month,
    @Default(0) double income,
    @Default([]) List<IncomeSource> incomeSources,
    @Default([]) List<FixedExpense> fixedExpenses,
    @Default(0) double savingsGoal,
    @Default([]) List<KakeiboExpense> expenses,
    @Default(Reflection()) Reflection reflection,
  }) = _KakeiboMonth;

  factory KakeiboMonth.fromJson(Map<String, dynamic> json) =>
      _$KakeiboMonthFromJson(json);
}

@freezed
class IncomeSource with _$IncomeSource {
  const factory IncomeSource({
    required String id,
    required String name,
    required double amount,
  }) = _IncomeSource;

  factory IncomeSource.fromJson(Map<String, dynamic> json) =>
      _$IncomeSourceFromJson(json);
}

@freezed
class KakeiboExpense with _$KakeiboExpense {
  const factory KakeiboExpense({
    required String id,
    required String date,
    required String description,
    required double amount,
    required Pillar pillar,
    @Default('') String notes,
    @Default(0) int createdAt,
  }) = _KakeiboExpense;

  factory KakeiboExpense.fromJson(Map<String, dynamic> json) =>
      _$KakeiboExpenseFromJson(json);
}

@freezed
class FixedExpense with _$FixedExpense {
  const factory FixedExpense({
    required String id,
    required String name,
    required double amount,
    @Default('Other') String category,
    int? dueDay,
  }) = _FixedExpense;

  factory FixedExpense.fromJson(Map<String, dynamic> json) =>
      _$FixedExpenseFromJson(json);
}

@freezed
class Reflection with _$Reflection {
  const factory Reflection({
    @Default(0) double actualSaved,
    @Default('') String howSaved,
    @Default('') String improvements,
    @Default('') String notes,
    @Default(0) double accountBalance,
    @Default(false) bool completed,
  }) = _Reflection;

  factory Reflection.fromJson(Map<String, dynamic> json) =>
      _$ReflectionFromJson(json);
}
