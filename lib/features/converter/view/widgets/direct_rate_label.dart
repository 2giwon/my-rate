import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

class DirectRateLabel extends StatelessWidget {
  const DirectRateLabel({
    super.key,
    required this.fromCode,
    required this.toCode,
    required this.directRate,
    required this.toDecimals,
  });

  final String fromCode;
  final String toCode;
  final double directRate;
  final int toDecimals;

  @override
  Widget build(BuildContext context) {
    return Text(
      '1 $fromCode = ${CurrencyFormatter.format(directRate, decimalPlaces: toDecimals)} $toCode',
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
