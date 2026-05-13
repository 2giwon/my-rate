import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/exchange_rate/providers.dart';
import '../../../domain/exchange_rate/models.dart';
import '../providers/converter_notifier.dart';
import '../providers/tip_tax_notifier.dart';
import 'widgets/amount_input.dart';
import 'widgets/currency_cell.dart';
import 'widgets/direct_rate_label.dart';
import 'widgets/offline_banner.dart';
import 'widgets/panels/discount_panel.dart';
import 'widgets/panels/tax_panel.dart';
import 'widgets/panels/tip_panel.dart';
import 'widgets/swap_button.dart';
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
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(converterNotifierProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          if (s.snapshot == null) {
            return Center(child: Text('${l10n.refreshButton}'));
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (s.isStale)
                    OfflineBanner(
                      message: l10n.offlineBanner(
                        DateFormatter.formatRateTimestamp(snapshot.apiUpdatedAt.toLocal()),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        '${l10n.lastUpdatedPrefix} ${DateFormatter.formatRateTimestamp(snapshot.apiUpdatedAt.toLocal())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  CurrencyCell(
                    currency: fromCurrency,
                    onTap: () => _openPicker(context, ref, isFrom: true, snapshot: snapshot),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: AmountInput(
                      value: s.amount,
                      decimalPlaces: fromCurrency.decimalPlaces,
                      onChanged: (v) {
                        ref.read(converterNotifierProvider.notifier).setAmount(v);
                        ref.read(tipTaxNotifierProvider.notifier).recomputeForAmount(v);
                      },
                    ),
                  ),
                  Center(
                    child: SwapButton(
                      onPressed: () => ref.read(converterNotifierProvider.notifier).swap(),
                    ),
                  ),
                  CurrencyCell(
                    currency: toCurrency,
                    onTap: () => _openPicker(context, ref, isFrom: false, snapshot: snapshot),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      result == null
                          ? '—'
                          : CurrencyFormatter.format(
                              result.convertedAmount,
                              decimalPlaces: toCurrency.decimalPlaces,
                            ),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (result != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DirectRateLabel(
                        fromCode: s.fromCode,
                        toCode: s.toCode,
                        directRate: result.directRate,
                        toDecimals: toCurrency.decimalPlaces == 0 ? 2 : toCurrency.decimalPlaces,
                      ),
                    ),
                  const Divider(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TipTaxSegment(
                      mode: tipTax.mode,
                      onChanged: (m) => ref.read(tipTaxNotifierProvider.notifier).setMode(m),
                    ),
                  ),
                  Expanded(child: _panel(tipTax.mode)),
                ],
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
