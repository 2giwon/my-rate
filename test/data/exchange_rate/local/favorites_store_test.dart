import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/core/constants/defaults.dart';
import 'package:myrate/data/exchange_rate/local/favorites_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('FavoritesStore', () {
    test('first read returns default favorites (seed)', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = FavoritesStore(prefs);
      expect(await store.read(), AppDefaults.defaultFavorites);
    });

    test('add appends and dedupes', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = FavoritesStore(prefs);
      await store.add('EUR');
      await store.add('EUR');
      final list = await store.read();
      expect(list.where((c) => c == 'EUR').length, 1);
      expect(list.contains('EUR'), isTrue);
    });

    test('remove deletes', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = FavoritesStore(prefs);
      await store.remove('KRW');
      expect((await store.read()).contains('KRW'), isFalse);
    });
  });
}
