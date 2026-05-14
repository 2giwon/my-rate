import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/calculator/logic/parser.dart';
import 'package:myrate/features/calculator/logic/tokenizer.dart';

double _eval(String input) => parse(tokenize(input));

void main() {
  group('parse (no percent)', () {
    test('single number', () => expect(_eval('42'), 42.0));
    test('addition', () => expect(_eval('1+2'), 3.0));
    test('subtraction', () => expect(_eval('10-3'), 7.0));
    test('multiplication', () => expect(_eval('4*5'), 20.0));
    test('division', () => expect(_eval('20/4'), 5.0));

    test('precedence: 1+2*3 = 7', () => expect(_eval('1+2*3'), 7.0));
    test('precedence: 2*3+1 = 7', () => expect(_eval('2*3+1'), 7.0));
    test('precedence: 100+50/2 = 125', () => expect(_eval('100+50/2'), 125.0));

    test('parentheses: (1+2)*3 = 9', () => expect(_eval('(1+2)*3'), 9.0));
    test('nested parens: ((1+2)*3) = 9', () => expect(_eval('((1+2)*3)'), 9.0));
    test('parens at end: 2*(3+4) = 14', () => expect(_eval('2*(3+4)'), 14.0));

    test(
      'unclosed paren auto-closed: (1+2 → 3',
      () => expect(_eval('(1+2'), 3.0),
    );
    test(
      'multiple unclosed parens: ((1+2 → 3',
      () => expect(_eval('((1+2'), 3.0),
    );

    test('division by zero throws', () {
      expect(() => _eval('5/0'), throwsA(isA<ParserError>()));
    });

    test('empty expression throws', () {
      expect(() => _eval(''), throwsA(isA<ParserError>()));
    });

    test('trailing operator: 5+ → uses last valid prefix → 5', () {
      expect(_eval('5+'), 5.0);
    });

    test('leading minus: -5 → -5', () => expect(_eval('-5'), -5.0));
    test(
      'leading minus in paren: (-5+3) → -2',
      () => expect(_eval('(-5+3)'), -2.0),
    );
  });
}
