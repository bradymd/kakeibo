import 'package:intl/intl.dart';

String formatDate(String isoDate) {
  try {
    final date = DateTime.parse(isoDate);
    return DateFormat('d MMM yyyy').format(date);
  } catch (_) {
    return isoDate;
  }
}

String todayIso() {
  return DateFormat('yyyy-MM-dd').format(DateTime.now());
}
