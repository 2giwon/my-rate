import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myrate/data/exchange_rate/local/settings_store.dart';
import 'package:myrate/data/exchange_rate/providers.dart';
import 'package:myrate/domain/calculator/models.dart';
import 'package:myrate/domain/exchange_rate/exchange_rate_repository.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/calculator/providers/calculator_notifier.dart';
import 'package:myrate/features/converter/providers/converter_notifier.dart';

class _MockRepo extends Mock implements ExchangeRateRepository {}

class _MockSettings extends Mock implements SettingsStore {}

void main() {
  late _MockRepo repo;
  late _MockSettings settings;

  setUpAll(() {});

  ExchangeRateSnapshot _snap({String base = 'KRW'}) => ExchangeRateSnapshot(
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
    ).thenAnswer((_) async => _snap());
  });

  test('initial build loads snapshot and defaults', () async {
    final c = makeContainer();
    addTearDown(c.dispose);

    final state = await c.read(converterNotifierProvider.future);
    expect(state.fromCode, 'KRW');
    expect(state.toCode, 'USD');
    expect(state.amount, 100000);
    expect(state.snapshot, isNotNull);
    expect(state.result?.convertedAmount, isNotNull);
  });

  test('setAmount updates amount and result', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(converterNotifierProvider.future);

    c.read(converterNotifierProvider.notifier).setAmount(50000);
    final state = c.read(converterNotifierProvider).valueOrNull!;
    expect(state.amount, 50000);
  });

  test('swap exchanges from/to and reloads snapshot for new base', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(converterNotifierProvider.future);

    await c.read(converterNotifierProvider.notifier).swap();
    final state = c.read(converterNotifierProvider).valueOrNull!;
    expect(state.fromCode, 'USD');
    expect(state.toCode, 'KRW');
    verify(
      () => repo.getLatest(
        baseCode: 'USD',
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).called(greaterThanOrEqualTo(1));
  });

  test('swap transfers converted amount to calculator (round-trip)', () async {
    // 회귀 테스트: 계산 결과 46,621 KRW (기본 KRW→USD) 상태에서 swap →
    // 새 from(USD)의 금액 = 46,621 KRW를 변환한 USD 값(≈ 34.22)이어야 함.
    // (스냅샷 rates: KRW=1.0, USD=1/1362.5)
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(converterNotifierProvider.future);

    c.read(calculatorNotifierProvider.notifier).setExpression(46621);
    const expectedAfter = 46621 / 1362.5; // KRW → USD 환산값

    await c.read(converterNotifierProvider.notifier).swap();

    final state = c.read(converterNotifierProvider).valueOrNull!;
    expect(state.fromCode, 'USD');
    expect(state.toCode, 'KRW');
    // 계산기에는 변환된 값이 들어가 있어야 함 — 이 단언이 round-trip 보장.
    expect(
      c.read(calculatorNotifierProvider).result,
      closeTo(expectedAfter, 1e-9),
    );
  });

  test('swap with null calculator result does not touch calculator', () async {
    // 입력 전 swap(앱 시작 직후 등): 계산기 result는 null로 유지되어야 함.
    // 빈 상태에서 0을 강제로 채워 넣지 않는다.
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(converterNotifierProvider.future);

    expect(c.read(calculatorNotifierProvider).result, isNull);
    await c.read(converterNotifierProvider.notifier).swap();

    final state = c.read(converterNotifierProvider).valueOrNull!;
    expect(state.fromCode, 'USD');
    expect(state.toCode, 'KRW');
    expect(c.read(calculatorNotifierProvider).result, isNull);
  });

  test('refresh forces API call', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(converterNotifierProvider.future);

    await c.read(converterNotifierProvider.notifier).refresh();
    verify(() => repo.getLatest(baseCode: 'KRW', forceRefresh: true)).called(1);
  });

  group('calculator decoupling', () {
    test('ConverterNotifier no longer rebuilds on calculator changes '
        '(amount is read in the UI layer instead)', () async {
      final c = makeContainer();
      addTearDown(c.dispose);
      await c.read(converterNotifierProvider.future);

      // Push several keys.
      c.read(calculatorNotifierProvider.notifier).onKey(const DigitKey(1));
      c.read(calculatorNotifierProvider.notifier).onKey(const DigitKey(2));
      c.read(calculatorNotifierProvider.notifier).onKey(const DigitKey(3));

      // ConverterNotifier should still hold the default amount —
      // it does not watch the calculator (avoids loading flicker).
      expect(c.read(converterNotifierProvider).valueOrNull?.amount, 100000);
      // The calculator side owns the current amount.
      expect(c.read(calculatorNotifierProvider).result, 123.0);
    });
  });
}
