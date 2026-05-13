import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _rateTs = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _rateDate = DateFormat('yyyy-MM-dd');

  static String formatRateTimestamp(DateTime dt) => _rateTs.format(dt);

  static String formatRateDate(DateTime dt) => _rateDate.format(dt);
}
