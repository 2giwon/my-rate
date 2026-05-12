import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/converter/logic/tip_calculator.dart';

void main() {
  group('calculateTip', () {
    test('10% tip on 100,000', () {
      final s = calculateTip(amount: 100000, percent: 10);
      expect(s.tipAmount, 10000);
      expect(s.total, 110000);
      expect(s.percent, 10);
    });

    test('0% tip', () {
      final s = calculateTip(amount: 100000, percent: 0);
      expect(s.tipAmount, 0);
      expect(s.total, 100000);
    });

    test('15.5% tip on 50.00', () {
      final s = calculateTip(amount: 50, percent: 15.5);
      expect(s.tipAmount, closeTo(7.75, 1e-9));
      expect(s.total, closeTo(57.75, 1e-9));
    });

    test('negative percent clamps to 0', () {
      final s = calculateTip(amount: 100, percent: -5);
      expect(s.percent, 0);
      expect(s.tipAmount, 0);
      expect(s.total, 100);
    });

    test('zero amount returns zero state', () {
      final s = calculateTip(amount: 0, percent: 10);
      expect(s.tipAmount, 0);
      expect(s.total, 0);
    });
  });
}
