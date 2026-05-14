import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/calculator/logic/evaluator.dart';

void main() {
  group('evaluate', () {
    test('returns Value on success', () {
      final r = evaluate('1+2*3');
      expect(r, isA<EvalSuccess>());
      expect((r as EvalSuccess).value, 7.0);
    });

    test('returns DivisionByZeroError on /0', () {
      final r = evaluate('5/0');
      expect(r, isA<EvalDivisionByZero>());
    });

    test('returns EmptyError on empty input', () {
      final r = evaluate('');
      expect(r, isA<EvalEmpty>());
    });

    test('returns InvalidSyntaxError on bad input', () {
      final r = evaluate('1abc');
      expect(r, isA<EvalSyntaxError>());
    });

    test('returns OverflowError on very large', () {
      // 20 multiplications of 1e15 ≈ 1e300 — overflows double on the last steps.
      final big = List.filled(25, '999999999999999').join('*');
      final r = evaluate(big);
      expect(r, isA<EvalOverflow>());
    });
  });
}
