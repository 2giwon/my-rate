import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/exchange_rate/providers.dart';
import '../../../domain/calculator/models.dart';
import '../../../domain/exchange_rate/models.dart';
import '../../calculator/providers/calculator_notifier.dart';
import '../../calculator/view/widgets/calculator_keypad.dart';
import '../../currency_picker/view/currency_picker_screen.dart';
import '../providers/converter_notifier.dart';
import '../providers/tip_tax_notifier.dart';
import 'widgets/converted_display.dart';
import 'widgets/direct_rate_inline.dart';
import 'widgets/expression_display.dart';
import 'widgets/offline_banner.dart';
import 'widgets/panels/discount_panel.dart';
import 'widgets/panels/tax_panel.dart';
import 'widgets/panels/tip_panel.dart';
import 'widgets/tip_tax_menu_button.dart';

class ConverterScreen extends ConsumerWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(converterNotifierProvider);
    final catalogAsync = ref.watch(currencyCatalogProvider);
    final calcState = ref.watch(calculatorNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        toolbarHeight: 72,
        actions: [
          TipTaxMenuButton(onSelected: (m) => _openPanel(context, ref, m)),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.refreshButton,
            onPressed: () =>
                ref.read(converterNotifierProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(width: 4),
        ],
        title: state.when(
          loading: () => Text(l10n.appTitle),
          error: (_, _) => Text(l10n.appTitle),
          data: (s) {
            final snap = s.snapshot;
            if (snap == null) return Text(l10n.appTitle);
            final result = s.result;
            final toDecimals = catalogAsync.maybeWhen(
              data: (catalog) {
                final lang = Localizations.localeOf(context).languageCode;
                return catalog
                    .resolve(s.toCode, languageCode: lang)
                    .decimalPlaces;
              },
              orElse: () => 2,
            );
            final adapted = _adaptiveRateDecimals(
              result?.directRate ?? 1,
              toDecimals,
            );
            return DirectRateInline(
              fromCode: s.fromCode,
              toCode: s.toCode,
              directRate: result?.directRate,
              basedOn: result?.basedOn,
              toDecimals: adapted,
            );
          },
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          final snap = s.snapshot;
          if (snap == null) return Center(child: Text(l10n.refreshButton));
          return catalogAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (catalog) {
              final lang = Localizations.localeOf(context).languageCode;
              final fromCurrency = catalog.resolve(
                s.fromCode,
                languageCode: lang,
              );
              final toCurrency = catalog.resolve(s.toCode, languageCode: lang);
              final convertedAmount = s.result?.convertedAmount;
              return Column(
                children: [
                  if (s.isStale)
                    OfflineBanner(
                      message: l10n.offlineBanner(
                        _formatTimestamp(snap.apiUpdatedAt.toLocal()),
                      ),
                    ),
                  const SizedBox(height: 4),
                  ExpressionDisplay(
                    currency: fromCurrency,
                    expression: calcState.expression,
                    result: s.amount,
                    hasError: calcState.hasError,
                    errorLabel: l10n.calcError,
                    onTapHeader: () =>
                        _openPicker(context, ref, isFrom: true, snapshot: snap),
                    onBackspace: () => ref
                        .read(calculatorNotifierProvider.notifier)
                        .onKey(const BackspaceKey()),
                  ),
                  Center(
                    child: IconButton(
                      icon: const Icon(Icons.swap_vert_rounded, size: 32),
                      onPressed: () =>
                          ref.read(converterNotifierProvider.notifier).swap(),
                    ),
                  ),
                  ConvertedDisplay(
                    currency: toCurrency,
                    convertedValue: convertedAmount,
                    onTapHeader: () => _openPicker(
                      context,
                      ref,
                      isFrom: false,
                      snapshot: snap,
                    ),
                  ),
                  const Expanded(child: CalculatorKeypad()),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime t) {
    final y = t.year.toString().padLeft(4, '0');
    final m = t.month.toString().padLeft(2, '0');
    final d = t.day.toString().padLeft(2, '0');
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Future<void> _openPanel(
    BuildContext context,
    WidgetRef ref,
    TipTaxMode mode,
  ) async {
    ref.read(tipTaxNotifierProvider.notifier).setMode(mode);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => switch (mode) {
        TipTaxMode.tip => const TipPanel(),
        TipTaxMode.tax => const TaxPanel(),
        TipTaxMode.discount => const DiscountPanel(),
        TipTaxMode.none => const SizedBox.shrink(),
      },
    );
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

/// Adaptive rate decimal: small rates (<1) get more decimals to keep
/// 4 significant digits; rates ≥ 1 use the destination currency's
/// default decimals (or 2 as a fallback).
@visibleForTesting
int adaptiveRateDecimals(double rate, int defaultDecimals) {
  final base = defaultDecimals == 0 ? 2 : defaultDecimals;
  if (rate <= 0 || rate >= 1) return base;
  final magnitude = (-math.log(rate) / math.ln10).ceil();
  return (magnitude + 3).clamp(base, 10);
}

int _adaptiveRateDecimals(double rate, int defaultDecimals) =>
    adaptiveRateDecimals(rate, defaultDecimals);
