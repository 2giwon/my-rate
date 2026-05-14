import '../../../domain/calculator/models.dart';
import 'evaluator.dart';
import 'percent_resolver.dart';

const _maxExpressionLength = 500;

CalculatorState applyKey(CalculatorState state, CalculatorKey key) {
  final cleared = state.hasError ? state.copyWith(hasError: false) : state;

  switch (key) {
    case ClearKey():
      return CalculatorState.initial();
    case BackspaceKey():
      return _backspace(cleared);
    case EqualsKey():
      return _evaluate(cleared);
    case DigitKey(:final digit):
      return _appendDigit(cleared, digit);
    case DotKey():
      return _appendDot(cleared);
    case OpKey(:final op):
      return _appendOperator(cleared, op);
    case ParenOpenKey():
      return _appendParenOpen(cleared);
    case ParenCloseKey():
      return _appendParenClose(cleared);
    case PercentKey():
      return _appendPercent(cleared);
  }
}

CalculatorState _withDisplay(CalculatorState s, String display) {
  if (_digitsOnly(display).length > _maxExpressionLength) return s;
  final result = _previewResult(display);
  return s.copyWith(
    expression: display,
    result: result,
    justEvaluated: false,
    hasError: false,
  );
}

String _digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

double? _previewResult(String display) {
  final evalExpr = _toEvalExpression(display);
  if (evalExpr.isEmpty) return null;
  final resolved = resolvePercent(evalExpr);
  final r = evaluate(resolved);
  return r is EvalSuccess ? r.value : null;
}

String _toEvalExpression(String display) => display
    .replaceAll(',', '')
    .replaceAll(' ', '')
    .replaceAll('×', '*')
    .replaceAll('÷', '/')
    .replaceAll('−', '-');

CalculatorState _appendDigit(CalculatorState s, int digit) {
  if (s.justEvaluated) {
    return _withDisplay(CalculatorState.initial(), digit.toString());
  }
  final prev = s.expression;
  final trimmed = prev.trimRight();
  if (trimmed.isEmpty) {
    return _withDisplay(s, digit.toString());
  }
  final lastChar = trimmed[trimmed.length - 1];
  if (lastChar == ')' || lastChar == '%') {
    return _withDisplay(s, '$trimmed × $digit');
  }
  if (lastChar == '(') {
    return _withDisplay(s, '$trimmed$digit');
  }
  if (_isOperatorChar(lastChar)) {
    return _withDisplay(s, '$trimmed $digit');
  }
  final next = _appendDigitToLastNumber(prev, digit);
  return _withDisplay(s, next);
}

String _appendDigitToLastNumber(String display, int digit) {
  final m = RegExp(r'([0-9,.]*)$').firstMatch(display);
  final tail = m?.group(1) ?? '';
  final prefix = display.substring(0, display.length - tail.length);
  final tailDigitsRaw = tail.replaceAll(',', '');
  final newTailRaw = '$tailDigitsRaw$digit';
  return prefix + _formatNumber(newTailRaw);
}

String _formatNumber(String raw) {
  final dotIdx = raw.indexOf('.');
  final intPart = dotIdx < 0 ? raw : raw.substring(0, dotIdx);
  final fracPart = dotIdx < 0 ? null : raw.substring(dotIdx + 1);
  final normalizedInt = intPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  final base = normalizedInt.isEmpty ? '0' : normalizedInt;
  final intWithCommas = _withThousandsSeparator(base);
  return fracPart == null ? intWithCommas : '$intWithCommas.$fracPart';
}

String _withThousandsSeparator(String digits) {
  if (digits.isEmpty) return '';
  final buf = StringBuffer();
  final n = digits.length;
  for (var i = 0; i < n; i++) {
    if (i > 0 && (n - i) % 3 == 0) {
      buf.write(',');
    }
    buf.write(digits[i]);
  }
  return buf.toString();
}

CalculatorState _appendDot(CalculatorState s) {
  if (s.justEvaluated) {
    return _withDisplay(CalculatorState.initial(), '0.');
  }
  final m = RegExp(r'([0-9,.]*)$').firstMatch(s.expression);
  final tail = m?.group(1) ?? '';
  if (tail.contains('.')) return s;
  if (tail.isEmpty) {
    return _withDisplay(s, '${s.expression}0.');
  }
  return _withDisplay(s, '${s.expression}.');
}

CalculatorState _appendOperator(CalculatorState s, Operator op) {
  if (s.justEvaluated && s.result != null) {
    final r = _formatResultForExpression(s.result!);
    return _withDisplay(CalculatorState.initial(), '$r ${op.symbol}');
  }
  final trimmed = s.expression.trimRight();
  if (trimmed.isEmpty) {
    return s;
  }
  final lastChar = trimmed[trimmed.length - 1];
  if (_isOperatorChar(lastChar)) {
    final newDisplay =
        '${trimmed.substring(0, trimmed.length - 1).trimRight()} ${op.symbol}';
    return _withDisplay(s, newDisplay);
  }
  return _withDisplay(s, '$trimmed ${op.symbol}');
}

bool _isOperatorChar(String c) => c == '+' || c == '−' || c == '×' || c == '÷';

String _formatResultForExpression(double value) {
  final rounded = (value * 1e10).round() / 1e10;
  final str = rounded == rounded.toInt()
      ? rounded.toInt().toString()
      : rounded.toString();
  return _formatNumber(str);
}

CalculatorState _appendParenOpen(CalculatorState s) {
  if (s.justEvaluated) {
    return _withDisplay(CalculatorState.initial(), '(');
  }
  final trimmed = s.expression.trimRight();
  final needsImplicitMul =
      trimmed.isNotEmpty && RegExp(r'[0-9)%]$').hasMatch(trimmed);
  final prefix = needsImplicitMul
      ? '$trimmed × '
      : (trimmed.isEmpty ? '' : '$trimmed ');
  return _withDisplay(s, '$prefix(');
}

CalculatorState _appendParenClose(CalculatorState s) {
  final trimmed = s.expression.trimRight();
  if (trimmed.isEmpty) return s;
  final open = '('.allMatches(trimmed).length;
  final close = ')'.allMatches(trimmed).length;
  if (close >= open) return s;
  final lastChar = trimmed[trimmed.length - 1];
  if (lastChar == '(') return s;
  return _withDisplay(s, '$trimmed)');
}

CalculatorState _appendPercent(CalculatorState s) {
  if (s.justEvaluated && s.result != null) {
    final r = _formatResultForExpression(s.result!);
    return _withDisplay(CalculatorState.initial(), '$r%');
  }
  final trimmed = s.expression.trimRight();
  if (trimmed.isEmpty) return s;
  final lastChar = trimmed[trimmed.length - 1];
  if (!RegExp(r'[0-9)]').hasMatch(lastChar)) return s;
  return _withDisplay(s, '$trimmed%');
}

CalculatorState _backspace(CalculatorState s) {
  if (s.expression.isEmpty) return s;
  if (s.justEvaluated) {
    return s.copyWith(justEvaluated: false, result: null);
  }
  var newDisplay = s.expression.trimRight();
  if (newDisplay.isEmpty) return _withDisplay(s, '');
  newDisplay = newDisplay.substring(0, newDisplay.length - 1).trimRight();
  final m = RegExp(r'([0-9,.]*)$').firstMatch(newDisplay);
  final tail = m?.group(1) ?? '';
  final prefix = newDisplay.substring(0, newDisplay.length - tail.length);
  final raw = tail.replaceAll(',', '');
  newDisplay = prefix + (raw.isEmpty ? '' : _formatNumber(raw));
  return _withDisplay(s, newDisplay);
}

CalculatorState _evaluate(CalculatorState s) {
  if (s.expression.isEmpty) return s;
  final evalExpr = _toEvalExpression(s.expression);
  if (evalExpr.isEmpty) return s;
  final resolved = resolvePercent(evalExpr);
  final r = evaluate(resolved);
  switch (r) {
    case EvalSuccess(:final value):
      return s.copyWith(result: value, justEvaluated: true, hasError: false);
    case EvalDivisionByZero():
    case EvalOverflow():
      return s.copyWith(hasError: true, result: null, justEvaluated: false);
    case EvalEmpty():
    case EvalSyntaxError():
      return s;
  }
}
