import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/defaults.dart';

class FavoritesStore {
  FavoritesStore(this._prefs);

  static const String _key = 'favorites.currencies';
  final SharedPreferences _prefs;

  Future<List<String>> read() async {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      final seed = AppDefaults.defaultFavorites;
      await _prefs.setString(_key, json.encode(seed));
      return List.of(seed);
    }
    try {
      final list = (json.decode(raw) as List).cast<String>();
      return list;
    } catch (_) {
      return List.of(AppDefaults.defaultFavorites);
    }
  }

  Future<void> _write(List<String> codes) => _prefs.setString(_key, json.encode(codes));

  Future<void> add(String code) async {
    final list = await read();
    if (!list.contains(code)) {
      list.add(code);
      await _write(list);
    }
  }

  Future<void> remove(String code) async {
    final list = await read();
    list.remove(code);
    await _write(list);
  }
}
