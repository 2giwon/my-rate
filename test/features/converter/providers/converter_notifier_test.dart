import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myrate/data/exchange_rate/local/settings_store.dart';
import 'package:myrate/data/exchange_rate/providers.dart';
import 'package:myrate/domain/exchange_rate/exchange_rate_repository.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/providers/converter_notifier.dart';
import 'package:riverpod/riverpod.dart';

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

  test('refresh forces API call', () async {
    final c = makeContainer();
    addTearDown(c.dispose);
    await c.read(converterNotifierProvider.future);

    await c.read(converterNotifierProvider.notifier).refresh();
    verify(() => repo.getLatest(baseCode: 'KRW', forceRefresh: true)).called(1);
  });
}
