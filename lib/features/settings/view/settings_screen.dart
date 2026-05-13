import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/popular_currencies.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/date_formatter.dart';
import '../../converter/providers/converter_notifier.dart';
import '../../currency_picker/view/currency_picker_screen.dart';
import '../providers/settings_notifier.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsNotifierProvider);
    final isKo = Localizations.localeOf(context).languageCode == 'ko';
    final converterState = ref.watch(converterNotifierProvider).valueOrNull;
    final lastUpdated = converterState?.snapshot?.apiUpdatedAt;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) => ListView(
          children: [
            ListTile(
              title: Text(l10n.settingsDefaultFrom),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.defaultFrom),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _pickDefaultCurrency(context, ref, isFrom: true),
            ),
            ListTile(
              title: Text(l10n.settingsDefaultTo),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.defaultTo),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => _pickDefaultCurrency(context, ref, isFrom: false),
            ),
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
            // spec § 4.4: 마지막 갱신 시각 (converter snapshot의 apiUpdatedAt)
            if (lastUpdated != null)
              ListTile(
                title: Text(isKo ? '마지막 갱신' : 'Last updated'),
                trailing: Text(DateFormatter.formatRateTimestamp(lastUpdated.toLocal())),
              ),
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
            const Divider(),
            // spec § 4.4: 앱 정보
            ListTile(
              title: Text(isKo ? '앱 정보' : 'About'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'MyRate',
                applicationVersion: '0.1.0',
                applicationLegalese: isKo ? '광고 없는 환율 계산기' : 'Ad-free currency converter',
              ),
            ),
            // spec § 4.4: 오픈소스 라이선스
            ListTile(
              title: Text(isKo ? '오픈소스 라이선스' : 'Open source licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'MyRate',
                applicationVersion: '0.1.0',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// spec § 4.4: 기본 From/To 통화는 Settings에서 picker로 변경한다.
  /// 가용 코드는 converter의 snapshot(있으면)에서 가져오고,
  /// 아직 로드되지 않았으면 인기 통화 + 기본값으로 폴백한다.
  Future<void> _pickDefaultCurrency(
    BuildContext context,
    WidgetRef ref, {
    required bool isFrom,
  }) async {
    final converterState = ref.read(converterNotifierProvider).valueOrNull;
    final snapshotCodes = converterState?.snapshot?.rates.keys.toList();
    final codes = (snapshotCodes != null && snapshotCodes.isNotEmpty)
        ? snapshotCodes
        : <String>{...kPopularCurrencyCodes, 'KRW', 'USD'}.toList();

    final picked = await context.push<String>(
      AppRoutes.picker,
      extra: CurrencyPickerArgs(availableCodes: codes),
    );
    if (picked == null) return;
    final notifier = ref.read(settingsNotifierProvider.notifier);
    if (isFrom) {
      await notifier.setDefaultFrom(picked);
    } else {
      await notifier.setDefaultTo(picked);
    }
  }
}
