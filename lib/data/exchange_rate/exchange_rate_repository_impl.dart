import '../../core/errors/app_exception.dart';
import '../../domain/exchange_rate/exchange_rate_repository.dart';
import '../../domain/exchange_rate/models.dart';
import 'currency_catalog.dart';
import 'local/favorites_store.dart';
import 'local/rate_cache.dart';
import 'remote/dtos.dart';
import 'remote/exchange_rate_api.dart';

typedef Clock = DateTime Function();

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  ExchangeRateRepositoryImpl({
    required ExchangeRateApi api,
    required RateCache cache,
    required FavoritesStore favorites,
    required CurrencyCatalog catalog,
    Clock? clock,
  }) : _api = api,
       _cache = cache,
       _favorites = favorites,
       _catalog = catalog,
       _clock = clock ?? DateTime.now;

  final ExchangeRateApi _api;
  final RateCache _cache;
  final FavoritesStore _favorites;
  // ignore: unused_field
  final CurrencyCatalog _catalog;
  final Clock _clock;

  @override
  Future<ExchangeRateSnapshot> getLatest({
    required String baseCode,
    bool forceRefresh = false,
  }) async {
    final now = _clock().toUtc();
    final cached = await _cache.read(baseCode);

    if (!forceRefresh && cached != null && !cached.isStaleAt(now)) {
      return cached;
    }

    try {
      final dto = await _api.fetchLatest(baseCode);
      final snap = _fromDto(dto, fetchedAt: now);
      await _cache.save(snap);
      return snap;
    } on NetworkException catch (e) {
      if (cached != null) return cached;
      throw NetworkException(e.message, cause: e.cause, hasCache: false);
    }
  }

  ExchangeRateSnapshot _fromDto(LatestRatesDto dto, {required DateTime fetchedAt}) {
    return ExchangeRateSnapshot(
      baseCode: dto.baseCode,
      rates: Map.unmodifiable(dto.conversionRates),
      fetchedAt: fetchedAt,
      apiUpdatedAt: DateTime.fromMillisecondsSinceEpoch(dto.timeLastUpdateUnix * 1000, isUtc: true),
      apiNextUpdateAt: DateTime.fromMillisecondsSinceEpoch(
        dto.timeNextUpdateUnix * 1000,
        isUtc: true,
      ),
    );
  }

  @override
  Future<List<Currency>> getAllCurrencies() async {
    // 카탈로그가 알고 있는 통화 + ExchangeRate-API 161개 폴백은
    // converter notifier가 latest snapshot의 rates.keys로부터 합산.
    // 여기서는 catalog가 알고 있는 코드만 반환.
    // 호출 시 languageCode는 features 레이어에서 결정 → catalog.resolve 직접 호출.
    throw UnimplementedError('Use catalog.resolveAll with snapshot.rates.keys');
  }

  @override
  Future<List<String>> getFavoriteCodes() => _favorites.read();

  @override
  Future<void> addFavorite(String code) => _favorites.add(code);

  @override
  Future<void> removeFavorite(String code) => _favorites.remove(code);
}
