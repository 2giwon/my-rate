import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/converter/logic/tax_calculator.dart';

void main() {
  group('calculateTax', () {
    test('exclusive mode: 100 + 10% VAT', () {
      final s = calculateTax(amount: 100, vatPercent: 10, isInclusive: false);
      expect(s.taxAmount, 10);
      expect(s.total, 110);
      expect(s.isInclusive, isFalse);
    });

    test('inclusive mode: 110 contains 10% VAT', () {
      final s = calculateTax(amount: 110, vatPercent: 10, isInclusive: true);
      expect(s.total, closeTo(100, 1e-9));
      expect(s.taxAmount, closeTo(10, 1e-9));
    });

    test('0% VAT returns amount unchanged in both modes', () {
      final exc = calculateTax(amount: 100, vatPercent: 0, isInclusive: false);
      expect(exc.taxAmount, 0);
      expect(exc.total, 100);

      final inc = calculateTax(amount: 100, vatPercent: 0, isInclusive: true);
      expect(inc.taxAmount, 0);
      expect(inc.total, 100);
    });

    test('negative VAT clamps to 0', () {
      final s = calculateTax(amount: 100, vatPercent: -5, isInclusive: false);
      expect(s.vatPercent, 0);
      expect(s.taxAmount, 0);
    });

    test('zero amount returns zeroed state', () {
      final s = calculateTax(amount: 0, vatPercent: 10, isInclusive: false);
      expect(s.taxAmount, 0);
      expect(s.total, 0);
    });
  });
}
