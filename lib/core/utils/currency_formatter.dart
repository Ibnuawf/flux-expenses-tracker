import 'dart:io';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    return NumberFormat.simpleCurrency(
      locale: Platform.localeName, 
      decimalDigits: 0
    ).format(amount);
  }
}
