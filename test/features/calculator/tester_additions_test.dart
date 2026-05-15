// Tester additions — independent verification of calculator behavior
// per spec docs/superpowers/specs/2026-05-14-calculator-design.md sections
// §4 (key behaviors), §10 (error handling), §15 (precision).
//
// These tests target gaps not covered by Developer's tests, focused on
// edge cases and state transitions per Tester rules (Unhappy path > Happy).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myrate/data/exchange_rate/local/settings_store.dart';
import 'package:myrate/data/exchange_rate/providers.dart';
import 'package:myrate/domain/calculator/models.dart';
import 'package:myrate/domain/exchange_rate/exchange_rate_repository.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/calculator/logic/evaluator.dart';
import 'package:myrate/features/calculator/logic/expression_builder.dart';
import 'package:myrate/features/calculator/logic/percent_resolver.dart';
import 'package:myrate/features/calculator/providers/calculator_notifier.dart';
import 'package:myrate/features/converter/providers/converter_notifier.dart';

class _MockRepo extends Mock implements ExchangeRateRepository {}

class _MockSettings extends Mock implements SettingsStore {}

CalculatorState _run(List<CalculatorKey> keys) {
  var s = CalculatorState.initial();
  for (final k in keys) {
    s = applyKey(s, k);
  }
  return s;
}

void main() {
  group('spec §4.2 — empty-expression operator inputs are ignored', () {
    test('empty + → no change', () {
      final s = applyKey(CalculatorState.initial(), const OpKey(Operator.add));
      expect(s.expression, '');
      expect(s.result, isNull);
    });
    test('empty − → no change', () {
      final s = applyKey(CalculatorState.initial(), const OpKey(Operator.sub));
      expect(s.expression, '');
    });
    test('empty × → no change (spec rule)', () {
      final s = applyKey(CalculatorState.initial(), const OpKey(Operator.mul));
      expect(s.expression, '');
    });
    test('empty ÷ → no change (spec rule)', () {
      final s = applyKey(CalculatorState.initial(), const OpKey(Operator.div));
      expect(s.expression, '');
    });
    test('empty % → no change (last char must be digit or `)`)', () {
      final s = applyKey(CalculatorState.initial(), const PercentKey());
      expect(s.expression, '');
    });
    test('empty ) → no change', () {
      final s = applyKey(CalculatorState.initial(), const ParenCloseKey());
      expect(s.expression, '');
    });
    test('empty = → no change, no error', () {
      final s = applyKey(CalculatorState.initial(), const EqualsKey());
      expect(s.expression, '');
      expect(s.result, isNull);
      expect(s.hasError, isFalse);
      expect(s.justEvaluated, isFalse);
    });
    test('empty . → starts a zero-prefixed decimal "0."', () {
      final s = applyKey(CalculatorState.initial(), const DotKey());
      expect(s.expression, '0.');
      expect(s.result, 0.0);
    });
  });

  group('spec §4.5 — key behavior immediately after `=`', () {
    test('= after = → no-op, justEvaluated stays true', () {
      final s = _run(const [DigitKey(5), EqualsKey(), EqualsKey()]);
      expect(s.expression, '5');
      expect(s.result, 5.0);
      expect(s.justEvaluated, isTrue);
    });

    test('⌫ after = → discards result; expression preserved', () {
      final s = _run(const [DigitKey(5), EqualsKey(), BackspaceKey()]);
      expect(s.expression, '5');
      expect(s.result, isNull);
      expect(s.justEvaluated, isFalse);
    });

    test('digit after = → starts new expression', () {
      final s = _run(const [DigitKey(5), EqualsKey(), DigitKey(7)]);
      expect(s.expression, '7');
      expect(s.justEvaluated, isFalse);
    });

    test('. after = → starts new expression as "0."', () {
      final s = _run(const [DigitKey(5), EqualsKey(), DotKey()]);
      expect(s.expression, '0.');
      expect(s.justEvaluated, isFalse);
    });

    test('( after = → starts new expression', () {
      final s = _run(const [DigitKey(5), EqualsKey(), ParenOpenKey()]);
      expect(s.expression, '(');
      expect(s.justEvaluated, isFalse);
    });

    test('operator after = → uses result as left operand', () {
      final s = _run(const [
        DigitKey(4),
        DigitKey(1),
        DigitKey(0),
        DigitKey(0),
        EqualsKey(),
        OpKey(Operator.mul),
      ]);
      expect(s.expression, '4,100 ×');
      expect(s.justEvaluated, isFalse);
    });

    test('% after = → result becomes n% (5 → 5% = 0.05)', () {
      final s = _run(const [DigitKey(5), EqualsKey(), PercentKey()]);
      expect(s.expression, '5%');
      expect(s.result, closeTo(0.05, 1e-9));
    });

    test('C after = → fully resets', () {
      final s = _run(const [DigitKey(5), EqualsKey(), ClearKey()]);
      expect(s.expression, '');
      expect(s.result, isNull);
      expect(s.justEvaluated, isFalse);
    });

    test(
      'result with thousands sep is preserved when continuing with operator',
      () {
        final s = _run(const [
          DigitKey(1),
          DigitKey(2),
          DigitKey(0),
          DigitKey(0),
          OpKey(Operator.mul),
          DigitKey(3),
          OpKey(Operator.add),
          DigitKey(5),
          DigitKey(0),
          DigitKey(0),
          EqualsKey(),
          OpKey(Operator.add),
          DigitKey(1),
        ]);
        // 4100 + 1 preview
        expect(s.expression, startsWith('4,100 + 1'));
        expect(s.result, 4101.0);
      },
    );
  });

  group('spec §4.4 — percent (iOS-style), additional cases', () {
    test('design §4.4 row: (100+50)+10% → 165 (left ctx is 150)', () {
      final resolved = resolvePercent('(100+50)+10%');
      final r = evaluate(resolved);
      expect((r as EvalSuccess).value, closeTo(165.0, 1e-9));
    });

    test('design §4.4 row: 5000+30%×2 → 8000 (precedence + iOS%)', () {
      final s = _run(const [
        DigitKey(5),
        DigitKey(0),
        DigitKey(0),
        DigitKey(0),
        OpKey(Operator.add),
        DigitKey(3),
        DigitKey(0),
        PercentKey(),
        OpKey(Operator.mul),
        DigitKey(2),
      ]);
      expect(s.result, closeTo(8000.0, 1e-9));
    });

    test('% on expression where last char is operator → ignored', () {
      final s = _run(const [DigitKey(5), OpKey(Operator.add), PercentKey()]);
      expect(s.expression, '5 +');
    });

    test('% on expression where last char is `(` → ignored', () {
      final s = _run(const [ParenOpenKey(), PercentKey()]);
      expect(s.expression, '(');
    });

    test(
      'consecutive %: second % ignored (last char is `%`, not digit/`)`)',
      () {
        final s = _run(const [DigitKey(5), PercentKey(), PercentKey()]);
        expect(s.expression, '5%');
        expect(s.result, closeTo(0.05, 1e-9));
      },
    );

    test('percent inside parens with division', () {
      // (100*10%) = 10
      final r = evaluate(resolvePercent('(100*10%)'));
      expect((r as EvalSuccess).value, closeTo(10.0, 1e-9));
    });

    test('multiple nested parens with %', () {
      // ((100+50)*10%) = 15
      final r = evaluate(resolvePercent('((100+50)*10%)'));
      expect((r as EvalSuccess).value, closeTo(15.0, 1e-9));
    });

    test('percent against negative left context: (0-100)+50% = -50', () {
      // left = -100, then -100 + (-100*50/100) = -100 + (-50) = -150
      final r = evaluate(resolvePercent('(0-100)+50%'));
      expect((r as EvalSuccess).value, closeTo(-150.0, 1e-9));
    });
  });

  group('spec §4 — implicit multiplication & paren', () {
    test('% then digit → implicit ×: 30%5 → 30%×5 = 1.5', () {
      final s = _run(const [
        DigitKey(3),
        DigitKey(0),
        PercentKey(),
        DigitKey(5),
      ]);
      expect(s.expression, '30% × 5');
      expect(s.result, closeTo(1.5, 1e-9));
    });

    test(') then ( → implicit ×: (2)(3) = 6', () {
      final s = _run(const [
        ParenOpenKey(),
        DigitKey(2),
        ParenCloseKey(),
        ParenOpenKey(),
        DigitKey(3),
        ParenCloseKey(),
      ]);
      expect(s.expression, '(2) × (3)');
      expect(s.result, 6.0);
    });

    test(') then digit: (2)3 → (2)×3 = 6', () {
      final s = _run(const [
        ParenOpenKey(),
        DigitKey(2),
        ParenCloseKey(),
        DigitKey(3),
      ]);
      expect(s.result, 6.0);
    });

    test('orphan ) ignored: 5)3 stays as 53 (no paren ever opened)', () {
      final s = _run(const [DigitKey(5), ParenCloseKey(), DigitKey(3)]);
      expect(s.expression, '53');
      expect(s.result, 53.0);
    });
  });

  group('spec §4.2 — backspace behavior across token types', () {
    test('backspace after `(` removes implicit×: 5( → 5 × → after ⌫ → 5', () {
      // implicit mul means `5(` becomes `5 × (`. One ⌫ removes the `(`,
      // leaving `5 ×`. This is current behavior (lock in).
      final s = _run(const [DigitKey(5), ParenOpenKey(), BackspaceKey()]);
      expect(s.expression, '5 ×');
    });

    test('backspace after operator: 5 + → 5', () {
      final s = _run(const [DigitKey(5), OpKey(Operator.add), BackspaceKey()]);
      expect(s.expression, '5');
    });

    test('backspace after %: 5% → 5', () {
      final s = _run(const [DigitKey(5), PercentKey(), BackspaceKey()]);
      expect(s.expression, '5');
      expect(s.result, 5.0);
    });

    test('backspace after `)`: (5) → (5', () {
      final s = _run(const [
        ParenOpenKey(),
        DigitKey(5),
        ParenCloseKey(),
        BackspaceKey(),
      ]);
      expect(s.expression, '(5');
      // Parser auto-closes — preview is 5.
      expect(s.result, 5.0);
    });

    test('backspace on number with comma: 1,000 → 100 (one digit removed)', () {
      final s = _run(const [
        DigitKey(1),
        DigitKey(0),
        DigitKey(0),
        DigitKey(0),
        BackspaceKey(),
      ]);
      expect(s.expression, '100');
    });

    test('backspace on empty → still empty (no crash)', () {
      final s = applyKey(CalculatorState.initial(), const BackspaceKey());
      expect(s.expression, '');
    });

    test('backspace into empty: 5 → backspace → ""', () {
      final s = _run(const [DigitKey(5), BackspaceKey()]);
      expect(s.expression, '');
      expect(s.result, isNull);
    });
  });

  group('spec §4.3 — dot rules', () {
    test('. . → single 0. (second dot ignored)', () {
      final s = _run(const [DotKey(), DotKey()]);
      expect(s.expression, '0.');
    });

    test('1.2 then . then 3 → 1.23 (second dot ignored, 3 appended)', () {
      final s = _run(const [
        DigitKey(1),
        DotKey(),
        DigitKey(2),
        DotKey(),
        DigitKey(3),
      ]);
      // Locking current implementation behavior.
      expect(s.expression, '1.23');
    });

    test('. immediately after operator: 5 + . → "5 +0." (lock current quirk; '
        'no space added before zero-prefixed decimal, unlike digit input)', () {
      final s = _run(const [DigitKey(5), OpKey(Operator.add), DotKey()]);
      // NOTE: A digit after operator produces "5 + 3" with a space,
      // but `_appendDot` builds "5 +0." with no leading space. This is
      // cosmetically inconsistent — flagged in TEST_REPORT.md.
      expect(s.expression, '5 +0.');
    });
  });

  group('spec §10 — error handling and recovery', () {
    test('5 ÷ 0 = → hasError true, expression preserved', () {
      final s = _run(const [
        DigitKey(5),
        OpKey(Operator.div),
        DigitKey(0),
        EqualsKey(),
      ]);
      expect(s.hasError, isTrue);
      expect(s.expression, '5 ÷ 0');
      expect(s.result, isNull);
    });

    test(
      'error state recovers on next key press (digit replaces last "0")',
      () {
        final s = _run(const [
          DigitKey(5),
          OpKey(Operator.div),
          DigitKey(0),
          EqualsKey(),
          DigitKey(7),
        ]);
        expect(s.hasError, isFalse);
        // The trailing 0 became 07 then formatted as 7 (leading-zero strip),
        // so expression is '5 ÷ 7'.
        expect(s.expression, '5 ÷ 7');
        expect(s.result, closeTo(5 / 7, 1e-9));
      },
    );

    test('error state cleared by ⌫', () {
      final s = _run(const [
        DigitKey(5),
        OpKey(Operator.div),
        DigitKey(0),
        EqualsKey(),
        BackspaceKey(),
      ]);
      expect(s.hasError, isFalse);
    });

    test('error state cleared by C', () {
      final s = _run(const [
        DigitKey(5),
        OpKey(Operator.div),
        DigitKey(0),
        EqualsKey(),
        ClearKey(),
      ]);
      expect(s.hasError, isFalse);
      expect(s.expression, '');
    });

    test('unclosed paren autoclosed on =: (5+3 = → 8', () {
      final s = _run(const [
        ParenOpenKey(),
        DigitKey(5),
        OpKey(Operator.add),
        DigitKey(3),
        EqualsKey(),
      ]);
      expect(s.result, 8.0);
      expect(s.justEvaluated, isTrue);
    });

    test('multiple unclosed parens autoclosed: ((1+2 = → 3', () {
      final s = _run(const [
        ParenOpenKey(),
        ParenOpenKey(),
        DigitKey(1),
        OpKey(Operator.add),
        DigitKey(2),
        EqualsKey(),
      ]);
      expect(s.result, 3.0);
    });

    test('trailing operator absorbed: 5 + = → 5', () {
      final s = _run(const [DigitKey(5), OpKey(Operator.add), EqualsKey()]);
      // Preview/eval drops trailing op.
      expect(s.result, 5.0);
    });
  });

  group('spec §4.3 — expression length cap (500 chars)', () {
    test('cap blocks further digit input but state remains valid', () {
      var s = CalculatorState.initial();
      for (var i = 0; i < 600; i++) {
        s = applyKey(s, const DigitKey(1));
      }
      final digits = s.expression.replaceAll(',', '').length;
      expect(digits, lessThanOrEqualTo(500));
      // Result is a finite number (or null on overflow — both are spec-ok
      // since beyond 1e15 design §10 says overflow handled gracefully).
      expect(s.hasError, isFalse);
    });
  });

  group('spec §15 — overflow and floating-point edge cases', () {
    test('1 ÷ 3 × 3 = → 1.0 (no accumulated FP error visible)', () {
      final s = _run(const [
        DigitKey(1),
        OpKey(Operator.div),
        DigitKey(3),
        OpKey(Operator.mul),
        DigitKey(3),
        EqualsKey(),
      ]);
      expect(s.result, closeTo(1.0, 1e-12));
    });

    test('0.1 + 0.2 = → state.result is unrounded FP (potential UI concern)', () {
      final s = _run(const [
        DigitKey(0),
        DotKey(),
        DigitKey(1),
        OpKey(Operator.add),
        DigitKey(0),
        DotKey(),
        DigitKey(2),
        EqualsKey(),
      ]);
      // Documents current behavior: result is NOT rounded to 10 significant
      // digits before storage. Display layer (CurrencyFormatter) typically
      // rounds, but the leaked `state.result` flows into ConverterState.amount.
      // See TEST_REPORT.md "potential issue" entry.
      expect(s.result, closeTo(0.3, 1e-9));
      expect(s.result, isNot(equals(0.3)));
    });

    test('huge expression → overflow → hasError true', () {
      // 999999999999999 ** 25 ≈ 1e375 → infinity.
      var s = CalculatorState.initial();
      for (var i = 0; i < 25; i++) {
        if (i > 0) s = applyKey(s, const OpKey(Operator.mul));
        for (final c in '999999999999999'.split('')) {
          s = applyKey(s, DigitKey(int.parse(c)));
        }
      }
      s = applyKey(s, const EqualsKey());
      expect(s.hasError, isTrue);
    });
  });

  group('CalculatorNotifier × ConverterNotifier — sync edge cases', () {
    late _MockRepo repo;
    late _MockSettings settings;
    ExchangeRateSnapshot snap() => ExchangeRateSnapshot(
      baseCode: 'KRW',
      rates: const {'KRW': 1.0, 'USD': 1 / 1362.5},
      fetchedAt: DateTime.utc(2026, 5, 12),
      apiUpdatedAt: DateTime.utc(2026, 5, 12),
      apiNextUpdateAt: DateTime.utc(2026, 5, 13),
    );

    ProviderContainer make() => ProviderContainer(
      overrides: [
        exchangeRateRepositoryProvider.overrideWith((_) async => repo),
        settingsStoreProvider.overrideWith((_) async => settings),
      ],
    );

    setUp(() {
      repo = _MockRepo();
      settings = _MockSettings();
      when(() => settings.defaultFrom()).thenAnswer((_) async => 'KRW');
      when(() => settings.defaultTo()).thenAnswer((_) async => 'USD');
      when(
        () => repo.getLatest(
          baseCode: any(named: 'baseCode'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => snap());
    });

    test('Clear key reverts amount to defaultAmount (100,000)', () async {
      final c = make();
      addTearDown(c.dispose);
      await c.read(converterNotifierProvider.future);

      final n = c.read(calculatorNotifierProvider.notifier);
      // First put something in calculator.
      n.onKey(const DigitKey(5));
      n.onKey(const DigitKey(0));
      await c.read(converterNotifierProvider.future);
      expect(c.read(converterNotifierProvider).valueOrNull?.amount, 50.0);

      // Clear.
      n.onKey(const ClearKey());
      await c.read(converterNotifierProvider.future);
      expect(c.read(converterNotifierProvider).valueOrNull?.amount, 100000.0);
    });

    test(
      'Error state (5÷0=) reverts amount to defaultAmount (calc.result null)',
      () async {
        final c = make();
        addTearDown(c.dispose);
        await c.read(converterNotifierProvider.future);

        final n = c.read(calculatorNotifierProvider.notifier);
        n.onKey(const DigitKey(5));
        n.onKey(const OpKey(Operator.div));
        n.onKey(const DigitKey(0));
        n.onKey(const EqualsKey());
        await c.read(converterNotifierProvider.future);
        expect(c.read(calculatorNotifierProvider).hasError, isTrue);
        expect(c.read(converterNotifierProvider).valueOrNull?.amount, 100000.0);
      },
    );

    test(
      'setExpression (e.g. tip-panel Apply) updates converter amount',
      () async {
        final c = make();
        addTearDown(c.dispose);
        await c.read(converterNotifierProvider.future);

        c.read(calculatorNotifierProvider.notifier).setExpression(4715);
        await c.read(converterNotifierProvider.future);
        expect(c.read(converterNotifierProvider).valueOrNull?.amount, 4715.0);
        expect(c.read(calculatorNotifierProvider).expression, '4,715');
      },
    );

    test('setExpression after an error state clears hasError', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      // Force error.
      final n = c.read(calculatorNotifierProvider.notifier);
      for (final k in const [
        DigitKey(5),
        OpKey(Operator.div),
        DigitKey(0),
        EqualsKey(),
      ]) {
        n.onKey(k);
      }
      expect(c.read(calculatorNotifierProvider).hasError, isTrue);
      n.setExpression(100);
      expect(c.read(calculatorNotifierProvider).hasError, isFalse);
      expect(c.read(calculatorNotifierProvider).result, 100.0);
    });

    test('rapid sequential key presses produce stable final state', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(calculatorNotifierProvider.notifier);
      // Simulate fast tapping: 1 + 2 + 3 = + 4 =
      const keys = [
        DigitKey(1),
        OpKey(Operator.add),
        DigitKey(2),
        OpKey(Operator.add),
        DigitKey(3),
        EqualsKey(),
        OpKey(Operator.add),
        DigitKey(4),
        EqualsKey(),
      ];
      for (final k in keys) {
        n.onKey(k);
      }
      expect(c.read(calculatorNotifierProvider).result, 10.0);
    });

    test('setExpression with decimal preserves precision', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(calculatorNotifierProvider.notifier).setExpression(3.14);
      final s = c.read(calculatorNotifierProvider);
      expect(s.expression, '3.14');
      expect(s.result, closeTo(3.14, 1e-12));
    });

    test(
      'setExpression with very large value is formatted with separators',
      () {
        final c = ProviderContainer();
        addTearDown(c.dispose);
        c.read(calculatorNotifierProvider.notifier).setExpression(1234567);
        expect(c.read(calculatorNotifierProvider).expression, '1,234,567');
      },
    );

    test('setExpression with zero', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(calculatorNotifierProvider.notifier).setExpression(0);
      expect(c.read(calculatorNotifierProvider).expression, '0');
      expect(c.read(calculatorNotifierProvider).result, 0.0);
    });
  });

  group('tokenizer / evaluator extra coverage', () {
    test('tokenize "5+%" stray percent: percent token at the end', () {
      // Tokenizer is permissive; semantic ignore happens in builder/parser.
      // Verify the tokenizer doesn't throw.
      // It just produces NumberToken, OperatorToken, PercentToken — no error.
      // (Validated via resolvePercent + evaluate pathway.)
      final r = evaluate(resolvePercent('5+%'));
      // Stray % is dropped by resolver; result is just `5+`.
      expect((r as EvalSuccess).value, 5.0);
    });

    test('evaluator: pure whitespace input → EvalEmpty', () {
      expect(evaluate('   '), isA<EvalEmpty>());
    });

    test(
      'evaluator: `(((` → EvalSyntaxError (parser cannot resolve empty inner)',
      () {
        // Three open parens with nothing inside: parser tries to read a factor
        // and hits EOF → ParserError("unexpected end of expression") which is
        // surfaced as EvalSyntaxError (not EvalEmpty, since the token list
        // wasn't empty going in).
        final r = evaluate('(((');
        expect(r, isA<EvalSyntaxError>());
      },
    );
  });
}
