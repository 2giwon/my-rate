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

  /// OXR 무료 플랜은 USD base만 제공하므로 캐시/요청을 USD로 고정한다.
  /// 교차환율은 conversion.dart가 rates 맵으로 직접 계산한다.
  static const String _baseCurrency = 'USD';

  /// OXR는 `time_next_update`를 주지 않으므로(시간당 갱신) 다음 갱신 시각을 합성한다.
  static const Duration _refreshTtl = Duration(hours: 1);

  @override
  Future<ExchangeRateSnapshot> getLatest({
    required String baseCode,
    bool forceRefresh = false,
  }) async {
    final now = _clock().toUtc();
    final cached = await _cache.read(_baseCurrency);

    if (!forceRefresh && cached != null && !cached.isStaleAt(now)) {
      return cached;
    }

    try {
      final dto = await _api.fetchLatest(_baseCurrency);
      final snap = _fromDto(dto, fetchedAt: now);
      await _cache.save(snap);
      return snap;
    } on InvalidApiKeyException {
      // spec § 10: '잘못된 API 키'는 개발자 설정 오류 — fallback 없이 그대로 전파.
      rethrow;
    } on NetworkException catch (e) {
      if (cached != null) return cached;
      throw NetworkException(e.message, cause: e.cause, hasCache: false);
    } on ApiException {
      // spec § 10: API HTTP 4xx/5xx + 캐시 있음 → fallback. 없으면 그대로 전파.
      if (cached != null) return cached;
      rethrow;
    }
  }

  ExchangeRateSnapshot _fromDto(
    LatestRatesDto dto, {
    required DateTime fetchedAt,
  }) {
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(
      dto.timestamp * 1000,
      isUtc: true,
    );
    return ExchangeRateSnapshot(
      baseCode: dto.base,
      rates: Map.unmodifiable(dto.rates),
      fetchedAt: fetchedAt,
      apiUpdatedAt: updatedAt,
      // OXR는 다음 갱신 시각을 제공하지 않으므로 시간당 TTL로 합성한다.
      apiNextUpdateAt: updatedAt.add(_refreshTtl),
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
