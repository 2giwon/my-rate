# MyRate 설계 문서

**작성일**: 2026-05-12
**버전**: v1.0 (MVP)
**작성자**: brainstorming via /super-develop
**상태**: 승인 대기 (사용자 spec 검토 단계)

---

## 1. 개요

### 1.1 배경

기존 환율 계산기 앱들은 광고가 과도하게 많아 사용성을 저해한다. 단순한 환율 조회조차 광고 시청을 강요받거나 화면의 절반이 광고 배너로 덮인다. 사용자는 "광고 없는 깨끗한 환율 계산기"를 원한다.

### 1.2 목표

광고 없는, 깔끔하고 빠른 환율 계산기 모바일 앱.
- 실시간 환율 갱신 (ExchangeRate-API)
- 한국 사용자를 1차 대상으로 한 통화 선택 UX
- 여행/쇼핑에서 자주 쓰는 팁/세금/할인 계산 통합

### 1.3 비목표 (Non-goals)

- 환율 히스토리/차트 (MVP 제외, 향후 확장)
- 통화 쌍 즐겨찾기 (개별 통화 즐겨찾기로 시작)
- 알림/위젯 (MVP 제외)
- 송금/거래 기능
- 사용자 추적/광고 SDK 일체 (앱의 핵심 차별점)

### 1.4 핵심 차별점

- **광고 0개** — Firebase Analytics, AdMob, Crashlytics 등 일체 미도입.
- **팁/세금/할인 계산 통합** — 환율 화면 하단 토글로 즉시 접근.
- **빠른 통화 선택** — 즐겨찾기 + 인기 + 알파벳 인덱스 검색.

---

## 2. 확정된 기술 결정

| 항목 | 결정 |
|---|---|
| 프레임워크 | Flutter (Dart 3.x) |
| 타겟 플랫폼 | Android, iOS (MVP 기준) |
| 상태관리 | Riverpod (`flutter_riverpod` + `riverpod_annotation`) |
| 환율 API | ExchangeRate-API (월 1500건 무료 플랜) |
| 로컬 저장 | `shared_preferences` (캐시/즐겨찾기/설정) |
| 네트워크 | `dio` |
| 다국어 | `flutter_localizations` + `intl` (한국어/영어) |
| 다크모드 | 시스템 자동 (`ThemeMode.system`) |
| 앱 이름 (Display) | **MyRate** |
| Dart 프로젝트명 (pubspec `name:`) | `myrate` (Dart 식별자 규칙상 dash 불가) |
| 패키지 ID / Bundle ID | `com.myrate.myrate` (`--org com.myrate --project-name myrate` 자동 합성) |
| 프로젝트 경로 | `~/Documents/my-rate` (폴더명만 dash) |
| GitHub 리포 | `my-rate` (Public) |

---

## 3. 사용자 플로우

```
[앱 실행]
   ↓
환율 캐시 확인 (time_next_update_unix 초과? 또는 없음?)
   ↓
초과/없음 → API 호출 / 유효 → 캐시 사용
   ↓
[메인: Converter 화면]
  - 상단: From 통화 셀 (탭 가능)
  - 중앙: 금액 입력 + swap 버튼
  - 중앙: To 통화 셀 (탭 가능) + 변환 결과
  - 보조: 1 From = X To 직접 환율 노출
  - 하단: 토글 세그먼트 [없음 | 팁 | 세금 | 할인]
   ↓
통화 셀 탭 → [Currency Picker 화면]
   - 상단: 검색바
   - 즐겨찾기 섹션 (탭으로 환율 화면 즉시 적용)
   - 인기 섹션
   - 전체 (알파벳 인덱스로 빠른 스크롤)
   ↓
새로고침 아이콘 탭 → 강제 API 호출 (사용자 의도)
   ↓
설정 진입 → 기본 통화/언어/테마/캐시 정보
```

---

## 4. 화면 정의

### 4.1 Converter (메인)

```
┌────────────────────────────────────┐
│ ⏱ 2026-05-12 14:32 기준        🔄  │  ← 갱신 시각 + 새로고침 버튼
├────────────────────────────────────┤
│  🇰🇷  KRW · 대한민국 원       ⌄    │  ← From 통화 (탭 시 picker)
│  ┌─────────────────────────────┐   │
│  │ 100,000                     │   │  ← 금액 입력 (단방향)
│  └─────────────────────────────┘   │
│              ⇅                     │  ← 통화 swap 버튼
├────────────────────────────────────┤
│  🇺🇸  USD · 미국 달러         ⌄    │  ← To 통화 (탭 시 picker)
│  ┌─────────────────────────────┐   │
│  │ 73.42                       │   │  ← 변환 결과 (read-only)
│  └─────────────────────────────┘   │
│  1 USD = 1,362.50 KRW              │  ← 직접 환율 보조 표시
├────────────────────────────────────┤
│  [ 없음 │ 팁 │ 세금 │ 할인 ]       │  ← 토글 세그먼트
│                                    │
│  (선택 시 expandable 영역)         │
└────────────────────────────────────┘
```

**오프라인 상태**:
- 상단에 노란 배너 추가: `⚠ 오프라인 · YYYY-MM-DD HH:mm 기준`
- 캐시 환율로 정상 계산 동작
- 새로고침 버튼은 활성화되어 있되, 탭 시 네트워크 안내 토스트

**입력 동작**:
- 금액은 From 통화 칸만 편집 가능 (단방향)
- swap 버튼은 From↔To 통화 교체 (금액은 유지, 결과는 재계산)

### 4.2 Currency Picker

```
┌────────────────────────────────────┐
│  ←  통화 선택              🔍       │  ← 상단바, 검색 토글
├────────────────────────────────────┤
│ ★ 즐겨찾기                          │
│   🇰🇷  KRW · 대한민국 원        ★    │
│   🇺🇸  USD · 미국 달러          ★    │
│   🇯🇵  JPY · 일본 엔            ★    │
├────────────────────────────────────┤
│ ⭐ 인기                             │
│   🇪🇺  EUR · 유로              ☆    │
│   🇬🇧  GBP · 영국 파운드        ☆    │
│   🇨🇳  CNY · 중국 위안          ☆    │
│   ...                              │
├────────────────────────────────────┤
│ A                                  │  ← 알파벳 섹션 헤더
│   🇦🇪  AED · UAE 디르함        ☆  │A│
│ B                                  │B│
│   🇧🇩  BDT · 방글라데시 타카   ☆  │C│
│ ...                                │…│
└────────────────────────────────────┘
```

**검색**:
- 🔍 탭 시 검색바 활성화, 키워드로 통화 코드/이름 필터.
- 검색어 입력 시 즐겨찾기/인기/전체 섹션 헤더는 숨김, 결과만 단일 리스트로.

**알파벳 인덱스**:
- 우측 사이드 인덱스 (A-Z). 탭/드래그 시 해당 섹션으로 점프.

**즐겨찾기**:
- 각 행 우측 별(☆) 탭 → 즐겨찾기 추가/해제.
- 즐겨찾기 변경은 SharedPreferences에 즉시 영속화.

**인기 통화** (한국 사용자 기준 고정):
- USD, EUR, JPY, CNY, GBP, AUD, CAD, HKD, SGD, THB, VND, PHP (12개)

### 4.3 Tip/Tax/Discount 패널

토글 세그먼트 선택 시 메인 화면 하단에 영역 expand.

**팁 (Tip)**:
```
┌────────────────────────────────────┐
│ 팁 비율                            │
│ [5%] [10%] [15%] [20%]  또는 직접  │
│ ┌──────┐                           │
│ │  15  │ %                         │
│ └──────┘                           │
├────────────────────────────────────┤
│ 팁 금액 (KRW)         15,000      │
│ 합계 (KRW)           115,000      │
│ 합계 (USD)             84.43      │  ← 변환 결과 동기화
└────────────────────────────────────┘
```

**세금 (Tax)**:
- VAT% 입력 (기본 10%)
- 세전/세후 토글
  - **세전 → 세후**: 입력 금액 × (1 + VAT/100)
  - **세후 → 세전**: 입력 금액 / (1 + VAT/100)
- 세금 금액 + 합계를 From, To 양쪽 통화로 표시

**할인 (Discount)**:
- 할인율(%) 또는 할인 금액 (radio toggle)
- 최종 금액 + 할인된 금액을 From, To 양쪽 통화로 표시

### 4.4 Settings

```
┌────────────────────────────────────┐
│  설정                              │
├────────────────────────────────────┤
│  기본 From 통화      KRW    >      │
│  기본 To 통화        USD    >      │
├────────────────────────────────────┤
│  언어               시스템   >      │  ← 한국어/영어/시스템
│  테마               시스템   >      │  ← 라이트/다크/시스템
├────────────────────────────────────┤
│  마지막 갱신   2026-05-12 14:32    │
│  캐시 정리                  >      │  ← 탭 시 확인 후 삭제
├────────────────────────────────────┤
│  앱 정보                    >      │
│  오픈소스 라이선스          >      │
└────────────────────────────────────┘
```

---

## 5. 도메인 모델

```dart
class Currency {
  final String code;          // 'USD', 'KRW', 'JPY'
  final String name;          // 현재 로케일 기반 표시명
  final String? flagEmoji;    // 🇺🇸, 🇰🇷 (없으면 null)
  final int decimalPlaces;    // KRW=0, USD=2, JPY=0
}

class ExchangeRateSnapshot {
  final String baseCode;
  final Map<String, double> rates;
  final DateTime fetchedAt;       // 우리가 API 호출한 시각
  final DateTime apiUpdatedAt;    // API의 time_last_update_unix
  final DateTime apiNextUpdateAt; // API의 time_next_update_unix
}

class ConversionResult {
  final String fromCode;
  final String toCode;
  final num amount;             // 입력 금액 (raw)
  final double convertedAmount; // 변환 결과
  final double directRate;      // 1 from = X to
  final DateTime basedOn;       // apiUpdatedAt
}

enum TipTaxMode { none, tip, tax, discount }

class TipState {
  final double percent;
  final double tipAmount;
  final double total;
}

class TaxState {
  final double vatPercent;
  final bool isInclusive;   // 세후→세전 모드 여부
  final double taxAmount;
  final double total;
}

class DiscountState {
  final bool byPercent;
  final double percentOrAmount;
  final double discountAmount;
  final double finalAmount;
}
```

---

## 6. 아키텍처 / 폴더 구조

**선택된 접근**: Feature-First + Layered

```
my-rate/
├── lib/
│   ├── main.dart
│   ├── app.dart                            ← MaterialApp, ProviderScope, 라우팅
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart              ← light/dark ThemeData
│   │   │   └── color_schemes.dart
│   │   ├── l10n/                           ← intl ARB
│   │   ├── constants/
│   │   │   ├── popular_currencies.dart     ← 한국 사용자 인기 12개
│   │   │   └── defaults.dart               ← 기본 From=KRW, To=USD
│   │   ├── errors/
│   │   │   └── app_exception.dart
│   │   ├── utils/
│   │   │   ├── currency_formatter.dart
│   │   │   └── date_formatter.dart
│   │   └── routing/
│   │       └── app_router.dart             ← go_router (간단) or Navigator
│   ├── data/
│   │   └── exchange_rate/
│   │       ├── remote/
│   │       │   ├── exchange_rate_api.dart  ← Dio 클라이언트
│   │       │   └── dtos.dart               ← ExchangeRateResponseDto
│   │       ├── local/
│   │       │   ├── rate_cache.dart         ← SharedPreferences 래퍼
│   │       │   └── favorites_store.dart
│   │       └── exchange_rate_repository_impl.dart
│   ├── domain/
│   │   └── exchange_rate/
│   │       ├── models.dart                 ← Currency, ExchangeRateSnapshot, ...
│   │       └── exchange_rate_repository.dart  ← abstract
│   └── features/
│       ├── converter/
│       │   ├── view/
│       │   │   ├── converter_screen.dart
│       │   │   └── widgets/
│       │   │       ├── currency_cell.dart
│       │   │       ├── amount_input.dart
│       │   │       ├── swap_button.dart
│       │   │       ├── direct_rate_label.dart
│       │   │       ├── tip_tax_segment.dart
│       │   │       └── panels/
│       │   │           ├── tip_panel.dart
│       │   │           ├── tax_panel.dart
│       │   │           └── discount_panel.dart
│       │   ├── providers/
│       │   │   ├── converter_notifier.dart
│       │   │   └── tip_tax_notifier.dart
│       │   └── logic/
│       │       ├── conversion.dart         ← 순수 계산 함수
│       │       ├── tip_calculator.dart
│       │       ├── tax_calculator.dart
│       │       └── discount_calculator.dart
│       ├── currency_picker/
│       │   ├── view/
│       │   │   ├── currency_picker_screen.dart
│       │   │   └── widgets/
│       │   │       ├── currency_row.dart
│       │   │       ├── alphabet_index.dart
│       │   │       └── search_bar.dart
│       │   └── providers/
│       │       └── currency_picker_notifier.dart
│       └── settings/
│           ├── view/
│           │   └── settings_screen.dart
│           └── providers/
│               └── settings_notifier.dart
├── test/
│   ├── core/
│   ├── data/
│   ├── domain/
│   └── features/
│       ├── converter/
│       │   ├── logic/                      ← 순수 함수 테스트
│       │   └── providers/                  ← Notifier 테스트
│       ├── currency_picker/
│       └── settings/
├── integration_test/
│   └── app_test.dart                       ← 골든 패스
├── android/
├── ios/
├── pubspec.yaml
├── analysis_options.yaml                   ← flutter_lints
├── .gitignore
├── .env.example
├── README.md
└── docs/
    └── superpowers/
        ├── specs/
        │   └── 2026-05-12-myrate-design.md  (this file)
        └── plans/
            └── (Phase 1 writing-plans 산출물)
```

---

## 7. 주요 라이브러리

| 용도 | 패키지 |
|---|---|
| 상태관리 | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` (dev) |
| 네트워크 | `dio` |
| JSON | `freezed`, `json_serializable`, `json_annotation` |
| 로컬 저장 | `shared_preferences` |
| 다국어 | `flutter_localizations`, `intl` |
| 환경변수 | `flutter_dotenv` (개발용), `--dart-define` (빌드 타임) |
| 코드 생성 | `build_runner` (dev) |
| 라우팅 | `go_router` |
| Lint | `flutter_lints` |
| 테스트 | `flutter_test`, `mocktail`, `integration_test` |

---

## 8. API 통합

### 8.1 엔드포인트

```
GET https://v6.exchangerate-api.com/v6/{API_KEY}/latest/{BASE_CODE}
```

응답 (요약):
```json
{
  "result": "success",
  "base_code": "USD",
  "time_last_update_unix": 1715472000,
  "time_next_update_unix": 1715558400,
  "conversion_rates": {
    "KRW": 1362.5,
    "JPY": 156.2,
    ...
  }
}
```

### 8.2 호출 전략

월 1500건 제한 (= 일 약 50건) 안에서 안전하게 동작:

| 시점 | 동작 |
|---|---|
| 앱 콜드 스타트 | 캐시 확인 → 없거나 `time_next_update_unix` 지남 → API 호출 / 유효 → 캐시 사용 |
| 포그라운드 복귀 | 동일 로직 |
| 새로고침 버튼 | 강제 API 호출 (사용자 명시적 의도) |
| From 통화 변경 | 해당 BASE의 캐시 없거나 만료 → API 호출 / 유효 → 캐시 사용 |
| 네트워크 없음 | 캐시 사용 + 경고 배너 |

**예상 호출량 (단일 사용자)**:
- 일 1~3회 (출근 길, 점심, 저녁)
- BASE 통화 변경 시 추가 호출
- 월 100건 미만 예상 → 무료 플랜 충분

### 8.3 API 키 관리

- `.env` 파일에 `EXCHANGE_RATE_API_KEY=xxx` 저장 (gitignore)
- `.env.example`만 리포에 포함 (값 비워둠)
- 빌드 시 `--dart-define=EXCHANGE_RATE_API_KEY=$KEY`로 주입
- Dio 인터셉터에서 URL 빌드 시 자동 삽입
- 코드/리포에 키 평문 절대 포함 X

---

## 9. 캐시 / 영속화 전략

### 9.1 SharedPreferences 키

| 키 | 값 | 비고 |
|---|---|---|
| `cache.rates.{BASE}` | JSON of `ExchangeRateSnapshot` | BASE 통화별 분리 |
| `favorites.currencies` | `["KRW","USD","JPY"]` (JSON 배열) | 즐겨찾기 통화 코드 |
| `settings.defaultFrom` | `"KRW"` | |
| `settings.defaultTo` | `"USD"` | |
| `settings.language` | `"system" \| "ko" \| "en"` | |
| `settings.themeMode` | `"system" \| "light" \| "dark"` | |

### 9.2 캐시 만료 판단

캐시 `apiNextUpdateAt`이 현재 시각보다 미래면 유효. 과거면 만료.

### 9.3 오프라인 폴백

- 네트워크 호출 실패(SocketException, TimeoutException 등) → 마지막 캐시 반환 + `isStale=true` 플래그.
- UI는 `isStale=true`이면 경고 배너 노출.

---

## 10. 에러 처리

| 상황 | UI 동작 |
|---|---|
| 네트워크 없음 + 캐시 있음 | 캐시 사용 + 상단 노란 배너 `⚠ 오프라인 · YYYY-MM-DD HH:mm 기준` |
| 네트워크 없음 + 캐시 없음 | 빈 상태 화면 + "네트워크 연결 후 다시 시도" + 재시도 버튼 |
| API HTTP 4xx | 캐시 있으면 fallback + 토스트(개발 빌드는 상세, 릴리즈는 일반 메시지), 없으면 에러 화면 |
| API HTTP 5xx | 동일 fallback |
| 잘못된 API 키 (`invalid-key`) | 개발 빌드: 명시 에러 / 릴리즈: 일반 메시지 |
| JSON 파싱 실패 | 캐시 fallback + Sentry 같은 에러 추적 없음 (MVP) — 로그만 |
| 0으로 나누기 (환율 변환 시 정상 케이스에선 발생 불가) | defensive: 0 반환 |

---

## 11. 보안 / 프라이버시

- **API 키**: 리포에 절대 포함 X. `.env` (gitignore) + `--dart-define`.
- **사용자 추적**: 광고/분석 SDK 일체 없음. Firebase Analytics, AdMob, Crashlytics, Sentry 등 미도입.
- **수집 데이터**: 없음. 모든 데이터는 로컬 SharedPreferences에만 저장.
- **권한**: 인터넷 권한만 필요.
- **개인정보처리방침**: "데이터를 수집하지 않습니다"를 명시한 간단한 페이지 — 스토어 등록 시 필요.

---

## 12. 다국어 (i18n)

- `flutter_localizations` + `intl` ARB 파일 (`app_ko.arb`, `app_en.arb`).
- 통화 이름은 ARB가 아닌 별도 데이터 소스 (예: `assets/currencies_ko.json`, `assets/currencies_en.json`)로 분리 — 통화가 161개이므로 ARB에 넣으면 비대.
- 숫자 포맷: `intl`의 `NumberFormat.currency(locale, name)` 사용. 통화별 decimalPlaces 자동 반영.
- 시스템 언어가 한국어/영어 외이면 영어로 폴백.

---

## 13. 테스트 전략

**피라미드 비율 70:30 (단위:E2E)**

### 13.1 단위 테스트 (목표 70%)

| 대상 | 테스트 |
|---|---|
| `lib/features/converter/logic/conversion.dart` | KRW→USD, USD→KRW, JPY→USD 등 각종 통화 환산, 0 입력, 큰 수, 소수점 처리 |
| `lib/features/converter/logic/tip_calculator.dart` | 0%, 10%, 15%, 20%, 임의 값, 음수/오버플로 방어 |
| `lib/features/converter/logic/tax_calculator.dart` | 세전→세후, 세후→세전, 0% VAT |
| `lib/features/converter/logic/discount_calculator.dart` | 율 모드, 금액 모드, 100% 할인, 0% 할인 |
| `lib/data/exchange_rate/local/rate_cache.dart` | 저장/조회/만료 판단, 손상된 JSON 처리 |
| `lib/data/exchange_rate/local/favorites_store.dart` | 추가/삭제/조회, 중복 방지 |
| `lib/data/exchange_rate/exchange_rate_repository_impl.dart` | API 성공/실패/오프라인 fallback (mocktail) |
| `lib/features/converter/providers/converter_notifier.dart` | 통화 변경, 금액 변경, swap, 새로고침 동작 |
| `lib/features/converter/providers/tip_tax_notifier.dart` | 모드 전환, 값 변경에 따른 합계 변화 |
| `lib/features/currency_picker/providers/currency_picker_notifier.dart` | 검색, 즐겨찾기 토글, 알파벳 그룹화 |

### 13.2 위젯 테스트 (목표 10%)

| 대상 | 테스트 |
|---|---|
| `tip_tax_segment.dart` | 토글 선택 시 onSelected 콜백 호출 |
| `currency_row.dart` | 즐겨찾기 별 탭 시 onFavoriteToggle 호출 |

### 13.3 통합 테스트 / E2E (목표 20%)

`integration_test/app_test.dart`:

| 시나리오 | 검증 |
|---|---|
| 골든 패스 | 앱 실행 → KRW→USD 변환 → 결과 확인 → 팁 10% → 합계 확인 |
| 통화 선택 | 메인에서 USD 셀 탭 → 검색 "EUR" → EUR 선택 → 메인에 EUR 반영 |
| 오프라인 | 네트워크 차단(mock) → 앱 재시작 → 캐시 환율로 동작 + 경고 배너 표시 |

> 통합 테스트는 Mock 서버(`http_mock_adapter`)로 API를 가짜 응답하여 결정성 확보.

---

## 14. CI / 품질 게이트 (선택)

MVP에서는 GitHub Actions 1개로 시작:
- `flutter analyze` (lint 0 warnings)
- `flutter test` (단위/위젯 테스트 100% 통과)
- 통합 테스트는 로컬 또는 추후 Firebase Test Lab으로

---

## 15. Git / 리포 설정

1. `flutter create --org com.myrate --project-name myrate --platforms=android,ios my-rate`
   - 결과: 폴더는 `my-rate`, pubspec name은 `myrate`, Bundle/Package ID는 `com.myrate.myrate`
2. `cd my-rate && git init`
3. `.gitignore` 보강 — Flutter 표준 + `.env`, `*.keystore`, `key.properties`, `.dart_tool/`, `build/` 등
4. `.env.example` 추가
5. 첫 커밋: `chore: initial commit`
6. `gh repo create my-rate --public --source=. --remote=origin --description "광고 없는 환율 계산기 (Flutter)"`
7. `git push -u origin main`
8. README.md 작성 (목적, 설치, API 키 설정 방법)

---

## 16. MVP 범위 명세

**포함**:
- [x] 환율 변환 (From↔To, swap, 단방향 금액 편집)
- [x] 통화 선택 (즐겨찾기/인기/전체 + 검색 + 알파벳 인덱스)
- [x] 통화 개별 즐겨찾기
- [x] 팁/세금/할인 토글 패널 (메인 하단)
- [x] 환율 자동 갱신 (앱 실행/포그라운드 + 캐시 만료 판단)
- [x] 수동 새로고침
- [x] 오프라인 캐시 + 경고 배너
- [x] 다국어 (한국어/영어)
- [x] 다크모드 (시스템 자동)
- [x] 설정 (기본 통화, 언어, 테마, 캐시 정리)

**제외 (향후 확장)**:
- [ ] 환율 히스토리/차트
- [ ] 통화 쌍 즐겨찾기
- [ ] 위젯/홈스크린
- [ ] 환율 목표 알림
- [ ] 일본어/중국어 지원
- [ ] iPad/Tablet 전용 레이아웃
- [ ] 분석/광고 SDK

---

## 17. 위험 요소

| 위험 | 영향 | 완화 |
|---|---|---|
| API 키 노출 | API quota 도용, 키 차단 | `.env` + `--dart-define` + `.gitignore`. Public 리포지만 키는 별도 관리. |
| 월 1500건 초과 | 다음 달까지 환율 갱신 안 됨 | 캐시 우선 + `time_next_update_unix` 존중. 사용자 1인 기준 안전. |
| API 응답 변경 | 파싱 실패 | DTO 분리 + 캐시 fallback + 단위 테스트. |
| 통화 데이터(이름/플래그) 정확성 | UX 저하 | 첫 릴리즈에 161개 모두 검수는 비현실적. 인기 12개 + 한국 사용자가 자주 쓰는 30개 정도만 검수, 나머지는 코드만 표시 폴백. |
| 다크모드 색 대비 | 가독성 저하 | Material 3 dynamic_color 또는 직접 정의한 ColorScheme로 WCAG AA 만족. |

---

## 18. 향후 확장 시 고려

- **유료 모델**: 광고 대신 차트, 위젯, 알림 등을 묶은 1회 결제 / 구독. 앱의 "광고 없음" 가치와 부합.
- **히스토리/차트**: Frankfurter API로 보충 (ECB 기준이지만 무료 무제한).
- **알림**: 목표 환율 도달 시 푸시. FCM 도입 필요.

---

## 19. 작업 산출물 위치

- 설계 문서: `docs/superpowers/specs/2026-05-12-myrate-design.md` (이 파일)
- 구현 계획: `docs/superpowers/plans/2026-05-12-myrate.md` (Phase 1에서 생성)
- 컨텍스트 스캔: `docs/superpowers/specs/2026-05-12-myrate-context.md` (Phase 0.7에서 생성 — 신규 프로젝트이므로 약식)
- TEST_REPORT.md: 프로젝트 루트 (Phase 3)
- QA_REPORT.md: 프로젝트 루트 (Phase 6)
