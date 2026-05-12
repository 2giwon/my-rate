import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/data/exchange_rate/local/rate_cache.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('RateCache', () {
    test('save and read same snapshot back', () async {
      final prefs = await SharedPreferences.getInstance();
      final cache = RateCache(prefs);

      final snap = ExchangeRateSnapshot(
        baseCode: 'USD',
        rates: const {'KRW': 1362.5, 'JPY': 156.2},
        fetchedAt: DateTime.utc(2026, 5, 12, 14, 30),
        apiUpdatedAt: DateTime.utc(2026, 5, 12, 0),
        apiNextUpdateAt: DateTime.utc(2026, 5, 13, 0),
      );

      await cache.save(snap);
      final loaded = await cache.read('USD');
      expect(loaded, isNotNull);
      expect(loaded!.baseCode, 'USD');
      expect(loaded.rates['KRW'], 1362.5);
      expect(loaded.apiNextUpdateAt, snap.apiNextUpdateAt);
    });

    test('read returns null when no entry', () async {
      final prefs = await SharedPreferences.getInstance();
      final cache = RateCache(prefs);
      expect(await cache.read('USD'), isNull);
    });

    test('corrupt JSON returns null (defensive)', () async {
      SharedPreferences.setMockInitialValues({'cache.rates.USD': 'not-json'});
      final prefs = await SharedPreferences.getInstance();
      final cache = RateCache(prefs);
      expect(await cache.read('USD'), isNull);
    });

    test('clear removes all rate keys', () async {
      SharedPreferences.setMockInitialValues({
        'cache.rates.USD': '{}',
        'cache.rates.KRW': '{}',
        'other.key': 'x',
      });
      final prefs = await SharedPreferences.getInstance();
      final cache = RateCache(prefs);
      await cache.clear();
      expect(prefs.getString('cache.rates.USD'), isNull);
      expect(prefs.getString('cache.rates.KRW'), isNull);
      expect(prefs.getString('other.key'), 'x');
    });
  });
}
