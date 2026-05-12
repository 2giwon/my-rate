import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/exchange_rate/exchange_rate_repository.dart';
import 'currency_catalog.dart';
import 'exchange_rate_repository_impl.dart';
import 'local/favorites_store.dart';
import 'local/rate_cache.dart';
import 'local/settings_store.dart';
import 'remote/exchange_rate_api.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) =>
    SharedPreferences.getInstance();

@Riverpod(keepAlive: true)
Future<CurrencyCatalog> currencyCatalog(CurrencyCatalogRef ref) async {
  final c = CurrencyCatalog();
  await c.load();
  return c;
}

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );
}

const String _kApiKeyDefine = 'EXCHANGE_RATE_API_KEY';
const String _kApiKey = String.fromEnvironment(_kApiKeyDefine);

@Riverpod(keepAlive: true)
ExchangeRateApi exchangeRateApi(ExchangeRateApiRef ref) {
  return ExchangeRateApi(dio: ref.watch(dioProvider), apiKey: _kApiKey);
}

@Riverpod(keepAlive: true)
Future<ExchangeRateRepository> exchangeRateRepository(ExchangeRateRepositoryRef ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final catalog = await ref.watch(currencyCatalogProvider.future);
  return ExchangeRateRepositoryImpl(
    api: ref.watch(exchangeRateApiProvider),
    cache: RateCache(prefs),
    favorites: FavoritesStore(prefs),
    catalog: catalog,
  );
}

@Riverpod(keepAlive: true)
Future<SettingsStore> settingsStore(SettingsStoreRef ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SettingsStore(prefs);
}
