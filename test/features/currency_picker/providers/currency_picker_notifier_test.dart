import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myrate/data/exchange_rate/currency_catalog.dart';
import 'package:myrate/data/exchange_rate/providers.dart';
import 'package:myrate/domain/exchange_rate/exchange_rate_repository.dart';
import 'package:myrate/features/currency_picker/providers/currency_picker_notifier.dart';
import 'package:riverpod/riverpod.dart';

class _MockRepo extends Mock implements ExchangeRateRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.getFavoriteCodes())
        .thenAnswer((_) async => ['KRW', 'USD']);
    when(() => repo.addFavorite(any())).thenAnswer((_) async {});
    when(() => repo.removeFavorite(any())).thenAnswer((_) async {});
  });

  ProviderContainer make({CurrencyCatalog? catalog}) {
    return ProviderContainer(overrides: [
      currencyCatalogProvider.overrideWith((_) async {
        final c = catalog ?? CurrencyCatalog();
        await c.load();
        return c;
      }),
      exchangeRateRepositoryProvider.overrideWith((_) async => repo),
    ]);
  }

  test('build returns sorted all, favorites, popular', () async {
    final c = make();
    addTearDown(c.dispose);

    final state = await c.read(
      currencyPickerNotifierProvider(
        availableCodes: const ['USD', 'KRW', 'JPY'],
        languageCode: 'ko',
      ).future,
    );

    expect(state.all.map((e) => e.code).toList(), ['JPY', 'KRW', 'USD']);
    expect(state.favorites, ['KRW', 'USD']);
    expect(state.popular.first.code, 'USD');
  });

  test('search filters by code or name', () async {
    final c = make();
    addTearDown(c.dispose);
    final notifier = c.read(currencyPickerNotifierProvider(
      availableCodes: const ['USD', 'KRW', 'JPY', 'EUR'],
      languageCode: 'ko',
    ).notifier);
    await c.read(
      currencyPickerNotifierProvider(
        availableCodes: const ['USD', 'KRW', 'JPY', 'EUR'],
        languageCode: 'ko',
      ).future,
    );

    notifier.search('유로');
    final state = c.read(currencyPickerNotifierProvider(
      availableCodes: const ['USD', 'KRW', 'JPY', 'EUR'],
      languageCode: 'ko',
    )).valueOrNull!;
    expect(state.searched.first.code, 'EUR');
  });

  test('toggleFavorite calls repo and refreshes favorites', () async {
    final c = make();
    addTearDown(c.dispose);
    final family = currencyPickerNotifierProvider(
      availableCodes: const ['USD', 'KRW'],
      languageCode: 'ko',
    );
    await c.read(family.future);

    when(() => repo.getFavoriteCodes())
        .thenAnswer((_) async => ['KRW', 'USD', 'EUR']);
    await c.read(family.notifier).toggleFavorite('EUR');
    verify(() => repo.addFavorite('EUR')).called(1);
    expect(c.read(family).valueOrNull!.favorites, contains('EUR'));
  });
}
