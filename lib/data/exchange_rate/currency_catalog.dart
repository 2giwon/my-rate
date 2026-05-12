import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle, AssetBundle;
import '../../core/constants/asset_paths.dart';
import '../../domain/exchange_rate/models.dart';

class CurrencyCatalog {
  CurrencyCatalog({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  Map<String, Map<String, dynamic>>? _data;

  Future<void> load() async {
    final raw = await _bundle.loadString(AssetPaths.currenciesJson);
    final decoded = json.decode(raw) as Map<String, dynamic>;
    _data = decoded.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
  }

  Currency resolve(String code, {required String languageCode}) {
    final data = _data;
    if (data == null) {
      throw StateError('CurrencyCatalog.load() not called');
    }
    final entry = data[code];
    if (entry == null) {
      return Currency(code: code, name: code, flagEmoji: '', decimalPlaces: 2);
    }
    final lang = languageCode == 'ko' ? 'ko' : 'en';
    final name = (entry[lang] as String?) ?? (entry['en'] as String?) ?? code;
    return Currency(
      code: code,
      name: name,
      flagEmoji: (entry['flag'] as String?) ?? '',
      decimalPlaces: (entry['decimals'] as int?) ?? 2,
    );
  }

  List<Currency> resolveAll(List<String> codes, {required String languageCode}) {
    return codes.map((c) => resolve(c, languageCode: languageCode)).toList(growable: false);
  }
}
