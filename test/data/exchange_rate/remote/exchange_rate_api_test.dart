import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myrate/core/errors/app_exception.dart';
import 'package:myrate/data/exchange_rate/remote/exchange_rate_api.dart';

class _FakeAdapter extends Mock implements HttpClientAdapter {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  group('ExchangeRateApi (Open Exchange Rates)', () {
    test('returns LatestRatesDto on 200', () async {
      final dio = Dio();
      final adapter = _FakeAdapter();
      dio.httpClientAdapter = adapter;

      when(() => adapter.fetch(any(), any(), any())).thenAnswer((_) async {
        return ResponseBody.fromString(
          '{"disclaimer":"x","license":"y","timestamp":1715472000,'
          '"base":"USD","rates":{"KRW":1362.5,"JPY":156.2}}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });

      final api = ExchangeRateApi(dio: dio, apiKey: 'test-key');
      final dto = await api.fetchLatest('USD');
      expect(dto.base, 'USD');
      expect(dto.timestamp, 1715472000);
      expect(dto.rates['KRW'], 1362.5);
    });

    test('throws InvalidApiKeyException on 401 invalid_app_id', () async {
      final dio = Dio();
      final adapter = _FakeAdapter();
      dio.httpClientAdapter = adapter;

      when(() => adapter.fetch(any(), any(), any())).thenAnswer((_) async {
        return ResponseBody.fromString(
          '{"error":true,"status":401,"message":"invalid_app_id","description":"bad key"}',
          401,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });

      final api = ExchangeRateApi(dio: dio, apiKey: 'bad');
      expect(
        () => api.fetchLatest('USD'),
        throwsA(isA<InvalidApiKeyException>()),
      );
    });

    test('throws ApiException on HTTP 500', () async {
      final dio = Dio();
      final adapter = _FakeAdapter();
      dio.httpClientAdapter = adapter;

      when(() => adapter.fetch(any(), any(), any())).thenAnswer((_) async {
        return ResponseBody.fromString('Server Error', 500);
      });

      final api = ExchangeRateApi(dio: dio, apiKey: 'k');
      expect(() => api.fetchLatest('USD'), throwsA(isA<ApiException>()));
    });

    test(
      'throws NetworkException on DioException connection failure',
      () async {
        final dio = Dio();
        final adapter = _FakeAdapter();
        dio.httpClientAdapter = adapter;

        when(() => adapter.fetch(any(), any(), any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ),
        );

        final api = ExchangeRateApi(dio: dio, apiKey: 'k');
        expect(() => api.fetchLatest('USD'), throwsA(isA<NetworkException>()));
      },
    );
  });
}
