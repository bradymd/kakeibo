import 'package:intl/intl.dart';

enum PaydayPreset { none, lastFriday, adjusted25th, endOfMonth }

class PaydayCalculator {
  const PaydayCalculator._();

  /// Compute the suggested payday for a given calendar month.
  static DateTime? suggestedPayday(int year, int month, PaydayPreset preset) {
    switch (preset) {
      case PaydayPreset.lastFriday:
        // Walk back from the last day of the month to find Friday (weekday 5).
        // Use day arithmetic instead of Duration to avoid DST issues.
        final lastDay = DateTime.utc(year, month + 1, 0);
        var day = lastDay.day;
        var wd = lastDay.weekday;
        while (wd != DateTime.friday) {
          day--;
          wd = DateTime.utc(year, month, day).weekday;
        }
        return DateTime(year, month, day);
      case PaydayPreset.adjusted25th:
        // 25th of the month, or previous Friday if it falls on Sat/Sun.
        final d = DateTime(year, month, 25);
        if (d.weekday == DateTime.saturday) {
          return DateTime(year, month, 24); // Friday
        } else if (d.weekday == DateTime.sunday) {
          return DateTime(year, month, 23); // Friday
        }
        return d;
      case PaydayPreset.endOfMonth:
        return DateTime(year, month + 1, 0);
      case PaydayPreset.none:
        return null;
    }
  }

  /// Days between two paydays.
  static int financialDays(DateTime payday, DateTime nextPayday) {
    return nextPayday.difference(payday).inDays;
  }

  /// Human-readable label for a preset.
  static String presetLabel(PaydayPreset preset) {
    return switch (preset) {
      PaydayPreset.none => 'Off (default)',
      PaydayPreset.lastFriday => 'Last Friday of the month',
      PaydayPreset.adjusted25th => '25th (adjusted for weekends)',
      PaydayPreset.endOfMonth => 'Last day of the month',
    };
  }

  /// Example string for a preset in a given month, e.g. "Mar 27 (Fri)".
  static String? presetExample(int year, int month, PaydayPreset preset) {
    final date = suggestedPayday(year, month, preset);
    if (date == null) return null;
    final dayName = DateFormat('E').format(date);
    final monthName = DateFormat('MMM').format(date);
    return '$monthName ${date.day} ($dayName)';
  }

  static PaydayPreset parsePreset(String value) {
    return switch (value) {
      'lastFriday' => PaydayPreset.lastFriday,
      'adjusted25th' => PaydayPreset.adjusted25th,
      'endOfMonth' => PaydayPreset.endOfMonth,
      _ => PaydayPreset.none,
    };
  }

  static String presetToString(PaydayPreset preset) {
    return switch (preset) {
      PaydayPreset.none => 'none',
      PaydayPreset.lastFriday => 'lastFriday',
      PaydayPreset.adjusted25th => 'adjusted25th',
      PaydayPreset.endOfMonth => 'endOfMonth',
    };
  }
}
