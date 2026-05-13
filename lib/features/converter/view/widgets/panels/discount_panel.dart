import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../providers/converter_notifier.dart';
import '../../../providers/tip_tax_notifier.dart';

class DiscountPanel extends ConsumerWidget {
  const DiscountPanel({super.key});

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
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text(l10n.discountByPercent)),
              ButtonSegment(value: false, label: Text(l10n.discountByAmount)),
            ],
            selected: {tipTax.discount.byPercent},
            onSelectionChanged: (s) => ref
                .read(tipTaxNotifierProvider.notifier)
                .setDiscount(
                  amount: amount,
                  value: tipTax.discount.percentOrAmount,
                  byPercent: s.first,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
            onChanged: (v) {
              final value = double.tryParse(v) ?? 0;
              ref
                  .read(tipTaxNotifierProvider.notifier)
                  .setDiscount(amount: amount, value: value, byPercent: tipTax.discount.byPercent);
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.finalAmountLabel),
              Text(CurrencyFormatter.format(tipTax.discount.finalAmount, decimalPlaces: 0)),
            ],
          ),
        ],
      ),
    );
  }
}
