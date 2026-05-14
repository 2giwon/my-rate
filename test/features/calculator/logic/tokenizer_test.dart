import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/calculator/logic/tokenizer.dart';

void main() {
  group('tokenize', () {
    test('empty input returns empty list', () {
      expect(tokenize(''), isEmpty);
    });

    test('single integer', () {
      final t = tokenize('123');
      expect(t, hasLength(1));
      expect(t[0], isA<NumberToken>());
      expect((t[0] as NumberToken).value, 123.0);
    });

    test('decimal number', () {
      final t = tokenize('3.14');
      expect((t.single as NumberToken).value, closeTo(3.14, 1e-9));
    });

    test('simple expression 1+2', () {
      final t = tokenize('1+2');
      expect(t, hasLength(3));
      expect((t[0] as NumberToken).value, 1.0);
      expect((t[1] as OperatorToken).operator, '+');
      expect((t[2] as NumberToken).value, 2.0);
    });

    test('all four operators', () {
      final t = tokenize('1+2-3*4/5');
      final ops = t.whereType<OperatorToken>().map((e) => e.operator).toList();
      expect(ops, ['+', '-', '*', '/']);
    });

    test('parentheses', () {
      final t = tokenize('(1+2)');
      expect(t[0], isA<ParenOpenToken>());
      expect(t[4], isA<ParenCloseToken>());
    });

    test('percent', () {
      final t = tokenize('30%');
      expect(t[1], isA<PercentToken>());
    });

    test('whitespace is ignored', () {
      final t = tokenize(' 1 + 2 ');
      expect(t, hasLength(3));
    });

    test('throws on unknown character', () {
      expect(() => tokenize('1a'), throwsA(isA<TokenizerError>()));
    });

    test('multi-digit and decimal combined', () {
      final t = tokenize('1200.50+0.5');
      expect((t[0] as NumberToken).value, closeTo(1200.50, 1e-9));
      expect((t[2] as NumberToken).value, closeTo(0.5, 1e-9));
    });

    test('leading minus is tokenized as operator (not signed number)', () {
      final t = tokenize('-5');
      expect(t[0], isA<OperatorToken>());
      expect((t[0] as OperatorToken).operator, '-');
      expect((t[1] as NumberToken).value, 5.0);
    });
  });
}
