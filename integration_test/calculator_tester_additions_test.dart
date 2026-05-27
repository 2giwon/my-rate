// Tester additions — integration coverage for spec §3 / §10 flows missed
// by Developer's `calculator_e2e_test.dart`.
//
// - ⌫ icon in ExpressionDisplay (backspace flow through screen)
// - C key clearing both expression and result on screen
// - Division-by-zero shows error label
// - Auto-recovery from error state by next digit
// - Calculator result feeds into ConvertedDisplay
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myrate/app.dart';
import 'package:myrate/data/exchange_rate/providers.dart';
import 'package:myrate/data/exchange_rate/remote/dtos.dart';
import 'package:myrate/data/exchange_rate/remote/exchange_rate_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApi extends ExchangeRateApi {
  _FakeApi() : super(dio: Dio(), apiKey: 'fake');
  @override
  Future<LatestRatesDto> fetchLatest(String baseCode) async => LatestRatesDto(
    base: baseCode,
    timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    rates: const {'KRW': 1.0, 'USD': 1 / 1362.5},
  );
}

Future<void> _bootApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [exchangeRateApiProvider.overrideWithValue(_FakeApi())],
      child: const MyRateApp(),
    ),
  );
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('backspace icon in From card removes last token', (tester) async {
    await _bootApp(tester);
    for (final k in const ['1', '2', '3']) {
      await tester.tap(find.text(k));
      await tester.pump();
    }
    expect(find.text('123'), findsWidgets);

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
    expect(find.text('12'), findsWidgets);
  });

  testWidgets('C key clears expression and resets amount display', (
    tester,
  ) async {
    await _bootApp(tester);
    for (final k in const ['9', '9', '9']) {
      await tester.tap(find.text(k));
      await tester.pump();
    }
    expect(find.text('999'), findsWidgets);
    await tester.tap(find.text('C'));
    await tester.pumpAndSettle();
    // After C, expression area shows "0" placeholder.
    expect(find.text('999'), findsNothing);
  });

  testWidgets('5 ÷ 0 = shows Error label in From card', (tester) async {
    await _bootApp(tester);
    for (final k in const ['5', '÷', '0', '=']) {
      await tester.tap(find.text(k));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('Error'), findsOneWidget);
  });

  testWidgets(
    'error recovers when user types next digit (no Error label after recovery)',
    (tester) async {
      await _bootApp(tester);
      for (final k in const ['5', '÷', '0', '=']) {
        await tester.tap(find.text(k));
        await tester.pump();
      }
      expect(find.text('Error'), findsOneWidget);
      // Press a digit — error should clear.
      await tester.tap(find.text('7'));
      await tester.pumpAndSettle();
      expect(find.text('Error'), findsNothing);
    },
  );

  testWidgets('(1000+500)×3= produces 4,500 and converts to USD', (
    tester,
  ) async {
    await _bootApp(tester);
    for (final k in const [
      '(',
      '1',
      '0',
      '0',
      '0',
      '+',
      '5',
      '0',
      '0',
      ')',
      '×',
      '3',
      '=',
    ]) {
      await tester.tap(find.text(k));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('4,500'), findsWidgets);
    // Converted (USD) should be 4500 / 1362.5 ≈ 3.30 — verify a USD value
    // less than the KRW value is shown somewhere.
    expect(find.textContaining('3.30'), findsWidgets);
  });
}
