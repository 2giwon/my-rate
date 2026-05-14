import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../calculator/providers/calculator_notifier.dart';
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
    const fromDecimals = 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.calcMenuDiscount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.panelBaseAmount}: ${CurrencyFormatter.format(amount, decimalPlaces: fromDecimals)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) {
                final value = double.tryParse(v) ?? 0;
                ref
                    .read(tipTaxNotifierProvider.notifier)
                    .setDiscount(
                      amount: amount,
                      value: value,
                      byPercent: tipTax.discount.byPercent,
                    );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.finalAmountLabel),
                Text(
                  CurrencyFormatter.format(
                    tipTax.discount.finalAmount,
                    decimalPlaces: fromDecimals,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref
                      .read(calculatorNotifierProvider.notifier)
                      .setExpression(tipTax.discount.finalAmount);
                  Navigator.of(context).pop();
                },
                child: Text(l10n.panelApplyButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
