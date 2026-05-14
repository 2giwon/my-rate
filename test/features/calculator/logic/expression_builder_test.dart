import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/calculator/models.dart';
import 'package:myrate/features/calculator/logic/expression_builder.dart';

CalculatorState _apply(CalculatorState s, CalculatorKey k) => applyKey(s, k);

CalculatorState _applyMany(List<CalculatorKey> keys) {
  var s = CalculatorState.initial();
  for (final k in keys) {
    s = _apply(s, k);
  }
  return s;
}

void main() {
  group('applyKey', () {
    test('digit appended to empty: 0..9', () {
      final s = _apply(CalculatorState.initial(), const DigitKey(5));
      expect(s.expression, '5');
      expect(s.result, 5.0);
    });

    test('multi-digit number with thousand separators', () {
      final s = _applyMany(const [
        DigitKey(1),
        DigitKey(2),
        DigitKey(0),
        DigitKey(0),
      ]);
      expect(s.expression, '1,200');
      expect(s.result, 1200.0);
    });

    test('dot: 3.14', () {
      final s = _applyMany(const [
        DigitKey(3),
        DotKey(),
        DigitKey(1),
        DigitKey(4),
      ]);
      expect(s.expression, '3.14');
      expect(s.result, closeTo(3.14, 1e-9));
    });

    test('duplicate dot is ignored: 3..1 → 3.1', () {
      final s = _applyMany(const [
        DigitKey(3),
        DotKey(),
        DotKey(),
        DigitKey(1),
      ]);
      expect(s.expression, '3.1');
    });

    test('addition: 1+2', () {
      final s = _applyMany(const [
        DigitKey(1),
        OpKey(Operator.add),
        DigitKey(2),
      ]);
      expect(s.expression, '1 + 2');
      expect(s.result, 3.0);
    });

    test('operator replaces previous operator: 5 + - → 5 -', () {
      final s = _applyMany(const [
        DigitKey(5),
        OpKey(Operator.add),
        OpKey(Operator.sub),
      ]);
      expect(s.expression, '5 −');
    });

    test('precedence: 1 + 2 × 3 = 7', () {
      final s = _applyMany(const [
        DigitKey(1),
        OpKey(Operator.add),
        DigitKey(2),
        OpKey(Operator.mul),
        DigitKey(3),
      ]);
      expect(s.result, 7.0);
    });

    test('paren: (1+2)*3 = 9', () {
      final s = _applyMany(const [
        ParenOpenKey(),
        DigitKey(1),
        OpKey(Operator.add),
        DigitKey(2),
        ParenCloseKey(),
        OpKey(Operator.mul),
        DigitKey(3),
      ]);
      expect(s.result, 9.0);
    });

    test('implicit multiplication: 5( → 5×(', () {
      final s = _applyMany(const [
        DigitKey(5),
        ParenOpenKey(),
        DigitKey(2),
        ParenCloseKey(),
      ]);
      expect(s.expression, '5 × (2)');
      expect(s.result, 10.0);
    });

    test('empty close paren ignored: ) on empty → no change', () {
      final s = _apply(CalculatorState.initial(), const ParenCloseKey());
      expect(s.expression, '');
    });

    test('close paren ignored when no open: 5) → 5', () {
      final s = _applyMany(const [DigitKey(5), ParenCloseKey()]);
      expect(s.expression, '5');
    });

    test('clear key resets', () {
      final s = _applyMany(const [
        DigitKey(5),
        OpKey(Operator.add),
        DigitKey(3),
        ClearKey(),
      ]);
      expect(s.expression, '');
      expect(s.result, isNull);
    });

    test('backspace removes last token', () {
      final s = _applyMany(const [
        DigitKey(1),
        DigitKey(2),
        DigitKey(3),
        BackspaceKey(),
      ]);
      expect(s.expression, '12');
    });

    test('backspace on digit removes one digit (1,200 → 120)', () {
      final s = _applyMany(const [
        DigitKey(1),
        DigitKey(2),
        DigitKey(0),
        DigitKey(0),
        BackspaceKey(),
      ]);
      expect(s.expression, '120');
    });

    test('equals sets justEvaluated', () {
      final s = _applyMany(const [
        DigitKey(1),
        OpKey(Operator.add),
        DigitKey(2),
        EqualsKey(),
      ]);
      expect(s.expression, '1 + 2');
      expect(s.result, 3.0);
      expect(s.justEvaluated, isTrue);
    });

    test('after equals, operator continues from result', () {
      final s1 = _applyMany(const [
        DigitKey(1),
        OpKey(Operator.add),
        DigitKey(2),
        EqualsKey(),
      ]);
      expect(s1.result, 3.0);
      final s2 = applyKey(s1, const OpKey(Operator.mul));
      expect(s2.expression, '3 ×');
      expect(s2.justEvaluated, isFalse);
    });

    test('after equals, digit starts new expression', () {
      final s1 = _applyMany(const [DigitKey(5), EqualsKey()]);
      final s2 = applyKey(s1, const DigitKey(7));
      expect(s2.expression, '7');
      expect(s2.justEvaluated, isFalse);
    });

    test('division by zero sets hasError', () {
      final s = _applyMany(const [
        DigitKey(5),
        OpKey(Operator.div),
        DigitKey(0),
        EqualsKey(),
      ]);
      expect(s.hasError, isTrue);
    });

    test('expression length cap: > 500 chars dropped', () {
      var s = CalculatorState.initial();
      for (var i = 0; i < 600; i++) {
        s = applyKey(s, const DigitKey(1));
      }
      expect(s.expression.replaceAll(',', '').length, lessThanOrEqualTo(500));
    });

    test('percent on plus: 5000+30% mid-input updates preview', () {
      final s = _applyMany(const [
        DigitKey(5),
        DigitKey(0),
        DigitKey(0),
        DigitKey(0),
        OpKey(Operator.add),
        DigitKey(3),
        DigitKey(0),
        PercentKey(),
      ]);
      expect(s.expression, contains('%'));
      expect(s.result, closeTo(6500.0, 1e-6));
    });
  });
}
