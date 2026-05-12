import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/exchange_rate/models.dart';
import '../logic/discount_calculator.dart';
import '../logic/tax_calculator.dart';
import '../logic/tip_calculator.dart';

part 'tip_tax_notifier.g.dart';

class TipTaxState {
  TipTaxState({
    required this.mode,
    required this.tip,
    required this.tax,
    required this.discount,
  });

  factory TipTaxState.initial() => TipTaxState(
        mode: TipTaxMode.none,
        tip: TipState.zero(),
        tax: TaxState.initial(),
        discount: DiscountState.initial(),
      );

  final TipTaxMode mode;
  final TipState tip;
  final TaxState tax;
  final DiscountState discount;

  TipTaxState copyWith({
    TipTaxMode? mode,
    TipState? tip,
    TaxState? tax,
    DiscountState? discount,
  }) =>
      TipTaxState(
        mode: mode ?? this.mode,
        tip: tip ?? this.tip,
        tax: tax ?? this.tax,
        discount: discount ?? this.discount,
      );
}

@riverpod
class TipTaxNotifier extends _$TipTaxNotifier {
  @override
  TipTaxState build() => TipTaxState.initial();

  void setMode(TipTaxMode mode) => state = state.copyWith(mode: mode);

  void setTipPercent(double percent, {required double amount}) {
    state = state.copyWith(tip: calculateTip(amount: amount, percent: percent));
  }

  void setTax({required double amount, required double vatPercent, required bool isInclusive}) {
    state = state.copyWith(
      tax: calculateTax(amount: amount, vatPercent: vatPercent, isInclusive: isInclusive),
    );
  }

  void setDiscount({required double amount, required double value, required bool byPercent}) {
    state = state.copyWith(
      discount: calculateDiscount(amount: amount, value: value, byPercent: byPercent),
    );
  }

  void recomputeForAmount(double amount) {
    state = state.copyWith(
      tip: calculateTip(amount: amount, percent: state.tip.percent),
      tax: calculateTax(
        amount: amount,
        vatPercent: state.tax.vatPercent,
        isInclusive: state.tax.isInclusive,
      ),
      discount: calculateDiscount(
        amount: amount,
        value: state.discount.percentOrAmount,
        byPercent: state.discount.byPercent,
      ),
    );
  }
}
