import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/data/exchange_rate/currency_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurrencyCatalog', () {
    test('loads bundled JSON and resolves USD with ko/en/flag', () async {
      final catalog = CurrencyCatalog();
      await catalog.load();

      final usd = catalog.resolve('USD', languageCode: 'ko');
      expect(usd.code, 'USD');
      expect(usd.name, '미국 달러');
      expect(usd.flagEmoji, '🇺🇸');
      expect(usd.decimalPlaces, 2);

      final usdEn = catalog.resolve('USD', languageCode: 'en');
      expect(usdEn.name, 'US Dollar');
    });

    test('unknown code falls back to code as name, empty flag, decimals=2', () async {
      final catalog = CurrencyCatalog();
      await catalog.load();

      final unknown = catalog.resolve('ZZZ', languageCode: 'ko');
      expect(unknown.code, 'ZZZ');
      expect(unknown.name, 'ZZZ');
      expect(unknown.flagEmoji, '');
      expect(unknown.decimalPlaces, 2);
    });

    test('resolveAll returns currencies for provided codes', () async {
      final catalog = CurrencyCatalog();
      await catalog.load();
      final list = catalog.resolveAll(['USD', 'KRW', 'JPY'], languageCode: 'ko');
      expect(list.map((c) => c.code).toList(), ['USD', 'KRW', 'JPY']);
    });

    test('throws StateError if accessed before load', () {
      final catalog = CurrencyCatalog();
      expect(() => catalog.resolve('USD', languageCode: 'ko'), throwsStateError);
    });
  });
}
