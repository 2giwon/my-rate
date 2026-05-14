import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/calculator/logic/evaluator.dart';
import 'package:myrate/features/calculator/logic/percent_resolver.dart';

double _eval(String expr) {
  final resolved = resolvePercent(expr);
  final r = evaluate(resolved);
  return (r as EvalSuccess).value;
}

void main() {
  group('resolvePercent', () {
    test('no percent: passes through', () {
      expect(resolvePercent('1+2'), '1+2');
    });

    test('standalone: 30% → (30/100)', () {
      expect(_eval('30%'), closeTo(0.3, 1e-9));
    });

    test('multiplied: 5000*30% → 5000*(30/100) = 1500', () {
      expect(_eval('5000*30%'), closeTo(1500.0, 1e-9));
    });

    test('divided: 100/10% → 100/(10/100) = 1000', () {
      expect(_eval('100/10%'), closeTo(1000.0, 1e-9));
    });

    test('added: 5000+30% → 5000+(5000*30/100) = 6500', () {
      expect(_eval('5000+30%'), closeTo(6500.0, 1e-9));
    });

    test('subtracted: 5000-20% → 5000-(5000*20/100) = 4000', () {
      expect(_eval('5000-20%'), closeTo(4000.0, 1e-9));
    });

    test('in parentheses, mul: (100+50)*10% → 150*0.1 = 15', () {
      expect(_eval('(100+50)*10%'), closeTo(15.0, 1e-9));
    });

    test('in parentheses, add: (100+10%)*2 → (100+10)*2 = 220', () {
      expect(_eval('(100+10%)*2'), closeTo(220.0, 1e-9));
    });

    test('percent followed by more ops: 5000+30%*2 → 5000+1500*2 = 8000', () {
      expect(_eval('5000+30%*2'), closeTo(8000.0, 1e-9));
    });

    test('standalone followed by add: 30%+50 → 0.3+50 = 50.3', () {
      expect(_eval('30%+50'), closeTo(50.3, 1e-9));
    });
  });
}
