import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/defaults.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../calculator/providers/calculator_notifier.dart';
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
                    l10n.calcMenuTip,
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      final p = double.tryParse(v) ?? 0;
                      ref
                          .read(tipTaxNotifierProvider.notifier)
                          .setTipPercent(p, amount: amount);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row(
              l10n.tipAmountLabel,
              CurrencyFormatter.format(
                tipTax.tip.tipAmount,
                decimalPlaces: fromDecimals,
              ),
            ),
            _row(
              l10n.totalLabel,
              CurrencyFormatter.format(
                tipTax.tip.total,
                decimalPlaces: fromDecimals,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref
                      .read(calculatorNotifierProvider.notifier)
                      .setExpression(tipTax.tip.total);
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

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label), Text(value)],
    ),
  );
}
