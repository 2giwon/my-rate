/// Independent QA Tester additions.
///
/// 이 파일은 Developer의 70 unit 테스트가 다루지 않은 spec 조항을 보강합니다.
/// 각 테스트는 spec 섹션을 주석으로 명시하여 추적 가능성을 유지합니다.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myrate/core/constants/defaults.dart';
import 'package:myrate/core/constants/popular_currencies.dart';
import 'package:myrate/core/errors/app_exception.dart';
import 'package:myrate/data/exchange_rate/currency_catalog.dart';
import 'package:myrate/data/exchange_rate/exchange_rate_repository_impl.dart';
import 'package:myrate/data/exchange_rate/local/favorites_store.dart';
import 'package:myrate/data/exchange_rate/local/rate_cache.dart';
import 'package:myrate/data/exchange_rate/providers.dart';
import 'package:myrate/data/exchange_rate/remote/dtos.dart';
import 'package:myrate/data/exchange_rate/remote/exchange_rate_api.dart';
import 'package:myrate/domain/exchange_rate/exchange_rate_repository.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/logic/conversion.dart';
import 'package:myrate/features/converter/logic/tip_calculator.dart';
import 'package:myrate/features/converter/providers/converter_notifier.dart';
import 'package:myrate/features/currency_picker/providers/currency_picker_notifier.dart';
import 'package:myrate/data/exchange_rate/local/settings_store.dart';
import 'package:riverpod/riverpod.dart';

class _MockApi extends Mock implements ExchangeRateApi {}

class _MockCache extends Mock implements RateCache {}

class _MockFavorites extends Mock implements FavoritesStore {}

class _MockCatalog extends Mock implements CurrencyCatalog {}

class _MockRepo extends Mock implements ExchangeRateRepository {}

class _MockSettings extends Mock implements SettingsStore {}

class _FakeAdapter extends Mock implements HttpClientAdapter {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────
  // 1) Spec 5 / 16: AppDefaults 상수 값 검증 (계약 잠금)
  //    '기본 From=KRW, To=USD, amount=100000'은 spec에 박힌 값이며,
  //    실수로 바뀌면 사용자 경험이 깨진다.
  // ───────────────────────────────────────────────────────────────────
  group('AppDefaults (spec 5 / 16 contract)', () {
    test('defaultFromCurrency = "KRW"', () {
      expect(AppDefaults.defaultFromCurrency, 'KRW');
    });

    test('defaultToCurrency = "USD"', () {
      expect(AppDefaults.defaultToCurrency, 'USD');
    });

    test('defaultAmount = 100000', () {
      expect(AppDefaults.defaultAmount, 100000);
    });

    test('tipPresets = [5, 10, 15, 20]', () {
      // spec 4.3 팁 패널: [5%] [10%] [15%] [20%]
      expect(AppDefaults.tipPresets, [5, 10, 15, 20]);
    });

    test('defaultVatPercent = 10', () {
      // spec 4.3 세금 패널: 기본 10%
      expect(AppDefaults.defaultVatPercent, 10);
    });

    test('defaultFavorites includes seeds KRW/USD/JPY (spec 4.2)', () {
      // spec 4.2 즐겨찾기 섹션 예시
      expect(AppDefaults.defaultFavorites, containsAll(['KRW', 'USD', 'JPY']));
    });

    test('kPopularCurrencyCodes contains 12 currencies (spec 4.2)', () {
      // spec 4.2: USD, EUR, JPY, CNY, GBP, AUD, CAD, HKD, SGD, THB, VND, PHP
      expect(kPopularCurrencyCodes.length, 12);
      expect(
        kPopularCurrencyCodes,
        containsAll([
          'USD',
          'EUR',
          'JPY',
          'CNY',
          'GBP',
          'AUD',
          'CAD',
          'HKD',
          'SGD',
          'THB',
          'VND',
          'PHP',
        ]),
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────
  // 2) Spec 8.1 / 8.2: time_next_update_unix 파싱 정확성
  //    repository_impl이 unix 초 → DateTime(UTC, ms) 변환을 올바로 수행해야
  //    캐시 만료 판단(spec 9.2)이 의미를 갖는다.
  // ───────────────────────────────────────────────────────────────────
  group('Repository — DTO parsing (spec 8.1)', () {
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

    test('time_next_update_unix → apiNextUpdateAt 변환 (UTC ms)', () async {
      // 2024-05-12 00:00:00 UTC == 1715472000
      // 2024-05-13 00:00:00 UTC == 1715558400
      when(() => cache.read('USD')).thenAnswer((_) async => null);
      when(() => cache.save(any())).thenAnswer((_) async {});
      when(() => api.fetchLatest('USD')).thenAnswer(
        (_) async => LatestRatesDto(
          result: 'success',
          baseCode: 'USD',
          timeLastUpdateUnix: 1715472000,
          timeNextUpdateUnix: 1715558400,
          conversionRates: const {'KRW': 1362.5},
        ),
      );

      final snap = await repo.getLatest(baseCode: 'USD');
      expect(
        snap.apiUpdatedAt,
        DateTime.fromMillisecondsSinceEpoch(1715472000 * 1000, isUtc: true),
      );
      expect(
        snap.apiNextUpdateAt,
        DateTime.fromMillisecondsSinceEpoch(1715558400 * 1000, isUtc: true),
      );
      // 두 값의 차이는 정확히 24시간이어야 한다 (API 갱신 주기)
      expect(
        snap.apiNextUpdateAt.difference(snap.apiUpdatedAt),
        const Duration(hours: 24),
      );
    });

    test('ApiException은 repository에서 catch 되지 않고 그대로 전파된다', () async {
      // Spec 10: API HTTP 4xx/5xx + 잘못된 API 키 등은 ApiException/InvalidApiKeyException으로
      // 표현된다. repository_impl 코드를 보면 NetworkException만 fallback 처리하고
      // ApiException은 catch 하지 않는다 — features 레이어에서 별도 처리해야 함.
      // 이 동작이 spec과 일치하는지 명시적으로 잠근다.
      when(() => cache.read('USD')).thenAnswer((_) async => null);
      when(
        () => api.fetchLatest('USD'),
      ).thenThrow(const ApiException('Server Error', statusCode: 500));

      await expectLater(
        repo.getLatest(baseCode: 'USD'),
        throwsA(isA<ApiException>()),
      );
    });

    test('InvalidApiKeyException도 그대로 전파된다 (캐시 fallback 없음)', () async {
      // Spec 10: '잘못된 API 키' 상태는 fallback 없이 사용자에게 노출되어야 한다.
      when(() => cache.read('USD')).thenAnswer((_) async => null);
      when(
        () => api.fetchLatest('USD'),
      ).thenThrow(const InvalidApiKeyException('invalid-key'));

      await expectLater(
        repo.getLatest(baseCode: 'USD'),
        throwsA(isA<InvalidApiKeyException>()),
      );
    });

    test('연속 호출 시 캐시 유효하면 API는 1번도 호출되지 않는다 (월 1500건 보호)', () async {
      // Spec 8.2: 무료 플랜 보호 — 캐시 유효 시 API 호출 안 함.
      final snap = ExchangeRateSnapshot(
        baseCode: 'USD',
        rates: const {'KRW': 1362.5},
        fetchedAt: DateTime.utc(2026, 5, 12),
        apiUpdatedAt: DateTime.utc(2026, 5, 12),
        apiNextUpdateAt: DateTime.utc(2026, 5, 13), // 내일
      );
      when(() => cache.read('USD')).thenAnswer((_) async => snap);
      when(() => cache.save(any())).thenAnswer((_) async {});

      await repo.getLatest(baseCode: 'USD');
      await repo.getLatest(baseCode: 'USD');
      await repo.getLatest(baseCode: 'USD');

      verifyNever(() => api.fetchLatest(any()));
    });
  });

  // ───────────────────────────────────────────────────────────────────
  // 3) Spec 10: API error-type 변종 — 'inactive-account'와 일반 에러
  // ───────────────────────────────────────────────────────────────────
  group('ExchangeRateApi — error-type 변종 (spec 10)', () {
    setUpAll(() {
      registerFallbackValue(RequestOptions(path: ''));
    });

    test('inactive-account → InvalidApiKeyException', () async {
      // spec 10: '잘못된 API 키' 카테고리에 inactive-account도 포함된다.
      // Developer 테스트는 invalid-key만 검증했음.
      final dio = Dio();
      final adapter = _FakeAdapter();
      dio.httpClientAdapter = adapter;

      when(() => adapter.fetch(any(), any(), any())).thenAnswer((_) async {
        return ResponseBody.fromString(
          '{"result":"error","error-type":"inactive-account"}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });

      final api = ExchangeRateApi(dio: dio, apiKey: 'inactive');
      expect(
        () => api.fetchLatest('USD'),
        throwsA(isA<InvalidApiKeyException>()),
      );
    });

    test(
      'result=error + unsupported-code → ApiException (not InvalidApiKeyException)',
      () async {
        // spec 10: 일반 API 에러는 ApiException으로 분류.
        final dio = Dio();
        final adapter = _FakeAdapter();
        dio.httpClientAdapter = adapter;

        when(() => adapter.fetch(any(), any(), any())).thenAnswer((_) async {
          return ResponseBody.fromString(
            '{"result":"error","error-type":"unsupported-code"}',
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
            },
          );
        });

        final api = ExchangeRateApi(dio: dio, apiKey: 'k');
        // ApiException이지만 InvalidApiKeyException은 아니어야 함
        expect(
          () => api.fetchLatest('USD'),
          throwsA(
            allOf(isA<ApiException>(), isNot(isA<InvalidApiKeyException>())),
          ),
        );
      },
    );

    test('HTTP 404 → ApiException with statusCode (spec 10)', () async {
      // Developer는 500만 검증. spec 10은 4xx도 동일 fallback 카테고리.
      final dio = Dio();
      final adapter = _FakeAdapter();
      dio.httpClientAdapter = adapter;

      when(() => adapter.fetch(any(), any(), any())).thenAnswer((_) async {
        return ResponseBody.fromString('Not Found', 404);
      });

      final api = ExchangeRateApi(dio: dio, apiKey: 'k');
      expect(
        () => api.fetchLatest('USD'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────
  // 4) Spec 9.2: 만료 판단 경계
  // ───────────────────────────────────────────────────────────────────
  group('Stale boundary (spec 9.2)', () {
    final snap = ExchangeRateSnapshot(
      baseCode: 'USD',
      rates: const {},
      fetchedAt: DateTime.utc(2026, 5, 12),
      apiUpdatedAt: DateTime.utc(2026, 5, 12),
      apiNextUpdateAt: DateTime.utc(2026, 5, 13, 0, 0, 0),
    );

    test('now == apiNextUpdateAt → not stale (isAfter는 strict)', () {
      // spec 9.2: '미래면 유효. 과거면 만료' — 동일 시각은 isAfter==false이므로 유효
      expect(snap.isStaleAt(DateTime.utc(2026, 5, 13, 0, 0, 0)), isFalse);
    });

    test('now == apiNextUpdateAt + 1ms → stale', () {
      expect(snap.isStaleAt(DateTime.utc(2026, 5, 13, 0, 0, 0, 1)), isTrue);
    });
  });

  // ───────────────────────────────────────────────────────────────────
  // 5) Spec 12 / 5: CurrencyCatalog — 알 수 없는 언어 코드는 en 폴백
  //    spec 12: '시스템 언어가 한국어/영어 외이면 영어로 폴백'.
  //    Developer는 ko/en만 검증했으므로 zh/fr 같은 비지원 언어를 검증.
  // ───────────────────────────────────────────────────────────────────
  group('CurrencyCatalog — language fallback (spec 12)', () {
    test('알 수 없는 언어 코드(zh) → 영어 이름 폴백', () async {
      final c = CurrencyCatalog();
      await c.load();

      final usd = c.resolve('USD', languageCode: 'zh');
      // ko가 아니면 en으로 강제되므로 'US Dollar' 반환
      expect(usd.name, 'US Dollar');
    });

    test('빈 문자열 언어 코드 → en 폴백', () async {
      final c = CurrencyCatalog();
      await c.load();
      final usd = c.resolve('USD', languageCode: '');
      expect(usd.name, 'US Dollar');
    });

    test('알 수 없는 코드 + en → 코드 자체를 이름으로 폴백', () async {
      // Developer는 ko만 검증했지만, en에서도 동일하게 동작해야 한다.
      final c = CurrencyCatalog();
      await c.load();
      final unknown = c.resolve('ZZZ', languageCode: 'en');
      expect(unknown.code, 'ZZZ');
      expect(unknown.name, 'ZZZ');
    });
  });

  // ───────────────────────────────────────────────────────────────────
  // 6) Spec 5 / 4.1: conversion — num(int) 입력 처리
  //    ConversionResult.amount는 num 타입이며 int/double 모두 허용한다.
  // ───────────────────────────────────────────────────────────────────
  group('convert — int amount input (spec 5 model)', () {
    final snap = ExchangeRateSnapshot(
      baseCode: 'USD',
      rates: const {'USD': 1.0, 'KRW': 1362.5},
      fetchedAt: DateTime(2026, 5, 12),
      apiUpdatedAt: DateTime(2026, 5, 12),
      apiNextUpdateAt: DateTime(2026, 5, 13),
    );

    test('int amount = 1 produces double convertedAmount', () {
      // amount는 num 타입(spec 5)이며 입력으로 int가 와도 안전해야 함.
      final r = convert(snap: snap, fromCode: 'USD', toCode: 'KRW', amount: 1);
      expect(r.amount, isA<num>());
      expect(r.amount, 1);
      expect(r.convertedAmount, isA<double>());
      expect(r.convertedAmount, closeTo(1362.5, 1e-9));
    });

    test('매우 큰 수 (1조원) 도 안전하게 변환', () {
      // KRW 1조원 → USD 환산 — overflow 없이 정상 처리되어야 함.
      final big = 1000000000000.0; // 1조
      final r = convert(
        snap: snap,
        fromCode: 'KRW',
        toCode: 'USD',
        amount: big,
      );
      expect(r.convertedAmount, closeTo(big / 1362.5, 1e-3));
      expect(r.convertedAmount.isFinite, isTrue);
    });
  });

  // ───────────────────────────────────────────────────────────────────
  // 7) Spec 4.3 팁 — 매우 큰 % 입력 (상한 없음, computed)
  // ───────────────────────────────────────────────────────────────────
  group('calculateTip — extreme values (spec 4.3)', () {
    test('200% tip on 100 → tip 200, total 300 (no upper clamp)', () {
      // tip_calculator는 음수만 0으로 클램프하며 상한은 없다.
      // discount_calculator와 다른 동작 — spec 4.3에 상한 명시가 없으므로 그대로 계산.
      final s = calculateTip(amount: 100, percent: 200);
      expect(s.tipAmount, 200);
      expect(s.total, 300);
    });

    test('9999% tip on 100 → tip 9999', () {
      // 사용자가 실수로 큰 값을 입력해도 nan/inf 없이 계산되어야 함.
      final s = calculateTip(amount: 100, percent: 9999);
      expect(s.tipAmount, 9999);
      expect(s.total, 10099);
      expect(s.tipAmount.isFinite, isTrue);
    });
  });

  // ───────────────────────────────────────────────────────────────────
  // 8) Spec 4.2 검색 — 코드/이름, 대소문자, 빈 쿼리
  // ───────────────────────────────────────────────────────────────────
  group('CurrencyPicker search (spec 4.2)', () {
    late _MockRepo repo;

    setUp(() {
      repo = _MockRepo();
      when(
        () => repo.getFavoriteCodes(),
      ).thenAnswer((_) async => ['KRW', 'USD']);
      when(() => repo.addFavorite(any())).thenAnswer((_) async {});
      when(() => repo.removeFavorite(any())).thenAnswer((_) async {});
    });

    ProviderContainer make() {
      return ProviderContainer(
        overrides: [
          currencyCatalogProvider.overrideWith((_) async {
            final c = CurrencyCatalog();
            await c.load();
            return c;
          }),
          exchangeRateRepositoryProvider.overrideWith((_) async => repo),
        ],
      );
    }

    test('소문자 코드 검색 "usd" → USD 매칭 (case-insensitive)', () async {
      final c = make();
      addTearDown(c.dispose);
      final family = currencyPickerNotifierProvider(
        availableCodes: const ['USD', 'KRW', 'JPY', 'EUR'],
        languageCode: 'ko',
      );
      await c.read(family.future);
      c.read(family.notifier).search('usd');
      final state = c.read(family).valueOrNull!;
      expect(state.searched.any((e) => e.code == 'USD'), isTrue);
    });

    test('빈 쿼리 → all 그대로 반환 (헤더 표시 모드)', () async {
      // spec 4.2: '검색어 입력 시 ... 결과만 단일 리스트로'. 빈 쿼리는 정상 섹션 모드.
      final c = make();
      addTearDown(c.dispose);
      final family = currencyPickerNotifierProvider(
        availableCodes: const ['USD', 'KRW', 'JPY'],
        languageCode: 'ko',
      );
      await c.read(family.future);
      c.read(family.notifier).search('');
      final state = c.read(family).valueOrNull!;
      expect(state.searched.length, 3);
    });

    test('검색 결과 0건 (매칭 안 됨)', () async {
      final c = make();
      addTearDown(c.dispose);
      final family = currencyPickerNotifierProvider(
        availableCodes: const ['USD', 'KRW', 'JPY'],
        languageCode: 'ko',
      );
      await c.read(family.future);
      c.read(family.notifier).search('zzzzz');
      final state = c.read(family).valueOrNull!;
      expect(state.searched, isEmpty);
    });

    test('toggleFavorite — 기존 즐겨찾기 해제', () async {
      // Developer는 추가만 검증. 해제 경로(removeFavorite)도 검증.
      final c = make();
      addTearDown(c.dispose);
      final family = currencyPickerNotifierProvider(
        availableCodes: const ['USD', 'KRW'],
        languageCode: 'ko',
      );
      await c.read(family.future);

      // USD는 초기 favorites에 포함됨 → toggle하면 remove 호출
      when(() => repo.getFavoriteCodes()).thenAnswer((_) async => ['KRW']);
      await c.read(family.notifier).toggleFavorite('USD');
      verify(() => repo.removeFavorite('USD')).called(1);
      expect(c.read(family).valueOrNull!.favorites, isNot(contains('USD')));
    });
  });

  // ───────────────────────────────────────────────────────────────────
  // 9) ConverterNotifier — setFromCode 동일 코드일 때 no-op
  //    Spec 4.1: 통화 셀 탭 → picker. 동일 통화 재선택 시 불필요한 API 호출 방지.
  // ───────────────────────────────────────────────────────────────────
  group('ConverterNotifier — idempotency & swap roundtrip', () {
    late _MockRepo repo;
    late _MockSettings settings;

    ExchangeRateSnapshot snap({String base = 'KRW'}) => ExchangeRateSnapshot(
      baseCode: base,
      rates: const {'KRW': 1.0, 'USD': 1 / 1362.5, 'JPY': 156.2 / 1362.5},
      fetchedAt: DateTime.utc(2026, 5, 12),
      apiUpdatedAt: DateTime.utc(2026, 5, 12),
      apiNextUpdateAt: DateTime.utc(2026, 5, 13),
    );

    ProviderContainer makeContainer() {
      return ProviderContainer(
        overrides: [
          exchangeRateRepositoryProvider.overrideWith((_) async => repo),
          settingsStoreProvider.overrideWith((_) async => settings),
        ],
      );
    }

    setUp(() {
      repo = _MockRepo();
      settings = _MockSettings();
      when(() => settings.defaultFrom()).thenAnswer((_) async => 'KRW');
      when(() => settings.defaultTo()).thenAnswer((_) async => 'USD');
      when(
        () => repo.getLatest(
          baseCode: any(named: 'baseCode'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((invocation) async {
        final base = invocation.namedArguments[#baseCode] as String;
        return snap(base: base);
      });
    });

    test('setFromCode(currentCode) → no-op, API 추가 호출 없음', () async {
      // spec: 동일 코드 재선택은 무의미한 재요청을 일으키지 말아야 한다.
      final c = makeContainer();
      addTearDown(c.dispose);
      await c.read(converterNotifierProvider.future);

      // 초기 빌드의 KRW 호출 1회를 검증하고 소비
      verify(
        () => repo.getLatest(
          baseCode: 'KRW',
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).called(1);

      // 동일 코드 재선택 시 추가 호출이 없어야 함
      await c.read(converterNotifierProvider.notifier).setFromCode('KRW');

      verifyNever(
        () => repo.getLatest(
          baseCode: any(named: 'baseCode'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      );
    });

    test('swap → swap → from/to 원래대로 복원', () async {
      // spec 4.1: swap은 사용자가 흔히 반복하는 동작. 두 번 누르면 원상복귀.
      final c = makeContainer();
      addTearDown(c.dispose);
      await c.read(converterNotifierProvider.future);

      await c.read(converterNotifierProvider.notifier).swap();
      await c.read(converterNotifierProvider.notifier).swap();

      final state = c.read(converterNotifierProvider).valueOrNull!;
      expect(state.fromCode, 'KRW');
      expect(state.toCode, 'USD');
    });

    test('초기 build의 amount는 spec 기본값 100000과 일치', () async {
      // spec 4.1: 금액 입력 칸 초기값 100,000.
      final c = makeContainer();
      addTearDown(c.dispose);
      final state = await c.read(converterNotifierProvider.future);
      expect(state.amount, AppDefaults.defaultAmount);
    });
  });
}
