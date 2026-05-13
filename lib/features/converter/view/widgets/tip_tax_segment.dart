import 'package:flutter/material.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../domain/exchange_rate/models.dart';

class TipTaxSegment extends StatelessWidget {
  const TipTaxSegment({super.key, required this.mode, required this.onChanged});
  final TipTaxMode mode;
  final ValueChanged<TipTaxMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<TipTaxMode>(
      segments: [
        ButtonSegment(value: TipTaxMode.none, label: Text(l10n.tipTaxNone)),
        ButtonSegment(value: TipTaxMode.tip, label: Text(l10n.tipTaxTip)),
        ButtonSegment(value: TipTaxMode.tax, label: Text(l10n.tipTaxTax)),
        ButtonSegment(value: TipTaxMode.discount, label: Text(l10n.tipTaxDiscount)),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
