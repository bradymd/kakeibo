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

/// Resolved payday for the previous month (start of this month's financial period).
final previousPaydayProvider = FutureProvider<DateTime?>((ref) async {
  final monthId = ref.watch(currentMonthIdProvider);
  final preset = ref.watch(paydayPresetProvider);
  if (preset == PaydayPreset.none) return null;

  final prevMonthId = MonthHelpers.getPrevMonthId(monthId);

  final override =
      await ref.watch(settingsProvider.notifier).getPaydayOverride(prevMonthId);
  if (override != null) return DateTime.tryParse(override);

  final (:year, :month) = MonthHelpers.parseMonthId(prevMonthId);
  return PaydayCalculator.suggestedPayday(year, month, preset);
});

/// Financial progress for the viewed month.
///
/// The financial period for a month runs from the PREVIOUS month's payday
/// to THIS month's payday. e.g. February = Jan 31 payday → Feb 27 payday.
///
/// If today >= this month's payday: complete.
/// If today < previous month's payday: null (not started).
/// Otherwise: live day counter.
final financialProgressProvider =
    Provider<({int day, int total})?>((ref) {
  final prevPaydayAsync = ref.watch(previousPaydayProvider);
  final currentPaydayAsync = ref.watch(currentPaydayProvider);

  final prevPayday = prevPaydayAsync.valueOrNull;
  final currentPayday = currentPaydayAsync.valueOrNull;
  if (prevPayday == null || currentPayday == null) return null;

  final startDate = DateTime(prevPayday.year, prevPayday.month, prevPayday.day);
  final endDate =
      DateTime(currentPayday.year, currentPayday.month, currentPayday.day);
  final total = PaydayCalculator.financialDays(startDate, endDate);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // On or after this month's payday — financial month is complete
  if (!today.isBefore(endDate)) {
    return (day: total, total: total);
  }

  // Before the previous month's payday — not started yet
  if (today.isBefore(startDate)) return null;

  final day = today.difference(startDate).inDays + 1;
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
