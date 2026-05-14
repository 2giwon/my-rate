# Calculator Integration Implementation Plan (v1.1)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** MyRate 환율 변환 화면에 인라인 계산기 키패드를 통합한다. 표현식 평가(`×÷ > +−`), 괄호, iOS 스타일 `%`를 지원하고, 팁/세금/할인은 AppBar 🧮 메뉴 → BottomSheet 모달로 분리한다.

**Architecture:** 신규 `lib/features/calculator/` 모듈(domain/logic/providers/view)을 추가. 순수 로직(tokenizer/parser/evaluator/builder/percent_resolver)은 의존성 0, 단위 테스트 100%. `CalculatorNotifier`가 source-of-truth, `ConverterNotifier`가 `ref.watch`로 결과를 구독(pull 방식)하여 환율 변환에 반영.

**Tech Stack:** Flutter 3.x, Riverpod codegen (`@riverpod`), freezed, mocktail. 외부 수식 평가 패키지 미사용 (직접 구현).

---

## 입력 문서

- **설계 문서**: `docs/superpowers/specs/2026-05-14-calculator-design.md`
- **컨텍스트 스캔**: `docs/superpowers/specs/2026-05-14-calculator-context.md`
- 이 plan은 spec을 **변경하지 않는다**. spec/context에서 명시적으로 plan으로 미룬 디테일만 결정 (아래 §결정).

## Plan 단계에서 결정한 디테일 (spec/context 미정 항목)

| 항목 | 결정 |
|---|---|
| `CalculatorNotifier` ↔ `ConverterNotifier` 동기화 방향 | **Pull (소비자 watch)** — `ConverterNotifier.build`가 `ref.watch(calculatorNotifierProvider).result`를 구독하여 `state.amount`를 갱신. 단방향 흐름, 무한 루프 위험 없음. |
| 키패드 sizing 전략 | `GridView.count(crossAxisCount: 4, childAspectRatio: 1.0)` + `Padding`로 키 사이 8dp. 키 최소 영역은 `LayoutBuilder`로 `(width - padding) / 4 ≥ 56dp` 보장. 미달 시 키패드 높이를 화면 50%까지 늘려 셀 영역 확보. |
| 햅틱 피드백 | 키 누름 시 `HapticFeedback.selectionClick()` (Android/iOS 공통). 사운드 없음. |
| 식 표시 폰트 단계 | 16 → 14 → 12 sp (3단계). 12sp에서도 안 들어가면 `SingleChildScrollView(scrollDirection: Axis.horizontal)`로 폴백. |
| 결과 폰트 단계 | 32 → 28 → 24 sp (3단계). 24sp에서도 안 들어가면 ellipsis. |
| 부동소수점 표시 라운딩 | 결과 표시 직전 `(value * 1e10).round() / 1e10`로 라운딩 (10자리 유효 숫자). |

---

## File Structure

### 새로 생성 (lib)

| 파일 | 책임 |
|---|---|
| `lib/domain/calculator/models.dart` | `CalculatorState` (freezed), `CalculatorKey` sealed, `Operator` enum |
| `lib/features/calculator/logic/tokenizer.dart` | 평가용 식 문자열 → `List<Token>` |
| `lib/features/calculator/logic/parser.dart` | 토큰 → AST + 평가 (재귀하강, 우선순위, 괄호) |
| `lib/features/calculator/logic/evaluator.dart` | 단일 진입 `evaluate(String)` → `EvalResult` (sealed: Value/Error) |
| `lib/features/calculator/logic/percent_resolver.dart` | iOS 스타일 `%` 사전 변환 |
| `lib/features/calculator/logic/expression_builder.dart` | 키 + state → 새 state (표시용/평가용 식 동기) |
| `lib/features/calculator/providers/calculator_notifier.dart` | `@riverpod class CalculatorNotifier` |
| `lib/features/calculator/view/widgets/key_button.dart` | 단일 키 (햅틱, 색상 분류) |
| `lib/features/calculator/view/widgets/calculator_keypad.dart` | 5×4 GridView |
| `lib/features/converter/view/widgets/direct_rate_inline.dart` | AppBar 환율 + 시각 |
| `lib/features/converter/view/widgets/expression_display.dart` | From 카드 (식 + 결과 + ⌫) |
| `lib/features/converter/view/widgets/converted_display.dart` | To 카드 (read-only 결과) |
| `lib/features/converter/view/widgets/tip_tax_menu_button.dart` | AppBar 🧮 → BottomSheet 메뉴 |

### 수정

| 파일 | 변경 |
|---|---|
| `lib/features/converter/view/converter_screen.dart` | 대폭 재구성 |
| `lib/features/converter/providers/converter_notifier.dart` | calculator 결과 watch 추가 |
| `lib/features/converter/view/widgets/panels/tip_panel.dart` | BottomSheet 컨테이너 + "적용" 버튼 |
| `lib/features/converter/view/widgets/panels/tax_panel.dart` | 동일 |
| `lib/features/converter/view/widgets/panels/discount_panel.dart` | 동일 |
| `lib/core/l10n/app_en.arb` | 신규 키 9개 |
| `lib/core/l10n/app_ko.arb` | 신규 키 9개 |

### 제거 (lib)

- `lib/features/converter/view/widgets/amount_input.dart`
- `lib/features/converter/view/widgets/currency_card_stack.dart`
- `lib/features/converter/view/widgets/direct_rate_label.dart`
- `lib/features/converter/view/widgets/tip_tax_segment.dart`

### 새로 생성 (test)

- `test/features/calculator/logic/tokenizer_test.dart`
- `test/features/calculator/logic/parser_test.dart`
- `test/features/calculator/logic/evaluator_test.dart`
- `test/features/calculator/logic/percent_resolver_test.dart`
- `test/features/calculator/logic/expression_builder_test.dart`
- `test/features/calculator/providers/calculator_notifier_test.dart`
- `test/features/calculator/view/widgets/key_button_test.dart`
- `test/features/calculator/view/widgets/calculator_keypad_test.dart`
- `test/features/converter/view/widgets/expression_display_test.dart`
- `test/features/converter/view/widgets/converted_display_test.dart`
- `test/features/converter/view/widgets/direct_rate_inline_test.dart`
- `test/features/converter/view/widgets/tip_tax_menu_button_test.dart`
- `integration_test/calculator_e2e_test.dart`

### 제거 (test)

- `test/features/converter/view/widgets/amount_input_test.dart`

### 수정 (test)

- `integration_test/app_test.dart`

---

## Task 1: 도메인 모델 (CalculatorState / CalculatorKey / Operator)

**Files:**
- Create: `lib/domain/calculator/models.dart`
- Create: `test/domain/calculator/models_test.dart`
- Auto-gen: `lib/domain/calculator/models.freezed.dart`

- [ ] **Step 1: Write the failing test**

`test/domain/calculator/models_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/calculator/models.dart';

void main() {
  group('CalculatorState', () {
    test('initial state is empty / no result / no error / not just evaluated', () {
      final s = CalculatorState.initial();
      expect(s.expression, '');
      expect(s.result, isNull);
      expect(s.hasError, isFalse);
      expect(s.justEvaluated, isFalse);
    });

    test('copyWith updates only specified fields', () {
      final s = CalculatorState.initial().copyWith(expression: '1+2', result: 3.0);
      expect(s.expression, '1+2');
      expect(s.result, 3.0);
      expect(s.hasError, isFalse);
    });
  });

  group('CalculatorKey hierarchy', () {
    test('DigitKey stores digit', () {
      expect(const DigitKey(5).digit, 5);
    });
    test('OpKey stores operator', () {
      expect(const OpKey(Operator.add).op, Operator.add);
    });
    test('singletons exist', () {
      expect(const DotKey(), isA<CalculatorKey>());
      expect(const ParenOpenKey(), isA<CalculatorKey>());
      expect(const ParenCloseKey(), isA<CalculatorKey>());
      expect(const PercentKey(), isA<CalculatorKey>());
      expect(const EqualsKey(), isA<CalculatorKey>());
      expect(const ClearKey(), isA<CalculatorKey>());
      expect(const BackspaceKey(), isA<CalculatorKey>());
    });
  });

  group('Operator', () {
    test('symbol returns display character', () {
      expect(Operator.add.symbol, '+');
      expect(Operator.sub.symbol, '−');
      expect(Operator.mul.symbol, '×');
      expect(Operator.div.symbol, '÷');
    });
    test('asciiSymbol returns evaluation character', () {
      expect(Operator.add.asciiSymbol, '+');
      expect(Operator.sub.asciiSymbol, '-');
      expect(Operator.mul.asciiSymbol, '*');
      expect(Operator.div.asciiSymbol, '/');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/domain/calculator/models_test.dart`
Expected: FAIL with "Target of URI doesn't exist: 'package:myrate/domain/calculator/models.dart'"

- [ ] **Step 3: Write the model file**

`lib/domain/calculator/models.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

@freezed
class CalculatorState with _$CalculatorState {
  const factory CalculatorState({
    required String expression,
    required double? result,
    required bool hasError,
    required bool justEvaluated,
  }) = _CalculatorState;

  factory CalculatorState.initial() => const CalculatorState(
    expression: '',
    result: null,
    hasError: false,
    justEvaluated: false,
  );
}

enum Operator {
  add(symbol: '+', asciiSymbol: '+'),
  sub(symbol: '−', asciiSymbol: '-'),
  mul(symbol: '×', asciiSymbol: '*'),
  div(symbol: '÷', asciiSymbol: '/');

  const Operator({required this.symbol, required this.asciiSymbol});

  final String symbol;
  final String asciiSymbol;
}

sealed class CalculatorKey {
  const CalculatorKey();
}

class DigitKey extends CalculatorKey {
  final int digit;
  const DigitKey(this.digit);
}

class DotKey extends CalculatorKey {
  const DotKey();
}

class OpKey extends CalculatorKey {
  final Operator op;
  const OpKey(this.op);
}

class ParenOpenKey extends CalculatorKey {
  const ParenOpenKey();
}

class ParenCloseKey extends CalculatorKey {
  const ParenCloseKey();
}

class PercentKey extends CalculatorKey {
  const PercentKey();
}

class EqualsKey extends CalculatorKey {
  const EqualsKey();
}

class ClearKey extends CalculatorKey {
  const ClearKey();
}

class BackspaceKey extends CalculatorKey {
  const BackspaceKey();
}
```

- [ ] **Step 4: Run build_runner to generate `.freezed.dart`**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `Succeeded after ...` with new file `lib/domain/calculator/models.freezed.dart`

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/domain/calculator/models_test.dart`
Expected: All 7 tests pass.

- [ ] **Step 6: Lint check**

Run: `flutter analyze lib/domain/calculator test/domain/calculator`
Expected: No issues.

- [ ] **Step 7: Format**

Run: `dart format lib/domain/calculator test/domain/calculator`

- [ ] **Step 8: Commit**

```bash
git add lib/domain/calculator test/domain/calculator
git commit -m "feat(calculator): add domain models (CalculatorState, CalculatorKey, Operator)"
```

---

## Task 2: Tokenizer

**Files:**
- Create: `lib/features/calculator/logic/tokenizer.dart`
- Create: `test/features/calculator/logic/tokenizer_test.dart`

토크나이저는 **평가용 식 문자열** (예: `1200*3+500`)을 입력받아 `List<Token>`을 반환한다. 표시용 식의 천 단위 쉼표와 유니코드 연산자 기호(`× ÷ −`)는 expression_builder가 평가용으로 정규화한 뒤 토크나이저에 넘긴다.

- [ ] **Step 1: Write the failing test**

`test/features/calculator/logic/tokenizer_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test (must fail)**

Run: `flutter test test/features/calculator/logic/tokenizer_test.dart`
Expected: FAIL — file not found.

- [ ] **Step 3: Implement tokenizer**

`lib/features/calculator/logic/tokenizer.dart`:

```dart
sealed class Token {
  const Token();
}

class NumberToken extends Token {
  final double value;
  const NumberToken(this.value);
}

class OperatorToken extends Token {
  final String operator; // '+', '-', '*', '/'
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
```

- [ ] **Step 4: Run test (must pass)**

Run: `flutter test test/features/calculator/logic/tokenizer_test.dart`
Expected: All 11 tests pass.

- [ ] **Step 5: Lint + format**

Run: `flutter analyze lib/features/calculator/logic test/features/calculator/logic` && `dart format lib/features/calculator/logic test/features/calculator/logic`
Expected: No issues.

- [ ] **Step 6: Commit**

```bash
git add lib/features/calculator/logic/tokenizer.dart test/features/calculator/logic/tokenizer_test.dart
git commit -m "feat(calculator): add tokenizer for numeric expressions"
```

---

## Task 3: Parser + Evaluator

**Files:**
- Create: `lib/features/calculator/logic/parser.dart`
- Create: `lib/features/calculator/logic/evaluator.dart`
- Create: `test/features/calculator/logic/parser_test.dart`
- Create: `test/features/calculator/logic/evaluator_test.dart`

재귀하강 파서로 토큰 리스트를 평가한다. 우선순위 `×÷` > `+−`, 괄호 지원. 닫지 않은 `(`는 자동 보정 (가상 `)` 추가).

- [ ] **Step 1: Write the parser tests**

`test/features/calculator/logic/parser_test.dart`:

```dart
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

    test('unclosed paren auto-closed: (1+2 → 3', () => expect(_eval('(1+2'), 3.0));
    test('multiple unclosed parens: ((1+2 → 3', () => expect(_eval('((1+2'), 3.0));

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
    test('leading minus in paren: (-5+3) → -2', () => expect(_eval('(-5+3)'), -2.0));
  });
}
```

- [ ] **Step 2: Run parser test (must fail)**

Run: `flutter test test/features/calculator/logic/parser_test.dart`
Expected: FAIL — file not found.

- [ ] **Step 3: Implement parser**

`lib/features/calculator/logic/parser.dart`:

```dart
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
```

- [ ] **Step 4: Run parser test (must pass)**

Run: `flutter test test/features/calculator/logic/parser_test.dart`
Expected: All 16 tests pass.

- [ ] **Step 5: Write the evaluator tests**

`test/features/calculator/logic/evaluator_test.dart`:

```dart
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
      final r = evaluate('1e308*1e308');
      expect(r, isA<EvalOverflow>());
    });
  });
}
```

- [ ] **Step 6: Implement evaluator**

`lib/features/calculator/logic/evaluator.dart`:

```dart
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
/// Returns sealed EvalResult — caller pattern-matches.
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
```

- [ ] **Step 7: Run evaluator test (must pass)**

Run: `flutter test test/features/calculator/logic/evaluator_test.dart`
Expected: All 5 tests pass.

- [ ] **Step 8: Lint + format**

Run: `flutter analyze lib/features/calculator/logic test/features/calculator/logic` && `dart format lib/features/calculator/logic test/features/calculator/logic`

- [ ] **Step 9: Commit**

```bash
git add lib/features/calculator/logic/parser.dart lib/features/calculator/logic/evaluator.dart test/features/calculator/logic/parser_test.dart test/features/calculator/logic/evaluator_test.dart
git commit -m "feat(calculator): add parser + evaluator with precedence and parens"
```

---

## Task 4: Percent Resolver

**Files:**
- Create: `lib/features/calculator/logic/percent_resolver.dart`
- Create: `test/features/calculator/logic/percent_resolver_test.dart`

iOS 스타일 `%` — `%` 키 누르는 즉시 좌항 컨텍스트에 따라 식의 숫자 부분을 사전 변환한다. 입력은 **평가용 식 문자열**, 출력도 평가용 식 문자열이지만 `%` 토큰이 모두 제거된 형태.

규칙 (spec §4.4):
- 직전 연산자 없음 또는 `*` `/`: `n%` → `(n/100)`
- 직전 연산자 `+` `-`: `n%` → `(L*n/100)` (L = 직전 연산자 좌측의 평가값)
- 괄호 내부의 `%`도 동일 (괄호 안 직전 연산자 기준)

구현 전략: 표현식을 **왼쪽에서 오른쪽**으로 한 번 스캔. `%`를 만나면 마지막 숫자 항을 백분율 값으로 치환. `+ −` 좌항이면 그 좌항의 부분식 값을 계산해 곱한다.

- [ ] **Step 1: Write percent resolver tests**

`test/features/calculator/logic/percent_resolver_test.dart`:

```dart
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
```

- [ ] **Step 2: Run test (must fail)**

Run: `flutter test test/features/calculator/logic/percent_resolver_test.dart`
Expected: FAIL — file not found.

- [ ] **Step 3: Implement percent resolver**

`lib/features/calculator/logic/percent_resolver.dart`:

```dart
import 'evaluator.dart';

/// Replaces every `%` in the expression with a context-aware numeric
/// expression following iOS-style rules.
/// Input is a normalized (ASCII-operator) expression string.
String resolvePercent(String input) {
  if (!input.contains('%')) return input;

  // Process inside parentheses recursively first, then replace top-level %.
  final unwrapped = _resolveParens(input);
  return _resolveFlat(unwrapped);
}

/// Recursively resolves `%` inside the innermost parentheses first,
/// then re-inserts the parenthesized sub-expression.
String _resolveParens(String input) {
  // Find the innermost '(...)' pair.
  var depth = 0;
  var innerStart = -1;
  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (c == '(') {
      depth++;
      innerStart = i;
    } else if (c == ')') {
      if (innerStart >= 0) {
        final inner = input.substring(innerStart + 1, i);
        final resolved = _resolveFlat(inner);
        final newInput = input.substring(0, innerStart + 1) + resolved + input.substring(i);
        return _resolveParens(newInput);
      }
      depth--;
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

    // Find the number ending at idx-1 (going backwards over digits/dot).
    var nStart = idx;
    while (nStart > 0 && _isNumberChar(s[nStart - 1])) {
      nStart--;
    }
    final numberStr = s.substring(nStart, idx);

    // Look at the operator just before nStart (if any).
    String op = '';
    var opPos = nStart - 1;
    if (opPos >= 0) {
      final c = s[opPos];
      if (c == '+' || c == '-' || c == '*' || c == '/') {
        op = c;
      }
    }

    String replacement;
    if (op == '+' || op == '-') {
      // Left context = substring(0, opPos), evaluate it.
      final left = s.substring(0, opPos);
      final leftValue = _evalQuiet(left);
      final pct = '($leftValue*$numberStr/100)';
      replacement = pct;
    } else {
      // Standalone, *, or / context: just (n/100)
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
```

- [ ] **Step 4: Run test (must pass)**

Run: `flutter test test/features/calculator/logic/percent_resolver_test.dart`
Expected: All 10 tests pass.

- [ ] **Step 5: Lint + format**

Run: `flutter analyze lib/features/calculator/logic/percent_resolver.dart test/features/calculator/logic/percent_resolver_test.dart` && `dart format lib/features/calculator/logic/percent_resolver.dart test/features/calculator/logic/percent_resolver_test.dart`

- [ ] **Step 6: Commit**

```bash
git add lib/features/calculator/logic/percent_resolver.dart test/features/calculator/logic/percent_resolver_test.dart
git commit -m "feat(calculator): add iOS-style percent resolver"
```

---

## Task 5: Expression Builder

**Files:**
- Create: `lib/features/calculator/logic/expression_builder.dart`
- Create: `test/features/calculator/logic/expression_builder_test.dart`

키 입력 + 직전 `CalculatorState` → 새 `CalculatorState`. 표시용 식(`displayExpression`, e.g. `1,200 × 3 + 500`)과 평가용 식(`evalExpression`, e.g. `1200*3+500`)을 동기 빌드. 미리보기 결과는 `evaluator + percent_resolver` 호출.

표시용↔평가용 문자 매핑:
- `×` ↔ `*`
- `÷` ↔ `/`
- `−` ↔ `-`
- 천 단위 쉼표는 표시용에만, 평가용은 제거

- [ ] **Step 1: Write expression builder tests**

`test/features/calculator/logic/expression_builder_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/calculator/models.dart';
import 'package:myrate/features/calculator/logic/expression_builder.dart';

CalculatorState _apply(CalculatorState s, CalculatorKey k) => applyKey(s, k);

CalculatorState _applyMany(List<CalculatorKey> keys) {
  var s = CalculatorState.initial();
  for (final k in keys) {
    s = _apply(s, k);
  }
  return s;
}

void main() {
  group('applyKey', () {
    test('digit appended to empty: 0..9', () {
      final s = _apply(CalculatorState.initial(), const DigitKey(5));
      expect(s.expression, '5');
      expect(s.result, 5.0);
    });

    test('multi-digit number with thousand separators', () {
      final s = _applyMany(const [DigitKey(1), DigitKey(2), DigitKey(0), DigitKey(0)]);
      expect(s.expression, '1,200');
      expect(s.result, 1200.0);
    });

    test('dot: 3.14', () {
      final s = _applyMany(const [DigitKey(3), DotKey(), DigitKey(1), DigitKey(4)]);
      expect(s.expression, '3.14');
      expect(s.result, closeTo(3.14, 1e-9));
    });

    test('duplicate dot is ignored: 3..1 → 3.1', () {
      final s = _applyMany(const [DigitKey(3), DotKey(), DotKey(), DigitKey(1)]);
      expect(s.expression, '3.1');
    });

    test('addition: 1+2', () {
      final s = _applyMany(const [DigitKey(1), OpKey(Operator.add), DigitKey(2)]);
      expect(s.expression, '1 + 2');
      expect(s.result, 3.0);
    });

    test('operator replaces previous operator: 5 + - → 5 -', () {
      final s = _applyMany(const [DigitKey(5), OpKey(Operator.add), OpKey(Operator.sub)]);
      expect(s.expression, '5 −');
    });

    test('precedence: 1 + 2 × 3 = 7', () {
      final s = _applyMany(const [
        DigitKey(1),
        OpKey(Operator.add),
        DigitKey(2),
        OpKey(Operator.mul),
        DigitKey(3),
      ]);
      expect(s.result, 7.0);
    });

    test('paren: (1+2)*3 = 9', () {
      final s = _applyMany(const [
        ParenOpenKey(),
        DigitKey(1),
        OpKey(Operator.add),
        DigitKey(2),
        ParenCloseKey(),
        OpKey(Operator.mul),
        DigitKey(3),
      ]);
      expect(s.result, 9.0);
    });

    test('implicit multiplication: 5( → 5×(', () {
      final s = _applyMany(const [DigitKey(5), ParenOpenKey(), DigitKey(2), ParenCloseKey()]);
      expect(s.expression, '5 × (2)');
      expect(s.result, 10.0);
    });

    test('empty close paren ignored: ) on empty → no change', () {
      final s = _apply(CalculatorState.initial(), const ParenCloseKey());
      expect(s.expression, '');
    });

    test('close paren ignored when no open: 5) → 5', () {
      final s = _applyMany(const [DigitKey(5), ParenCloseKey()]);
      expect(s.expression, '5');
    });

    test('clear key resets', () {
      final s = _applyMany(const [DigitKey(5), OpKey(Operator.add), DigitKey(3), ClearKey()]);
      expect(s.expression, '');
      expect(s.result, isNull);
    });

    test('backspace removes last token', () {
      final s = _applyMany(const [DigitKey(1), DigitKey(2), DigitKey(3), BackspaceKey()]);
      expect(s.expression, '12');
    });

    test('backspace on digit removes one digit (1,200 → 120)', () {
      final s = _applyMany(const [
        DigitKey(1), DigitKey(2), DigitKey(0), DigitKey(0),
        BackspaceKey(),
      ]);
      expect(s.expression, '120');
    });

    test('equals sets justEvaluated', () {
      final s = _applyMany(const [DigitKey(1), OpKey(Operator.add), DigitKey(2), EqualsKey()]);
      expect(s.expression, '1 + 2');
      expect(s.result, 3.0);
      expect(s.justEvaluated, isTrue);
    });

    test('after equals, operator continues from result', () {
      final s1 = _applyMany(const [
        DigitKey(1), OpKey(Operator.add), DigitKey(2), EqualsKey(),
      ]);
      expect(s1.result, 3.0);
      final s2 = applyKey(s1, const OpKey(Operator.mul));
      expect(s2.expression, '3 ×');
      expect(s2.justEvaluated, isFalse);
    });

    test('after equals, digit starts new expression', () {
      final s1 = _applyMany(const [DigitKey(5), EqualsKey()]);
      final s2 = applyKey(s1, const DigitKey(7));
      expect(s2.expression, '7');
      expect(s2.justEvaluated, isFalse);
    });

    test('division by zero sets hasError', () {
      final s = _applyMany(const [DigitKey(5), OpKey(Operator.div), DigitKey(0), EqualsKey()]);
      expect(s.hasError, isTrue);
    });

    test('expression length cap: > 500 chars dropped', () {
      var s = CalculatorState.initial();
      for (var i = 0; i < 600; i++) {
        s = applyKey(s, const DigitKey(1));
      }
      expect(s.expression.replaceAll(',', '').length, lessThanOrEqualTo(500));
    });

    test('percent on plus: 5000+30% mid-input updates preview', () {
      final s = _applyMany(const [
        DigitKey(5), DigitKey(0), DigitKey(0), DigitKey(0),
        OpKey(Operator.add),
        DigitKey(3), DigitKey(0),
        PercentKey(),
      ]);
      expect(s.expression, contains('%'));
      expect(s.result, closeTo(6500.0, 1e-6));
    });
  });
}
```

- [ ] **Step 2: Run test (must fail)**

Run: `flutter test test/features/calculator/logic/expression_builder_test.dart`
Expected: FAIL — file not found.

- [ ] **Step 3: Implement expression builder**

`lib/features/calculator/logic/expression_builder.dart`:

```dart
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

String _toEvalExpression(String display) =>
    display.replaceAll(',', '').replaceAll(' ', '').replaceAll('×', '*').replaceAll('÷', '/').replaceAll('−', '-');

CalculatorState _appendDigit(CalculatorState s, int digit) {
  if (s.justEvaluated) {
    return _withDisplay(CalculatorState.initial(), digit.toString());
  }
  final prev = s.expression;
  final lastIsCloseParenOrPercent = prev.isNotEmpty && (prev.endsWith(')') || prev.endsWith('%'));
  final withImplicitMul = lastIsCloseParenOrPercent ? '$prev × ' : prev;
  final next = _appendDigitToLastNumber(withImplicitMul, digit);
  return _withDisplay(s, next);
}

String _appendDigitToLastNumber(String display, int digit) {
  // Split off the trailing number token (digits/comma/dot).
  final m = RegExp(r'([0-9,.]*)$').firstMatch(display);
  final tail = m?.group(1) ?? '';
  final prefix = display.substring(0, display.length - tail.length);
  final tailDigitsRaw = tail.replaceAll(',', '');
  final dotIdx = tailDigitsRaw.indexOf('.');
  String newTailRaw;
  if (dotIdx >= 0) {
    newTailRaw = '$tailDigitsRaw$digit';
  } else {
    newTailRaw = '$tailDigitsRaw$digit';
  }
  return prefix + _formatNumber(newTailRaw);
}

String _formatNumber(String raw) {
  final dotIdx = raw.indexOf('.');
  final intPart = dotIdx < 0 ? raw : raw.substring(0, dotIdx);
  final fracPart = dotIdx < 0 ? null : raw.substring(dotIdx + 1);
  final normalizedInt = intPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  final intWithCommas = _withThousandsSeparator(normalizedInt.isEmpty ? '0' : normalizedInt);
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
  if (tail.contains('.')) return s; // already has dot
  if (tail.isEmpty) {
    return _withDisplay(s, '${s.expression}0.');
  }
  return _withDisplay(s, '${s.expression}.');
}

CalculatorState _appendOperator(CalculatorState s, Operator op) {
  // After =, continue from result.
  if (s.justEvaluated && s.result != null) {
    final r = _formatResultForExpression(s.result!);
    return _withDisplay(CalculatorState.initial(), '$r ${op.symbol}');
  }
  final trimmed = s.expression.trimRight();
  if (trimmed.isEmpty) {
    // Empty + +/-/×/÷: ignore (no signed start)
    return s;
  }
  final lastChar = trimmed[trimmed.length - 1];
  if (_isOperatorChar(lastChar)) {
    // Replace last operator
    final newDisplay = '${trimmed.substring(0, trimmed.length - 1).trimRight()} ${op.symbol}';
    return _withDisplay(s, newDisplay);
  }
  return _withDisplay(s, '$trimmed ${op.symbol}');
}

bool _isOperatorChar(String c) => c == '+' || c == '−' || c == '×' || c == '÷';

String _formatResultForExpression(double value) {
  final rounded = (value * 1e10).round() / 1e10;
  final str = rounded == rounded.toInt() ? rounded.toInt().toString() : rounded.toString();
  return _formatNumber(str);
}

CalculatorState _appendParenOpen(CalculatorState s) {
  if (s.justEvaluated) {
    return _withDisplay(CalculatorState.initial(), '(');
  }
  final trimmed = s.expression.trimRight();
  final needsImplicitMul = trimmed.isNotEmpty &&
      (RegExp(r'[0-9)%]$').hasMatch(trimmed));
  final prefix = needsImplicitMul ? '$trimmed × ' : (trimmed.isEmpty ? '' : '$trimmed ');
  return _withDisplay(s, '$prefix(');
}

CalculatorState _appendParenClose(CalculatorState s) {
  final trimmed = s.expression.trimRight();
  if (trimmed.isEmpty) return s;
  final open = '('.allMatches(trimmed).length;
  final close = ')'.allMatches(trimmed).length;
  if (close >= open) return s; // nothing to close
  final lastChar = trimmed[trimmed.length - 1];
  if (lastChar == '(' ) return s; // empty paren ()
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
  if (!RegExp(r'[0-9)]').hasMatch(lastChar)) return s; // only after a number or close paren
  return _withDisplay(s, '$trimmed%');
}

CalculatorState _backspace(CalculatorState s) {
  if (s.expression.isEmpty) return s;
  if (s.justEvaluated) {
    return s.copyWith(justEvaluated: false, result: null);
  }
  // Remove last meaningful character (skip trailing space).
  var newDisplay = s.expression.trimRight();
  if (newDisplay.isEmpty) return _withDisplay(s, '');
  newDisplay = newDisplay.substring(0, newDisplay.length - 1).trimRight();
  // Reformat number tails (the last token might now be a partial number).
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
      return s; // no-op
  }
}
```

- [ ] **Step 4: Run test (must pass)**

Run: `flutter test test/features/calculator/logic/expression_builder_test.dart`
Expected: All 20 tests pass.

- [ ] **Step 5: Lint + format**

Run: `flutter analyze lib/features/calculator/logic/expression_builder.dart test/features/calculator/logic/expression_builder_test.dart` && `dart format lib/features/calculator/logic/expression_builder.dart test/features/calculator/logic/expression_builder_test.dart`

- [ ] **Step 6: Commit**

```bash
git add lib/features/calculator/logic/expression_builder.dart test/features/calculator/logic/expression_builder_test.dart
git commit -m "feat(calculator): add expression builder (key → state transitions)"
```

---

## Task 6: CalculatorNotifier

**Files:**
- Create: `lib/features/calculator/providers/calculator_notifier.dart`
- Create: `test/features/calculator/providers/calculator_notifier_test.dart`
- Auto-gen: `lib/features/calculator/providers/calculator_notifier.g.dart`

`@riverpod` notifier가 `expression_builder.applyKey`를 호출하여 state 전이.

- [ ] **Step 1: Write notifier tests**

`test/features/calculator/providers/calculator_notifier_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/calculator/models.dart';
import 'package:myrate/features/calculator/providers/calculator_notifier.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('CalculatorNotifier', () {
    test('initial state', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final s = c.read(calculatorNotifierProvider);
      expect(s.expression, '');
      expect(s.result, isNull);
    });

    test('onKey applies single digit', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(calculatorNotifierProvider.notifier).onKey(const DigitKey(5));
      expect(c.read(calculatorNotifierProvider).expression, '5');
      expect(c.read(calculatorNotifierProvider).result, 5.0);
    });

    test('chain of keys: 1+2= → 3', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(calculatorNotifierProvider.notifier);
      n.onKey(const DigitKey(1));
      n.onKey(const OpKey(Operator.add));
      n.onKey(const DigitKey(2));
      n.onKey(const EqualsKey());
      final s = c.read(calculatorNotifierProvider);
      expect(s.result, 3.0);
      expect(s.justEvaluated, isTrue);
    });

    test('clear key resets to initial', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final n = c.read(calculatorNotifierProvider.notifier);
      n.onKey(const DigitKey(9));
      n.onKey(const ClearKey());
      expect(c.read(calculatorNotifierProvider).expression, '');
    });

    test('setExpression replaces with new value (used by panel apply)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(calculatorNotifierProvider.notifier).setExpression(1234);
      final s = c.read(calculatorNotifierProvider);
      expect(s.expression, '1,234');
      expect(s.result, 1234.0);
    });
  });
}
```

- [ ] **Step 2: Run test (must fail)**

Run: `flutter test test/features/calculator/providers/calculator_notifier_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement notifier**

`lib/features/calculator/providers/calculator_notifier.dart`:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/calculator/models.dart';
import '../logic/expression_builder.dart';

part 'calculator_notifier.g.dart';

@Riverpod(keepAlive: true)
class CalculatorNotifier extends _$CalculatorNotifier {
  @override
  CalculatorState build() => CalculatorState.initial();

  void onKey(CalculatorKey key) {
    state = applyKey(state, key);
  }

  /// Replace the expression with the formatted numeric value.
  /// Used by Tip/Tax/Discount panel "Apply" button.
  void setExpression(double value) {
    final rounded = (value * 1e10).round() / 1e10;
    final str = rounded == rounded.toInt() ? rounded.toInt().toString() : rounded.toString();
    state = CalculatorState(
      expression: _formatNumber(str),
      result: value,
      hasError: false,
      justEvaluated: true,
    );
  }
}

String _formatNumber(String raw) {
  final dotIdx = raw.indexOf('.');
  final intPart = dotIdx < 0 ? raw : raw.substring(0, dotIdx);
  final fracPart = dotIdx < 0 ? null : raw.substring(dotIdx + 1);
  final normalizedInt = intPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  final base = normalizedInt.isEmpty ? '0' : normalizedInt;
  final n = base.length;
  final buf = StringBuffer();
  for (var i = 0; i < n; i++) {
    if (i > 0 && (n - i) % 3 == 0) buf.write(',');
    buf.write(base[i]);
  }
  return fracPart == null ? buf.toString() : '${buf.toString()}.$fracPart';
}
```

- [ ] **Step 4: Generate `.g.dart`**

Run: `dart run build_runner build --delete-conflicting-outputs`

- [ ] **Step 5: Run test (must pass)**

Run: `flutter test test/features/calculator/providers/calculator_notifier_test.dart`
Expected: All 5 tests pass.

- [ ] **Step 6: Lint + format + commit**

Run: `flutter analyze lib/features/calculator/providers test/features/calculator/providers` && `dart format lib/features/calculator/providers test/features/calculator/providers`

```bash
git add lib/features/calculator/providers test/features/calculator/providers
git commit -m "feat(calculator): add CalculatorNotifier (Riverpod)"
```

---

## Task 7: ConverterNotifier — calculator 결과 구독 (pull 패턴)

**Files:**
- Modify: `lib/features/converter/providers/converter_notifier.dart`
- Modify: `test/features/converter/providers/converter_notifier_test.dart`

`ConverterNotifier.build()`가 `ref.watch(calculatorNotifierProvider).result`를 구독하여 `amount`를 자동 갱신. 기존 `setAmount` API는 유지(외부 직접 호출에 대응).

- [ ] **Step 1: Add a failing test that asserts amount syncs from calculator**

`test/features/converter/providers/converter_notifier_test.dart`에 다음 그룹 추가 (기존 파일 끝에 append, 다른 그룹 건드리지 않음):

```dart
  group('calculator sync', () {
    test('amount auto-updates when CalculatorNotifier.result changes', () async {
      final container = ProviderContainer(overrides: [
        // ... 기존 테스트 setup과 동일한 overrides 재사용
      ]);
      addTearDown(container.dispose);
      await container.read(converterNotifierProvider.future);

      container
          .read(calculatorNotifierProvider.notifier)
          .onKey(const DigitKey(1));
      container
          .read(calculatorNotifierProvider.notifier)
          .onKey(const DigitKey(2));
      container
          .read(calculatorNotifierProvider.notifier)
          .onKey(const DigitKey(3));

      // pump to allow ref.watch propagation
      await Future<void>.delayed(Duration.zero);

      expect(container.read(converterNotifierProvider).valueOrNull?.amount, 123.0);
    });
  });
```

> 주: 기존 test 파일의 helper/overrides 구조를 그대로 사용. 새 imports: `package:myrate/domain/calculator/models.dart`, `package:myrate/features/calculator/providers/calculator_notifier.dart`.

- [ ] **Step 2: Run (must fail)**

Run: `flutter test test/features/converter/providers/converter_notifier_test.dart`
Expected: FAIL (existing notifier doesn't watch calculator).

- [ ] **Step 3: Update ConverterNotifier**

`lib/features/converter/providers/converter_notifier.dart`의 `build` 메서드를 수정. 기존 build 본문 시작 부분에 calculator 구독 추가하고, 반환 직전에 amount 결정.

```dart
  @override
  Future<ConverterState> build() async {
    // Subscribe to calculator result; default to 100,000 when calculator is empty.
    final calcResult = ref.watch(calculatorNotifierProvider).result;
    final amount = calcResult ?? AppDefaults.defaultAmount;

    final settings = await ref.watch(settingsStoreProvider.future);
    final from = await settings.defaultFrom();
    final to = await settings.defaultTo();
    final repo = await ref.watch(exchangeRateRepositoryProvider.future);

    try {
      final snap = await repo.getLatest(baseCode: from);
      return ConverterState(fromCode: from, toCode: to, amount: amount, snapshot: snap);
    } on NetworkException catch (e) {
      return ConverterState(
        fromCode: from,
        toCode: to,
        amount: amount,
        error: e,
        isStale: e.hasCache,
      );
    }
  }
```

새 import 추가:
```dart
import '../../../core/constants/defaults.dart';
import '../../calculator/providers/calculator_notifier.dart';
```

기존 `setAmount` 메서드는 그대로 두되, 더 이상 ConverterScreen에서는 호출되지 않음 (호환성 유지).

- [ ] **Step 4: Run test (must pass)**

Run: `flutter test test/features/converter/providers/converter_notifier_test.dart`
Expected: All tests pass including new sync test.

- [ ] **Step 5: Format + commit**

Run: `dart format lib/features/converter/providers/converter_notifier.dart test/features/converter/providers/converter_notifier_test.dart`

```bash
git add lib/features/converter/providers/converter_notifier.dart test/features/converter/providers/converter_notifier_test.dart
git commit -m "feat(converter): ConverterNotifier subscribes to CalculatorNotifier.result"
```

---

## Task 8: KeyButton widget

**Files:**
- Create: `lib/features/calculator/view/widgets/key_button.dart`
- Create: `test/features/calculator/view/widgets/key_button_test.dart`

단일 키 버튼. 햅틱 피드백 포함, 색상 분류 enum.

- [ ] **Step 1: Write widget test**

`test/features/calculator/view/widgets/key_button_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/calculator/view/widgets/key_button.dart';

void main() {
  group('KeyButton', () {
    testWidgets('shows label and calls onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: KeyButton(
            label: '7',
            kind: KeyKind.digit,
            onTap: () => tapped = true,
          ),
        ),
      ));
      expect(find.text('7'), findsOneWidget);
      await tester.tap(find.text('7'));
      expect(tapped, isTrue);
    });

    testWidgets('different kinds render', (tester) async {
      for (final k in KeyKind.values) {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: KeyButton(label: 'X', kind: k, onTap: () {}),
          ),
        ));
        expect(find.text('X'), findsOneWidget);
      }
    });
  });
}
```

- [ ] **Step 2: Run (must fail)**

Run: `flutter test test/features/calculator/view/widgets/key_button_test.dart`
Expected: FAIL — file not found.

- [ ] **Step 3: Implement KeyButton**

`lib/features/calculator/view/widgets/key_button.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum KeyKind { digit, operator, equals, edit }

class KeyButton extends StatelessWidget {
  const KeyButton({
    super.key,
    required this.label,
    required this.kind,
    required this.onTap,
  });

  final String label;
  final KeyKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (kind) {
      KeyKind.digit => (scheme.surfaceContainerHighest, scheme.onSurface),
      KeyKind.edit => (scheme.surfaceContainerHigh, scheme.onSurfaceVariant),
      KeyKind.operator => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      KeyKind.equals => (scheme.primary, scheme.onPrimary),
    };
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 24,
              fontWeight: kind == KeyKind.equals ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test (must pass)**

Run: `flutter test test/features/calculator/view/widgets/key_button_test.dart`
Expected: All tests pass.

- [ ] **Step 5: Format + commit**

```bash
dart format lib/features/calculator/view/widgets/key_button.dart test/features/calculator/view/widgets/key_button_test.dart
git add lib/features/calculator/view/widgets/key_button.dart test/features/calculator/view/widgets/key_button_test.dart
git commit -m "feat(calculator): add KeyButton widget with haptic + color kinds"
```

---

## Task 9: CalculatorKeypad widget

**Files:**
- Create: `lib/features/calculator/view/widgets/calculator_keypad.dart`
- Create: `test/features/calculator/view/widgets/calculator_keypad_test.dart`

5×4 GridView. 각 탭 → `ref.read(calculatorNotifierProvider.notifier).onKey(key)`.

- [ ] **Step 1: Write widget test**

`test/features/calculator/view/widgets/calculator_keypad_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/features/calculator/providers/calculator_notifier.dart';
import 'package:myrate/features/calculator/view/widgets/calculator_keypad.dart';

void main() {
  Future<void> _pump(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: Scaffold(body: CalculatorKeypad())),
    ));
  }

  testWidgets('renders all 20 keys', (tester) async {
    await _pump(tester);
    for (final label in const [
      'C', '(', ')', '÷', '7', '8', '9', '×',
      '4', '5', '6', '−', '1', '2', '3', '+',
      '%', '0', '.', '=',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'key "$label" missing');
    }
  });

  testWidgets('tapping 5 updates CalculatorNotifier.expression', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: CalculatorKeypad())),
    ));
    await tester.tap(find.text('5'));
    await tester.pump();
    expect(container.read(calculatorNotifierProvider).expression, '5');
  });

  testWidgets('tapping 1+2= produces result 3', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: CalculatorKeypad())),
    ));
    await tester.tap(find.text('1'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('2'));
    await tester.tap(find.text('='));
    await tester.pump();
    expect(container.read(calculatorNotifierProvider).result, 3.0);
  });
}
```

- [ ] **Step 2: Run (must fail)**

Run: `flutter test test/features/calculator/view/widgets/calculator_keypad_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement keypad**

`lib/features/calculator/view/widgets/calculator_keypad.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/calculator/models.dart';
import '../../providers/calculator_notifier.dart';
import 'key_button.dart';

class CalculatorKeypad extends ConsumerWidget {
  const CalculatorKeypad({super.key});

  static const List<List<_KeySpec>> _layout = [
    [
      _KeySpec('C', KeyKind.edit, ClearKey()),
      _KeySpec('(', KeyKind.edit, ParenOpenKey()),
      _KeySpec(')', KeyKind.edit, ParenCloseKey()),
      _KeySpec('÷', KeyKind.operator, OpKey(Operator.div)),
    ],
    [
      _KeySpec('7', KeyKind.digit, DigitKey(7)),
      _KeySpec('8', KeyKind.digit, DigitKey(8)),
      _KeySpec('9', KeyKind.digit, DigitKey(9)),
      _KeySpec('×', KeyKind.operator, OpKey(Operator.mul)),
    ],
    [
      _KeySpec('4', KeyKind.digit, DigitKey(4)),
      _KeySpec('5', KeyKind.digit, DigitKey(5)),
      _KeySpec('6', KeyKind.digit, DigitKey(6)),
      _KeySpec('−', KeyKind.operator, OpKey(Operator.sub)),
    ],
    [
      _KeySpec('1', KeyKind.digit, DigitKey(1)),
      _KeySpec('2', KeyKind.digit, DigitKey(2)),
      _KeySpec('3', KeyKind.digit, DigitKey(3)),
      _KeySpec('+', KeyKind.operator, OpKey(Operator.add)),
    ],
    [
      _KeySpec('%', KeyKind.operator, PercentKey()),
      _KeySpec('0', KeyKind.digit, DigitKey(0)),
      _KeySpec('.', KeyKind.digit, DotKey()),
      _KeySpec('=', KeyKind.equals, EqualsKey()),
    ],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(calculatorNotifierProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _layout
            .map(
              (row) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: row
                        .map(
                          (k) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: KeyButton(
                                label: k.label,
                                kind: k.kind,
                                onTap: () => notifier.onKey(k.key),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _KeySpec {
  final String label;
  final KeyKind kind;
  final CalculatorKey key;
  const _KeySpec(this.label, this.kind, this.key);
}
```

- [ ] **Step 4: Run test (must pass)**

Run: `flutter test test/features/calculator/view/widgets/calculator_keypad_test.dart`
Expected: All 3 tests pass.

- [ ] **Step 5: Format + commit**

```bash
dart format lib/features/calculator/view/widgets/calculator_keypad.dart test/features/calculator/view/widgets/calculator_keypad_test.dart
git add lib/features/calculator/view/widgets/calculator_keypad.dart test/features/calculator/view/widgets/calculator_keypad_test.dart
git commit -m "feat(calculator): add CalculatorKeypad (5x4 grid)"
```

---

## Task 10: ExpressionDisplay widget (From 카드)

**Files:**
- Create: `lib/features/converter/view/widgets/expression_display.dart`
- Create: `test/features/converter/view/widgets/expression_display_test.dart`

From 통화 카드. 헤더(국기/이름/⌄) + 식(작게, 자동축소) + ⌫ 아이콘 + 결과(굵게, 크게). 통화 영역 탭 → `onTapHeader` 콜백.

- [ ] **Step 1: Write widget test**

`test/features/converter/view/widgets/expression_display_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/view/widgets/expression_display.dart';

void main() {
  const currency = Currency(code: 'KRW', name: '대한민국 원', flagEmoji: '🇰🇷', decimalPlaces: 0);

  testWidgets('shows expression and result', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExpressionDisplay(
          currency: currency,
          expression: '1,200 × 3 + 500',
          result: 4100.0,
          hasError: false,
          onTapHeader: () {},
          onBackspace: () {},
        ),
      ),
    ));
    expect(find.text('1,200 × 3 + 500'), findsOneWidget);
    expect(find.text('4,100'), findsOneWidget); // formatted with decimalPlaces=0
    expect(find.text('KRW'), findsOneWidget);
  });

  testWidgets('tap header calls onTapHeader', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExpressionDisplay(
          currency: currency,
          expression: '',
          result: null,
          hasError: false,
          onTapHeader: () => tapped = true,
          onBackspace: () {},
        ),
      ),
    ));
    await tester.tap(find.text('KRW'));
    expect(tapped, isTrue);
  });

  testWidgets('tap backspace icon calls onBackspace', (tester) async {
    var bs = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExpressionDisplay(
          currency: currency,
          expression: '5',
          result: 5.0,
          hasError: false,
          onTapHeader: () {},
          onBackspace: () => bs = true,
        ),
      ),
    ));
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    expect(bs, isTrue);
  });

  testWidgets('hasError shows error label instead of result', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExpressionDisplay(
          currency: currency,
          expression: '5 ÷ 0',
          result: null,
          hasError: true,
          onTapHeader: () {},
          onBackspace: () {},
        ),
      ),
    ));
    expect(find.text('Error'), findsOneWidget); // English default
  });
}
```

- [ ] **Step 2: Run (must fail)**

Run: `flutter test test/features/converter/view/widgets/expression_display_test.dart`
Expected: FAIL.

- [ ] **Step 3: Implement ExpressionDisplay**

`lib/features/converter/view/widgets/expression_display.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/exchange_rate/models.dart';

class ExpressionDisplay extends StatelessWidget {
  const ExpressionDisplay({
    super.key,
    required this.currency,
    required this.expression,
    required this.result,
    required this.hasError,
    required this.onTapHeader,
    required this.onBackspace,
    this.errorLabel = 'Error',
  });

  final Currency currency;
  final String expression;
  final double? result;
  final bool hasError;
  final VoidCallback onTapHeader;
  final VoidCallback onBackspace;
  final String errorLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onTapHeader,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(currency.flagEmoji ?? '', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(currency.code,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(currency.name,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.expand_more, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      expression.isEmpty ? '0' : expression,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.backspace_outlined),
                  onPressed: onBackspace,
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                hasError
                    ? errorLabel
                    : CurrencyFormatter.format(result ?? 0, decimalPlaces: currency.decimalPlaces),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: hasError ? Colors.red : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test (must pass)**

Run: `flutter test test/features/converter/view/widgets/expression_display_test.dart`
Expected: All 4 tests pass.

- [ ] **Step 5: Format + commit**

```bash
dart format lib/features/converter/view/widgets/expression_display.dart test/features/converter/view/widgets/expression_display_test.dart
git add lib/features/converter/view/widgets/expression_display.dart test/features/converter/view/widgets/expression_display_test.dart
git commit -m "feat(converter): add ExpressionDisplay widget (From card)"
```

---

## Task 11: ConvertedDisplay widget (To 카드)

**Files:**
- Create: `lib/features/converter/view/widgets/converted_display.dart`
- Create: `test/features/converter/view/widgets/converted_display_test.dart`

To 통화 카드. read-only. 통화 헤더(탭 시 picker) + 변환 결과 값.

- [ ] **Step 1: Write widget test**

`test/features/converter/view/widgets/converted_display_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/view/widgets/converted_display.dart';

void main() {
  const currency = Currency(code: 'USD', name: 'US Dollar', flagEmoji: '🇺🇸', decimalPlaces: 2);

  testWidgets('shows code, name, and converted value', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ConvertedDisplay(
          currency: currency,
          convertedValue: 3.01,
          onTapHeader: () {},
        ),
      ),
    ));
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('3.01'), findsOneWidget);
  });

  testWidgets('null value shows placeholder', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ConvertedDisplay(currency: currency, convertedValue: null, onTapHeader: () {}),
      ),
    ));
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('tap header calls onTapHeader', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ConvertedDisplay(
          currency: currency,
          convertedValue: 1.0,
          onTapHeader: () => tapped = true,
        ),
      ),
    ));
    await tester.tap(find.text('USD'));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run (must fail)**

- [ ] **Step 3: Implement ConvertedDisplay**

`lib/features/converter/view/widgets/converted_display.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../domain/exchange_rate/models.dart';

class ConvertedDisplay extends StatelessWidget {
  const ConvertedDisplay({
    super.key,
    required this.currency,
    required this.convertedValue,
    required this.onTapHeader,
  });

  final Currency currency;
  final double? convertedValue;
  final VoidCallback onTapHeader;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onTapHeader,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(currency.flagEmoji ?? '', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(currency.code,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(currency.name,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.expand_more, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                convertedValue == null
                    ? '—'
                    : CurrencyFormatter.format(convertedValue!, decimalPlaces: currency.decimalPlaces),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test (must pass) + Step 5: Format + commit**

```bash
flutter test test/features/converter/view/widgets/converted_display_test.dart
dart format lib/features/converter/view/widgets/converted_display.dart test/features/converter/view/widgets/converted_display_test.dart
git add lib/features/converter/view/widgets/converted_display.dart test/features/converter/view/widgets/converted_display_test.dart
git commit -m "feat(converter): add ConvertedDisplay widget (To card)"
```

---

## Task 12: DirectRateInline widget (AppBar)

**Files:**
- Create: `lib/features/converter/view/widgets/direct_rate_inline.dart`
- Create: `test/features/converter/view/widgets/direct_rate_inline_test.dart`

AppBar title 영역. `FittedBox(scaleDown)` 적용. 환율 + 갱신 시각 2줄.

- [ ] **Step 1: Write widget test**

`test/features/converter/view/widgets/direct_rate_inline_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/core/l10n/generated/app_localizations.dart';
import 'package:myrate/features/converter/view/widgets/direct_rate_inline.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(appBar: AppBar(title: child)),
    );

void main() {
  testWidgets('shows rate and timestamp', (tester) async {
    final t = DateTime.utc(2026, 5, 14, 5, 32);
    await tester.pumpWidget(_wrap(DirectRateInline(
      fromCode: 'USD',
      toCode: 'KRW',
      directRate: 1362.5,
      basedOn: t,
      toDecimals: 2,
    )));
    expect(find.textContaining('USD'), findsWidgets);
    expect(find.textContaining('KRW'), findsWidgets);
    expect(find.textContaining('1,362.50'), findsWidgets);
  });

  testWidgets('shows placeholder when rate is null', (tester) async {
    await tester.pumpWidget(_wrap(const DirectRateInline(
      fromCode: 'USD',
      toCode: 'KRW',
      directRate: null,
      basedOn: null,
      toDecimals: 2,
    )));
    expect(find.text('MyRate'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run (must fail)**

- [ ] **Step 3: Implement DirectRateInline**

`lib/features/converter/view/widgets/direct_rate_inline.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';

class DirectRateInline extends StatelessWidget {
  const DirectRateInline({
    super.key,
    required this.fromCode,
    required this.toCode,
    required this.directRate,
    required this.basedOn,
    required this.toDecimals,
  });

  final String fromCode;
  final String toCode;
  final double? directRate;
  final DateTime? basedOn;
  final int toDecimals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (directRate == null) {
      return Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.w700));
    }
    final rateText = l10n.convertedDirectRateLabel(
      fromCode,
      CurrencyFormatter.format(directRate!, decimalPlaces: toDecimals),
      toCode,
    );
    final timeText = basedOn == null
        ? ''
        : '${DateFormatter.formatRateTimestamp(basedOn!.toLocal())} ${l10n.lastUpdatedPrefix}';
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rateText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          if (timeText.isNotEmpty)
            Text(timeText, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4-5: Run + format + commit**

```bash
flutter test test/features/converter/view/widgets/direct_rate_inline_test.dart
dart format lib/features/converter/view/widgets/direct_rate_inline.dart test/features/converter/view/widgets/direct_rate_inline_test.dart
git add lib/features/converter/view/widgets/direct_rate_inline.dart test/features/converter/view/widgets/direct_rate_inline_test.dart
git commit -m "feat(converter): add DirectRateInline widget for AppBar"
```

---

## Task 13: l10n 키 추가 (Task 14 위젯의 사전 의존)

**Files:**
- Modify: `lib/core/l10n/app_en.arb`
- Modify: `lib/core/l10n/app_ko.arb`

신규 키 9개. spec §9 참조. 키 13(이 task)을 14보다 먼저 처리하는 이유: Task 14의 TipTaxMenuButton 위젯이 신규 l10n 키를 참조하기 때문.

- [ ] **Step 1: Append new keys to `lib/core/l10n/app_en.arb`**

기존 마지막 항목(`"refreshButton": "Refresh"`) 뒤에 콤마 추가하고 다음 키들 추가:

```json
  "calcError": "Error",
  "calcMenuTitle": "Calculation tools",
  "calcMenuTip": "Tip",
  "calcMenuTax": "Tax",
  "calcMenuDiscount": "Discount",
  "panelBaseAmount": "Base amount",
  "panelApplyButton": "Apply",
  "appBarRateLabel": "1 {from} = {value} {to}",
  "@appBarRateLabel": {
    "placeholders": {
      "from": { "type": "String" },
      "value": { "type": "String" },
      "to": { "type": "String" }
    }
  },
  "appBarTimestamp": "As of {ts}",
  "@appBarTimestamp": {
    "placeholders": { "ts": { "type": "String" } }
  }
```

- [ ] **Step 2: Append matching keys to `lib/core/l10n/app_ko.arb`**

```json
  "calcError": "오류",
  "calcMenuTitle": "계산 도구",
  "calcMenuTip": "팁 계산",
  "calcMenuTax": "세금 계산",
  "calcMenuDiscount": "할인 계산",
  "panelBaseAmount": "기준 금액",
  "panelApplyButton": "적용",
  "appBarRateLabel": "1 {from} = {value} {to}",
  "appBarTimestamp": "{ts} 기준"
```

- [ ] **Step 3: Regenerate l10n**

Run: `flutter gen-l10n`
Expected: Updates `lib/core/l10n/generated/app_localizations*.dart` (gitignored).

- [ ] **Step 4: Verify by analysing**

Run: `flutter analyze lib/core/l10n`
Expected: No issues.

- [ ] **Step 5: Commit**

```bash
git add lib/core/l10n/app_en.arb lib/core/l10n/app_ko.arb
git commit -m "feat(l10n): add calculator and panel keys (en/ko)"
```

---

## Task 14: TipTaxMenuButton widget

**Files:**
- Create: `lib/features/converter/view/widgets/tip_tax_menu_button.dart`
- Create: `test/features/converter/view/widgets/tip_tax_menu_button_test.dart`

AppBar 🧮 아이콘. 탭 시 BottomSheet 메뉴 → 항목 선택 시 콜백.

- [ ] **Step 1: Write widget test**

`test/features/converter/view/widgets/tip_tax_menu_button_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myrate/core/l10n/generated/app_localizations.dart';
import 'package:myrate/domain/exchange_rate/models.dart';
import 'package:myrate/features/converter/view/widgets/tip_tax_menu_button.dart';

void main() {
  Widget _wrap(Widget child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(appBar: AppBar(actions: [child])),
      );

  testWidgets('tap shows menu with tip/tax/discount', (tester) async {
    TipTaxMode? selected;
    await tester.pumpWidget(_wrap(TipTaxMenuButton(onSelected: (m) => selected = m)));
    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Tip'), findsOneWidget);
    expect(find.text('Tax'), findsOneWidget);
    expect(find.text('Discount'), findsOneWidget);

    await tester.tap(find.text('Tip'));
    await tester.pumpAndSettle();
    expect(selected, TipTaxMode.tip);
  });
}
```

- [ ] **Step 2-3: Run (must fail) + Implement**

`lib/features/converter/view/widgets/tip_tax_menu_button.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../domain/exchange_rate/models.dart';

class TipTaxMenuButton extends StatelessWidget {
  const TipTaxMenuButton({super.key, required this.onSelected});

  final ValueChanged<TipTaxMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.calculate_outlined),
      tooltip: AppLocalizations.of(context)!.calcMenuTitle,
      onPressed: () => _openMenu(context),
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showModalBottomSheet<TipTaxMode>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.calcMenuTitle, style: const TextStyle(fontWeight: FontWeight.w600))),
            const Divider(height: 1),
            ListTile(
              leading: const Text('💰', style: TextStyle(fontSize: 22)),
              title: Text(l10n.calcMenuTip),
              onTap: () => Navigator.of(ctx).pop(TipTaxMode.tip),
            ),
            ListTile(
              leading: const Text('🧾', style: TextStyle(fontSize: 22)),
              title: Text(l10n.calcMenuTax),
              onTap: () => Navigator.of(ctx).pop(TipTaxMode.tax),
            ),
            ListTile(
              leading: const Text('🏷', style: TextStyle(fontSize: 22)),
              title: Text(l10n.calcMenuDiscount),
              onTap: () => Navigator.of(ctx).pop(TipTaxMode.discount),
            ),
          ],
        ),
      ),
    );
    if (picked != null) onSelected(picked);
  }
}
```

- [ ] **Step 4-5: Run test + format + commit**

```bash
flutter test test/features/converter/view/widgets/tip_tax_menu_button_test.dart
dart format lib/features/converter/view/widgets/tip_tax_menu_button.dart test/features/converter/view/widgets/tip_tax_menu_button_test.dart
git add lib/features/converter/view/widgets/tip_tax_menu_button.dart test/features/converter/view/widgets/tip_tax_menu_button_test.dart
git commit -m "feat(converter): add TipTaxMenuButton (AppBar bottom sheet menu)"
```

---

## Task 15: Panel BottomSheet 변환 (TipPanel/TaxPanel/DiscountPanel)

**Files:**
- Modify: `lib/features/converter/view/widgets/panels/tip_panel.dart`
- Modify: `lib/features/converter/view/widgets/panels/tax_panel.dart`
- Modify: `lib/features/converter/view/widgets/panels/discount_panel.dart`

기존 인라인 패널을 BottomSheet 호환 형태로 변환:
1. 외부 `Padding` 제거 (modal sheet 자체가 padding을 가짐)
2. `SingleChildScrollView`로 감싸기 (키보드 올라올 때 스크롤)
3. 상단 헤더 (제목 + ✕) + 기준 금액 표시 + "적용" 버튼 추가
4. "적용" 누르면 `ref.read(calculatorNotifierProvider.notifier).setExpression(totalValue)` + `Navigator.pop`

- [ ] **Step 1: Edit `tip_panel.dart` — wrap with sheet container + add Apply**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/defaults.dart';
import '../../../../../core/l10n/generated/app_localizations.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../calculator/providers/calculator_notifier.dart';
import '../../../providers/converter_notifier.dart';
import '../../../providers/tip_tax_notifier.dart';

class TipPanel extends ConsumerWidget {
  const TipPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final converter = ref.watch(converterNotifierProvider).valueOrNull;
    final tipTax = ref.watch(tipTaxNotifierProvider);
    if (converter == null) return const SizedBox.shrink();

    final amount = converter.amount;
    final fromDecimals = 0; // KRW base; refined when currency catalog wired

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.calcMenuTip,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${l10n.panelBaseAmount}: ${CurrencyFormatter.format(amount, decimalPlaces: fromDecimals)}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: AppDefaults.tipPresets.map((p) {
                final selected = tipTax.tip.percent == p.toDouble();
                return ChoiceChip(
                  label: Text('$p%'),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(tipTaxNotifierProvider.notifier)
                      .setTipPercent(p.toDouble(), amount: amount),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(l10n.tipPercentLabel),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    onChanged: (v) {
                      final p = double.tryParse(v) ?? 0;
                      ref.read(tipTaxNotifierProvider.notifier).setTipPercent(p, amount: amount);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _row(l10n.tipAmountLabel,
                CurrencyFormatter.format(tipTax.tip.tipAmount, decimalPlaces: fromDecimals)),
            _row(l10n.totalLabel,
                CurrencyFormatter.format(tipTax.tip.total, decimalPlaces: fromDecimals)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref.read(calculatorNotifierProvider.notifier).setExpression(tipTax.tip.total);
                  Navigator.of(context).pop();
                },
                child: Text(l10n.panelApplyButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text(value)],
        ),
      );
}
```

- [ ] **Step 2: Edit `tax_panel.dart` similarly**

같은 구조로 `TaxPanel` 수정. 핵심 변경:
- 상단 헤더 + ✕ 버튼
- `MediaQuery.of(context).viewInsets.bottom` 패딩
- "적용" 버튼: `ref.read(calculatorNotifierProvider.notifier).setExpression(tipTax.tax.total)` + pop

(`tax_panel.dart` 전체 코드는 `tip_panel.dart` 패턴을 그대로 따르며 `tax` 필드/`taxVatLabel` 등으로 치환. spec §3.1과 일치.)

- [ ] **Step 3: Edit `discount_panel.dart` similarly**

같은 구조. "적용" 버튼: `setExpression(tipTax.discount.finalAmount)`.

- [ ] **Step 4: Run all existing panel-related tests to verify no regression**

Run: `flutter test test/features/converter/`
Expected: 모든 기존 테스트 통과.

- [ ] **Step 5: Format + commit**

```bash
dart format lib/features/converter/view/widgets/panels
git add lib/features/converter/view/widgets/panels
git commit -m "feat(panels): convert tip/tax/discount panels to bottom sheet with Apply button"
```

---

## Task 16: ConverterScreen 재구성

**Files:**
- Modify: `lib/features/converter/view/converter_screen.dart`

새 위젯들을 조립한 새 화면. AppBar = `DirectRateInline` + actions(`TipTaxMenuButton`, refresh, settings). Body = `Column[ ExpressionDisplay, SwapButton, ConvertedDisplay, Spacer or fixed gap, CalculatorKeypad ]`. 오프라인 배너는 SafeArea 바로 안.

- [ ] **Step 1: Rewrite `converter_screen.dart`**

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/exchange_rate/providers.dart';
import '../../../domain/exchange_rate/models.dart';
import '../../calculator/view/widgets/calculator_keypad.dart';
import '../providers/converter_notifier.dart';
import '../providers/tip_tax_notifier.dart';
import 'widgets/converted_display.dart';
import 'widgets/direct_rate_inline.dart';
import 'widgets/expression_display.dart';
import 'widgets/offline_banner.dart';
import 'widgets/panels/discount_panel.dart';
import 'widgets/panels/tax_panel.dart';
import 'widgets/panels/tip_panel.dart';
import 'widgets/tip_tax_menu_button.dart';
import '../../currency_picker/view/currency_picker_screen.dart';

class ConverterScreen extends ConsumerWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(converterNotifierProvider);
    final catalogAsync = ref.watch(currencyCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        toolbarHeight: 72,
        actions: [
          TipTaxMenuButton(onSelected: (m) => _openPanel(context, ref, m)),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.refreshButton,
            onPressed: () => ref.read(converterNotifierProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(width: 4),
        ],
        title: state.when(
          loading: () => Text(l10n.appTitle),
          error: (_, __) => Text(l10n.appTitle),
          data: (s) {
            final snap = s.snapshot;
            if (snap == null) return Text(l10n.appTitle);
            final result = s.result;
            final toDecimals = catalogAsync.maybeWhen(
              data: (catalog) {
                final lang = Localizations.localeOf(context).languageCode;
                return catalog.resolve(s.toCode, languageCode: lang).decimalPlaces;
              },
              orElse: () => 2,
            );
            final adapted = _adaptiveRateDecimals(result?.directRate ?? 1, toDecimals);
            return DirectRateInline(
              fromCode: s.fromCode,
              toCode: s.toCode,
              directRate: result?.directRate,
              basedOn: result?.basedOn,
              toDecimals: adapted,
            );
          },
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (s) {
          final snap = s.snapshot;
          if (snap == null) return Center(child: Text(l10n.refreshButton));
          return catalogAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (catalog) {
              final lang = Localizations.localeOf(context).languageCode;
              final fromCurrency = catalog.resolve(s.fromCode, languageCode: lang);
              final toCurrency = catalog.resolve(s.toCode, languageCode: lang);
              final convertedAmount = s.result?.convertedAmount;
              return Column(
                children: [
                  if (s.isStale)
                    OfflineBanner(
                      message: l10n.offlineBanner(
                        DateFormatter.formatRateTimestamp(snap.apiUpdatedAt.toLocal()),
                      ),
                    ),
                  const SizedBox(height: 4),
                  ExpressionDisplay(
                    currency: fromCurrency,
                    expression: ref
                        .watch(converterNotifierProvider)
                        .maybeWhen(data: (_) => _watchExpression(ref), orElse: () => ''),
                    result: s.amount,
                    hasError: _watchHasError(ref),
                    errorLabel: l10n.calcError,
                    onTapHeader: () => _openPicker(context, ref, isFrom: true, snapshot: snap),
                    onBackspace: () => ref.read(_calcNotifier(ref)).onKey(_backspaceKey),
                  ),
                  Center(
                    child: IconButton(
                      icon: const Icon(Icons.swap_vert_rounded, size: 32),
                      onPressed: () => ref.read(converterNotifierProvider.notifier).swap(),
                    ),
                  ),
                  ConvertedDisplay(
                    currency: toCurrency,
                    convertedValue: convertedAmount,
                    onTapHeader: () => _openPicker(context, ref, isFrom: false, snapshot: snap),
                  ),
                  const Expanded(child: CalculatorKeypad()),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _watchExpression(WidgetRef ref) {
    // Avoid coupling import — inline read of calculator state
    return ref
        .watch(_calculatorStateProvider)
        .expression;
  }

  bool _watchHasError(WidgetRef ref) =>
      ref.watch(_calculatorStateProvider).hasError;

  Future<void> _openPanel(BuildContext context, WidgetRef ref, TipTaxMode mode) async {
    ref.read(tipTaxNotifierProvider.notifier).setMode(mode);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => switch (mode) {
        TipTaxMode.tip => const TipPanel(),
        TipTaxMode.tax => const TaxPanel(),
        TipTaxMode.discount => const DiscountPanel(),
        TipTaxMode.none => const SizedBox.shrink(),
      },
    );
  }

  Future<void> _openPicker(
    BuildContext context,
    WidgetRef ref, {
    required bool isFrom,
    required ExchangeRateSnapshot snapshot,
  }) async {
    final codes = snapshot.rates.keys.toList();
    final picked = await context.push<String>(
      AppRoutes.picker,
      extra: CurrencyPickerArgs(availableCodes: codes),
    );
    if (picked == null) return;
    if (isFrom) {
      await ref.read(converterNotifierProvider.notifier).setFromCode(picked);
    } else {
      ref.read(converterNotifierProvider.notifier).setToCode(picked);
    }
  }
}

// Helper providers/keys to keep imports tidy:
final _calculatorStateProvider = Provider((ref) =>
    ref.watch(_calcProviderImport()));
ProviderOrFamily<dynamic> _calcProviderImport() {
  // Implementation note: replace with direct calculatorNotifierProvider import.
  throw UnimplementedError('replace with calculatorNotifierProvider');
}

const _backspaceKey = _BackspaceMarker();

class _BackspaceMarker { const _BackspaceMarker(); }
```

> **중요**: 위 스니펫의 helper provider/keys 부분은 의도적으로 missing-link 표기. 실제 구현 시 다음으로 대체:
> 1. 파일 상단 import에 `import '../../calculator/providers/calculator_notifier.dart';` 와 `import '../../../domain/calculator/models.dart';` 추가.
> 2. `_calculatorStateProvider`/`_calcProviderImport`/`_backspaceKey`/`_BackspaceMarker` 제거.
> 3. `_watchExpression`/`_watchHasError`는 `ref.watch(calculatorNotifierProvider).expression`/`.hasError`로 단순화.
> 4. backspace 콜백: `() => ref.read(calculatorNotifierProvider.notifier).onKey(const BackspaceKey())`.

이 task는 가장 위험한 통합 단계. 직접 컴파일/실행하며 import를 정리.

`int _adaptiveRateDecimals(double rate, int defaultDecimals)`는 기존 `converter_screen.dart`에 이미 정의되어 있으므로 그대로 둠 (Read tool로 87~178줄 확인).

- [ ] **Step 2: 컴파일 + analyze**

Run: `flutter analyze lib/features/converter/view/converter_screen.dart`
Expected: No errors (warnings 0). 위 helper 표기는 제거해야 함.

- [ ] **Step 3: Run all converter tests**

Run: `flutter test test/features/converter/`
Expected: 모든 기존 단위 테스트 + 새 위젯 테스트 통과.

- [ ] **Step 4: Commit**

```bash
dart format lib/features/converter/view/converter_screen.dart
git add lib/features/converter/view/converter_screen.dart
git commit -m "feat(converter): redesign ConverterScreen with calculator integration"
```

---

## Task 17: 기존 위젯 제거

**Files:**
- Delete: `lib/features/converter/view/widgets/amount_input.dart`
- Delete: `lib/features/converter/view/widgets/currency_card_stack.dart`
- Delete: `lib/features/converter/view/widgets/direct_rate_label.dart`
- Delete: `lib/features/converter/view/widgets/tip_tax_segment.dart`
- Delete: `test/features/converter/view/widgets/amount_input_test.dart`

`adaptive_rate_decimals_test.dart`는 `converter_screen.dart`의 `adaptiveRateDecimals` 함수를 import하므로 그대로 유지 (Task 16에서 함수 보존됨).

- [ ] **Step 1: Verify no remaining references**

Run: `grep -rn --include='*.dart' -E "AmountInput|CurrencyCardStack|DirectRateLabel|TipTaxSegment|ThousandsSeparatorInputFormatter" lib test integration_test`
Expected: 출력 없음 (CalculatorScreen 재구성 후 모든 참조 정리됨).

만약 출력이 있다면 해당 파일을 먼저 수정한 뒤 다음 단계.

- [ ] **Step 2: Delete the files**

```bash
git rm lib/features/converter/view/widgets/amount_input.dart \
       lib/features/converter/view/widgets/currency_card_stack.dart \
       lib/features/converter/view/widgets/direct_rate_label.dart \
       lib/features/converter/view/widgets/tip_tax_segment.dart \
       test/features/converter/view/widgets/amount_input_test.dart
```

- [ ] **Step 3: Run full test suite**

Run: `flutter test`
Expected: 모든 테스트 통과 (단위 + 위젯).

- [ ] **Step 4: Lint**

Run: `flutter analyze`
Expected: 0 warnings, 0 errors.

- [ ] **Step 5: Commit**

```bash
git commit -m "chore(converter): remove legacy widgets (AmountInput, CurrencyCardStack, DirectRateLabel, TipTaxSegment)"
```

---

## Task 18: 통합 테스트 — app_test.dart 수정 + 신규 calculator_e2e

**Files:**
- Modify: `integration_test/app_test.dart`
- Create: `integration_test/calculator_e2e_test.dart`

`app_test.dart`는 화면 구조 변경에 따라 셀렉터 수정.
신규 E2E는 spec §13의 4 시나리오를 커버.

- [ ] **Step 1: Update `app_test.dart`**

`integration_test/app_test.dart`의 셀렉터 부분(line 41-44)을 수정:

```dart
    // 메인 화면: AppBar에 환율, 키패드에 숫자 키 노출
    expect(find.text('KRW'), findsWidgets);
    expect(find.text('USD'), findsWidgets);
    expect(find.text('7'), findsOneWidget); // calculator keypad
    expect(find.text('='), findsOneWidget);
```

- [ ] **Step 2: Run app_test.dart**

Run: `flutter test integration_test/app_test.dart`
Expected: 통과.

- [ ] **Step 3: Write `calculator_e2e_test.dart`**

`integration_test/calculator_e2e_test.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myrate/app.dart';
import 'package:myrate/data/exchange_rate/providers.dart';
import 'package:myrate/data/exchange_rate/remote/dtos.dart';
import 'package:myrate/data/exchange_rate/remote/exchange_rate_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApi extends ExchangeRateApi {
  _FakeApi() : super(dio: Dio(), apiKey: 'fake');
  @override
  Future<LatestRatesDto> fetchLatest(String baseCode) async => LatestRatesDto(
        result: 'success',
        baseCode: baseCode,
        timeLastUpdateUnix: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        timeNextUpdateUnix:
            DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch ~/ 1000,
        conversionRates: const {'KRW': 1.0, 'USD': 1 / 1362.5},
      );
}

Future<void> _bootApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(ProviderScope(
    overrides: [exchangeRateApiProvider.overrideWithValue(_FakeApi())],
    child: const MyRateApp(),
  ));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('golden path: 1200 × 3 + 500 = 4,100 → USD ≈ 3.01', (tester) async {
    await _bootApp(tester);
    // tap "1, 2, 0, 0, ×, 3, +, 5, 0, 0, ="
    for (final key in const ['1', '2', '0', '0', '×', '3', '+', '5', '0', '0', '=']) {
      await tester.tap(find.text(key));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('4,100'), findsWidgets);
    expect(find.textContaining('3.01'), findsWidgets);
  });

  testWidgets('parentheses: (1000 + 500) × 3 = 4,500', (tester) async {
    await _bootApp(tester);
    for (final key in const ['(', '1', '0', '0', '0', '+', '5', '0', '0', ')', '×', '3', '=']) {
      await tester.tap(find.text(key));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('4,500'), findsWidgets);
  });

  testWidgets('percent: 50000 − 30 % = 35,000', (tester) async {
    await _bootApp(tester);
    for (final key in const ['5', '0', '0', '0', '0', '−', '3', '0', '%', '=']) {
      await tester.tap(find.text(key));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('35,000'), findsWidgets);
  });

  testWidgets('tip modal: 4,100 + 10% tip → 4,510 applied', (tester) async {
    await _bootApp(tester);
    for (final key in const ['4', '1', '0', '0']) {
      await tester.tap(find.text(key));
      await tester.pump();
    }
    await tester.tap(find.byIcon(Icons.calculate_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tip').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('10%'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('4,510'), findsWidgets);
  });
}
```

- [ ] **Step 4: Run integration tests**

Run: `flutter test integration_test/calculator_e2e_test.dart`
Expected: 모든 4 시나리오 통과.

- [ ] **Step 5: Run full test suite + lint**

Run: `flutter test && flutter analyze`
Expected: All pass. 0 warnings.

- [ ] **Step 6: Commit**

```bash
git add integration_test/app_test.dart integration_test/calculator_e2e_test.dart
git commit -m "test(integration): update app_test, add calculator E2E (golden/parens/percent/tip)"
```

---

## 최종 단계 (스킬이 종료된 후 super-develop이 이어감)

위 18개 task가 모두 완료되면:
- 단위 테스트 70+ (Developer 추정), Phase 3에서 Tester가 추가 보강
- 위젯 테스트 4 + 2 + ... ≈ 10
- 통합 테스트 5
- 0 lint warnings

이후 super-develop의 Phase 3 (Tester) → Phase 4 (gstack QA, 모바일이라 통합 테스트로 대체 가능) → Phase 5 (테스트 케이스 노출) → Phase 6 (Evaluator)로 자동 전환.

---

## Self-Review Notes

**Spec coverage:**
- §3 화면 정의 → Task 10/11/12/13/14/16
- §4 키패드 사양 (레이아웃/동작/% 규칙) → Task 5/9
- §5 도메인 모델 → Task 1
- §6 폴더 구조 → 모든 task
- §8 데이터 흐름 → Task 7 (pull 패턴)
- §9 l10n → Task 13
- §10 에러 처리 → Task 5 (hasError), Task 10 (errorLabel)
- §12 테스트 전략 → 각 task의 step 1
- §13 영향 매트릭스 → Task 17 (제거), Task 7/15/16 (수정)
- §15 위험 — 시스템 키보드 충돌 → TextField 미사용 (Task 9 GridView), 부동소수점 → `_formatResultForExpression` 라운딩 (Task 5)

**Placeholder scan:** Task 16의 `_calcProviderImport` 부분은 "implementation note"로 명시적 가이드라인이 있음 — 실제 빌드 전 정리 요구. 다른 placeholder 없음.

**Type consistency:**
- `CalculatorState.expression` (String) ✓
- `CalculatorState.result` (double?) ✓
- `Operator.symbol/asciiSymbol` ✓
- `applyKey(CalculatorState, CalculatorKey)` ✓ Task 5에서 정의, Task 6에서 사용
- `setExpression(double)` ✓ Task 6에서 정의, Task 15에서 사용
- `KeyKind` enum 4가지 ✓ Task 8/9에서 일치
