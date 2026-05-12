import 'models.dart';

abstract class ExchangeRateRepository {
  /// BASE 통화 기준 최신 환율을 반환.
  /// - 캐시가 유효(`apiNextUpdateAt`이 미래)하면 캐시 반환
  /// - 만료/없으면 API 호출, 결과 캐시 저장 후 반환
  /// - 네트워크 실패 + 캐시 있으면 `isStale=true`로 캐시 반환
  /// - 네트워크 실패 + 캐시 없으면 NetworkException(hasCache: false) throw
  Future<ExchangeRateSnapshot> getLatest({
    required String baseCode,
    bool forceRefresh = false,
  });

  /// 사용 가능한 모든 통화 목록 (로컬 catalog 기반)
  Future<List<Currency>> getAllCurrencies();

  /// 즐겨찾기 통화 코드 (정렬 순서 유지)
  Future<List<String>> getFavoriteCodes();

  Future<void> addFavorite(String code);

  Future<void> removeFavorite(String code);
}
