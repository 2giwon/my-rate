sealed class Token {
  const Token();
}

class NumberToken extends Token {
  final double value;
  const NumberToken(this.value);
}

class OperatorToken extends Token {
  final String operator;
  const OperatorToken(this.operator);
}

class ParenOpenToken extends Token {
  const ParenOpenToken();
}

class ParenCloseToken extends Token {
  const ParenCloseToken();
}

class PercentToken extends Token {
  const PercentToken();
}

class TokenizerError implements Exception {
  final String message;
  final int position;
  const TokenizerError(this.message, this.position);
  @override
  String toString() => 'TokenizerError($message at $position)';
}

List<Token> tokenize(String input) {
  final tokens = <Token>[];
  var i = 0;
  while (i < input.length) {
    final c = input[i];
    if (c == ' ' || c == '\t') {
      i++;
      continue;
    }
    if (_isDigit(c) || c == '.') {
      final start = i;
      while (i < input.length && (_isDigit(input[i]) || input[i] == '.')) {
        i++;
      }
      final raw = input.substring(start, i);
      final value = double.tryParse(raw);
      if (value == null) {
        throw TokenizerError('invalid number "$raw"', start);
      }
      tokens.add(NumberToken(value));
      continue;
    }
    switch (c) {
      case '+':
      case '-':
      case '*':
      case '/':
        tokens.add(OperatorToken(c));
        i++;
        continue;
      case '(':
        tokens.add(const ParenOpenToken());
        i++;
        continue;
      case ')':
        tokens.add(const ParenCloseToken());
        i++;
        continue;
      case '%':
        tokens.add(const PercentToken());
        i++;
        continue;
    }
    throw TokenizerError('unknown character "$c"', i);
  }
  return tokens;
}

bool _isDigit(String c) {
  final code = c.codeUnitAt(0);
  return code >= 0x30 && code <= 0x39;
}
