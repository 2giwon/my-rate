import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class DirectRateInline extends StatelessWidget {
  const DirectRateInline({
    super.key,
    required this.fromCode,
    required this.toCode,
    required this.directRate,
    required this.basedOn,
    required this.toDecimals,
  });

  final String fromCode;
  final String toCode;
  final double? directRate;
  final DateTime? basedOn;
  final int toDecimals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (directRate == null) {
      return Text(
        l10n.appTitle,
        style: const TextStyle(fontWeight: FontWeight.w700),
      );
    }
    final rateText = l10n.convertedDirectRateLabel(
      fromCode,
      CurrencyFormatter.format(directRate!, decimalPlaces: toDecimals),
      toCode,
    );
    final timeText = basedOn == null
        ? ''
        : '${DateFormatter.formatRateTimestamp(basedOn!.toLocal())} ${l10n.lastUpdatedPrefix}';
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rateText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (timeText.isNotEmpty)
            Text(
              timeText,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
