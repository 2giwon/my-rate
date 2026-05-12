import '../../../domain/exchange_rate/models.dart';

/// snap의 baseCode를 기준으로 환율을 cross-rate 계산.
/// 같은 통화는 1.0, BASE→Other는 직접 rate, Other→Other는 USD를 통한 교차 계산.
ConversionResult convert({
  required ExchangeRateSnapshot snap,
  required String fromCode,
  required String toCode,
  required num amount,
}) {
  if (fromCode == toCode) {
    return ConversionResult(
      fromCode: fromCode,
      toCode: toCode,
      amount: amount,
      convertedAmount: amount.toDouble(),
      directRate: 1.0,
      basedOn: snap.apiUpdatedAt,
    );
  }

  final fromRate = snap.rateFor(fromCode);
  final toRate = snap.rateFor(toCode);
  if (fromRate == null) {
    throw ArgumentError.value(fromCode, 'fromCode', 'Missing rate in snapshot');
  }
  if (toRate == null) {
    throw ArgumentError.value(toCode, 'toCode', 'Missing rate in snapshot');
  }

  final directRate = toRate / fromRate;
  final converted = amount.toDouble() * directRate;

  return ConversionResult(
    fromCode: fromCode,
    toCode: toCode,
    amount: amount,
    convertedAmount: converted,
    directRate: directRate,
    basedOn: snap.apiUpdatedAt,
  );
}
