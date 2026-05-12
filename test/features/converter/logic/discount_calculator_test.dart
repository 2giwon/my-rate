import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/converter/logic/discount_calculator.dart';

void main() {
  group('calculateDiscount', () {
    test('20% off 100,000', () {
      final s = calculateDiscount(amount: 100000, value: 20, byPercent: true);
      expect(s.discountAmount, 20000);
      expect(s.finalAmount, 80000);
    });

    test('fixed amount 3000 off 50,000', () {
      final s = calculateDiscount(amount: 50000, value: 3000, byPercent: false);
      expect(s.discountAmount, 3000);
      expect(s.finalAmount, 47000);
    });

    test('100% off returns 0 final', () {
      final s = calculateDiscount(amount: 50000, value: 100, byPercent: true);
      expect(s.finalAmount, 0);
    });

    test('discount > amount in fixed mode clamps final to 0', () {
      final s = calculateDiscount(amount: 1000, value: 5000, byPercent: false);
      expect(s.discountAmount, 1000);
      expect(s.finalAmount, 0);
    });

    test('percent over 100 clamps to 100', () {
      final s = calculateDiscount(amount: 1000, value: 150, byPercent: true);
      expect(s.discountAmount, 1000);
      expect(s.finalAmount, 0);
    });

    test('negative value clamps to 0', () {
      final s = calculateDiscount(amount: 1000, value: -10, byPercent: true);
      expect(s.discountAmount, 0);
      expect(s.finalAmount, 1000);
    });
  });
}
