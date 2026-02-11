import 'package:intl/intl.dart';

class MonthHelpers {
  const MonthHelpers._();

  static String getCurrentMonthId() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  static ({int year, int month}) parseMonthId(String id) {
    final parts = id.split('-');
    return (year: int.parse(parts[0]), month: int.parse(parts[1]));
  }

  static String formatMonthDisplay(int year, int month) {
    final date = DateTime(year, month);
    return DateFormat('MMMM yyyy').format(date);
  }

  static String getNextMonthId(String id) {
    final (:year, :month) = parseMonthId(id);
    if (month == 12) {
      return '${year + 1}-01';
    }
    return '$year-${(month + 1).toString().padLeft(2, '0')}';
  }

  static String getPrevMonthId(String id) {
    final (:year, :month) = parseMonthId(id);
    if (month == 1) {
      return '${year - 1}-12';
    }
    return '$year-${(month - 1).toString().padLeft(2, '0')}';
  }

  static String makeMonthId(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }
}
