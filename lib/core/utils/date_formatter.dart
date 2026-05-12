import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _rateTs = DateFormat('yyyy-MM-dd HH:mm');

  static String formatRateTimestamp(DateTime dt) => _rateTs.format(dt);
}
