import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

/// 변환 환율을 한 줄로 표시한다.
/// 형식: "{날짜} 환율: 1 {fromUnit} = {value} {toUnit}"
/// `basedOn`이 null이면 날짜 prefix 생략.
/// `fromUnit`/`toUnit`은 짧은 통화 이름(원/달러/엔 또는 won/dollar/yen).
class DirectRateLabel extends StatelessWidget {
  const DirectRateLabel({
    super.key,
    required this.fromUnit,
    required this.toUnit,
    required this.directRate,
    required this.toDecimals,
    this.basedOn,
  });

  final String fromUnit;
  final String toUnit;
  final double directRate;
  final int toDecimals;
  final DateTime? basedOn;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final formatted = CurrencyFormatter.format(directRate, decimalPlaces: toDecimals);
    final rateText = '1 $fromUnit = $formatted $toUnit';

    final based = basedOn;
    String text;
    if (based == null) {
      text = rateText;
    } else {
      final dateOnly = DateFormatter.formatRateDate(based.toLocal());
      text = lang == 'ko' ? '$dateOnly 환율: $rateText' : '$dateOnly rate: $rateText';
    }

    return Text(text, style: Theme.of(context).textTheme.bodySmall);
  }
}
