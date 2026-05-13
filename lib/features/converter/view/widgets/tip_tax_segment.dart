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
      // 선택된 세그먼트의 체크 아이콘이 텍스트 영역을 좁혀 영어 'None'이 줄바꿈되는
      // 문제 회피. 배경색으로 선택 상태 충분히 식별 가능.
      showSelectedIcon: false,
      segments: [
        ButtonSegment(
          value: TipTaxMode.none,
          label: Text(l10n.tipTaxNone, softWrap: false, overflow: TextOverflow.fade),
        ),
        ButtonSegment(
          value: TipTaxMode.tip,
          label: Text(l10n.tipTaxTip, softWrap: false, overflow: TextOverflow.fade),
        ),
        ButtonSegment(
          value: TipTaxMode.tax,
          label: Text(l10n.tipTaxTax, softWrap: false, overflow: TextOverflow.fade),
        ),
        ButtonSegment(
          value: TipTaxMode.discount,
          label: Text(l10n.tipTaxDiscount, softWrap: false, overflow: TextOverflow.fade),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
