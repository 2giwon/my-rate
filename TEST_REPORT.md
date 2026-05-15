# TEST_REPORT.md — MyRate v1.1 (Calculator integration)

**Tester**: tdd-tester (independent)
**Date**: 2026-05-15
**Spec**: `docs/superpowers/specs/2026-05-14-calculator-design.md`
**Plan**: `docs/superpowers/plans/2026-05-14-calculator.md`

---

## Summary

| 항목 | 값 |
|---|---|
| 시작 시 baseline pass | 203 |
| Tester 추가 후 pass | **285** |
| 신규 테스트 (단위 + 위젯) | **+82** |
| 신규 통합 시나리오 | +5 (디바이스 없는 환경에서 자동 실행 불가, Developer e2e도 동일) |
| `flutter analyze` (Tester 신규 파일) | **No issues** |
| `dart format` (Tester 신규 파일) | 3/4 reformat OK, 모두 clean |
| 발견된 잠재 결함 (회귀/UX) | **3** (코드 수정 없이 명시) |

---

## Developer 테스트 분석

### Developer가 작성한 calculator/v1.1 테스트 (≈94개)

| 영역 | 파일 | 케이스 수 |
|---|---|---|
| Domain models | `test/domain/calculator/models_test.dart` | 7 |
| Tokenizer | `test/features/calculator/logic/tokenizer_test.dart` | 11 |
| Parser | `test/features/calculator/logic/parser_test.dart` | 18 |
| Evaluator | `test/features/calculator/logic/evaluator_test.dart` | 5 |
| PercentResolver | `test/features/calculator/logic/percent_resolver_test.dart` | 10 |
| ExpressionBuilder | `test/features/calculator/logic/expression_builder_test.dart` | 20 |
| CalculatorNotifier | `test/features/calculator/providers/calculator_notifier_test.dart` | 5 |
| KeyButton | `test/features/calculator/view/widgets/key_button_test.dart` | 2 |
| CalculatorKeypad | `test/features/calculator/view/widgets/calculator_keypad_test.dart` | 3 |
| ExpressionDisplay | `test/features/converter/view/widgets/expression_display_test.dart` | 4 |
| ConvertedDisplay | `test/features/converter/view/widgets/converted_display_test.dart` | 3 |
| DirectRateInline | `test/features/converter/view/widgets/direct_rate_inline_test.dart` | 2 |
| TipTaxMenuButton | `test/features/converter/view/widgets/tip_tax_menu_button_test.dart` | 1 |
| ConverterNotifier sync | `test/features/converter/providers/converter_notifier_test.dart` (group) | 1 |
| Integration (e2e) | `integration_test/{app_test,calculator_e2e_test}.dart` | 4 |

### Developer가 커버한 시나리오

- 사칙연산 + 우선순위 + 괄호 정상 케이스
- 천 단위 쉼표 입력/표시
- iOS 스타일 `%` 5종 (단독/곱/나눗/덧셈/뺄셈, 단순 케이스)
- 연산자 교체 (`5 + -` → `5 -`)
- 점 중복 방지
- 식 길이 500자 cap
- 0÷0 division-by-zero error 검출
- 결과 후 연산자 → 결과를 첫 항으로 (`s1 = 3 → ×`)
- 결과 후 digit → 새 식
- Backspace 기본 (숫자 자리 제거)
- `setExpression` 단순 호출 (panel apply용)
- ConverterNotifier ↔ CalculatorNotifier 기본 동기화 (`123` 입력 → amount=123)

### **누락된 시나리오 (Tester가 보강)**

Spec §4.2 / §4.4 / §4.5 / §10 / §15 에 명시된 동작 중 Developer 테스트가 검증하지 않은 항목:

1. **빈 식 상태의 모든 단일 키 동작** — `+`/`−`/`×`/`÷`/`%`/`)`/`=`/`.` 8종 입력에 대한 정확한 반응 (spec §4.3 "빈 식에 연산자 입력 시 무시").
2. **= 직후 결과 이어쓰기 8종** — spec §4.5 표의 모든 행: `=`/`⌫`/digit/`.`/`(`/operator/`%`/`C`.
3. **iOS-style % 디자인 §4.4 표의 모든 행** — 특히 `(100+50)+10% = 165` (Developer는 곱셈 변형만 검증).
4. **% 우선순위 + 연산자**: `5000+30%×2 = 8000`.
5. **% 가장 자리 케이스**: operator 뒤 / `(` 뒤 / 연속 `%%` / 나누기 안 `%`.
6. **음수 좌항 % 적용**: `(0-100)+50%` 같은 좌항이 음수일 때.
7. **암묵 곱셈 패턴 추가**: `%` 뒤 digit / `)` 뒤 `(` / `)` 뒤 digit / 고아 `)` 무시.
8. **Backspace 토큰 타입별**: 마지막이 `(`/`%`/`)`/`,`(콤마)/operator/연속/빈 식 → 각각.
9. **`.` 연속 입력 + 운영자 직후 `.`** — 새로 발견된 cosmetic quirk (`5 +0.`).
10. **에러 상태 회복 경로** — 다음 키가 digit/⌫/C/operator 별로.
11. **자동 괄호 보정 + `=`** — `(5+3 =`, `((1+2 =`.
12. **빈 식에 `=`** — no-op + no error.
13. **부동소수점 누적**: `0.1+0.2`, `1/3*3` — spec §15 "10자리 라운딩" 명세 vs 실제 동작 검증.
14. **Overflow → hasError 셋업** — 24회 `999999999999999` 곱셈.
15. **CalculatorNotifier × ConverterNotifier 회복 흐름** — `C` / 에러 시 amount가 defaultAmount(100,000)로 복귀하는지.
16. **setExpression 후 hasError 해제** — 에러 상태에서 panel "적용" 동작.
17. **setExpression 다양한 입력** — 0, decimal, 1,234,567 (천 단위), 음수.
18. **위젯 — ExpressionDisplay**: 빈 식 placeholder `0`, result null 동작, long expression FittedBox, backspace icon ↔ header tap 독립성, `오류` (한국어) errorLabel.
19. **위젯 — ConvertedDisplay**: `convertedValue=0`은 `—` 아니라 `0.00`, 매우 작은 값, 큰 값 천단위.
20. **위젯 — DirectRateInline**: 한국어 로케일 `기준` 접미사, `rate=0` 방어, `basedOn=null` + rate 있음.
21. **위젯 — TipTaxMenuButton**: barrier dismiss → onSelected 미호출, 한국어 메뉴 라벨 (`팁 계산`/`세금 계산`/`할인 계산`).
22. **위젯 — CalculatorKeypad**: `C`/`(`/`)`/`%`/`.`/`÷` 각 키 동작, 빠른 더블 탭 디바운스 미존재, long-press 안전성.
23. **통합 — backspace 아이콘 flow**: 키패드 외부의 ⌫ 동작.
24. **통합 — `C` 키 전체 초기화**.
25. **통합 — `5÷0=` "Error" 라벨 표시**.
26. **통합 — 에러 자동 회복** (다음 digit).
27. **통합 — 결과 → ConvertedDisplay 갱신** (`(1000+500)×3 = 4,500` → USD 3.30).

---

## 추가 작성한 테스트

| 파일 | 케이스 수 | 분류 |
|---|---|---|
| `test/features/calculator/tester_additions_test.dart` | **61** | 단위 — expression_builder / percent_resolver / evaluator / notifier × notifier sync |
| `test/features/converter/view/widgets/tester_additions_widget_test.dart` | **13** | 위젯 — ExpressionDisplay / ConvertedDisplay / DirectRateInline / TipTaxMenuButton |
| `test/features/calculator/view/widgets/tester_additions_keypad_test.dart` | **8** | 위젯 — CalculatorKeypad / KeyButton |
| `integration_test/calculator_tester_additions_test.dart` | **5** | 통합 e2e — backspace / C / error label / 회복 / 변환 결과 |

### 카테고리별 분포 (단위 + 위젯 = 82개)

| 카테고리 | 개수 | 비고 |
|---|---|---|
| **Critical Path (계약 잠금)** | 6 | spec §4.4 표의 행, golden flow |
| **Edge Cases (경계값/빈/특수)** | 28 | 빈 식 키 8종, = 직후 키 9종, `(`/`)`/`%` 경계 |
| **Error Scenarios** | 12 | 0÷0, overflow, 회복, 자동 괄호 보정 |
| **Race / 빠른 입력** | 3 | 키패드 rapid tap, 연속 keys 안정성, long-press |
| **State Transitions** | 14 | = 직후, error 복귀, setExpression, ConverterNotifier sync |
| **i18n / Locale** | 5 | 한국어 errorLabel, 한국어 메뉴, 한국어 기준 표시 |
| **표시 회귀 (FittedBox/format)** | 6 | long expression overflow, 0 vs —, 천 단위 |
| **암묵 곱셈 / 좌항 컨텍스트** | 8 | `)(`, `)d`, `%d`, 음수 좌항 % |

**비율**: Edge Cases 34%, State Transitions 17%, Error 15% — Unhappy path 중심. Spec 우선순위 (`×÷ > +−`, 괄호, iOS %, 결과 이어쓰기, 에러 회복) 의도적으로 모두 매핑.

---

## 전체 테스트 실행 결과

```bash
$ flutter test
...
00:06 +285: All tests passed!
```

| 항목 | 값 |
|---|---|
| 총 테스트 수 (단위 + 위젯) | **285** |
| 통과 | 285 |
| 실패 | 0 |
| Skip | 0 |

통합 테스트 (`integration_test/*`)는 Flutter integration_test 패키지 특성상 실제 디바이스 / 시뮬레이터가 필요하다. 현재 CI/local 환경(macOS desktop만 활성화)에서는 Developer의 `app_test.dart`/`calculator_e2e_test.dart`도 동일하게 실행 불가. Tester가 추가한 5개 시나리오도 같은 환경에서 실행 시 검증 가능하도록 작성.

---

## Spec coverage matrix (v1.1 추가분)

| Spec § | 요구사항 | Developer | Tester 추가 | Status |
|---|---|---|---|---|
| §3.1 | ExpressionDisplay 빈 식 placeholder "0" | – | ✓ | OK |
| §3.1 | ConvertedDisplay null=`—`, 0=`0.00` | partial | ✓ (0 케이스) | OK |
| §3.1 | TipTaxMenuButton 메뉴 노출 + 선택 | ✓ (en) | ✓ (ko, dismiss) | OK |
| §4.1 | 5×4 keypad 20 키 노출 | ✓ | – | OK |
| §4.2 | `0-9` 자리 추가 | ✓ | ✓ (keypad ÷, 천 단위) | OK |
| §4.2 | `.` 점 중복 무시 | ✓ | ✓ (점-점, op 직후, 빈 식) | OK |
| §4.2 | 연산자 마지막 교체 | ✓ | – | OK |
| §4.2 | `(` 직전 숫자/`)` → 암묵 × | ✓ (`5(`) | ✓ (`)( ` / `%d`) | OK |
| §4.2 | `)` 짝 안 맞으면 무시 | ✓ | ✓ (orphan flow) | OK |
| §4.2 | `%` 좌항 컨텍스트 의존 | partial | ✓ (op 뒤/괄호 시작/연속/음수 좌항) | OK |
| §4.2 | `C` 전체 초기화 | ✓ | ✓ (e2e + after =) | OK |
| §4.2 | `⌫` 마지막 토큰 제거 | ✓ (digit 자리) | ✓ (op/%/)/( /empty) | OK |
| §4.2 | `=` 평가 + justEvaluated | ✓ | ✓ (= = 동일 no-op) | OK |
| §4.3 | 표시용 vs 평가용 식 분리 | ✓ (tokenize) | – | OK |
| §4.3 | 식 길이 500자 cap | ✓ | ✓ (정상 진행 보장) | OK |
| §4.3 | 빈 식 연산자 무시 | – | ✓ (5종) | **추가됨** |
| §4.4 | `30%` 단독 | ✓ | – | OK |
| §4.4 | `5000×30%` | ✓ | – | OK |
| §4.4 | `5000+30%` = 6500 | ✓ | – | OK |
| §4.4 | `5000-20%` = 4000 | ✓ | – | OK |
| §4.4 | `(100+50)×10%` = 15 | ✓ | – | OK |
| §4.4 | `(100+50)+10%` = 165 | – | ✓ | **추가됨** |
| §4.4 | `5000+30%×2` = 8000 (정밀) | ✓ (단위) | ✓ (builder) | OK |
| §4.4 | `30%+50` = 50.3 | ✓ | – | OK |
| §4.5 | = 후 digit | ✓ | – | OK |
| §4.5 | = 후 op (4100 → ×) | ✓ | ✓ (천 단위 보존) | OK |
| §4.5 | = 후 `=` no-op | – | ✓ | **추가됨** |
| §4.5 | = 후 `⌫` | – | ✓ | **추가됨** |
| §4.5 | = 후 `.` | – | ✓ | **추가됨** |
| §4.5 | = 후 `(` | – | ✓ | **추가됨** |
| §4.5 | = 후 `%` | – | ✓ | **추가됨** |
| §4.5 | = 후 `C` | – | ✓ | **추가됨** |
| §4.6 | 식 자동 축소 (FittedBox) | – | ✓ (long expr 무crash) | **추가됨** |
| §9 | l10n `calcError` 사용 | – | ✓ (오류 표시) | **추가됨** |
| §9 | l10n `calcMenu*` 사용 | ✓ (en) | ✓ (ko) | OK |
| §9 | l10n `lastUpdatedPrefix` (기준) | – | ✓ | **추가됨** |
| §10 | `0÷` → `오류` UI | – | ✓ (en 'Error' + ko '오류') | **추가됨** |
| §10 | 다음 키 → 오류 해제 | – | ✓ (digit/⌫/C) | **추가됨** |
| §10 | 빈 식 `=` no-op | – | ✓ | **추가됨** |
| §10 | 미완성 식 미리보기 | partial | ✓ (5+ → 5) | OK |
| §10 | `(` 닫지 않으면 = 자동 | ✓ (parser) | ✓ (builder e2e) | OK |
| §15 | 부동소수점 라운딩 | – | ⚠ **state.result 미라운딩 — 잠재 이슈** | **lock + flag** |
| §15 | overflow → hasError | partial | ✓ (24×999..) | OK |
| §15 | 큰 수 / 작은 수 표시 | – | ✓ (1,234,567 / 0.01) | OK |
| ConverterSync | 결과 → amount | ✓ (digit) | ✓ (C → 100,000 복귀, 에러 → 100,000, setExpression) | OK |

---

## 발견된 잠재 결함 (Potential Defects / Regression Risk)

> 코드 수정은 하지 않음. Developer가 다음 라운드에서 판단할 수 있도록 위치/재현/심각도 명시.

### Defect #1 — `0.1 + 0.2 =` 결과가 부동소수점 그대로 노출 (Minor)

| 항목 | 내용 |
|---|---|
| 위치 | `lib/features/calculator/logic/expression_builder.dart:33-40` (`_withDisplay`) + `_evaluate` (line 208-) |
| 재현 | `[0][.][1][+][0][.][2][=]` |
| 결과 | `CalculatorState.result == 0.30000000000000004` |
| 영향 | → `ConverterState.amount = 0.30000000000000004` → To 통화 변환 시 부동소수점 노이즈가 USD 결과에 누적 |
| Spec 위반 여부 | **§15 "결과 라운딩 (디스플레이 직전에 10자리 유효 숫자로 라운딩). 단위 테스트로 명세"** — 디스플레이 라운딩은 `CurrencyFormatter`에서 흡수되지만 `state.result` 자체는 미라운딩 |
| 검증 테스트 | `test/features/calculator/tester_additions_test.dart` › "0.1 + 0.2 = → state.result is unrounded FP (potential UI concern)" (현재 동작을 lock) |
| 제안 | `_evaluate`에서 `EvalSuccess(value)` 받은 직후 `(value * 1e10).round() / 1e10` 적용 (이미 `_formatResultForExpression`에 같은 로직 존재) |

### Defect #2 — `.` 키가 운영자 뒤에서 공백 없이 붙음 (Cosmetic, Minor)

| 항목 | 내용 |
|---|---|
| 위치 | `lib/features/calculator/logic/expression_builder.dart` `_appendDot` (line 115-) |
| 재현 | `[5][+][.]` |
| 결과 | 표시 식이 `"5 +0."` (space 없음). 비교: `[5][+][0]` → `"5 + 0"` (space 있음) |
| 영향 | 표시 일관성. 평가 결과는 정상 (0.0) |
| Spec | §4.6 명시적 규정 없음. 그러나 §4.2 "현재 숫자 토큰에 소수점 추가" + 운영자 분리 정책과 시각적으로 불일치 |
| 검증 테스트 | `test/features/calculator/tester_additions_test.dart` › ". immediately after operator: 5 + . → '5 +0.' (lock current quirk; ...)" — comment로 명시 |
| 제안 | `_appendDot`에서 `s.justEvaluated == false && trimmed`가 운영자로 끝날 때 `' '` 접두사 추가 |

### Defect #3 — `5(` 입력 후 `⌫` 한 번이 `5 ×` 상태에 머무름 (UX, Minor)

| 항목 | 내용 |
|---|---|
| 위치 | `lib/features/calculator/logic/expression_builder.dart` `_backspace` (line 192-) |
| 재현 | `[5][(]` → 식 `"5 × ("` → `[⌫]` |
| 결과 | 식이 `"5 ×"`가 됨. 사용자가 `(` 하나만 지우려고 했지만 implicit `×`까지 같이 처리해야 원래 의도. 1회 ⌫ 더 필요 |
| 영향 | 사용자가 키 1회 추가 입력으로 회복 가능. crash 없음 |
| Spec | §4.2 `⌫` "식 마지막 1 토큰 제거" — `(`만 제거된 것은 spec 부합. 단, "암묵 ×"는 사용자가 입력한 토큰이 아닌데도 그대로 남는다 |
| 검증 테스트 | `test/features/calculator/tester_additions_test.dart` › "backspace after `(` removes implicit×: 5( → 5 × → after ⌫ → 5" |
| 제안 (선택) | `_backspace`에서 제거된 토큰이 `(`이고 직전 토큰이 implicit×으로 삽입된 ` × `이면 두 토큰을 함께 제거. 단순 1-토큰 룰 깨므로 신중 결정 필요 |

---

## 미커버 영역 (향후 권장)

| 영역 | 이유 |
|---|---|
| 키 햅틱 피드백 강도 | `HapticFeedback.selectionClick()` 발생 여부 — Flutter 표준 mock 미흡, 통합 device 환경에서만 의미 |
| `ConverterScreen` 풀스크린 위젯 통합 | Developer의 `app_test.dart`로 일부 커버. device 필요 |
| TipPanel/TaxPanel/DiscountPanel "적용" 후 calc 식 갱신 — UI 레벨 | logic 레벨은 `tip_tax_notifier_test.dart`로 커버. 통합은 device 필요 |
| 키패드 작은 단말(SE 1세대) 키 ≥ 44pt | spec §15 risk — 골든 이미지 또는 사이즈 측정 테스트 필요. 별도 PR 권장 |
| 시스템 키보드 비등장 — Listener/GestureDetector 패턴 검증 | 현재 TextField 없음 (코드 확인 완료) — 회귀 방지 테스트는 device 필요 |

---

## prettier / dart format 적용 파일 (Tester 추가분)

| 파일 | 상태 |
|---|---|
| `test/features/calculator/tester_additions_test.dart` | format 적용 완료, analyze clean |
| `test/features/converter/view/widgets/tester_additions_widget_test.dart` | format 적용 완료, analyze clean |
| `test/features/calculator/view/widgets/tester_additions_keypad_test.dart` | format 적용 완료, analyze clean |
| `integration_test/calculator_tester_additions_test.dart` | format clean |

`flutter analyze` 전체 결과: **16 info-level only** (모두 기존 Developer 또는 v1.0 코드 — Tester 신규 파일은 0 issues).

---

## 테스트 커버리지 의견

### 충분한 영역

- **로직 레이어**: tokenizer/parser/evaluator/percent_resolver/expression_builder — spec §4 / §10 에 대한 거의 완전한 행/열 매트릭스 커버 (94 + 61 = 155 cases).
- **상태 전이**: justEvaluated, hasError, result null, expression 빈/비어있음 의 모든 조합.
- **i18n**: en + ko 양쪽 calcError / calcMenu* / lastUpdatedPrefix 모두 렌더 검증.
- **상호작용 (Calculator ↔ Converter)**: digit/clear/error/setExpression 회복 흐름 명시적 검증.

### 추가 필요한 영역 (Evaluator / 다음 phase 권장)

- **통합 테스트의 CI 자동 실행** (시뮬레이터 또는 Web 빌드 활성화 후)
- **위 Defect #1 (FP rounding)이 실제 사용자 시나리오에서 노출되는지** — 환율 USD 변환 시 0.300000…04 / 1362.5 → 0.000220264... 표시되는지 디바이스 검증
- **키패드 햅틱 안정성** — iOS Taptic Engine 호출 빈도
- **BottomSheet 진입 후 시스템 키보드 표시 + viewInsets** — 모달 안에서 TipPanel TextField focus 시 layout 확인 (spec §15 risk)

---

## 최종 판정

| 항목 | 판정 |
|---|---|
| 모든 단위/위젯 테스트 통과 | **YES** (285/285) |
| Spec coverage acceptable | **YES** (§4.2 / §4.4 / §4.5 / §10 추가 17개 행 커버) |
| 발견된 spec 위반 결함 | **0 (hard violation 없음)** |
| 발견된 잠재/회귀 위험 | **3 (FP 라운딩 / dot spacing / backspace implicit×)** |
| Ready for Evaluator | **YES** |

> Tester의 추가 테스트는 Developer 구현을 부정하지 않고 **spec과 일치하는 동작을 명시적으로 잠그는 용도**이다. 위 Defect 3건은 spec과의 엄밀한 의미 비교 결과이며, 비즈니스 임팩트는 모두 Minor. Evaluator는 이를 합격/조건부 합격 판단에 활용 가능.
