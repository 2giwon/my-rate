import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/defaults.dart';

class SettingsStore {
  SettingsStore(this._prefs);
  final SharedPreferences _prefs;

  static const String _kFrom = 'settings.defaultFrom';
  static const String _kTo = 'settings.defaultTo';
  static const String _kLang = 'settings.language';
  static const String _kTheme = 'settings.themeMode';

  Future<String> defaultFrom() async =>
      _prefs.getString(_kFrom) ?? AppDefaults.defaultFromCurrency;
  Future<void> setDefaultFrom(String code) => _prefs.setString(_kFrom, code);

  Future<String> defaultTo() async => _prefs.getString(_kTo) ?? AppDefaults.defaultToCurrency;
  Future<void> setDefaultTo(String code) => _prefs.setString(_kTo, code);

  Future<String> language() async => _prefs.getString(_kLang) ?? 'system';
  Future<void> setLanguage(String lang) => _prefs.setString(_kLang, lang);

  Future<String> themeMode() async => _prefs.getString(_kTheme) ?? 'system';
  Future<void> setThemeMode(String mode) => _prefs.setString(_kTheme, mode);
}
