import 'tokenizer.dart';

class ParserError implements Exception {
  final String message;
  const ParserError(this.message);
  @override
  String toString() => 'ParserError($message)';
}

/// Parses a flat token list and evaluates to a double using standard
/// operator precedence (`*/` > `+-`) and parentheses. Unbalanced `(`
/// is auto-closed; trailing operator is dropped (the prefix is evaluated).
/// Throws [ParserError] on division by zero or empty input.
double parse(List<Token> tokens) {
  if (tokens.isEmpty) {
    throw const ParserError('empty expression');
  }
  final cleaned = _dropTrailingOperator(tokens);
  if (cleaned.isEmpty) {
    throw const ParserError('empty expression');
  }
  final state = _ParseState(cleaned);
  final result = state.parseExpression();
  return result;
}

List<Token> _dropTrailingOperator(List<Token> tokens) {
  var end = tokens.length;
  while (end > 0 && tokens[end - 1] is OperatorToken) {
    end--;
  }
  return tokens.sublist(0, end);
}

class _ParseState {
  _ParseState(this.tokens);

  final List<Token> tokens;
  int pos = 0;

  Token? peek() => pos < tokens.length ? tokens[pos] : null;
  Token consume() => tokens[pos++];

  double parseExpression() {
    var left = parseTerm();
    while (true) {
      final t = peek();
      if (t is OperatorToken && (t.operator == '+' || t.operator == '-')) {
        consume();
        final right = parseTerm();
        left = t.operator == '+' ? left + right : left - right;
      } else {
        break;
      }
    }
    return left;
  }

  double parseTerm() {
    var left = parseFactor();
    while (true) {
      final t = peek();
      if (t is OperatorToken && (t.operator == '*' || t.operator == '/')) {
        consume();
        final right = parseFactor();
        if (t.operator == '/') {
          if (right == 0) {
            throw const ParserError('division by zero');
          }
          left = left / right;
        } else {
          left = left * right;
        }
      } else {
        break;
      }
    }
    return left;
  }

  double parseFactor() {
    final t = peek();
    if (t == null) {
      throw const ParserError('unexpected end of expression');
    }
    if (t is OperatorToken && t.operator == '-') {
      consume();
      return -parseFactor();
    }
    if (t is OperatorToken && t.operator == '+') {
      consume();
      return parseFactor();
    }
    if (t is NumberToken) {
      consume();
      return t.value;
    }
    if (t is ParenOpenToken) {
      consume();
      final value = parseExpression();
      final next = peek();
      if (next is ParenCloseToken) {
        consume();
      }
      // unbalanced '(' — silently accept and treat as closed
      return value;
    }
    throw ParserError('unexpected token ${t.runtimeType}');
  }
}
