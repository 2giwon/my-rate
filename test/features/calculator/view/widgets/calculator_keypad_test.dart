import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/calculator/providers/calculator_notifier.dart';
import 'package:myrate/features/calculator/view/widgets/calculator_keypad.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: CalculatorKeypad())),
      ),
    );
  }

  testWidgets('renders all 20 keys', (tester) async {
    await pump(tester);
    for (final label in const [
      'C',
      '(',
      ')',
      '÷',
      '7',
      '8',
      '9',
      '×',
      '4',
      '5',
      '6',
      '−',
      '1',
      '2',
      '3',
      '+',
      '%',
      '0',
      '.',
      '=',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'key "$label" missing');
    }
  });

  testWidgets('tapping 5 updates CalculatorNotifier.expression', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: CalculatorKeypad())),
      ),
    );
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(container.read(calculatorNotifierProvider).expression, '5');
  });

  testWidgets('tapping 1+2= produces result 3', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: CalculatorKeypad())),
      ),
    );
    await tester.tap(find.text('1'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(container.read(calculatorNotifierProvider).result, 3.0);
  });
}
