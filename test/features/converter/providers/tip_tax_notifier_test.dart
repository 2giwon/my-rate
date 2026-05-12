import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/providers/tip_tax_notifier.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  ProviderContainer make() => ProviderContainer();

  test('initial mode is none and zero states', () {
    final c = make();
    addTearDown(c.dispose);
    final s = c.read(tipTaxNotifierProvider);
    expect(s.mode, TipTaxMode.none);
    expect(s.tip.tipAmount, 0);
    expect(s.tax.total, 0);
    expect(s.discount.finalAmount, 0);
  });

  test('setMode switches mode', () {
    final c = make();
    addTearDown(c.dispose);
    c.read(tipTaxNotifierProvider.notifier).setMode(TipTaxMode.tip);
    expect(c.read(tipTaxNotifierProvider).mode, TipTaxMode.tip);
  });

  test('setTipPercent computes', () {
    final c = make();
    addTearDown(c.dispose);
    c.read(tipTaxNotifierProvider.notifier).setTipPercent(15, amount: 100);
    final s = c.read(tipTaxNotifierProvider);
    expect(s.tip.tipAmount, 15);
    expect(s.tip.total, 115);
  });

  test('recomputeForAmount re-applies last params', () {
    final c = make();
    addTearDown(c.dispose);
    c.read(tipTaxNotifierProvider.notifier).setTipPercent(20, amount: 100);
    c.read(tipTaxNotifierProvider.notifier).recomputeForAmount(50);
    expect(c.read(tipTaxNotifierProvider).tip.tipAmount, 10);
    expect(c.read(tipTaxNotifierProvider).tip.total, 60);
  });
}
