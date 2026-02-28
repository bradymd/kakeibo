import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/providers/kakeibo_provider.dart';
import 'package:kakeibo/providers/settings_provider.dart';
import 'package:kakeibo/services/month_helpers.dart';
import 'package:kakeibo/services/payday_calculator.dart';

/// The global payday preset parsed from settings.
final paydayPresetProvider = Provider<PaydayPreset>((ref) {
  final settings = ref.watch(settingsProvider);
  final raw = settings.whenOrNull(data: (s) => s.paydayPreset) ?? 'none';
  return PaydayCalculator.parsePreset(raw);
});

/// Resolved payday for the viewed month:
/// per-month override → preset computation → null.
final currentPaydayProvider = FutureProvider<DateTime?>((ref) async {
  final monthId = ref.watch(currentMonthIdProvider);
  final preset = ref.watch(paydayPresetProvider);
  if (preset == PaydayPreset.none) return null;

  final override =
      await ref.watch(settingsProvider.notifier).getPaydayOverride(monthId);
  if (override != null) return DateTime.tryParse(override);

  final (:year, :month) = MonthHelpers.parseMonthId(monthId);
  return PaydayCalculator.suggestedPayday(year, month, preset);
});

/// Resolved payday for the next month (needed for financial day total).
final nextPaydayProvider = FutureProvider<DateTime?>((ref) async {
  final monthId = ref.watch(currentMonthIdProvider);
  final preset = ref.watch(paydayPresetProvider);
  if (preset == PaydayPreset.none) return null;

  final nextMonthId = MonthHelpers.getNextMonthId(monthId);

  final override =
      await ref.watch(settingsProvider.notifier).getPaydayOverride(nextMonthId);
  if (override != null) return DateTime.tryParse(override);

  final (:year, :month) = MonthHelpers.parseMonthId(nextMonthId);
  return PaydayCalculator.suggestedPayday(year, month, preset);
});

/// Financial progress for the viewed month.
///
/// For the current calendar month: day = today - payday + 1.
/// For past months (today > end of month): day = total (month complete).
/// For future months or before payday: null.
final financialProgressProvider =
    Provider<({int day, int total})?>((ref) {
  final paydayAsync = ref.watch(currentPaydayProvider);
  final nextPaydayAsync = ref.watch(nextPaydayProvider);
  final monthId = ref.watch(currentMonthIdProvider);

  final payday = paydayAsync.valueOrNull;
  final nextPayday = nextPaydayAsync.valueOrNull;
  if (payday == null || nextPayday == null) return null;

  final paydayDate = DateTime(payday.year, payday.month, payday.day);
  final nextPaydayDate =
      DateTime(nextPayday.year, nextPayday.month, nextPayday.day);
  final total = PaydayCalculator.financialDays(paydayDate, nextPaydayDate);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Is this a past month? (today is past the end of the viewed calendar month)
  final (:year, :month) = MonthHelpers.parseMonthId(monthId);
  final endOfMonth = DateTime(year, month + 1, 0);
  if (today.isAfter(endOfMonth)) {
    // Past month — show as complete
    return (day: total, total: total);
  }

  // Current or future month — show live progress if after payday
  if (today.isBefore(paydayDate)) return null;

  final day = today.difference(paydayDate).inDays + 1;
  return (day: day, total: total);
});

/// Days until payday in the viewed month.
/// Null if no payday set, today is on/after payday, or month is in the past.
final daysUntilPaydayProvider = Provider<int?>((ref) {
  final paydayAsync = ref.watch(currentPaydayProvider);
  final monthId = ref.watch(currentMonthIdProvider);
  final payday = paydayAsync.valueOrNull;
  if (payday == null) return null;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // Past month — no countdown
  final (:year, :month) = MonthHelpers.parseMonthId(monthId);
  final endOfMonth = DateTime(year, month + 1, 0);
  if (today.isAfter(endOfMonth)) return null;

  final paydayDate = DateTime(payday.year, payday.month, payday.day);
  if (!today.isBefore(paydayDate)) return null;

  return paydayDate.difference(today).inDays;
});
