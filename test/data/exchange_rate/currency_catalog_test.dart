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

    test('shortName ko returns Korean short form (원/달러/엔)', () async {
      final catalog = CurrencyCatalog();
      await catalog.load();

      expect(catalog.resolve('KRW', languageCode: 'ko').shortName, '원');
      expect(catalog.resolve('USD', languageCode: 'ko').shortName, '달러');
      expect(catalog.resolve('JPY', languageCode: 'ko').shortName, '엔');
      expect(catalog.resolve('EUR', languageCode: 'ko').shortName, '유로');
      expect(catalog.resolve('CNY', languageCode: 'ko').shortName, '위안');
    });

    test('shortName en returns English short form', () async {
      final catalog = CurrencyCatalog();
      await catalog.load();

      expect(catalog.resolve('KRW', languageCode: 'en').shortName, 'won');
      expect(catalog.resolve('USD', languageCode: 'en').shortName, 'dollar');
      expect(catalog.resolve('JPY', languageCode: 'en').shortName, 'yen');
    });

    test('unknown code shortName falls back to ISO code', () async {
      final catalog = CurrencyCatalog();
      await catalog.load();

      final unknown = catalog.resolve('ZZZ', languageCode: 'ko');
      expect(unknown.shortName, 'ZZZ');
    });
  });
}
