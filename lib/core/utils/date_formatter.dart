import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _format = DateFormat.yMMMd();

  static String format(DateTime date) => _format.format(date);

  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
