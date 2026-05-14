import 'evaluator.dart';

/// Replaces every `%` in the expression with a context-aware numeric
/// expression following iOS-style rules.
/// Input is a normalized (ASCII-operator) expression string.
String resolvePercent(String input) {
  if (!input.contains('%')) return input;

  final unwrapped = _resolveParens(input);
  return _resolveFlat(unwrapped);
}

/// Recursively resolves `%` inside the innermost parentheses first,
/// then re-inserts the parenthesized sub-expression.
String _resolveParens(String input) {
  var innerStart = -1;
  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (c == '(') {
      innerStart = i;
    } else if (c == ')' && innerStart >= 0) {
      final inner = input.substring(innerStart + 1, i);
      if (!inner.contains('%')) {
        // No work to do inside; keep scanning for a paren that has %.
        innerStart = -1;
        continue;
      }
      final resolved = _resolveFlat(inner);
      final newInput =
          input.substring(0, innerStart + 1) + resolved + input.substring(i);
      return _resolveParens(newInput);
    }
  }
  return input;
}

/// Resolve `%` within a parenthesis-free (or top-level) substring.
String _resolveFlat(String input) {
  var s = input;
  while (true) {
    final idx = s.indexOf('%');
    if (idx < 0) return s;

    var nStart = idx;
    while (nStart > 0 && _isNumberChar(s[nStart - 1])) {
      nStart--;
    }
    final numberStr = s.substring(nStart, idx);
    if (numberStr.isEmpty) {
      // stray '%' — drop it
      s = s.substring(0, idx) + s.substring(idx + 1);
      continue;
    }

    var op = '';
    final opPos = nStart - 1;
    if (opPos >= 0) {
      final c = s[opPos];
      if (c == '+' || c == '-' || c == '*' || c == '/') {
        op = c;
      }
    }

    String replacement;
    if (op == '+' || op == '-') {
      final left = s.substring(0, opPos);
      final leftValue = _evalQuiet(left);
      replacement = '($leftValue*$numberStr/100)';
    } else {
      replacement = '($numberStr/100)';
    }

    s = s.substring(0, nStart) + replacement + s.substring(idx + 1);
  }
}

bool _isNumberChar(String c) {
  if (c == '.') return true;
  final code = c.codeUnitAt(0);
  return code >= 0x30 && code <= 0x39;
}

double _evalQuiet(String expr) {
  if (expr.isEmpty) return 0;
  final r = evaluate(expr);
  return r is EvalSuccess ? r.value : 0;
}
