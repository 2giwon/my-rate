import '../../../domain/exchange_rate/models.dart';

TaxState calculateTax({
  required double amount,
  required double vatPercent,
  required bool isInclusive,
}) {
  final pct = vatPercent < 0 ? 0.0 : vatPercent;

  if (pct == 0) {
    return TaxState(vatPercent: 0, isInclusive: isInclusive, taxAmount: 0, total: amount);
  }

  if (isInclusive) {
    final preTax = amount / (1 + pct / 100);
    final tax = amount - preTax;
    return TaxState(vatPercent: pct, isInclusive: true, taxAmount: tax, total: preTax);
  } else {
    final tax = amount * pct / 100;
    return TaxState(vatPercent: pct, isInclusive: false, taxAmount: tax, total: amount + tax);
  }
}
