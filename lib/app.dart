import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_notifier.dart';

class MyRateApp extends ConsumerWidget {
  const MyRateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final router = buildAppRouter();

    return settings.when(
      data: (s) => MaterialApp.router(
        title: 'MyRate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: s.flutterThemeMode,
        locale: s.flutterLocale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(body: Center(child: Text('Failed to load settings: $e'))),
      ),
    );
  }
}
