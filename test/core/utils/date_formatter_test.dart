import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('formatRateTimestamp returns YYYY-MM-DD HH:mm', () {
      final dt = DateTime(2026, 5, 12, 14, 32);
      expect(DateFormatter.formatRateTimestamp(dt), '2026-05-12 14:32');
    });

    test('zero-pads single-digit month/day/hour/minute', () {
      final dt = DateTime(2026, 1, 3, 4, 5);
      expect(DateFormatter.formatRateTimestamp(dt), '2026-01-03 04:05');
    });

    test('formatRateDate returns YYYY-MM-DD without time', () {
      final dt = DateTime(2026, 5, 13, 14, 32);
      expect(DateFormatter.formatRateDate(dt), '2026-05-13');
    });
  });
}
