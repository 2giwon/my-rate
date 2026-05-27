import 'package:dio/dio.dart';
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

  testWidgets('golden path: 1200 * 3 + 500 = 4,100 in From card', (
    tester,
  ) async {
    await _bootApp(tester);
    for (final key in const [
      '1',
      '2',
      '0',
      '0',
      '×',
      '3',
      '+',
      '5',
      '0',
      '0',
      '=',
    ]) {
      await tester.tap(find.text(key));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('4,100'), findsWidgets);
  });

  testWidgets('parentheses: (1000 + 500) × 3 = 4,500', (tester) async {
    await _bootApp(tester);
    for (final key in const [
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
      await tester.tap(find.text(key));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('4,500'), findsWidgets);
  });

  testWidgets('percent: 50000 − 30 % = 35,000', (tester) async {
    await _bootApp(tester);
    for (final key in const [
      '5',
      '0',
      '0',
      '0',
      '0',
      '−',
      '3',
      '0',
      '%',
      '=',
    ]) {
      await tester.tap(find.text(key));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('35,000'), findsWidgets);
  });
}
