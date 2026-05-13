import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/converter/view/converter_screen.dart';

void main() {
  group('adaptiveRateDecimals', () {
    test('rate >= 1 uses default decimals (decimalPlaces or 2 fallback)', () {
      expect(adaptiveRateDecimals(1490.20, 2), 2); // USD default
      expect(adaptiveRateDecimals(1490.20, 0), 2); // KRW: 0 → fallback to 2
      expect(adaptiveRateDecimals(1.0, 2), 2);
      expect(adaptiveRateDecimals(156.2, 0), 2);
    });

    test('rate just below 1 expands decimals to keep 4 significant digits', () {
      // 0.92 EUR/USD → magnitude=1 → 1+3 = 4 decimals
      expect(adaptiveRateDecimals(0.92, 2), 4);
    });

    test('rate around 0.001 uses ~6 decimals', () {
      // 0.00067 (1 KRW = 1/1490 USD) → magnitude=4 → 7 decimals
      expect(adaptiveRateDecimals(0.000671, 2), 7);
      // 0.0421 → magnitude=2 → 5 decimals
      expect(adaptiveRateDecimals(0.0421, 2), 5);
    });

    test('very small rates clamp at 10 decimals max', () {
      expect(adaptiveRateDecimals(1e-12, 2), 10);
    });

    test('zero or negative defaults to base decimals', () {
      expect(adaptiveRateDecimals(0, 2), 2);
      expect(adaptiveRateDecimals(-1.5, 2), 2);
    });
  });
}
