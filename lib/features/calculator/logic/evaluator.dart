import 'parser.dart';
import 'tokenizer.dart';

sealed class EvalResult {
  const EvalResult();
}

class EvalSuccess extends EvalResult {
  final double value;
  const EvalSuccess(this.value);
}

class EvalEmpty extends EvalResult {
  const EvalEmpty();
}

class EvalDivisionByZero extends EvalResult {
  const EvalDivisionByZero();
}

class EvalSyntaxError extends EvalResult {
  final String message;
  const EvalSyntaxError(this.message);
}

class EvalOverflow extends EvalResult {
  const EvalOverflow();
}

/// Evaluate a normalized (ASCII-operator) expression string.
/// Returns sealed [EvalResult] — caller pattern-matches.
EvalResult evaluate(String input) {
  if (input.trim().isEmpty) {
    return const EvalEmpty();
  }
  try {
    final tokens = tokenize(input);
    final value = parse(tokens);
    if (value.isInfinite || value.isNaN) {
      return const EvalOverflow();
    }
    return EvalSuccess(value);
  } on TokenizerError catch (e) {
    return EvalSyntaxError(e.message);
  } on ParserError catch (e) {
    if (e.message.contains('division by zero')) {
      return const EvalDivisionByZero();
    }
    if (e.message.contains('empty')) {
      return const EvalEmpty();
    }
    return EvalSyntaxError(e.message);
  }
}
