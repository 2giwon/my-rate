import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/exchange_rate/local/rate_cache.dart';
import '../../../data/exchange_rate/providers.dart';

part 'settings_notifier.g.dart';

class AppSettings {
  AppSettings({
    required this.defaultFrom,
    required this.defaultTo,
    required this.language,
    required this.themeMode,
  });

  final String defaultFrom;
  final String defaultTo;
  final String language; // 'system' | 'ko' | 'en'
  final String themeMode; // 'system' | 'light' | 'dark'

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Locale? get flutterLocale {
    switch (language) {
      case 'ko':
        return const Locale('ko');
      case 'en':
        return const Locale('en');
      default:
        return null;
    }
  }

  AppSettings copyWith({
    String? defaultFrom,
    String? defaultTo,
    String? language,
    String? themeMode,
  }) =>
      AppSettings(
        defaultFrom: defaultFrom ?? this.defaultFrom,
        defaultTo: defaultTo ?? this.defaultTo,
        language: language ?? this.language,
        themeMode: themeMode ?? this.themeMode,
      );
}

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Future<AppSettings> build() async {
    final store = await ref.watch(settingsStoreProvider.future);
    return AppSettings(
      defaultFrom: await store.defaultFrom(),
      defaultTo: await store.defaultTo(),
      language: await store.language(),
      themeMode: await store.themeMode(),
    );
  }

  Future<void> setDefaultFrom(String code) async {
    final store = await ref.read(settingsStoreProvider.future);
    await store.setDefaultFrom(code);
    final cur = state.valueOrNull;
    if (cur != null) state = AsyncData(cur.copyWith(defaultFrom: code));
  }

  Future<void> setDefaultTo(String code) async {
    final store = await ref.read(settingsStoreProvider.future);
    await store.setDefaultTo(code);
    final cur = state.valueOrNull;
    if (cur != null) state = AsyncData(cur.copyWith(defaultTo: code));
  }

  Future<void> setLanguage(String lang) async {
    final store = await ref.read(settingsStoreProvider.future);
    await store.setLanguage(lang);
    final cur = state.valueOrNull;
    if (cur != null) state = AsyncData(cur.copyWith(language: lang));
  }

  Future<void> setThemeMode(String mode) async {
    final store = await ref.read(settingsStoreProvider.future);
    await store.setThemeMode(mode);
    final cur = state.valueOrNull;
    if (cur != null) state = AsyncData(cur.copyWith(themeMode: mode));
  }

  Future<void> clearCache() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await RateCache(prefs).clear();
  }
}
