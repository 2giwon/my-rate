import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/converter/view/widgets/amount_input.dart';

void main() {
  group('ThousandsSeparatorInputFormatter', () {
    TextEditingValue format(String oldText, String newText, {int maxDecimals = 2}) {
      final f = ThousandsSeparatorInputFormatter(maxDecimals: maxDecimals);
      return f.formatEditUpdate(
        TextEditingValue(
          text: oldText,
          selection: TextSelection.collapsed(offset: oldText.length),
        ),
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        ),
      );
    }

    test('inserts comma for thousands', () {
      expect(format('', '1000').text, '1,000');
      expect(format('1,000', '10000').text, '10,000');
      expect(format('10,000', '100000').text, '100,000');
      expect(format('100,000', '1000000').text, '1,000,000');
    });

    test('preserves leading typed digits without trailing commas', () {
      expect(format('', '1').text, '1');
      expect(format('1', '12').text, '12');
      expect(format('12', '123').text, '123');
      expect(format('123', '1234').text, '1,234');
    });

    test('empty stays empty', () {
      expect(format('', '').text, '');
    });

    test('maxDecimals=0 strips the dot (e.g. KRW)', () {
      // "1000.5" with no decimals → digits "10005" → "10,005"
      expect(format('', '1000.5', maxDecimals: 0).text, '10,005');
      expect(format('', '1000.', maxDecimals: 0).text, '1,000');
    });

    test('maxDecimals=2 truncates excess decimals', () {
      expect(format('', '73.4267', maxDecimals: 2).text, '73.42');
    });

    test('allows single decimal point (USD)', () {
      expect(format('', '73.4', maxDecimals: 2).text, '73.4');
      expect(format('', '0.5', maxDecimals: 2).text, '0.5');
    });

    test('multiple dots collapse to one (only first kept)', () {
      expect(format('', '1.2.3', maxDecimals: 2).text, '1.23');
    });

    test('large numbers grouped correctly', () {
      expect(format('', '1234567890').text, '1,234,567,890');
    });

    test('cursor stays after typed digit (cursor at end)', () {
      final r = format('1,234', '12345');
      expect(r.text, '12,345');
      // Cursor is at end after typing.
      expect(r.selection.baseOffset, r.text.length);
    });

    test('handles backspace (text shorter than before)', () {
      final r = format('1,234', '1,23');
      expect(r.text, '123');
    });
  });
}
