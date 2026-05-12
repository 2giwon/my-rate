import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('KRW formatted with no decimal and thousand separator', () {
      expect(CurrencyFormatter.format(123456.78, decimalPlaces: 0), '123,457');
    });

    test('USD formatted with 2 decimals', () {
      expect(CurrencyFormatter.format(73.42, decimalPlaces: 2), '73.42');
    });

    test('JPY formatted with no decimal', () {
      expect(CurrencyFormatter.format(15600.0, decimalPlaces: 0), '15,600');
    });

    test('zero is formatted as 0 / 0.00 based on decimals', () {
      expect(CurrencyFormatter.format(0, decimalPlaces: 0), '0');
      expect(CurrencyFormatter.format(0, decimalPlaces: 2), '0.00');
    });

    test('parse strips commas and returns null on invalid', () {
      expect(CurrencyFormatter.parse('123,456'), 123456.0);
      expect(CurrencyFormatter.parse('abc'), isNull);
      expect(CurrencyFormatter.parse(''), isNull);
    });
  });
}
