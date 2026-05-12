class AppDefaults {
  AppDefaults._();

  static const String defaultFromCurrency = 'KRW';
  static const String defaultToCurrency = 'USD';
  static const double defaultAmount = 100000;

  /// 기본 즐겨찾기 (초기 설치 시 시드)
  static const List<String> defaultFavorites = ['KRW', 'USD', 'JPY'];

  /// 기본 팁 비율 프리셋
  static const List<int> tipPresets = [5, 10, 15, 20];

  /// 기본 VAT (한국 부가가치세)
  static const double defaultVatPercent = 10.0;
}
