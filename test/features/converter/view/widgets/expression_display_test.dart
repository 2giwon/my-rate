import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/view/widgets/expression_display.dart';

void main() {
  const currency = Currency(
    code: 'KRW',
    name: '대한민국 원',
    flagEmoji: '🇰🇷',
    decimalPlaces: 0,
  );

  testWidgets('shows expression and result', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpressionDisplay(
            currency: currency,
            expression: '1,200 × 3 + 500',
            result: 4100.0,
            hasError: false,
            onTapHeader: () {},
          ),
        ),
      ),
    );
    expect(find.text('1,200 × 3 + 500'), findsOneWidget);
    expect(find.text('4,100'), findsOneWidget);
    expect(find.text('KRW'), findsOneWidget);
  });

  testWidgets('tap header calls onTapHeader', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpressionDisplay(
            currency: currency,
            expression: '',
            result: null,
            hasError: false,
            onTapHeader: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('KRW'));
    expect(tapped, isTrue);
  });

  testWidgets('hasError shows error label instead of result', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpressionDisplay(
            currency: currency,
            expression: '5 ÷ 0',
            result: null,
            hasError: true,
            onTapHeader: () {},
          ),
        ),
      ),
    );
    expect(find.text('Error'), findsOneWidget);
  });
}
