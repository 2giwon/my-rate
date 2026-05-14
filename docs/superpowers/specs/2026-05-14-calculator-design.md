# MyRate 계산기 기능 추가 설계 문서

**작성일**: 2026-05-14
**버전**: v1.1 (Calculator integration)
**작성자**: brainstorming via /super-develop
**상태**: 사용자 검토 단계

---

## 1. 개요

### 1.1 배경

MyRate v1.0(2026-05-12)은 환율 변환 + 팁/세금/할인 보조 계산을 제공한다. 그러나 실제 사용 시나리오 — 여행/쇼핑 — 에서는 환율 변환 전에 **임시 산수**(`1,200 × 3 + 500`, `(15,000 + 5,000) × 4`)가 자주 필요하다. 현재는 시스템 키보드로 단일 숫자만 입력 가능하므로, 사용자가 외부 계산기 앱을 오가야 한다.

### 1.2 목표

환율 변환 화면 안에서 **사칙연산 + 괄호 + %** 계산이 가능하도록 인라인 계산기 키패드를 통합한다. 계산 결과는 곧바로 환율 변환의 입력 금액이 된다.

### 1.3 비목표

- 공학 계산(`√`, `x²`, `sin`, `log`)
- 메모리 키(`MC`/`M+`/`M-`/`MR`)
- 부호 변경 키(`+/-`) — 환율 금액은 양수 전제
- 히스토리(과거 식 보관) — 향후 확장
- 음성 입력
- 단위 변환(길이/무게 등) — 환율 외 범위

### 1.4 핵심 차별점

- **외부 계산기 앱 불필요** — 환율 변환 컨텍스트(통화/환율)를 잃지 않고 즉시 계산
- **광고 0개 · 추적 0개** 원칙 유지
- **모바일 한 손 사용** — 5행 4열 키패드, 시스템 키보드 비활성화

---

## 2. 사용자 플로우

```
[앱 실행]
   ↓
환율 캐시 확인 → 메인(ConverterScreen)
   ↓
AppBar: "1 USD = 1,362.50 KRW · 14:32 기준  🧮  🔄  ⚙"
From 카드(KRW): 식 입력란(작게) + 결과(굵게/크게)
To   카드(USD): 자동 환산 결과(read-only)
하단: 5행 4열 계산기 키패드 (상시 노출)
   ↓
사용자가 [1][,][2][0][0] [×] [3] [+] [5][0][0] [=] 탭
   ↓
From 결과 = 4,100 KRW, To = 4,100 × (1 USD / 1,362.50 KRW) = 약 3.01 USD
   ↓
선택적: AppBar 🧮 탭
   → BottomSheet 메뉴 [💰 팁 / 🧾 세금 / 🏷 할인]
   → 선택 시 모달 BottomSheet (기준 금액 = From 결과)
   → 모달 내에서 비율/금액 입력 → "적용" → From 결과를 모달 계산 합계로 갱신
```

---

## 3. 화면 정의

### 3.1 ConverterScreen (재설계)

```
┌────────────────────────────────────────┐
│ 1 USD = 1,362.50 KRW       🧮  🔄  ⚙ │  ← AppBar (직접환율 + 액션 3개)
│ 14:32 기준                              │
├────────────────────────────────────────┤  ← ⚠ 오프라인 배너 (조건부)
│  🇰🇷 KRW · 원                    ⌄    │  ← From 통화 (얇은 카드)
│  ─────────────────────────────         │
│  1,200 × 3 + 500           ⌫           │  ← 입력 식 (작은 글씨, 자동 축소)
│                                        │
│  4,100                                 │  ← 결과 (굵게, 크게, 강조)
├────────────────────────────────────────┤
│                ⇅                       │  ← swap 버튼
├────────────────────────────────────────┤
│  🇺🇸 USD · 미국 달러              ⌄    │  ← To 통화 (얇은 카드, 변환 결과만)
│  3.01                                  │
├────────────────────────────────────────┤
│  [ C ]  [ ( ]  [ ) ]  [ ÷ ]            │  ← 계산기 키패드 (5행 4열, 상시)
│  [ 7 ]  [ 8 ]  [ 9 ]  [ × ]            │
│  [ 4 ]  [ 5 ]  [ 6 ]  [ − ]            │
│  [ 1 ]  [ 2 ]  [ 3 ]  [ + ]            │
│  [ % ]  [ 0 ]  [ . ]  [ = ]            │
└────────────────────────────────────────┘
```

- AppBar 영역에 `DirectRateInline` 위젯 — 환율 + 갱신 시각을 항상 노출
- From 카드의 결과 영역이 환율 변환의 입력 금액
- 가운데 swap 버튼은 기존 동작 유지 (From↔To 통화 교체)
- 키패드는 화면 하단에 항상 고정, 시스템 키보드는 표시되지 않음
- 화면 폭이 좁거나 식이 길면 식 영역의 폰트가 자동 축소되고, 임계점 이하에서 가로 스크롤

**🧮 TipTaxMenu** (BottomSheet — AppBar 진입)

```
┌────────────────────────────┐
│  ▔▔▔ (drag handle)        │
│   계산 도구                │
│ ──────────────────────────│
│   💰 팁 계산        →     │
│   🧾 세금 계산      →     │
│   🏷 할인 계산      →     │
└────────────────────────────┘
```

탭하면 해당 모달 BottomSheet로 전환 (push replacement 또는 두 단계 시트).

**팁/세금/할인 모달 BottomSheet 공통 구조**

```
┌────────────────────────────────────┐
│  ▔▔▔ (drag handle)                │
│  💰 팁 계산                  ✕    │
│ ─────────────────────────────────  │
│  기준 금액: 4,100 KRW              │
│                                    │
│  [ 5% ][ 10% ][ 15% ][ 20% ]       │
│  [    직접 입력 [ 15 ] %    ]      │
│                                    │
│  팁 금액      :     615 KRW        │
│  합계         :   4,715 KRW        │
│  합계 (USD)   :     3.46 USD       │
│                                    │
│  [   적용 (From 결과 = 4,715)    ] │
└────────────────────────────────────┘
```

- "적용" 누르면 `CalculatorNotifier`에 합계를 새 식으로 주입 (예: `4715`) 후 시트 닫힘
- "적용 없이 닫기" — drag down / 외부 탭 / ✕

### 3.2 CurrencyPicker / Settings

기존 v1.0과 동일 — 변경 없음.

---

## 4. 키패드 사양

### 4.1 레이아웃

```
[ C ]  [ ( ]  [ ) ]  [ ÷ ]
[ 7 ]  [ 8 ]  [ 9 ]  [ × ]
[ 4 ]  [ 5 ]  [ 6 ]  [ − ]
[ 1 ]  [ 2 ]  [ 3 ]  [ + ]
[ % ]  [ 0 ]  [ . ]  [ = ]
```

- 5행 4열 정사각 그리드
- 좌측 3열 = 숫자/. /%/C, 우측 1열 = 연산자/=
- `=`는 강조 색상(primary), 연산자는 보조 색상, 숫자/편집은 기본 색상
- 키 사이 간격은 디자인 시스템 표준 (`SizedBox` spacing 4px)
- `⌫` 키는 키패드가 아닌 식 표시 영역 우측에 별도 아이콘 버튼

### 4.2 키 동작 정의

| 키 | 동작 |
|---|---|
| `0–9` | 현재 숫자 토큰에 자리 추가. 결과 직후(`justEvaluated`)이면 새 식 시작 |
| `.` | 현재 숫자 토큰에 소수점 추가. 이미 점이 있으면 무시 |
| `+ − × ÷` | 연산자 토큰 추가. 마지막 토큰이 연산자면 교체. 결과 직후면 결과를 첫 항으로 이어쓰기 |
| `(` | 괄호 열기 토큰 추가. 직전이 숫자 또는 `)`이면 암묵적 곱셈 `× (` 자동 삽입 |
| `)` | 괄호 닫기 토큰 추가. 열린 괄호 수 ≤ 닫힌 괄호 수면 무시 |
| `%` | 마지막 숫자/괄호 식을 백분율 컨텍스트로 마킹. 평가 시 좌항 컨텍스트 의존 (§4.4) |
| `C` | 식과 결과 전체 초기화 (`CalculatorState.initial()`) |
| `⌫` | 식 마지막 1 토큰 제거 (숫자면 마지막 자리, 그 외는 전체 토큰) |
| `=` | 식을 평가하고 결과를 표시. `justEvaluated = true` |

### 4.3 식 빌드 규칙

- 입력 중 식은 표시용 문자열(천 단위 쉼표 포함)과 평가용 문자열(쉼표 제거)을 분리하여 유지
- 표시: `1,200 × 3 + 500`
- 평가: `1200*3+500`
- 식 길이 상한: 500자 (방어). 초과 입력은 무시
- 연산자 연속 입력 시 마지막 것만 유지: `5 + ×` → `5 ×`
- 빈 식에 연산자 입력 시: `+` `−` 는 무시(부호 변경 없음 정책), `× ÷`는 무시

### 4.4 % 동작 (iOS 스타일)

`%`는 단독 의미가 아니라 좌항 컨텍스트에 따라 해석된다.

| 입력 | 평가식 변환 | 결과 |
|---|---|---|
| `30 %` | `30 / 100` | `0.3` |
| `5000 × 30 %` | `5000 × (30 / 100)` | `1,500` |
| `5000 + 30 %` | `5000 + (5000 × 30 / 100)` | `6,500` |
| `5000 − 20 %` | `5000 − (5000 × 20 / 100)` | `4,000` |
| `(100 + 50) × 10 %` | `(100 + 50) × (10 / 100)` | `15` |
| `(100 + 50) + 10 %` | `(100 + 50) + ((100 + 50) × 10 / 100)` | `165` |

규칙 (단순화된 명세):
- `%` 키를 누르는 즉시, `%` 직전의 숫자 항을 **고정된 숫자 값으로 치환**한다 (지연 평가 없음). 좌항 컨텍스트 기준:
  - 직전 연산자가 `+` / `−` 이면 → `좌항 × n / 100` 값으로 치환 (좌항 = `%` 직전 연산자 왼쪽의 평가값, 빈 식이면 0)
  - 직전 연산자가 `× ` / `÷` 이면 → `n / 100` 값으로 치환
  - 단독 `n %` (직전 연산자 없음) → `n / 100` 값으로 치환
  - 괄호 내부의 `%`도 동일 규칙 — 좌항은 현재 괄호 안의 직전 연산자 좌측 평가값
- 치환된 값은 식의 한 항으로 남는다. 그 후 추가 연산자/숫자가 와도 일반적인 우선순위 평가
- 표시 식에서는 `%`가 사라지지 않고 그대로 보여 사용자가 원래 의도를 추적 가능 (평가용 식과 표시용 식 분리)

예시 (확장):

| 입력 | 평가용 변환 | 결과 |
|---|---|---|
| `5000 + 30 % × 2` | `5000 + 1500 × 2` (30% → 5000×0.3 = 1500) → 우선순위 적용 | `8,000` |
| `30 % + 50` | `0.3 + 50` (단독 30%) | `50.3` |
| `(100 + 10 %) × 2` | `(100 + 10) × 2` (괄호 안 좌항 100의 10% = 10) | `220` |

### 4.5 결과 이어쓰기

`=` 직후 키 입력:

| 다음 키 | 동작 |
|---|---|
| `0–9`, `.`, `(` | 새 식 시작, 이전 결과 폐기 |
| `+ − × ÷` | 결과를 첫 항으로 식 시작 (예: `4100`이 결과면 `4100 + ...`) |
| `C` | 초기 상태 복귀 |
| `⌫` | 결과 폐기, 식만 유지된 상태로 |
| `%` | 결과 × (n/100)을 다음 연산에서 사용. 빈 상태에선 단독 `n%` 동작 |
| `=` | 무동작 (이미 평가됨) |

### 4.6 식 표시 영역의 시각 처리

- 기본 폰트: 16sp (식), 32sp/굵게 (결과)
- 식이 1줄을 넘으면: 단계적 축소 (16 → 14 → 12sp)
- 12sp에서도 안 들어가면: 가로 스크롤, 커서 위치(=식 끝)에 자동 정렬
- 결과는 무조건 1줄 유지, 길어지면 `intl`의 천 단위 + decimalPlaces 적용 후에도 길면 폰트 축소 (32 → 28 → 24sp)

---

## 5. 도메인 모델

`lib/domain/calculator/models.dart` (신규)

```dart
@freezed
class CalculatorState with _$CalculatorState {
  const factory CalculatorState({
    required String expression,   // 표시용 식 ("1,200 × 3 + 500")
    required double? result,      // 평가 결과 (미완성/오류면 null)
    required bool hasError,       // 0÷ 등
    required bool justEvaluated,  // = 직후
  }) = _CalculatorState;

  factory CalculatorState.initial() => const CalculatorState(
    expression: '',
    result: null,
    hasError: false,
    justEvaluated: false,
  );
}

enum Operator { add, sub, mul, div }

sealed class CalculatorKey {
  const CalculatorKey();
}
class DigitKey extends CalculatorKey {
  final int digit; // 0..9
  const DigitKey(this.digit);
}
class DotKey extends CalculatorKey { const DotKey(); }
class OpKey extends CalculatorKey { final Operator op; const OpKey(this.op); }
class ParenOpenKey extends CalculatorKey { const ParenOpenKey(); }
class ParenCloseKey extends CalculatorKey { const ParenCloseKey(); }
class PercentKey extends CalculatorKey { const PercentKey(); }
class EqualsKey extends CalculatorKey { const EqualsKey(); }
class ClearKey extends CalculatorKey { const ClearKey(); }
class BackspaceKey extends CalculatorKey { const BackspaceKey(); }
```

- `domain` 레이어이므로 Flutter import 금지 (`Riverpod`, `flutter/material.dart` 사용 X)
- 평가/파서 결과 도메인 타입은 `lib/features/calculator/logic/` 내부에 sealed class로 별도 정의 (도메인 외부 노출 불필요)

### ConverterState와의 관계

```dart
ConverterState.amount = CalculatorState.result ?? 0
```

- 기존 `ConverterNotifier.setAmount(double)` API는 유지
- `CalculatorNotifier`가 결과 변화를 감지하고 `ConverterNotifier.setAmount(result)`를 호출
  - 또는 ConverterNotifier가 `ref.watch(calculatorNotifierProvider).result`를 구독하는 식
- 둘 중 어느 패턴이 깔끔한지는 writing-plans에서 결정 (생산자→소비자 방향이 단순하므로 후자 가설)

---

## 6. 아키텍처 / 폴더 구조

```
lib/
├── domain/
│   └── calculator/
│       └── models.dart                         (신규)
├── features/
│   ├── calculator/                             (신규)
│   │   ├── logic/
│   │   │   ├── tokenizer.dart                  ← 식 문자열 ↔ 토큰
│   │   │   ├── parser.dart                     ← 토큰 → AST (재귀하강)
│   │   │   ├── evaluator.dart                  ← AST → double | EvalError
│   │   │   ├── expression_builder.dart         ← 키 입력 → 식 빌드
│   │   │   └── percent_resolver.dart           ← iOS-style % 해석
│   │   ├── providers/
│   │   │   ├── calculator_notifier.dart        ← @riverpod
│   │   │   └── calculator_notifier.g.dart      (build_runner)
│   │   └── view/
│   │       └── widgets/
│   │           ├── calculator_keypad.dart      ← 5x4 grid
│   │           └── key_button.dart             ← 단일 키 버튼
│   └── converter/
│       └── view/
│           ├── converter_screen.dart           (대폭 수정)
│           └── widgets/
│               ├── direct_rate_inline.dart     (신규, AppBar용)
│               ├── tip_tax_menu_button.dart    (신규, 🧮 → BottomSheet 메뉴)
│               ├── expression_display.dart     (신규, From 카드)
│               ├── converted_display.dart      (신규, To 카드)
│               ├── currency_card_stack.dart    (제거)
│               ├── amount_input.dart           (제거)
│               ├── direct_rate_label.dart      (제거)
│               ├── tip_tax_segment.dart        (제거)
│               └── panels/
│                   ├── tip_panel.dart          (유지 — BottomSheet 컨테이너 추가)
│                   ├── tax_panel.dart          (유지)
│                   └── discount_panel.dart     (유지)
└── core/
    └── l10n/
        ├── app_en.arb                          (키 추가)
        └── app_ko.arb                          (키 추가)
```

**의존성 방향**:
- `features/calculator/view` → `features/calculator/providers` → `features/calculator/logic` + `domain/calculator`
- `features/converter` → `features/calculator/providers` (결과 구독)
- `features/calculator` → `features/converter`로의 역방향 의존 없음

---

## 7. 라이브러리

기존 v1.0 라이브러리에서 **추가 없음**.

- 수식 평가: 외부 패키지(`math_expressions` 등) 사용하지 않음 — % 동작이 패키지 표준과 다르고, 의존성 0 유지 원칙
- 직접 구현: `tokenizer`(약 80줄) + `parser`(약 150줄) + `evaluator`(약 80줄) — 단순 사칙 + 괄호 + %만 다루므로 충분

---

## 8. 데이터 흐름

```
사용자 키 탭
   ↓
CalculatorKeypad.onTap(CalculatorKey)
   ↓
ref.read(calculatorNotifierProvider.notifier).onKey(key)
   ↓
expression_builder.applyKey(state, key) → new expression string
   ↓
tokenizer → parser → evaluator (=가 아니어도 미리보기 계산은 시도)
   ↓
CalculatorState 갱신 (expression / result / hasError / justEvaluated)
   ↓
ExpressionDisplay rebuild
   ↓ (별도 구독)
ConverterNotifier.setAmount(result) 호출 → ConverterState.amount 갱신
   ↓
ConvertedDisplay rebuild (To 통화 결과 자동 재계산)
```

**핵심 원칙**: `CalculatorState`가 source-of-truth, `ConverterState.amount`는 derived.

---

## 9. 다국어 (i18n)

신규 키 (en/ko ARB 모두 추가):

| 키 | en | ko |
|---|---|---|
| `calcError` | `Error` | `오류` |
| `calcMenuTitle` | `Calculation tools` | `계산 도구` |
| `calcMenuTip` | `Tip` | `팁 계산` |
| `calcMenuTax` | `Tax` | `세금 계산` |
| `calcMenuDiscount` | `Discount` | `할인 계산` |
| `appBarRateLabel` | `1 {from} = {value} {to}` | `1 {from} = {value} {to}` |
| `appBarTimestamp` | `As of {ts}` | `{ts} 기준` |
| `panelBaseAmount` | `Base amount` | `기준 금액` |
| `panelApplyButton` | `Apply` | `적용` |

기존 `offlineBanner`, `convertedDirectRateLabel`, `tipTaxNone/Tip/Tax/Discount` 일부 키는 더 이상 사용되지 않으나 (v1.0 호환 위해) 삭제하지 않음.

---

## 10. 에러 처리

| 상황 | UI 동작 |
|---|---|
| `n ÷ 0 =` | 결과 영역에 l10n `오류` 표시. 식은 유지. 다음 어떤 키 누르면 오류 해제 |
| 미완성 식 (`5 +`) | 결과 영역에 마지막 유효 부분식 값 미리보기 (`5`). `=` 누르면 마지막 연산자 무시하고 평가 (`5`) |
| `(` 닫지 않음 | `=` 시 자동으로 부족한 `)` 추가 후 평가 |
| 빈 식에 `=` | 무동작 (`result = null`, 결과 영역 비움) |
| 식 > 500자 | 추가 입력 무시 (방어). 사용자에게 토스트 등 알림 없음 (조용한 무시) |
| 환율 캐시 없음 | 기존 `OfflineBanner` AppBar 아래 표시 (변경 없음) |
| 환율 스냅샷이 To 통화 코드를 갖지 않음 | 기존 동작 유지 — ConvertedDisplay가 `--`로 표시 |
| 계산 결과가 너무 큰 경우 (>1e15) | `intl` 천 단위 + 폰트 자동 축소로 처리. 그 이상이면 지수 표기 `1.23e+16` |

---

## 11. 보안 / 프라이버시

v1.0과 동일. 신규 변경 없음.
- 사용자가 입력한 식은 메모리에만 존재, 영속화하지 않음 (히스토리는 비목표)
- 광고/분석 SDK 미도입 원칙 유지

---

## 12. 테스트 전략

비율: 단위 80%, 위젯 10%, 통합 10%

### 12.1 단위 테스트 (목표 80%)

| 대상 | 케이스 |
|---|---|
| `tokenizer.dart` | 정상 토큰화, 천 단위 쉼표 무시(평가용), `5(` 처리, 연속 점, 음수 부호 X |
| `parser.dart` | 우선순위(`1+2*3`=7), 괄호(`(1+2)*3`=9), 중첩 괄호, 닫지 않은 괄호 자동 보정, 빈 입력 |
| `evaluator.dart` | 사칙연산 정확성, 0÷ → `EvalError.divisionByZero`, 부동소수점 라운딩 |
| `expression_builder.dart` | 모든 키 종류별 state 전이, 결과 이어쓰기, `justEvaluated` 처리, 점 중복 방지, 연산자 교체 |
| `percent_resolver.dart` | `30%` 단독, `5000×30%`, `5000+30%` (iOS 스타일), `(100+50)×10%`, 괄호 내 % |
| `calculator_notifier.dart` | state 전이, ConverterNotifier 동기화 (mocktail) |

### 12.2 위젯 테스트 (목표 10%)

| 대상 | 케이스 |
|---|---|
| `calculator_keypad.dart` | 각 키 탭 시 notifier `onKey` 호출, 키 색상 분류 |
| `expression_display.dart` | 식/결과 표시, 오류 표시, ⌫ 탭 시 notifier `backspace` 호출 |
| `tip_tax_menu_button.dart` | 탭 시 BottomSheet 노출, 각 항목 탭 시 해당 panel 시트 진입 |
| `direct_rate_inline.dart` | from/to 통화/환율/시각 표시, 환율 null이면 placeholder |

### 12.3 통합 테스트 (목표 10%)

`integration_test/calculator_e2e_test.dart` (신규):
- 골든 패스: 키패드로 `1,200 × 3 + 500 =` 입력 → From 4,100 KRW → To USD 자동 환산
- 괄호: `(1,000 + 500) × 3 =` → 4,500
- 백분율: `50,000 − 30 % =` → 35,000
- 팁 모달: AppBar 🧮 → 팁 → 10% 적용 → From 결과가 합계로 갱신

기존 `integration_test/app_test.dart`(v1.0)는 화면 구조가 바뀌므로 **수정** (KRW/USD 셀 단순 존재 확인 → 키패드 + 식 표시 검증으로 변경).

---

## 13. v1.0 → v1.1 변경 영향 매트릭스

| 영역 | 변경 종류 | 비고 |
|---|---|---|
| `lib/features/converter/view/converter_screen.dart` | 대폭 수정 | AppBar/위젯 트리 재구성 |
| `lib/features/converter/view/widgets/currency_card_stack.dart` | **제거** | `ExpressionDisplay` + `ConvertedDisplay`로 분할 대체 |
| `lib/features/converter/view/widgets/amount_input.dart` | **제거** | 키패드가 입력을 담당 |
| `lib/features/converter/view/widgets/direct_rate_label.dart` | **제거** | `DirectRateInline`이 AppBar에서 대체 |
| `lib/features/converter/view/widgets/tip_tax_segment.dart` | **제거** | AppBar 🧮 메뉴로 대체 |
| `lib/features/converter/view/widgets/panels/*.dart` | 컨테이너 수정 | BottomSheet 환경에서 동작하도록 padding/스크롤 조정 |
| `lib/features/converter/providers/converter_notifier.dart` | 소폭 수정 | `setAmount` 호출 출처가 키패드로 전환됨. API는 유지 |
| `lib/features/converter/providers/tip_tax_notifier.dart` | 소폭 수정 | `recomputeForAmount` 호출 출처가 변경. API 유지 |
| `lib/features/converter/logic/conversion.dart` | 변경 없음 | |
| `lib/features/converter/logic/{tip,tax,discount}_calculator.dart` | 변경 없음 | |
| `lib/data/`, `lib/domain/exchange_rate/` | 변경 없음 | |
| `lib/core/l10n/app_*.arb` | 키 추가 | §9 |
| `test/features/converter/view/widgets/amount_input_test.dart` | 제거 | |
| `test/features/converter/view/adaptive_rate_decimals_test.dart` | 유지 | DirectRate 로직 재사용 |
| `integration_test/app_test.dart` | 수정 | 새 화면 구조 반영 |

---

## 14. v1.1 범위 명세

**포함**:
- [x] 환율 변환 화면 재설계 (얇은 From/To 카드 + 키패드)
- [x] AppBar에 직접환율 + 갱신 시각 표시
- [x] 인라인 계산기 키패드 (5×4, 사칙연산 + 괄호 + %)
- [x] 표현식 평가 (`×÷` > `+−` 우선순위)
- [x] iOS 스타일 % 동작
- [x] 결과 이어쓰기 (`=` 후 연산자 누르면 결과를 첫 항으로)
- [x] 식 자동 축소 + 가로 스크롤
- [x] 0÷ 등 오류 표시
- [x] AppBar 🧮 → BottomSheet 메뉴 → 팁/세금/할인 모달 BottomSheet
- [x] 팁/세금/할인 "적용" 시 From 결과 갱신
- [x] 다국어 (en/ko) 키 추가

**제외 (향후 확장)**:
- [ ] 식 히스토리
- [ ] 메모리 키 (M+/M-/MC/MR)
- [ ] 공학 계산기
- [ ] 부호 변경 키
- [ ] 음성 입력
- [ ] 클립보드 복사/붙여넣기

---

## 15. 위험 요소

| 위험 | 영향 | 완화 |
|---|---|---|
| 시스템 키보드와 인라인 키패드 충돌 | 키패드 위에 시스템 키보드 올라옴 | TextField 사용 안 함. `Listener`/`GestureDetector` 기반 식 표시 영역으로 대체. focus 처리 X. |
| 작은 단말(SE 1세대 ~ 4.7") 키패드 비좁음 | 키 크기 < 44pt → 탭 정확도 저하 | 키 최소 크기 보장 (`AspectRatio` 또는 `Wrap`). 식/결과 영역 폰트 축소 적극 활용 |
| 부동소수점 누적 오차 | `0.1 + 0.2 = 0.30000000000000004` 노출 | 결과 라운딩 (디스플레이 직전에 10자리 유효 숫자로 라운딩). 단위 테스트로 명세 |
| 큰 수 오버플로 | `1e308` 이상에서 `double` overflow | 결과 `isInfinite`/`isNaN` 검출 시 `오류` 표시 |
| 식 빌더 상태 머신 복잡도 | 키 입력 순서에 따른 edge case 누락 | `expression_builder` 단위 테스트를 키 종류 × 직전 토큰 조합으로 매트릭스 작성 |
| BottomSheet 내부에서 시스템 키보드 사용 | 모달 안 직접 입력(%) 시 키보드 올라옴 | 모달 내에서는 시스템 숫자 키보드 허용 — 모달은 계산기와 분리된 정형 UI |
| AppBar 액션 아이콘 3개로 가로 공간 부족 | 작은 단말에서 환율 텍스트 잘림 | 환율 영역은 `FittedBox(fit: BoxFit.scaleDown)`로 폰트 자동 축소 (Marquee/ellipsis는 사용성 저하로 미채택). 액션 아이콘은 24dp 표준 |

---

## 16. 변경 일정 (개략 — 자세한 작업 분할은 plan에서)

| 단계 | 산출물 | 예상 분량 |
|---|---|---|
| 0 | 도메인 모델 정의 | `models.dart` + freezed 생성 |
| 1 | 순수 로직 (tokenizer/parser/evaluator/builder/%) | 500줄 + 단위 테스트 |
| 2 | `CalculatorNotifier` + ConverterNotifier 연동 | 100줄 + 테스트 |
| 3 | UI 위젯 (`KeyButton`/`CalculatorKeypad`) | 200줄 |
| 4 | `ExpressionDisplay` / `ConvertedDisplay` / `DirectRateInline` | 200줄 |
| 5 | `ConverterScreen` 재구성, 기존 위젯 제거 | 100줄 변경 |
| 6 | TipTaxMenuButton + BottomSheet 래핑 | 100줄 |
| 7 | l10n 추가, integration test 수정 | 50줄 + 신규 통합 테스트 |

---

## 17. 작업 산출물 위치

- 설계 문서: `docs/superpowers/specs/2026-05-14-calculator-design.md` (이 파일)
- 컨텍스트 스캔: `docs/superpowers/specs/2026-05-14-calculator-context.md` (Phase 0.7)
- 구현 계획: `docs/superpowers/plans/2026-05-14-calculator.md` (Phase 1, writing-plans 산출)
- TEST_REPORT.md: 프로젝트 루트 (Phase 3 갱신)
- BROWSER_QA_REPORT.md: 프로젝트 루트 (Phase 4 — 모바일 앱이므로 통합 테스트로 대체 가능)
- QA_REPORT.md: 프로젝트 루트 (Phase 6 갱신)
