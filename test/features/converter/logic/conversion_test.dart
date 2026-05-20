import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/logic/conversion.dart';

void main() {
  final snap = ExchangeRateSnapshot(
    baseCode: 'USD',
    rates: const {'USD': 1.0, 'KRW': 1362.5, 'JPY': 156.2, 'EUR': 0.92},
    fetchedAt: DateTime(2026, 5, 12),
    apiUpdatedAt: DateTime(2026, 5, 12),
    apiNextUpdateAt: DateTime(2026, 5, 13),
  );

  group('convert', () {
    test('same currency returns input amount and rate 1.0', () {
      final r = convert(
        snap: snap,
        fromCode: 'USD',
        toCode: 'USD',
        amount: 100,
      );
      expect(r.convertedAmount, 100);
      expect(r.directRate, 1.0);
    });

    test('USD to KRW uses direct rate', () {
      final r = convert(snap: snap, fromCode: 'USD', toCode: 'KRW', amount: 1);
      expect(r.convertedAmount, closeTo(1362.5, 1e-9));
      expect(r.directRate, closeTo(1362.5, 1e-9));
    });

    test('KRW to USD inverts the rate', () {
      final r = convert(
        snap: snap,
        fromCode: 'KRW',
        toCode: 'USD',
        amount: 100000,
      );
      expect(r.convertedAmount, closeTo(100000 / 1362.5, 1e-6));
      expect(r.directRate, closeTo(1 / 1362.5, 1e-9));
    });

    test('cross rate JPY to EUR via USD base', () {
      final r = convert(
        snap: snap,
        fromCode: 'JPY',
        toCode: 'EUR',
        amount: 100,
      );
      const expected = 100 * (1 / 156.2) * 0.92;
      expect(r.convertedAmount, closeTo(expected, 1e-9));
    });

    test('amount 0 returns 0 result', () {
      final r = convert(snap: snap, fromCode: 'USD', toCode: 'KRW', amount: 0);
      expect(r.convertedAmount, 0);
    });

    test('throws ArgumentError when from currency missing in snapshot', () {
      expect(
        () => convert(snap: snap, fromCode: 'XXX', toCode: 'USD', amount: 1),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError when to currency missing', () {
      expect(
        () => convert(snap: snap, fromCode: 'USD', toCode: 'XXX', amount: 1),
        throwsArgumentError,
      );
    });
  });
}
