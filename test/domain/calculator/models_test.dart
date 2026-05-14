import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/calculator/models.dart';

void main() {
  group('CalculatorState', () {
    test(
      'initial state is empty / no result / no error / not just evaluated',
      () {
        final s = CalculatorState.initial();
        expect(s.expression, '');
        expect(s.result, isNull);
        expect(s.hasError, isFalse);
        expect(s.justEvaluated, isFalse);
      },
    );

    test('copyWith updates only specified fields', () {
      final s = CalculatorState.initial().copyWith(
        expression: '1+2',
        result: 3.0,
      );
      expect(s.expression, '1+2');
      expect(s.result, 3.0);
      expect(s.hasError, isFalse);
    });
  });

  group('CalculatorKey hierarchy', () {
    test('DigitKey stores digit', () {
      expect(const DigitKey(5).digit, 5);
    });
    test('OpKey stores operator', () {
      expect(const OpKey(Operator.add).op, Operator.add);
    });
    test('singletons exist', () {
      expect(const DotKey(), isA<CalculatorKey>());
      expect(const ParenOpenKey(), isA<CalculatorKey>());
      expect(const ParenCloseKey(), isA<CalculatorKey>());
      expect(const PercentKey(), isA<CalculatorKey>());
      expect(const EqualsKey(), isA<CalculatorKey>());
      expect(const ClearKey(), isA<CalculatorKey>());
      expect(const BackspaceKey(), isA<CalculatorKey>());
    });
  });

  group('Operator', () {
    test('symbol returns display character', () {
      expect(Operator.add.symbol, '+');
      expect(Operator.sub.symbol, '−');
      expect(Operator.mul.symbol, '×');
      expect(Operator.div.symbol, '÷');
    });
    test('asciiSymbol returns evaluation character', () {
      expect(Operator.add.asciiSymbol, '+');
      expect(Operator.sub.asciiSymbol, '-');
      expect(Operator.mul.asciiSymbol, '*');
      expect(Operator.div.asciiSymbol, '/');
    });
  });
}
