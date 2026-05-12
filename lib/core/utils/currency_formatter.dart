import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(num value, {required int decimalPlaces}) {
    final pattern = decimalPlaces == 0 ? '#,##0' : '#,##0.${'0' * decimalPlaces}';
    return NumberFormat(pattern, 'en_US').format(value);
  }

  static double? parse(String input) {
    if (input.isEmpty) return null;
    final cleaned = input.replaceAll(',', '');
    return double.tryParse(cleaned);
  }
}
