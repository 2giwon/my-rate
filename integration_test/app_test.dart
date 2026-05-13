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
  Future<LatestRatesDto> fetchLatest(String baseCode) async {
    return LatestRatesDto(
      result: 'success',
      baseCode: baseCode,
      timeLastUpdateUnix: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      timeNextUpdateUnix:
          DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000,
      conversionRates: const {'KRW': 1.0, 'USD': 1 / 1362.5, 'JPY': 156.2 / 1362.5},
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('golden path: app loads → converts KRW→USD', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [exchangeRateApiProvider.overrideWithValue(_FakeApi())],
        child: const MyRateApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 메인 화면이 보인다
    expect(find.text('KRW'), findsWidgets);
    expect(find.text('USD'), findsWidgets);
    // 환율 결과가 0이 아닌 값으로 표시
    expect(find.textContaining('73'), findsWidgets);
  });
}
