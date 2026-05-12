import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/exchange_rate/models.dart';

class RateCache {
  RateCache(this._prefs);

  static const String _prefix = 'cache.rates.';

  final SharedPreferences _prefs;

  String _key(String baseCode) => '$_prefix$baseCode';

  Future<void> save(ExchangeRateSnapshot snap) async {
    final m = {
      'baseCode': snap.baseCode,
      'rates': snap.rates,
      'fetchedAt': snap.fetchedAt.toUtc().toIso8601String(),
      'apiUpdatedAt': snap.apiUpdatedAt.toUtc().toIso8601String(),
      'apiNextUpdateAt': snap.apiNextUpdateAt.toUtc().toIso8601String(),
    };
    await _prefs.setString(_key(snap.baseCode), json.encode(m));
  }

  Future<ExchangeRateSnapshot?> read(String baseCode) async {
    final raw = _prefs.getString(_key(baseCode));
    if (raw == null) return null;
    try {
      final m = json.decode(raw) as Map<String, dynamic>;
      return ExchangeRateSnapshot(
        baseCode: m['baseCode'] as String,
        rates: (m['rates'] as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
        fetchedAt: DateTime.parse(m['fetchedAt'] as String),
        apiUpdatedAt: DateTime.parse(m['apiUpdatedAt'] as String),
        apiNextUpdateAt: DateTime.parse(m['apiNextUpdateAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
