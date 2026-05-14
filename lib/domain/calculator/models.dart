import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

@freezed
class CalculatorState with _$CalculatorState {
  const factory CalculatorState({
    required String expression,
    required double? result,
    required bool hasError,
    required bool justEvaluated,
  }) = _CalculatorState;

  factory CalculatorState.initial() => const CalculatorState(
    expression: '',
    result: null,
    hasError: false,
    justEvaluated: false,
  );
}

enum Operator {
  add(symbol: '+', asciiSymbol: '+'),
  sub(symbol: '−', asciiSymbol: '-'),
  mul(symbol: '×', asciiSymbol: '*'),
  div(symbol: '÷', asciiSymbol: '/');

  const Operator({required this.symbol, required this.asciiSymbol});

  final String symbol;
  final String asciiSymbol;
}

sealed class CalculatorKey {
  const CalculatorKey();
}

class DigitKey extends CalculatorKey {
  final int digit;
  const DigitKey(this.digit);
}

class DotKey extends CalculatorKey {
  const DotKey();
}

class OpKey extends CalculatorKey {
  final Operator op;
  const OpKey(this.op);
}

class ParenOpenKey extends CalculatorKey {
  const ParenOpenKey();
}

class ParenCloseKey extends CalculatorKey {
  const ParenCloseKey();
}

class PercentKey extends CalculatorKey {
  const PercentKey();
}

class EqualsKey extends CalculatorKey {
  const EqualsKey();
}

class ClearKey extends CalculatorKey {
  const ClearKey();
}

class BackspaceKey extends CalculatorKey {
  const BackspaceKey();
}
