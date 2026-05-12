import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/core/constants/defaults.dart';
import 'package:myrate/data/exchange_rate/local/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('SettingsStore', () {
    test('defaults on first run', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = SettingsStore(prefs);
      expect(await store.defaultFrom(), AppDefaults.defaultFromCurrency);
      expect(await store.defaultTo(), AppDefaults.defaultToCurrency);
      expect(await store.language(), 'system');
      expect(await store.themeMode(), 'system');
    });

    test('setters persist', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = SettingsStore(prefs);
      await store.setDefaultFrom('JPY');
      await store.setDefaultTo('EUR');
      await store.setLanguage('ko');
      await store.setThemeMode('dark');
      expect(await store.defaultFrom(), 'JPY');
      expect(await store.defaultTo(), 'EUR');
      expect(await store.language(), 'ko');
      expect(await store.themeMode(), 'dark');
    });
  });
}
