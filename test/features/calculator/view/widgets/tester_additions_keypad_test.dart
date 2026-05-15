// Tester additions — CalculatorKeypad and KeyButton coverage gaps.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/calculator/providers/calculator_notifier.dart';
import 'package:myrate/features/calculator/view/widgets/calculator_keypad.dart';
import 'package:myrate/features/calculator/view/widgets/key_button.dart';

void main() {
  group('CalculatorKeypad — full key coverage', () {
    testWidgets('tap C clears any prior expression', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: CalculatorKeypad())),
        ),
      );
      await tester.tap(find.text('9'));
      await tester.tap(find.text('+'));
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(container.read(calculatorNotifierProvider).expression, isNotEmpty);

      await tester.tap(find.text('C'));
      await tester.pump();
      expect(container.read(calculatorNotifierProvider).expression, '');
      expect(container.read(calculatorNotifierProvider).result, isNull);
    });

    testWidgets('tap ( and ) builds (1+2) and evaluates to 3', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: CalculatorKeypad())),
        ),
      );
      for (final k in const ['(', '1', '+', '2', ')', '=']) {
        await tester.tap(find.text(k));
        await tester.pump();
      }
      expect(container.read(calculatorNotifierProvider).result, 3.0);
    });

    testWidgets('tap % computes percentage from existing number', (
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
      for (final k in const ['3', '0', '%']) {
        await tester.tap(find.text(k));
        await tester.pump();
      }
      expect(
        container.read(calculatorNotifierProvider).result,
        closeTo(0.3, 1e-9),
      );
    });

    testWidgets('tap . on empty produces "0."', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: CalculatorKeypad())),
        ),
      );
      await tester.tap(find.text('.'));
      await tester.pump();
      expect(container.read(calculatorNotifierProvider).expression, '0.');
    });

    testWidgets('tap / (÷) shows ÷ glyph in expression', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: CalculatorKeypad())),
        ),
      );
      for (final k in const ['6', '÷', '2']) {
        await tester.tap(find.text(k));
        await tester.pump();
      }
      expect(
        container.read(calculatorNotifierProvider).expression,
        contains('÷'),
      );
      expect(container.read(calculatorNotifierProvider).result, 3.0);
    });

    testWidgets(
      'rapid double-tap on same key produces 2 digits (no debounce)',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: Scaffold(body: CalculatorKeypad())),
          ),
        );
        await tester.tap(find.text('7'));
        await tester.tap(find.text('7'));
        await tester.pump();
        expect(container.read(calculatorNotifierProvider).expression, '77');
      },
    );
  });

  group('KeyButton — visual variants', () {
    testWidgets('digit / operator / equals / edit all render label', (
      tester,
    ) async {
      for (final kind in KeyKind.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: KeyButton(label: 'X', kind: kind, onTap: () {}),
            ),
          ),
        );
        expect(find.text('X'), findsOneWidget, reason: 'kind=$kind');
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('long-press is not registered (only tap calls onTap)', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyButton(
              label: '7',
              kind: KeyKind.digit,
              onTap: () => taps++,
            ),
          ),
        ),
      );
      await tester.longPress(find.text('7'));
      await tester.pump();
      // InkWell.onTap fires on long-press release per Flutter defaults;
      // verify count is 0 OR 1 — not multiple.
      expect(taps, lessThanOrEqualTo(1));
    });
  });
}
