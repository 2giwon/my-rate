import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/defaults.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../providers/converter_notifier.dart';
import '../../../providers/tip_tax_notifier.dart';

class TipPanel extends ConsumerWidget {
  const TipPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final converter = ref.watch(converterNotifierProvider).valueOrNull;
    final tipTax = ref.watch(tipTaxNotifierProvider);
    if (converter == null) return const SizedBox.shrink();

    final amount = converter.amount;
    final fromDecimals = converter.snapshot?.rateFor(converter.fromCode) == null
        ? 2
        : 0; // converter.fromCode currency decimalPlaces; simplified.

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: AppDefaults.tipPresets.map((p) {
              final selected = tipTax.tip.percent == p.toDouble();
              return ChoiceChip(
                label: Text('$p%'),
                selected: selected,
                onSelected: (_) => ref
                    .read(tipTaxNotifierProvider.notifier)
                    .setTipPercent(p.toDouble(), amount: amount),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(l10n.tipPercentLabel),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  onChanged: (v) {
                    final p = double.tryParse(v) ?? 0;
                    ref.read(tipTaxNotifierProvider.notifier).setTipPercent(p, amount: amount);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row(
            l10n.tipAmountLabel,
            CurrencyFormatter.format(tipTax.tip.tipAmount, decimalPlaces: fromDecimals),
          ),
          _row(
            l10n.totalLabel,
            CurrencyFormatter.format(tipTax.tip.total, decimalPlaces: fromDecimals),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    ),
  );
}
