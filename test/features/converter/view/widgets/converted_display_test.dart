import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/view/widgets/converted_display.dart';

void main() {
  const currency = Currency(
    code: 'USD',
    name: 'US Dollar',
    flagEmoji: '🇺🇸',
    decimalPlaces: 2,
  );

  testWidgets('shows code, name, and converted value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConvertedDisplay(
            currency: currency,
            convertedValue: 3.01,
            onTapHeader: () {},
          ),
        ),
      ),
    );
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('3.01'), findsOneWidget);
  });

  testWidgets('null value shows placeholder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConvertedDisplay(
            currency: currency,
            convertedValue: null,
            onTapHeader: () {},
          ),
        ),
      ),
    );
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('tap header calls onTapHeader', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ConvertedDisplay(
            currency: currency,
            convertedValue: 1.0,
            onTapHeader: () => tapped = true,
          ),
        ),
      ),
    );
    await tester.tap(find.text('USD'));
    expect(tapped, isTrue);
  });
}
