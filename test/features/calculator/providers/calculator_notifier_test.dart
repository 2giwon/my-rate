import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/calculator/models.dart';
import 'package:myrate/features/calculator/providers/calculator_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('CalculatorNotifier', () {
    test('initial state', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final s = c.read(calculatorNotifierProvider);
      expect(s.expression, '');
      expect(s.result, isNull);
    });

    test('onKey applies single digit', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(calculatorNotifierProvider.notifier).onKey(const DigitKey(5));
      expect(c.read(calculatorNotifierProvider).expression, '5');
      expect(c.read(calculatorNotifierProvider).result, 5.0);
    });

    test('chain of keys: 1+2= → 3', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(calculatorNotifierProvider.notifier);
      n.onKey(const DigitKey(1));
      n.onKey(const OpKey(Operator.add));
      n.onKey(const DigitKey(2));
      n.onKey(const EqualsKey());
      final s = c.read(calculatorNotifierProvider);
      expect(s.result, 3.0);
      expect(s.justEvaluated, isTrue);
    });

    test('clear key resets to initial', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(calculatorNotifierProvider.notifier);
      n.onKey(const DigitKey(9));
      n.onKey(const ClearKey());
      expect(c.read(calculatorNotifierProvider).expression, '');
    });

    test('setExpression replaces with new value (used by panel apply)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(calculatorNotifierProvider.notifier).setExpression(1234);
      final s = c.read(calculatorNotifierProvider);
      expect(s.expression, '1,234');
      expect(s.result, 1234.0);
    });
  });
}
