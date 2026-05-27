/// Open Exchange Rates `latest.json` 응답 DTO.
///
/// 응답 예시:
/// ```json
/// { "disclaimer": "...", "license": "...", "timestamp": 1715472000,
///   "base": "USD", "rates": { "KRW": 1506.2, "JPY": 156.2, ... } }
/// ```
/// 무료 플랜은 `base`가 항상 `USD`이며 시간당 갱신된다. ExchangeRate-API와 달리
/// `time_next_update` 필드가 없으므로 다음 갱신 시각은 repository에서 합성한다.
class LatestRatesDto {
  LatestRatesDto({
    required this.base,
    required this.timestamp,
    required this.rates,
  });

  /// rates 맵의 기준 통화. OXR 무료 플랜에서는 항상 'USD'.
  final String base;

  /// 마지막 환율 갱신 시각 (unix seconds, OXR `timestamp`).
  final int timestamp;

  /// 통화 코드 → [base] 1단위당 환율.
  final Map<String, double> rates;

  factory LatestRatesDto.fromJson(Map<String, dynamic> json) {
    final rates = (json['rates'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, (v as num).toDouble()),
    );
    return LatestRatesDto(
      base: json['base'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      rates: rates,
    );
  }
}
