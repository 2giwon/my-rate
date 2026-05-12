import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/exchange_rate/models.dart';

void main() {
  group('Currency', () {
    test('value equality by code', () {
      const a = Currency(code: 'USD', name: 'US Dollar', flagEmoji: '🇺🇸', decimalPlaces: 2);
      const b = Currency(code: 'USD', name: 'US Dollar', flagEmoji: '🇺🇸', decimalPlaces: 2);
      expect(a, b);
    });
  });

  group('ExchangeRateSnapshot', () {
    test('rateFor returns rate for code', () {
      final snap = ExchangeRateSnapshot(
        baseCode: 'USD',
        rates: const {'KRW': 1362.5, 'JPY': 156.2},
        fetchedAt: DateTime(2026, 5, 12),
        apiUpdatedAt: DateTime(2026, 5, 12),
        apiNextUpdateAt: DateTime(2026, 5, 13),
      );
      expect(snap.rateFor('KRW'), 1362.5);
      expect(snap.rateFor('XXX'), isNull);
    });

    test('isStaleAt returns true when now is after apiNextUpdateAt', () {
      final snap = ExchangeRateSnapshot(
        baseCode: 'USD',
        rates: const {},
        fetchedAt: DateTime(2026, 5, 12),
        apiUpdatedAt: DateTime(2026, 5, 12),
        apiNextUpdateAt: DateTime(2026, 5, 13),
      );
      expect(snap.isStaleAt(DateTime(2026, 5, 14)), isTrue);
      expect(snap.isStaleAt(DateTime(2026, 5, 12, 12)), isFalse);
    });
  });

  group('ConversionResult', () {
    test('exposes input and converted amount', () {
      final r = ConversionResult(
        fromCode: 'KRW',
        toCode: 'USD',
        amount: 100000,
        convertedAmount: 73.42,
        directRate: 1362.5,
        basedOn: DateTime(2026, 5, 12),
      );
      expect(r.convertedAmount, 73.42);
      expect(r.directRate, 1362.5);
    });
  });
}
