import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../providers/settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) => ListView(
          children: [
            ListTile(title: Text(l10n.settingsDefaultFrom), trailing: Text(s.defaultFrom)),
            ListTile(title: Text(l10n.settingsDefaultTo), trailing: Text(s.defaultTo)),
            const Divider(),
            ListTile(
              title: Text(l10n.settingsLanguage),
              trailing: DropdownButton<String>(
                value: s.language,
                items: [
                  DropdownMenuItem(value: 'system', child: Text(l10n.languageSystem)),
                  DropdownMenuItem(value: 'ko', child: Text(l10n.languageKorean)),
                  DropdownMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
                ],
                onChanged: (v) {
                  if (v != null) ref.read(settingsNotifierProvider.notifier).setLanguage(v);
                },
              ),
            ),
            ListTile(
              title: Text(l10n.settingsTheme),
              trailing: DropdownButton<String>(
                value: s.themeMode,
                items: [
                  DropdownMenuItem(value: 'system', child: Text(l10n.themeSystem)),
                  DropdownMenuItem(value: 'light', child: Text(l10n.themeLight)),
                  DropdownMenuItem(value: 'dark', child: Text(l10n.themeDark)),
                ],
                onChanged: (v) {
                  if (v != null) ref.read(settingsNotifierProvider.notifier).setThemeMode(v);
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.settingsClearCache),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                await ref.read(settingsNotifierProvider.notifier).clearCache();
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
