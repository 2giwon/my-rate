import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/calculator/view/widgets/key_button.dart';

void main() {
  group('KeyButton', () {
    testWidgets('shows label and calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KeyButton(
              label: '7',
              kind: KeyKind.digit,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      expect(find.text('7'), findsOneWidget);
      await tester.tap(find.text('7'));
      expect(tapped, isTrue);
    });

    testWidgets('different kinds render', (tester) async {
      for (final k in KeyKind.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: KeyButton(label: 'X', kind: k, onTap: () {}),
            ),
          ),
        );
        expect(find.text('X'), findsOneWidget);
      }
    });
  });
}
