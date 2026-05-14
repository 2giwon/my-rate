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
}

@riverpod
class ConverterNotifier extends _$ConverterNotifier {
  @override
  Future<ConverterState> build() async {
    // Subscribe to calculator result; default to AppDefaults.defaultAmount
    // when calculator is empty.
    final calcResult = ref.watch(calculatorNotifierProvider).result;
    final amount = calcResult ?? AppDefaults.defaultAmount;

    final settings = await ref.watch(settingsStoreProvider.future);
    final from = await settings.defaultFrom();
    final to = await settings.defaultTo();
    final repo = await ref.watch(exchangeRateRepositoryProvider.future);

    try {
      final snap = await repo.getLatest(baseCode: from);
      return ConverterState(
        fromCode: from,
        toCode: to,
        amount: amount,
        snapshot: snap,
      );
    } on NetworkException catch (e) {
      return ConverterState(
        fromCode: from,
        toCode: to,
        amount: amount,
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
    state = AsyncData(
      s.copyWith(fromCode: s.toCode, toCode: s.fromCode, loading: true),
    );
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
