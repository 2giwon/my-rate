import '../../../domain/exchange_rate/models.dart';

DiscountState calculateDiscount({
  required double amount,
  required double value,
  required bool byPercent,
}) {
  final clamped = value < 0 ? 0.0 : value;

  double raw;
  if (byPercent) {
    final pct = clamped > 100 ? 100.0 : clamped;
    raw = amount * pct / 100;
  } else {
    raw = clamped;
  }

  final discount = raw > amount ? amount : raw;
  final finalAmount = amount - discount;

  return DiscountState(
    byPercent: byPercent,
    percentOrAmount: clamped,
    discountAmount: discount,
    finalAmount: finalAmount,
  );
}
