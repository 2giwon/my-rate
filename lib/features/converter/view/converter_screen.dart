import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/exchange_rate/providers.dart';
import '../../../domain/exchange_rate/models.dart';
import '../providers/converter_notifier.dart';
import '../providers/tip_tax_notifier.dart';
import 'widgets/currency_card_stack.dart';
import 'widgets/direct_rate_label.dart';
import 'widgets/offline_banner.dart';
import 'widgets/panels/discount_panel.dart';
import 'widgets/panels/tax_panel.dart';
import 'widgets/panels/tip_panel.dart';
import 'widgets/tip_tax_segment.dart';
import '../../currency_picker/view/currency_picker_screen.dart';

class ConverterScreen extends ConsumerWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(converterNotifierProvider);
    final catalogAsync = ref.watch(currencyCatalogProvider);
    final tipTax = ref.watch(tipTaxNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        toolbarHeight: 64,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(converterNotifierProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          if (s.snapshot == null) {
            return Center(child: Text(l10n.refreshButton));
          }
          final snapshot = s.snapshot!;
          return catalogAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (catalog) {
              final lang = Localizations.localeOf(context).languageCode;
              final fromCurrency = catalog.resolve(s.fromCode, languageCode: lang);
              final toCurrency = catalog.resolve(s.toCode, languageCode: lang);
              final result = s.result;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (s.isStale)
                      OfflineBanner(
                        message: l10n.offlineBanner(
                          DateFormatter.formatRateTimestamp(snapshot.apiUpdatedAt.toLocal()),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: CurrencyCardStack(
                        fromCurrency: fromCurrency,
                        toCurrency: toCurrency,
                        amount: s.amount,
                        convertedAmount: result?.convertedAmount,
                        onAmountChanged: (v) {
                          ref.read(converterNotifierProvider.notifier).setAmount(v);
                          ref.read(tipTaxNotifierProvider.notifier).recomputeForAmount(v);
                        },
                        onSwap: () => ref.read(converterNotifierProvider.notifier).swap(),
                        onTapFrom: () =>
                            _openPicker(context, ref, isFrom: true, snapshot: snapshot),
                        onTapTo: () => _openPicker(context, ref, isFrom: false, snapshot: snapshot),
                      ),
                    ),
                    if (result != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Center(
                          child: DirectRateLabel(
                            fromUnit: fromCurrency.shortName ?? fromCurrency.code,
                            toUnit: toCurrency.shortName ?? toCurrency.code,
                            directRate: result.directRate,
                            toDecimals: _adaptiveRateDecimals(
                              result.directRate,
                              toCurrency.decimalPlaces,
                            ),
                            basedOn: snapshot.apiUpdatedAt,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TipTaxSegment(
                        mode: tipTax.mode,
                        onChanged: (m) => ref.read(tipTaxNotifierProvider.notifier).setMode(m),
                      ),
                    ),
                    _panel(tipTax.mode),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _panel(TipTaxMode mode) {
    switch (mode) {
      case TipTaxMode.tip:
        return const TipPanel();
      case TipTaxMode.tax:
        return const TaxPanel();
      case TipTaxMode.discount:
        return const DiscountPanel();
      case TipTaxMode.none:
        return const SizedBox.shrink();
    }
  }

  Future<void> _openPicker(
    BuildContext context,
    WidgetRef ref, {
    required bool isFrom,
    required ExchangeRateSnapshot snapshot,
  }) async {
    final codes = snapshot.rates.keys.toList();
    final picked = await context.push<String>(
      AppRoutes.picker,
      extra: CurrencyPickerArgs(availableCodes: codes),
    );
    if (picked == null) return;
    if (isFrom) {
      await ref.read(converterNotifierProvider.notifier).setFromCode(picked);
    } else {
      ref.read(converterNotifierProvider.notifier).setToCode(picked);
    }
  }
}

/// 환율 라벨의 표시 소수점 자리수를 적응형으로 결정한다.
/// 큰 값(>=1)은 기본 자리수(통화별), 작은 값(<1)은 유효 숫자 4자리 확보.
/// 예) 0.000671 → 7자리, 0.0421 → 5자리, 1.234 → 4자리(기본), 1490.20 → 2자리.
@visibleForTesting
int adaptiveRateDecimals(double rate, int defaultDecimals) {
  final base = defaultDecimals == 0 ? 2 : defaultDecimals;
  if (rate <= 0 || rate >= 1) return base;
  final magnitude = (-math.log(rate) / math.ln10).ceil();
  return (magnitude + 3).clamp(base, 10);
}

int _adaptiveRateDecimals(double rate, int defaultDecimals) =>
    adaptiveRateDecimals(rate, defaultDecimals);
