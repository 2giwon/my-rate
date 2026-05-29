import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/defaults.dart';
import '../../../core/errors/app_exception.dart';
import '../../../data/exchange_rate/providers.dart';
import '../../../domain/exchange_rate/models.dart';
import '../../calculator/providers/calculator_notifier.dart';
import '../logic/conversion.dart';

part 'converter_notifier.g.dart';

class ConverterState {
  const ConverterState({
    required this.fromCode,
    required this.toCode,
    required this.amount,
    this.snapshot,
    this.error,
    this.loading = false,
    this.isStale = false,
  });

  final String fromCode;
  final String toCode;
  final double amount;
  final ExchangeRateSnapshot? snapshot;
  final AppException? error;
  final bool loading;
  final bool isStale;

  ConverterState copyWith({
    String? fromCode,
    String? toCode,
    double? amount,
    ExchangeRateSnapshot? snapshot,
    AppException? error,
    bool? loading,
    bool? isStale,
    bool clearError = false,
  }) {
    return ConverterState(
      fromCode: fromCode ?? this.fromCode,
      toCode: toCode ?? this.toCode,
      amount: amount ?? this.amount,
      snapshot: snapshot ?? this.snapshot,
      error: clearError ? null : (error ?? this.error),
      loading: loading ?? this.loading,
      isStale: isStale ?? this.isStale,
    );
  }

  ConversionResult? get result {
    final s = snapshot;
    if (s == null) return null;
    if (s.rateFor(fromCode) == null || s.rateFor(toCode) == null) return null;
    return convert(snap: s, fromCode: fromCode, toCode: toCode, amount: amount);
  }

  /// Convert an externally-provided [amount] (typically the calculator
  /// result) using the current snapshot. Returns null if the snapshot is
  /// missing either currency.
  ConversionResult? convertFor(double amount) {
    final s = snapshot;
    if (s == null) return null;
    if (s.rateFor(fromCode) == null || s.rateFor(toCode) == null) return null;
    return convert(snap: s, fromCode: fromCode, toCode: toCode, amount: amount);
  }
}

@riverpod
class ConverterNotifier extends _$ConverterNotifier {
  @override
  Future<ConverterState> build() async {
    // ConverterState carries snapshot/from/to only; the displayed `amount`
    // is owned by CalculatorNotifier and read by the UI directly. This
    // avoids re-running build() on every keypress (which caused a
    // full-screen loading flicker).
    final settings = await ref.watch(settingsStoreProvider.future);
    final from = await settings.defaultFrom();
    final to = await settings.defaultTo();
    final repo = await ref.watch(exchangeRateRepositoryProvider.future);

    try {
      final snap = await repo.getLatest(baseCode: from);
      return ConverterState(
        fromCode: from,
        toCode: to,
        amount: AppDefaults.defaultAmount,
        snapshot: snap,
      );
    } on NetworkException catch (e) {
      return ConverterState(
        fromCode: from,
        toCode: to,
        amount: AppDefaults.defaultAmount,
        error: e,
        isStale: e.hasCache,
      );
    }
  }

  void setAmount(double amount) {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(amount: amount));
  }

  Future<void> setFromCode(String code) async {
    final s = state.valueOrNull;
    if (s == null) return;
    if (code == s.fromCode) return;
    state = AsyncData(
      s.copyWith(fromCode: code, loading: true, clearError: true),
    );
    await _reloadSnapshot(base: code);
  }

  void setToCode(String code) {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(toCode: code));
  }

  Future<void> swap() async {
    final s = state.valueOrNull;
    if (s == null) return;

    // 변환된 값을 새 'from' 금액으로 이동시켜 round-trip 유지.
    // 예: 46,621 USD → 70,069,620 KRW 표시 → swap → 70,069,620 KRW → 46,621 USD.
    // swap 코드 변경 *전에* 계산해야 함 — 변경 후엔 from/to가 뒤집혀
    // 잘못된 방향으로 변환됨. picker 변경(setFromCode/setToCode)은 substitution
    // 의미라 round-trip을 적용하지 않는다.
    double? newAmount;
    if (s.snapshot != null) {
      final current = ref.read(calculatorNotifierProvider).result;
      if (current != null) {
        newAmount = s.convertFor(current)?.convertedAmount;
      }
    }

    state = AsyncData(
      s.copyWith(fromCode: s.toCode, toCode: s.fromCode, loading: true),
    );
    if (newAmount != null) {
      ref.read(calculatorNotifierProvider.notifier).setExpression(newAmount);
    }
    await _reloadSnapshot(base: s.toCode);
  }

  Future<void> refresh() async {
    final s = state.valueOrNull;
    if (s == null) return;
    state = AsyncData(s.copyWith(loading: true, clearError: true));
    await _reloadSnapshot(base: s.fromCode, force: true);
  }

  Future<void> _reloadSnapshot({
    required String base,
    bool force = false,
  }) async {
    final repo = await ref.read(exchangeRateRepositoryProvider.future);
    final current = state.valueOrNull;
    if (current == null) return;
    try {
      final snap = await repo.getLatest(baseCode: base, forceRefresh: force);
      state = AsyncData(
        current.copyWith(
          snapshot: snap,
          loading: false,
          isStale: false,
          clearError: true,
        ),
      );
    } on NetworkException catch (e) {
      state = AsyncData(
        current.copyWith(
          loading: false,
          error: e,
          isStale: current.snapshot != null,
        ),
      );
    }
  }
}
