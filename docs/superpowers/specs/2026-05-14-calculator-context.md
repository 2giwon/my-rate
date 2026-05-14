# Brownfield Context Scan — Calculator integration (v1.1)

**작성일**: 2026-05-14
**대응 spec**: `docs/superpowers/specs/2026-05-14-calculator-design.md`
**스캔 방법**: `grep -rn --include='*.dart'` on `lib/`, `test/`, `integration_test/`, `lib/core/l10n/*.arb`

---

## 1. 추출 키워드

| 카테고리 | 키워드 |
|---|---|
| 도메인 명사 | 계산기, 식, 표현식, 계산 결과, 환율, From/To 통화 |
| 도메인 모델 | `CalculatorState`, `CalculatorKey`, `Operator`, `ConverterState`, `TipTaxMode`, `ExchangeRateSnapshot` |
| 신규 위젯 | `CalculatorKeypad`, `KeyButton`, `ExpressionDisplay`, `ConvertedDisplay`, `DirectRateInline`, `TipTaxMenuButton` |
| 제거 위젯 | `AmountInput`, `CurrencyCardStack`, `DirectRateLabel`, `TipTaxSegment` |
| 유지(컨테이너 수정) 위젯 | `TipPanel`, `TaxPanel`, `DiscountPanel` (BottomSheet 안에서 동작하도록 padding/scroll 조정) |
| 상태관리 | `CalculatorNotifier` (신규), `ConverterNotifier` (유지, 호출처 변경), `TipTaxNotifier` (유지, 호출처 변경) |
| 핵심 API | `ConverterNotifier.setAmount`, `TipTaxNotifier.recomputeForAmount` |
| 순수 로직 | `tokenizer`, `parser`, `evaluator`, `expression_builder`, `percent_resolver` (모두 신규) |
| 재사용 후보 | `ThousandsSeparatorInputFormatter`, `CurrencyFormatter.parse/format` |
| l10n 키 | `appTitle`, `lastUpdatedPrefix`, `offlineBanner`, `convertedDirectRateLabel`, `tipTax{None,Tip,Tax,Discount}`, `refreshButton`, `appBarRateLabel`(신규), `appBarTimestamp`(신규), `calcError`(신규), `calcMenu*`(신규), `panelBaseAmount`(신규), `panelApplyButton`(신규) |

---

## 2. 영향 파일 매트릭스

### 2.1 위젯 — 제거

| 파일 | 영향 종류 | 사용처 (grep 검증) | 수정 |
|---|---|---|---|
| `lib/features/converter/view/widgets/amount_input.dart` | 위젯 + `ThousandsSeparatorInputFormatter` 클래스 | 직접 import: 없음. **내부 클래스 `ThousandsSeparatorInputFormatter`는 `currency_card_stack.dart`에서 `show` 절로 재export** | ✅ 제거 (단, `ThousandsSeparatorInputFormatter`는 더 이상 필요 없음 — 계산기는 TextField를 쓰지 않음) |
| `lib/features/converter/view/widgets/currency_card_stack.dart` | 위젯 + 내부 TextField | `converter_screen.dart:82` (1곳) | ✅ 제거 → `ExpressionDisplay` + `ConvertedDisplay`로 분할 대체 |
| `lib/features/converter/view/widgets/direct_rate_label.dart` | 위젯 | `converter_screen.dart:101` (1곳) | ✅ 제거 → `DirectRateInline`(AppBar)으로 대체 |
| `lib/features/converter/view/widgets/tip_tax_segment.dart` | 위젯 | `converter_screen.dart:116` (1곳) | ✅ 제거 → `TipTaxMenuButton`(AppBar 🧮)으로 대체 |

> 모든 제거 위젯은 `converter_screen.dart` **단일 호출처**에만 의존. 외부 영향 없음.

### 2.2 위젯 — 신규

| 파일 | 책임 |
|---|---|
| `lib/features/converter/view/widgets/direct_rate_inline.dart` | AppBar title 영역의 환율 + 갱신 시각. `FittedBox(fit: BoxFit.scaleDown)` 적용 |
| `lib/features/converter/view/widgets/tip_tax_menu_button.dart` | AppBar 액션 🧮 — 탭 시 `showModalBottomSheet`로 메뉴 → 항목 탭 시 해당 panel 시트 노출 |
| `lib/features/converter/view/widgets/expression_display.dart` | From 카드 — 통화 헤더 + 입력 식(작게/축소/스크롤) + ⌫ 아이콘 + 결과(굵게/크게) |
| `lib/features/converter/view/widgets/converted_display.dart` | To 카드 — 통화 헤더 + 변환 결과(read-only) |
| `lib/features/calculator/view/widgets/calculator_keypad.dart` | 5×4 grid `GridView.count` 또는 `Column<Row>`. 키 누름 → `CalculatorNotifier.onKey(key)` |
| `lib/features/calculator/view/widgets/key_button.dart` | 개별 키 (라벨 + 색상 분류: 숫자/연산자/=/편집). `InkWell` + 햅틱 피드백 |

### 2.3 위젯 — 유지하되 컨테이너 수정

| 파일 | 영향 | 수정 |
|---|---|---|
| `lib/features/converter/view/widgets/panels/tip_panel.dart` | BottomSheet 안에서 표시. 기존엔 인라인 expand 영역 | ⚠️ 외부 padding 제거, `SingleChildScrollView` 래핑, "적용" 버튼 추가 (CalculatorNotifier.setExpression 호출) |
| `lib/features/converter/view/widgets/panels/tax_panel.dart` | 동일 | ⚠️ 동일 |
| `lib/features/converter/view/widgets/panels/discount_panel.dart` | 동일 | ⚠️ 동일 |

### 2.4 화면 / 라우팅

| 파일 | 수정 |
|---|---|
| `lib/features/converter/view/converter_screen.dart` | 대폭 수정 — AppBar 재구성, body 위젯 트리 재작성, panel 진입 로직 BottomSheet로 |
| `lib/core/routing/app_router.dart` | 변경 없음 — 모달 BottomSheet는 라우트 추가 불필요 |
| `lib/app.dart` | 변경 없음 |
| `lib/main.dart` | 변경 없음 |

### 2.5 도메인 / 상태관리

| 파일 | 영향 | 수정 |
|---|---|---|
| `lib/domain/calculator/models.dart` | **신규** — `CalculatorState`(freezed), `CalculatorKey` sealed hierarchy, `Operator` enum | ✅ 신규 |
| `lib/domain/exchange_rate/models.dart` | `TipTaxMode` enum 그대로. 의미는 BottomSheet 메뉴 라벨 키로 재사용 | ✓ 변경 없음 |
| `lib/features/calculator/providers/calculator_notifier.dart` (+ `.g.dart`) | **신규** — `@riverpod class CalculatorNotifier` | ✅ 신규 (build_runner) |
| `lib/features/converter/providers/converter_notifier.dart` | `setAmount(double)` API 유지. ConverterScreen의 호출자는 사라지고 CalculatorNotifier가 호출 | ⚠️ ConverterScreen에서의 호출 제거 (CalculatorNotifier로 이관) |
| `lib/features/converter/providers/tip_tax_notifier.dart` | `recomputeForAmount(double)` API 유지. BottomSheet 모달에서 호출 | ⚠️ 호출 시점만 변경, API 유지 |

### 2.6 순수 로직 (신규, `lib/features/calculator/logic/`)

| 파일 | 책임 |
|---|---|
| `tokenizer.dart` | 식 문자열(평가용) → `List<Token>` (Number/Operator/ParenOpen/ParenClose/Percent) |
| `parser.dart` | 토큰 리스트 → AST. 우선순위(`×÷ > +−`), 괄호 처리, 닫지 않은 괄호 자동 보정 |
| `evaluator.dart` | AST → `double` 또는 `EvalError`(divisionByZero / overflow / invalidSyntax) |
| `expression_builder.dart` | 키 입력 + 직전 `CalculatorState` → 새 `CalculatorState`. 표시용/평가용 식 동기 빌드 |
| `percent_resolver.dart` | `%` 토큰을 좌항 컨텍스트 기준으로 사전 변환 (iOS 스타일, design.md §4.4) |

### 2.7 l10n

| 파일 | 영향 | 수정 |
|---|---|---|
| `lib/core/l10n/app_en.arb` | 신규 키 9개 (design.md §9). 기존 `tipTax{None,Tip,Tax,Discount}`는 BottomSheet 메뉴 라벨로 **재사용** 가능 (label만 일치하면 의미 통함) | ✅ 추가 |
| `lib/core/l10n/app_ko.arb` | 동일 | ✅ 추가 |
| `lib/core/l10n/generated/*.dart` | build 시 자동 재생성 (gitignored) | ⚙️ 자동 |

### 2.8 테스트

| 파일 | 영향 | 수정 |
|---|---|---|
| `test/features/converter/view/widgets/amount_input_test.dart` | `AmountInput` 제거에 따라 | ✅ 제거 |
| `test/features/converter/view/adaptive_rate_decimals_test.dart` | `_adaptiveRateDecimals` 로직은 `DirectRateInline`에서 재사용 — 단순 import 경로 조정 | ⚠️ import 라인 검토 |
| `test/features/converter/providers/converter_notifier_test.dart` | `setAmount` API 유지 — 테스트 그대로 통과해야 함 | ✓ 유지 |
| `test/features/converter/providers/tip_tax_notifier_test.dart` | `recomputeForAmount` API 유지 | ✓ 유지 |
| `test/tester_additions_test.dart` | AppDefaults / spec 5/16 contract — 변경 없음 | ✓ 유지 |
| `test/core/utils/currency_formatter_test.dart` | 변경 없음 | ✓ 유지 |
| `test/data/**` | 변경 없음 (data layer 영향 없음) | ✓ 유지 |
| `integration_test/app_test.dart` | 화면 구조 변경 — `expect(find.text('KRW'), findsWidgets)` 같은 셀렉터 수정 | ⚠️ 수정 |
| **신규 테스트 폴더** `test/domain/calculator/`, `test/features/calculator/{logic,providers,view}/` | 신규 | ✅ 신규 |
| `integration_test/calculator_e2e_test.dart` | 신규 | ✅ 신규 |

---

## 3. FK 영향 분석

**N/A** — 모바일 클라이언트 단일 앱. 백엔드/DB 없음. 환율 데이터는 외부 API(ExchangeRate-API) + SharedPreferences 캐시이며 신규 변경 없음.

---

## 4. 공통 컴포넌트 consumer 분석

제거 대상 4개 위젯 모두 **`converter_screen.dart` 단일 호출처**에서만 사용.

| 위젯 | 호출처 | 비고 |
|---|---|---|
| `CurrencyCardStack` | `converter_screen.dart:82` | 1곳 |
| `DirectRateLabel` | `converter_screen.dart:101` | 1곳 |
| `TipTaxSegment` | `converter_screen.dart:116` | 1곳 |
| `AmountInput` | (외부 호출 없음, `CurrencyCardStack`이 `ThousandsSeparatorInputFormatter`만 `show` 절로 import) | — |

→ 영향 전파 범위가 좁고, API 응답 구조 등 외부 의존성 없음.

---

## 5. 동일 진입점 / 같은 호출 패턴

`setAmount`/`recomputeForAmount` 호출 패턴:

| 호출처 | 현재 코드 | 변경 후 |
|---|---|---|
| `converter_screen.dart:88` | `ref.read(converterNotifierProvider.notifier).setAmount(v)` | **제거** — `CalculatorNotifier.onKey()`가 결과 변화 시 자동 호출 |
| `converter_screen.dart:89` | `ref.read(tipTaxNotifierProvider.notifier).recomputeForAmount(v)` | **제거** — 팁/세금/할인 BottomSheet 진입 시 + "적용" 시 호출 |

테스트는 API 단위로 호출 검증되므로 그대로 통과.

---

## 6. 다국어 키 활용 계획

| 기존 키 | 활용 방식 |
|---|---|
| `appTitle` | AppBar 환율 영역이 잡지 못할 때(예: snapshot null) 폴백으로 표시 |
| `lastUpdatedPrefix` | AppBar 두 번째 줄 "{ts} 기준"에서 사용 |
| `offlineBanner` | AppBar 아래 배너에 그대로 |
| `convertedDirectRateLabel` | AppBar의 `DirectRateInline`에서 `"1 {from} = {value} {to}"` 포맷에 재사용 |
| `tipTaxNone` | **사용 안 함** (BottomSheet 메뉴에서는 "없음" 항목 없음). 키 자체는 남겨두되 미사용 — 제거하면 v1.0 스냅샷 테스트 회귀 우려 → 유지 |
| `tipTaxTip` / `tipTaxTax` / `tipTaxDiscount` | BottomSheet 메뉴 라벨에 재사용 가능. 또는 신규 `calcMenu*` 키로 분리 — **plan 단계에서 결정** |
| `refreshButton` | AppBar 🔄 아이콘 툴팁/접근성 라벨에 그대로 |

---

## 7. 미확인 영역 / 가설

| 항목 | 상태 | 처리 |
|---|---|---|
| `CalculatorNotifier` ↔ `ConverterNotifier` 동기화 패턴 (push vs pull) | **plan에서 결정** | spec §5 메모: "둘 중 어느 패턴이 깔끔한지는 writing-plans에서 결정 (생산자→소비자 방향이 단순하므로 후자 가설)" |
| BottomSheet 안에서 `TipPanel` 등이 시스템 키보드 올라올 때 레이아웃 | **plan에서 처리** | `isScrollControlled: true` + `Padding(MediaQuery.viewInsets.bottom)` |
| 키패드 작은 단말 최소 키 크기 | **plan에서 처리** | spec §15 위험 항목 — `AspectRatio` 또는 동적 sizing 검토 |
| 햅틱 피드백 강도 | spec 미정의 | plan에서 `HapticFeedback.selectionClick()` 기본값으로 |
| 키 입력 시 사운드 | 비목표 | 추가하지 않음 |
| 식의 음수 첫 항(예: `-5 + 3`) 허용 여부 | spec §4.3에 "빈 식의 `+ −`는 무시"로 명시 | 음수는 괄호+0으로 우회(`(0-5) + 3`). 추가 지원 없음 |

---

## 8. Context Score: **0.92**

### 근거

- 모든 제거 대상 위젯은 단일 화면(`ConverterScreen`)에만 의존 → 영향 범위 명확
- 도메인/데이터 레이어 변경 없음 → 회귀 위험 낮음
- 핵심 API(`setAmount`/`recomputeForAmount`) 유지 → 기존 단위 테스트 통과 보장
- l10n 키 추가/재사용 정책 명확
- FK/DB 없음 → 라이브 장애 위험 없음
- 미확인 7건 모두 plan 단계에서 결정 가능한 디테일

### 점수가 1.0이 아닌 이유

- 일부 디테일(동기화 방향, 키 사이즈, 햅틱)이 spec에서 의도적으로 plan으로 이관됨
- 통합 테스트 스크립트의 셀렉터 수정 분량은 코드 작성 단계에서 정확히 파악
