import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myrate/core/errors/app_exception.dart';
import 'package:myrate/data/exchange_rate/currency_catalog.dart';
import 'package:myrate/data/exchange_rate/exchange_rate_repository_impl.dart';
import 'package:myrate/data/exchange_rate/local/favorites_store.dart';
import 'package:myrate/data/exchange_rate/local/rate_cache.dart';
import 'package:myrate/data/exchange_rate/remote/dtos.dart';
import 'package:myrate/data/exchange_rate/remote/exchange_rate_api.dart';
import 'package:myrate/domain/exchange_rate/models.dart';

class _MockApi extends Mock implements ExchangeRateApi {}

class _MockCache extends Mock implements RateCache {}

class _MockFavorites extends Mock implements FavoritesStore {}

class _MockCatalog extends Mock implements CurrencyCatalog {}

void main() {
  late _MockApi api;
  late _MockCache cache;
  late _MockFavorites favorites;
  late _MockCatalog catalog;
  late ExchangeRateRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(
      ExchangeRateSnapshot(
        baseCode: 'USD',
        rates: const {},
        fetchedAt: DateTime(2000),
        apiUpdatedAt: DateTime(2000),
        apiNextUpdateAt: DateTime(2000),
      ),
    );
  });

  setUp(() {
    api = _MockApi();
    cache = _MockCache();
    favorites = _MockFavorites();
    catalog = _MockCatalog();
    repo = ExchangeRateRepositoryImpl(
      api: api,
      cache: cache,
      favorites: favorites,
      catalog: catalog,
      clock: () => DateTime.utc(2026, 5, 12, 12),
    );
  });

  ExchangeRateSnapshot snap({DateTime? nextUpdate}) => ExchangeRateSnapshot(
    baseCode: 'USD',
    rates: const {'KRW': 1362.5},
    fetchedAt: DateTime.utc(2026, 5, 12),
    apiUpdatedAt: DateTime.utc(2026, 5, 12),
    apiNextUpdateAt: nextUpdate ?? DateTime.utc(2026, 5, 13),
  );

  test('valid cache: returns cache without API call', () async {
    when(() => cache.read('USD')).thenAnswer((_) async => snap());
    when(() => cache.save(any())).thenAnswer((_) async {});

    final r = await repo.getLatest(baseCode: 'USD');
    expect(r.baseCode, 'USD');
    verifyNever(() => api.fetchLatest(any()));
  });

  test('expired cache: calls API and saves', () async {
    when(
      () => cache.read('USD'),
    ).thenAnswer((_) async => snap(nextUpdate: DateTime.utc(2026, 5, 1)));
    when(() => api.fetchLatest('USD')).thenAnswer(
      (_) async => LatestRatesDto(
        base: 'USD',
        timestamp: 1715472000,
        rates: const {'KRW': 1400.0},
      ),
    );
    when(() => cache.save(any())).thenAnswer((_) async {});

    final r = await repo.getLatest(baseCode: 'USD');
    expect(r.rates['KRW'], 1400.0);
    verify(() => cache.save(any())).called(1);
  });

  test('forceRefresh: bypasses cache', () async {
    when(() => cache.read('USD')).thenAnswer((_) async => snap());
    when(() => api.fetchLatest('USD')).thenAnswer(
      (_) async => LatestRatesDto(
        base: 'USD',
        timestamp: 1715472000,
        rates: const {'KRW': 1400.0},
      ),
    );
    when(() => cache.save(any())).thenAnswer((_) async {});

    final r = await repo.getLatest(baseCode: 'USD', forceRefresh: true);
    expect(r.rates['KRW'], 1400.0);
    verify(() => api.fetchLatest('USD')).called(1);
  });

  test('network failure + cache: returns cache', () async {
    when(
      () => cache.read('USD'),
    ).thenAnswer((_) async => snap(nextUpdate: DateTime.utc(2026, 5, 1)));
    when(
      () => api.fetchLatest('USD'),
    ).thenThrow(const NetworkException('offline'));

    final r = await repo.getLatest(baseCode: 'USD');
    expect(r.baseCode, 'USD');
  });

  test('network failure + no cache: rethrows', () async {
    when(() => cache.read('USD')).thenAnswer((_) async => null);
    when(
      () => api.fetchLatest('USD'),
    ).thenThrow(const NetworkException('offline'));

    expect(
      () => repo.getLatest(baseCode: 'USD'),
      throwsA(isA<NetworkException>()),
    );
  });
}
