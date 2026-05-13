import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../providers/converter_notifier.dart';
import '../../../providers/tip_tax_notifier.dart';

class TaxPanel extends ConsumerWidget {
  const TaxPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final converter = ref.watch(converterNotifierProvider).valueOrNull;
    final tipTax = ref.watch(tipTaxNotifierProvider);
    if (converter == null) return const SizedBox.shrink();

    final amount = converter.amount;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.taxVatLabel),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                  controller: TextEditingController(text: tipTax.tax.vatPercent.toString()),
                  onChanged: (v) {
                    final p = double.tryParse(v) ?? 0;
                    ref
                        .read(tipTaxNotifierProvider.notifier)
                        .setTax(amount: amount, vatPercent: p, isInclusive: tipTax.tax.isInclusive);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(l10n.taxInclusiveLabel),
            value: tipTax.tax.isInclusive,
            onChanged: (b) {
              ref
                  .read(tipTaxNotifierProvider.notifier)
                  .setTax(amount: amount, vatPercent: tipTax.tax.vatPercent, isInclusive: b);
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.totalLabel),
              Text(CurrencyFormatter.format(tipTax.tax.total, decimalPlaces: 0)),
            ],
          ),
        ],
      ),
    );
  }
}
