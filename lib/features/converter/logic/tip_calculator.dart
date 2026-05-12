import '../../../domain/exchange_rate/models.dart';

TipState calculateTip({required double amount, required double percent}) {
  final pct = percent < 0 ? 0.0 : percent;
  final tip = amount * pct / 100;
  return TipState(percent: pct, tipAmount: tip, total: amount + tip);
}
