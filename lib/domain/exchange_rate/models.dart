import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

@freezed
class Currency with _$Currency {
  const factory Currency({
    required String code,
    required String name,
    required String? flagEmoji,
    required int decimalPlaces,
    @Default(null) String? shortName,
  }) = _Currency;
}

@freezed
class ExchangeRateSnapshot with _$ExchangeRateSnapshot {
  const ExchangeRateSnapshot._();

  const factory ExchangeRateSnapshot({
    required String baseCode,
    required Map<String, double> rates,
    required DateTime fetchedAt,
    required DateTime apiUpdatedAt,
    required DateTime apiNextUpdateAt,
  }) = _ExchangeRateSnapshot;

  double? rateFor(String code) => rates[code];

  bool isStaleAt(DateTime now) => now.isAfter(apiNextUpdateAt);
}

@freezed
class ConversionResult with _$ConversionResult {
  const factory ConversionResult({
    required String fromCode,
    required String toCode,
    required num amount,
    required double convertedAmount,
    required double directRate,
    required DateTime basedOn,
  }) = _ConversionResult;
}

enum TipTaxMode { none, tip, tax, discount }

@freezed
class TipState with _$TipState {
  const factory TipState({
    required double percent,
    required double tipAmount,
    required double total,
  }) = _TipState;

  factory TipState.zero() => const TipState(percent: 0, tipAmount: 0, total: 0);
}

@freezed
class TaxState with _$TaxState {
  const factory TaxState({
    required double vatPercent,
    required bool isInclusive,
    required double taxAmount,
    required double total,
  }) = _TaxState;

  factory TaxState.initial({double vat = 10}) =>
      TaxState(vatPercent: vat, isInclusive: false, taxAmount: 0, total: 0);
}

@freezed
class DiscountState with _$DiscountState {
  const factory DiscountState({
    required bool byPercent,
    required double percentOrAmount,
    required double discountAmount,
    required double finalAmount,
  }) = _DiscountState;

  factory DiscountState.initial() =>
      const DiscountState(byPercent: true, percentOrAmount: 0, discountAmount: 0, finalAmount: 0);
}
