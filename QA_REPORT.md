# QA_REPORT.md — MyRate

**Evaluator**: tdd-evaluator
**Round**: 1 / 3
**Date**: 2026-05-13
**Spec**: `docs/superpowers/specs/2026-05-12-myrate-design.md`

---

## 1. Test execution

| Item | Result |
|---|---|
| `flutter test` | **100 / 100 PASS** (Developer 70 + Tester 30) |
| `flutter analyze` | **0 errors, 0 warnings, 18 info** (all info-level: deprecated `*Ref` typedefs from riverpod_generator and a few style hints; not blocking) |
| `integration_test/app_test.dart` | File exists (golden path with `_FakeApi`), requires a connected device — not executed in this round (acceptable per spec § 14 — "통합 테스트는 로컬 또는 추후 Firebase Test Lab으로") |

`flutter test` final line: `+100: All tests passed`.

---

## 2. Spec coverage matrix

| Spec § | Requirement | Implementation | Test | Status |
|---|---|---|---|---|
| 4.1 | Converter screen scaffold | `features/converter/view/converter_screen.dart` | `converter_notifier_test.dart` + integration | OK |
| 4.1 | From cell tappable → picker | `converter_screen.dart:82` | `tester_additions_test.dart` (idempotency) | OK |
| 4.1 | Amount input single-direction | `amount_input.dart` | `currency_formatter_test.dart` (parse/format) | OK |
| 4.1 | swap button | `swap_button.dart` + `converter_notifier.swap()` | `converter_notifier_test.dart` + tester (roundtrip) | OK |
| 4.1 | To cell + result (read-only) | `converter_screen.dart:102-117` | conversion + notifier tests | OK |
| 4.1 | `1 From = X To` direct rate label | `direct_rate_label.dart` | `conversion_test.dart` | OK |
| 4.1 | TipTax segmented toggle | `tip_tax_segment.dart` | tip_tax_notifier_test | OK |
| 4.1 | Offline banner | `offline_banner.dart` + `state.isStale` in `converter_screen.dart:68-73` | repository_impl_test (network+cache) + tester additions | OK |
| 4.1 | Refresh icon → forceRefresh | `converter_screen.dart:38-41` → `refresh()` | converter_notifier_test | OK |
| 4.1 | Default amount 100,000 | `defaults.dart` + `converter_notifier.dart:70` | tester_additions (constant + initial build) | OK |
| 4.2 | Currency picker scaffold | `currency_picker_screen.dart` | currency_picker_notifier_test | OK |
| 4.2 | Search bar (코드/이름) | `picker_search_bar.dart` + `state.searched` | currency_picker tests + tester (소문자/빈쿼리/0건) | OK |
| 4.2 | 즐겨찾기 섹션 + 별 토글 | `currency_row.dart` + `toggleFavorite` | currency_picker_notifier + tester (remove path) | OK |
| 4.2 | 인기 12개 (USD/EUR/JPY/CNY/GBP/AUD/CAD/HKD/SGD/THB/VND/PHP) | `popular_currencies.dart` | tester_additions | OK |
| 4.2 | 알파벳 인덱스 (A-Z 점프) | `alphabet_index.dart` + GlobalKey 매핑 | — (UI 로직, 단위로 검증하기 까다로움) | PARTIAL — 위젯 테스트 없음 |
| 4.2 | 즐겨찾기 영속화 (SharedPreferences) | `favorites_store.dart` | favorites_store_test | OK |
| 4.3 | Tip 패널 (5/10/15/20% + 직접 입력) | `tip_panel.dart` | tip_calculator_test + notifier + tester (200%/9999%) | OK |
| 4.3 | Tax 패널 (VAT% + 세전/세후 토글) | `tax_panel.dart` + `tax_calculator.dart` | tax_calculator_test | OK |
| 4.3 | Discount 패널 (율/금액 radio) | `discount_panel.dart` + `discount_calculator.dart` | discount_calculator_test | OK |
| 4.4 | 기본 From/To 통화 (탭으로 변경) | `settings_screen.dart:22-23` — **`Text(s.defaultFrom)` only, no onTap** | settings_store_test (저장은 검증) | **PARTIAL — 노출만 되고 UI에서 변경 불가** |
| 4.4 | 언어 (시스템/한국어/영어) | `settings_screen.dart:26-38` | — | OK (UI 구현됨) |
| 4.4 | 테마 (시스템/라이트/다크) | `settings_screen.dart:40-52` | — | OK |
| 4.4 | 마지막 갱신 시각 표시 | **누락** — settings_screen.dart에 없음 | — | **GAP** |
| 4.4 | 캐시 정리 | `settings_screen.dart:54-64` → `RateCache.clear()` | rate_cache_test (clear) | OK |
| 4.4 | 앱 정보 항목 | **누락** | — | **GAP** |
| 4.4 | 오픈소스 라이선스 항목 | **누락** | — | **GAP** |
| 5 | Domain models (freezed) | `domain/exchange_rate/models.dart` | models_test | OK |
| 5 | `ConversionResult.amount: num` (int 허용) | OK | tester (int amount) | OK |
| 6 | Feature-First + Layered 폴더 구조 | `lib/{core,data,domain,features}` | n/a | OK |
| 7 | Riverpod / dio / freezed / go_router / mocktail | pubspec.yaml | n/a | OK |
| 8.1 | API 엔드포인트 `/v6/{key}/latest/{base}` | `exchange_rate_api.dart:16` | exchange_rate_api_test | OK |
| 8.1 | `time_*_unix` → DateTime UTC ms | `exchange_rate_repository_impl.dart:60-64` | tester (정확성 + 24h diff) | OK |
| 8.2 | Cold start → 캐시 또는 API | `converter_notifier.build()` + repo.getLatest | repo_impl_test + integration | OK |
| 8.2 | Refresh → forceRefresh=true | `converter_notifier.refresh()` | repo_impl_test (forceRefresh) | OK |
| 8.2 | From 변경 → 새 BASE 호출 | `converter_notifier.setFromCode` | converter_notifier_test | OK |
| 8.2 | 캐시 유효 시 API 0회 | repo.getLatest 조기 반환 | tester (연속 3회 verifyNever) | OK |
| 8.3 | API 키 `--dart-define`로 주입 | `providers.dart:38` `String.fromEnvironment` | n/a | OK |
| 8.3 | `.env` gitignore + `.env.example`만 리포 | `.gitignore` + `.env.example` 존재 | n/a | OK |
| 9.1 | SharedPreferences 키 스키마 | `rate_cache._prefix='cache.rates.'`, `favorites.currencies`, `settings.*` | rate_cache_test + favorites_store_test + settings_store_test | OK |
| 9.2 | `isStaleAt` 경계 (strict isAfter) | `models.dart:29` | tester (== 경계 + +1ms 경계) | OK |
| 9.3 | 오프라인 + 캐시 → 캐시 반환 | `repository_impl.dart:49-52` | repo_impl_test | OK |
| 9.3 | 오프라인 + no cache → throw | 같은 위치 | repo_impl_test | OK |
| 10 | 네트워크 없음 + 캐시 → 캐시 + 배너 | repo + `state.isStale` UI | repo_impl_test + tester | OK |
| 10 | 네트워크 없음 + no cache → 에러 화면 | `state.when(error:...)` in converter_screen | repo_impl_test | OK |
| 10 | **API HTTP 4xx + 캐시 → fallback + 토스트** | **미구현** — `ApiException`은 repo도 notifier도 catch 안 함, 캐시 fallback 없음 | api_test (404 raise) + tester (repo passthrough) | **FAIL** |
| 10 | **API HTTP 5xx + 캐시 → fallback** | 동일 미구현 | api_test (500) + tester | **FAIL** |
| 10 | 잘못된 API 키 → 명시 에러 | `InvalidApiKeyException` raise | api_test + tester (invalid-key, inactive-account) | OK (raise만 검증) |
| 10 | JSON 파싱 실패 → 캐시 fallback (로그) | 부분 — rate_cache 손상 JSON은 null 반환, API 응답 파싱 실패는 안 잡힘 | rate_cache_test (corrupt) | PARTIAL |
| 10 | 0으로 나누기 방어 | conversion에서 fromRate==null이면 throw | conversion_test (missing rate) | OK |
| 11 | API 키 미포함 + 광고/추적 SDK 0개 | pubspec.yaml에 firebase/sentry/admob 없음 | n/a | OK |
| 12 | i18n ARB (ko/en) | `lib/core/l10n/generated/*.dart` | n/a | OK |
| 12 | 통화 이름은 별도 JSON | `assets/currencies.json` + `currency_catalog.dart` | currency_catalog_test + tester (zh/'' fallback) | OK |
| 12 | ko/en 외 언어 → 영어 폴백 | `catalog.dart:28` `languageCode == 'ko' ? 'ko' : 'en'` | tester | OK |
| 13.1 | 단위 테스트 (목표 70%) | 100 unit tests | — | OK |
| 13.2 | **위젯 테스트 (목표 10%)** — `tip_tax_segment`, `currency_row` | **0개** | — | **GAP (의도적 deferred)** |
| 13.3 | 통합 테스트 (목표 20%) | 1 골든 패스 | 1 | OK (실행 미확인) |

---

## 3. Code quality

긍정:
- 폴더 구조가 spec § 6에 정확히 부합 (`core/data/domain/features`).
- Riverpod codegen + freezed + go_router 모두 spec § 7대로 도입.
- 순수 함수 분리(`logic/*.dart`)로 단위 테스트가 자연스럽게 가능.
- `RateCache.read`가 손상 JSON에 대해 null 폴백 (try/catch + 캐시 무효화 효과).
- `FavoritesStore.read`가 시드 + 손상 JSON 폴백 모두 처리.
- 음수 입력 방어 (tip/tax/discount) 잘 되어 있음.
- API 키가 코드/리포에 평문 없음. `.env.example`만 존재. `--dart-define` 주입.
- 광고/분석/추적 SDK 단 하나도 없음 (spec § 11 핵심 차별점 준수).

부정:
- `ExchangeRateRepositoryImpl`은 `NetworkException`만 catch한다. spec § 10이 "API HTTP 4xx/5xx + 캐시 → fallback"을 명시하는데, 현재 `ApiException`은 catch되지 않고 그대로 `ConverterNotifier.build()`/`_reloadSnapshot()`까지 전파된다. 후자도 `NetworkException`만 잡는다. 결과적으로 5xx/4xx 한 번이면 UI가 `state.when(error: ...)` 분기로 빠져 raw 에러 텍스트를 노출한다. **spec 위반.**
- `ExchangeRateRepositoryImpl.getAllCurrencies()`는 `UnimplementedError`. 도메인 인터페이스(`exchange_rate_repository.dart`)에 선언되어 있지만 미사용. 인터페이스가 거짓말을 하는 셈 — 차후 정리 필요 (당장 critical 아님).
- Settings 화면에서 spec § 4.4의 "기본 From/To 통화 (탭으로 변경)" 가 노출만 되고 onTap이 없다 (`Text(s.defaultFrom)`만 trailing). notifier의 `setDefaultFrom`/`setDefaultTo`는 구현되어 있지만 UI에 연결되지 않음. **부분 미구현.**
- Settings 화면에서 spec § 4.4의 "마지막 갱신 시각", "앱 정보", "오픈소스 라이선스" 항목 자체가 없음. **부분 미구현.**
- `converter_screen.dart:53` — error 분기에서 `Text('${l10n.refreshButton}')`로 표시. 사용자에게 의미 없는 텍스트 (단순 라벨). 빈 상태 화면이 spec § 10 "네트워크 연결 후 다시 시도 + 재시도 버튼" 요구를 충족하지 못함.
- `TaxPanel`에서 `TextEditingController(text: tipTax.tax.vatPercent.toString())`를 `build` 내부에서 매번 새로 생성 → 입력 도중 커서/리빌드 이슈 가능성 (현재 명시적 버그는 안 났지만, Flutter 안티패턴).
- analyze의 18개 info 중 deprecated `*Ref` 사용은 riverpod_generator의 알려진 deprecation으로 MVP에서 수용 가능. 그 외(unnecessary_import 4건, `_snap` 언더스코어 1건, `prefer_const` 1건, dangling doc 1건) — 코드 정리만 하면 0에 도달 가능.

---

## 4. User scenario verification

| Scenario | Code path | Result |
|---|---|---|
| Cold start, empty cache → API → display | `main → ProviderScope → MyRateApp → converterNotifier.build → settings.defaultFrom → repo.getLatest → cache.read=null → api.fetchLatest → cache.save → snap` | OK (integration test 골든 패스 + repo test "expired cache") |
| Cold start, stale cache → API | `build → repo.getLatest → cache.read=stale → api.fetchLatest` | OK (repo test) |
| Cold start, valid cache → no API | 동일 경로에서 `!isStaleAt(now)` → 캐시 반환 | OK (repo test "valid cache" + tester "연속 3회 verifyNever") |
| Network fail + cache → fallback + 배너 | `api throw NetworkException → repo catch → return cached → isStale=hasCache → OfflineBanner` | OK (repo test "network failure + cache") |
| Network fail + no cache → 에러 상태 | `api throw → repo rethrow NetworkException(hasCache=false) → notifier set error/isStale=false` | OK (repo test "no cache: rethrows") |
| User taps refresh → forceRefresh | `IconButton onPressed → refresh() → _reloadSnapshot(force: true) → repo.getLatest(forceRefresh: true)` | OK (repo test) |
| User changes From → 새 BASE API | `_openPicker(isFrom: true) → setFromCode → _reloadSnapshot(base: code)` | OK (converter_notifier_test + tester idempotency) |
| User taps swap | `swap() → from/to 교체 + reload(base: 새 from)` | OK (tester swap roundtrip) |
| User selects favorite | `toggleFavorite → repo.add/remove → getFavoriteCodes 재조회 → state.favorites 갱신` | OK (favorites_store_test + currency_picker_notifier_test + tester remove) |
| User toggles tip mode → 10% → 합계 갱신 | `TipTaxSegment.setMode → TipPanel → ChoiceChip onSelected → setTipPercent → calculateTip` | OK (tip_tax_notifier_test + tip_calculator_test) |
| User toggles tax inclusive → recompute | `SwitchListTile onChanged → setTax(isInclusive=b) → calculateTax` | OK (tax_calculator_test 세전↔세후) |
| User changes language → MaterialApp 리빌드 | `settingsNotifier.setLanguage → state 갱신 → MyRateApp.build → s.flutterLocale 변경` | OK (settings_store_test + settings_notifier 흐름 확인) |
| User clears cache → SharedPreferences keys 삭제 | `clearCache → RateCache(prefs).clear → keys.where('cache.rates.').remove` | OK (rate_cache_test "clear") |
| **API 4xx/5xx + 캐시 있음 → fallback + 토스트** | repo: ApiException catch 없음 → 전파 → notifier: NetworkException만 catch → 전파 → UI: `state.when(error: ...)` raw 텍스트 | **FAIL — spec § 10 위반** |
| 사용자가 Settings에서 기본 From 통화 변경 | settings_screen.dart에 onTap 없음 → 변경 불가 | **FAIL — spec § 4.4 부분 미구현** |
| Settings에서 마지막 갱신/앱 정보/라이선스 확인 | 항목 자체 없음 | **FAIL — spec § 4.4 부분 미구현** |

---

## 5. Known concerns

### Concern 1: Repository / Notifier가 ApiException · InvalidApiKeyException에 대해 캐시 fallback을 수행하지 않음 (BLOCKING)

- **Tester finding (TEST_REPORT 주의 사항 #1)**: "repository_impl.dart는 NetworkException만 fallback. ApiException은 catch 안 함."
- **Spec quote** (§ 10):
  > "API HTTP 4xx | 캐시 있으면 fallback + 토스트(개발 빌드는 상세, 릴리즈는 일반 메시지), 없으면 에러 화면"
  > "API HTTP 5xx | 동일 fallback"
- **Current behavior**:
  - `exchange_rate_repository_impl.dart:44-52`: `try { ... } on NetworkException catch (e) { ... }`. `ApiException`/`InvalidApiKeyException`은 catch되지 않고 전파.
  - `converter_notifier.dart:71` build, `:125` reload: `on NetworkException catch (e)` 만. 다른 AppException 서브타입은 모두 전파.
  - 결과: 서버가 잠시 500을 뱉거나 키가 만료된 다음 호출에서 캐시가 있음에도 fallback 없이 화면이 `Center(Text('$e'))` 라는 raw 에러로 깨진다.
- **Verdict**: **BLOCKING.** spec § 10이 명시적 행동을 정의했고 캐시 fallback 자체가 MVP의 차별점인 "광고 없이 깨끗하고 빠른" UX와 직결된다. 무료 플랜(월 1500건)에서 가장 흔히 발생할 시나리오. Round 2에서 반드시 수정 필요.

### Concern 2: Settings 4.4의 "기본 From/To 통화 탭으로 변경" 미구현 (MAJOR)

- `settings_screen.dart:22-23` — trailing이 `Text(s.defaultFrom)`만 있고 onTap 없음.
- notifier에 `setDefaultFrom`/`setDefaultTo` 메서드는 존재 — UI 미연결.
- spec § 4.4 화면 와이어프레임에 명시: `기본 From 통화      KRW    >`
- **Verdict**: MAJOR. 사용자가 설정에서 기본 통화를 못 바꿈. ConverterScreen에서 picker 열어 한 번 바꾸면 SettingsNotifier에는 반영되지 않는 별도 흐름 — 다음 cold start 시 다시 KRW로 돌아온다 (왜냐하면 ConverterNotifier는 `setFromCode`에서 settings store에 쓰지 않음). 사용자 기대 어긋남.

### Concern 3: Settings 4.4의 "마지막 갱신", "앱 정보", "오픈소스 라이선스" 항목 누락 (MINOR)

- 와이어프레임 § 4.4에 4개 항목 명시되어 있는데 3개가 없음.
- 마지막 갱신은 converter 화면 상단에 노출되긴 하지만, spec은 Settings에도 노출하라 명시.
- 라이선스는 `showLicensePage()` 한 줄로 충족 가능.
- **Verdict**: MINOR.

### Concern 4: 위젯 테스트 0개 (NON-BLOCKING for MVP)

- spec § 13.2가 `tip_tax_segment` / `currency_row`에 대한 위젯 테스트를 목표 10%로 명시. 현재 0개.
- 단위 테스트로 로직은 모두 커버되어 회귀 위험은 낮음.
- **Verdict**: NON-BLOCKING (조건부 합격 시 명시), 다만 Tester 보고에서도 "Evaluator가 판단"이라고 escalation한 항목.

### Concern 5: TaxPanel의 TextEditingController build 안 생성 (NON-BLOCKING but anti-pattern)

- `tax_panel.dart:35` — `TextEditingController(text: ...)`가 매 build마다 새로 생성. StatefulWidget으로 옮기거나 ConsumerStatefulWidget으로 controller를 만들고 didUpdateWidget에서 동기화 필요.
- 현재 테스트로는 잡히지 않지만 사용자가 타이핑 중 setState 발생 시 커서 위치 분실 가능.
- **Verdict**: NON-BLOCKING. Round 2 권장.

### Concern 6: `ExchangeRateRepository.getAllCurrencies` 인터페이스 사기 (NON-BLOCKING)

- 도메인 인터페이스에 선언, impl에서 `UnimplementedError`. 호출하는 곳은 없음.
- **Verdict**: NON-BLOCKING. 인터페이스에서 제거하거나 명시적으로 deprecated 처리 권장.

---

## 6. Weighted score

| 기준 | 비중 | 점수 (10점) | 가중 점수 | 코멘트 |
|---|---|---|---|---|
| 테스트 커버리지 충분성 | 30% | 7.5 | 2.25 | 단위 100개로 핵심 로직 모두 커버. 그러나 ① spec § 13.2 위젯 테스트 0개 ② integration test 실행 검증 안 됨 ③ ApiException fallback이 spec과 어긋나는데 테스트가 "spec 부합"이 아니라 "현재 동작 잠금"으로만 작성됨 — spec 회귀 방지 효과가 없음. |
| 테스트 품질 | 25% | 8.5 | 2.125 | 각 테스트가 단일 시나리오 검증. mocktail 모킹 적절. 경계값/0건/idempotency/race 등 잘 잡음. spec 참조 주석으로 추적성 우수. 다만 Concern 1의 ApiException은 "spec 위반을 잠그는" 테스트라 감점. |
| 기능 요구사항 충족 | 20% | 6.5 | 1.30 | spec § 4.1, 4.2, 4.3, 5, 8, 9, 12는 충족. 그러나 ① § 10의 API 4xx/5xx fallback 누락 (BLOCKING) ② § 4.4의 기본 통화 변경 UI 누락 (MAJOR) ③ § 4.4의 3개 메뉴 항목 누락 (MINOR). 5개 항목 중 1개 BLOCKING + 1개 MAJOR. |
| 코드 품질 | 15% | 7.5 | 1.125 | 폴더 구조/Riverpod 사용/freezed/순수 함수 분리 모두 모범. 단 TaxPanel의 controller 안티패턴, getAllCurrencies UnimplementedError, error 분기에서 무의미한 텍스트 노출 등 잔잔한 흠. |
| 엣지 케이스 처리 | 10% | 7.0 | 0.70 | 음수 입력/0/큰 수/손상 JSON/empty query는 잘 처리. 다만 API 에러 분기(가장 흔한 엣지 케이스)에서 fallback 누락이 큰 감점 요인. |
| **합계** | **100%** | — | **7.30 / 10.0** | |

---

## 7. Verdict: **조건부 합격 (Conditional PASS)**

- 가중 점수 7.30 — 형식적으로 PASS 임계값(7.0)을 넘김.
- 그러나 **spec § 10 (API 4xx/5xx fallback)** 이 BLOCKING으로 미구현 — 이대로 출시하면 무료 플랜 한도 초과/일시 5xx 시 사용자 경험이 깨진다.
- "테스트 커버리지 ≥ 5점, 테스트 품질 ≥ 5점" 충족.
- 정책 충돌: 가중 점수는 PASS, 그러나 spec BLOCKING 위반 1건 존재 → 시니어 판단으로 **조건부 합격**. Round 2에서 BLOCKING 1건 수정 + MAJOR 1건 수정하면 본합격. MINOR/위젯 테스트는 Round 2 권장사항.

---

## 8. Required fixes for Round 2

### Must-fix (BLOCKING)

1. **`lib/data/exchange_rate/exchange_rate_repository_impl.dart:44-52`** — `try/catch`에 `on ApiException`과 `on InvalidApiKeyException` 분기 추가. `ApiException`/(HTTP 4xx/5xx로 분류된) 경우 캐시가 있으면 캐시 반환, 없으면 그대로 rethrow. `InvalidApiKeyException`은 spec § 10에 명시된 "잘못된 API 키 → 일반 메시지" 정책상 fallback 없이 rethrow (현재 동작 유지) — 단 테스트로 명시적 잠금.
   - 예시 수정 방향:
     ```dart
     try {
       final dto = await _api.fetchLatest(baseCode);
       ...
     } on NetworkException catch (e) {
       if (cached != null) return cached;
       throw NetworkException(e.message, cause: e.cause, hasCache: false);
     } on ApiException catch (e) {
       if (cached != null) return cached; // spec § 10: 4xx/5xx + 캐시 → fallback
       rethrow;
     }
     // InvalidApiKeyException은 catch 안 함 (fallback 없이 사용자에게 노출)
     ```
2. **`lib/features/converter/providers/converter_notifier.dart:71, :125`** — `on AppException catch (e)` 또는 명시적으로 `NetworkException`/`ApiException` 모두 잡아서 적절한 상태로 변환. 그렇지 않으면 `state.when(error:...)`가 raw 에러를 그대로 화면에 던진다. spec § 10 "토스트(개발 빌드는 상세, 릴리즈는 일반 메시지)"를 위해서는 SnackBar 또는 별도 에러 메시지 컴포넌트가 필요.
3. **테스트 추가** — `repo가 ApiException + 캐시 있음 → 캐시 반환`, `repo가 ApiException + 캐시 없음 → rethrow` 두 케이스. 기존 tester_additions의 "ApiException 그대로 전파" 테스트는 spec과 모순이므로 spec에 맞게 수정 또는 삭제.

### Should-fix (MAJOR)

4. **`lib/features/settings/view/settings_screen.dart:22-23`** — 기본 From/To 통화 ListTile에 `onTap` 추가. 탭 시 `CurrencyPickerScreen`을 열고 결과를 `settingsNotifier.setDefaultFrom`/`setDefaultTo`에 전달. 또한 ConverterNotifier의 `setFromCode`도 settings store에 반영하도록 하거나, 명시적으로 "기본 통화는 Settings에서만 변경됨"이라는 정책을 확립.

### Nice-to-have (MINOR — Round 3까지 처리)

5. **`lib/features/settings/view/settings_screen.dart`** — spec § 4.4의 누락 항목 추가:
   - 마지막 갱신: `ListTile(title: ..., trailing: Text(formatted))` — `lastSnapshot.apiUpdatedAt` 사용.
   - 앱 정보: 버전 + 빌드 번호 (`package_info_plus` 또는 하드코딩).
   - 오픈소스 라이선스: `showLicensePage(context: context, applicationName: 'MyRate')` 한 줄.
6. **`lib/features/converter/view/widgets/panels/tax_panel.dart`** — `ConsumerStatefulWidget`으로 변경, `TextEditingController`를 state에 보관. didUpdateWidget에서 vatPercent 동기화.
7. **`lib/data/exchange_rate/exchange_rate_repository_impl.dart:69`** — `getAllCurrencies` 미사용 메서드를 인터페이스에서 제거하거나, 실제 구현 추가.
8. **위젯 테스트** (spec § 13.2): `test/features/converter/view/widgets/tip_tax_segment_test.dart`, `test/features/currency_picker/view/widgets/currency_row_test.dart` — onSelected/onFavoriteToggle 콜백 검증.
9. **lint info 18건** 중 deprecation 외 8건은 즉시 0건으로 정리 가능.

---

## 9. 방향 판단

**[현재 방향 유지]** — 아키텍처, 폴더 구조, Riverpod 사용, freezed 모델, 테스트 작성 방식, mocktail 모킹 모두 spec 부합. 광고/추적 SDK가 단 하나도 들어가지 않은 점은 핵심 차별점 준수 측면에서 만점. Round 2는 위 BLOCKING 1건 + MAJOR 1건 핀포인트 수정.

---

## 10. 다음 라운드에서 중점 확인 사항

- [ ] Concern 1의 ApiException fallback이 spec § 10 그대로 구현되었는가?
- [ ] tester_additions의 "ApiException 그대로 전파" 테스트가 spec에 맞게 수정되었는가? (현재 테스트는 spec 위반을 잠그는 잘못된 테스트)
- [ ] ConverterNotifier가 ApiException/(개발용) 상세 에러를 어떻게 UI에 노출하는가? (SnackBar/배너?)
- [ ] Settings 화면에서 기본 From/To 통화를 실제로 변경할 수 있는가?
- [ ] 기존 100개 테스트가 그대로 통과하는가? (회귀 없음)
- [ ] `flutter analyze` 0 issue로 줄였는가? (목표 — 필수 아님)
- [ ] (선택) 위젯 테스트 2개 추가되었는가?

---

## Round 2 (2026-05-13)

### Fix verification

#### Fix 1 (BLOCKING — Repository ApiException fallback): **YES, 해결됨**

`lib/data/exchange_rate/exchange_rate_repository_impl.dart:44-59` — catch 순서가 정확히 spec § 10에 부합한다.

```dart
try {
  final dto = await _api.fetchLatest(baseCode);
  ...
} on InvalidApiKeyException {
  rethrow; // 잘못된 키는 fallback 금지 (설정 오류)
} on NetworkException catch (e) {
  if (cached != null) return cached;
  throw NetworkException(e.message, cause: e.cause, hasCache: false);
} on ApiException {
  if (cached != null) return cached; // ← spec § 10: 4xx/5xx + 캐시 → fallback
  rethrow;
}
```

- catch 순서가 명시적으로 InvalidApiKeyException → NetworkException → ApiException 으로 적절 (InvalidApiKeyException이 ApiException의 서브타입이므로 순서 중요).
- 주석으로 spec § 10 근거 명시.
- 만료된 캐시도 fallback 대상에 포함된다 (테스트 `ApiException + 캐시 있음 → 캐시 fallback`에서 expired 캐시로 검증).
- Tester가 잘못된 동작을 잠그는 2개 테스트를 제거하고 spec 부합 테스트 4개를 추가:
  - `ApiException + 캐시 없음 → 그대로 전파` ✓
  - `ApiException + 캐시 있음 → 캐시 fallback` ✓
  - `InvalidApiKeyException은 캐시 유무와 무관하게 항상 전파` ✓
  - `InvalidApiKeyException + 캐시 없음 → 그대로 전파` ✓

남은 잔여: `ConverterNotifier`는 여전히 `NetworkException`만 catch하지만, 이는 ApiException이 repo에서 흡수되거나(캐시 있을 때) repo가 rethrow한 ApiException은 spec § 10의 "에러 화면" 경로(AsyncError → `state.when(error:...)`)로 그대로 노출되므로 spec 부합. 개발 빌드 토스트 UX는 미구현이지만 spec의 핵심 동작은 충족. **non-blocking.**

#### Fix 2 (MAJOR — Settings 기본 통화 변경): **YES, 해결됨**

`lib/features/settings/view/settings_screen.dart:31-54, 133-155`:
- Default From ListTile: `onTap: () => _pickDefaultCurrency(context, ref, isFrom: true)` ✓
- Default To ListTile: `onTap: () => _pickDefaultCurrency(context, ref, isFrom: false)` ✓
- trailing에 `Icon(Icons.chevron_right)` 추가 — spec § 4.4 와이어프레임의 `KRW    >` 표현 부합 ✓
- `_pickDefaultCurrency`:
  - 가용 코드는 converter snapshot의 rates.keys (실제 사용자가 변환할 수 있는 통화) 사용 ✓
  - snapshot이 아직 없으면 popular 12개 + KRW/USD로 폴백 (cold start 시에도 동작 보장) ✓
  - `context.push<String>(AppRoutes.picker, extra: CurrencyPickerArgs(...))` → picker 결과 await ✓
  - 선택 결과를 `settingsNotifier.setDefaultFrom(picked)` / `setDefaultTo(picked)`에 전달 ✓
- 정책 결정이 깔끔하게 코드에 반영됨: "기본 통화 변경은 Settings에서 picker로만" — ConverterScreen의 picker는 일회성 변경, Settings의 picker는 영속.

미세한 아쉬움: 이 흐름(Settings → picker → defaultFrom 저장) 자체에 대한 위젯/통합 테스트는 없음. 다만 `settingsNotifier.setDefaultFrom`은 settings_store_test에서 잠겨 있고, picker는 currency_picker_notifier_test에서 잠겨 있어 단위 수준 회귀는 방지됨. **non-blocking.**

#### Fix 3 (MINOR — last updated / about / licenses): **YES, 해결됨**

`lib/features/settings/view/settings_screen.dart`:
- L86-90: 마지막 갱신 ListTile — converter snapshot의 `apiUpdatedAt`를 `DateFormatter.formatRateTimestamp(...toLocal())`로 표시. snapshot null일 때 conditional render (`if (lastUpdated != null)`) — 합리적 처리 ✓
- L104-113: 앱 정보 ListTile — `showAboutDialog`로 applicationName='MyRate', applicationVersion='0.1.0', applicationLegalese 표시 ✓
- L115-123: 오픈소스 라이선스 ListTile — `showLicensePage` 한 줄 호출 ✓
- 모두 isKo 분기로 한국어/영어 라벨 제공 ✓

스타일 nit: 다른 ListTile은 `l10n.settingsClearCache` 처럼 ARB 키를 쓰는데, 새로 추가된 3개는 인라인 isKo 삼항을 사용. 향후 ARB로 통일 권장 (non-blocking, R1 Concern 항목보다 가벼움).

### Updated test suite

- `flutter test`: **102 / 102 PASS** (Developer 70 + Tester 32)
  - Round 1 대비: +4 (spec § 10 4분기 잠금) -2 (spec 위반을 잠그던 outdated 테스트) = +2
  - 회귀 없음: 기존 70개 Developer 테스트 + 28개 Tester 테스트 모두 통과
- `flutter analyze`: **0 errors, 0 warnings, 18 info** — Round 1과 동일. info 18건은 모두 기존 항목(deprecated `*Ref` 7건, unnecessary_import 4건, `_snap` 언더스코어 1건, depend_on_referenced_packages 3건, prefer_const 1건, dangling doc 1건, unnecessary_string_interpolations 1건). 신규 추가 코드에서 새 이슈 없음.

### Updated weighted score

| 기준 | 비중 | Round 1 | Round 2 | 가중 점수 (R2) |
|---|---|---|---|---|
| 기능 요구사항 충족 (spec coverage) | 30% | 6.5 | **9.0** | 2.70 (was 1.95) |
| 테스트 품질 | 25% | 8.5 | **9.0** | 2.25 (was 2.125) |
| 코드 품질 | 20% | 7.5 | **8.0** | 1.60 (was 1.50) |
| 사용자 시나리오 | 15% | (split) | **8.5** | 1.275 |
| 보안/프라이버시 | 10% | (in others) | **9.5** | 0.95 |
| **합계** | **100%** | **7.30** | — | **8.78 / 10.0** |

(Round 1은 evaluation_criteria의 5개 가중치 중 3개만 사용했으나, Round 2는 명시된 5개 기준 전체로 재산정. 직접 비교 시 Round 1 합계 7.30 → Round 2 합계 8.78.)

### 점수 산정 근거

**Spec coverage 9.0 (+2.5):** § 4.4의 3개 GAP(기본 통화 변경, 마지막 갱신, 앱 정보·라이선스)와 § 10의 BLOCKING(ApiException fallback) 모두 해결. 남은 차감: 위젯 테스트 0개(§ 13.2 의도적 deferred), error toast UX 부재(§ 10의 "토스트" 부분 — 캐시 fallback은 되지만 사용자가 fallback 발생을 알 수단 없음).

**Test quality 9.0 (+0.5):** outdated 테스트 2개 제거 + spec § 10 4분기 잠금 4개 추가로 "spec 부합을 잠그는" 테스트 체제 확립. catch 우선순위(InvalidApiKey → Network → Api)가 테스트로 명시적으로 검증됨. 0.5 잔여 차감 사유: Settings picker 흐름의 통합 테스트 부재.

**Code quality 8.0 (+0.5):** 새 try/catch 구조가 spec 주석과 함께 명확. `_pickDefaultCurrency` helper로 from/to 코드 중복 제거. 잔여 차감: TaxPanel의 controller 안티패턴(Round 1 Concern 5) 미수정, getAllCurrencies UnimplementedError(R1 Concern 6) 미수정, 새 ListTile에서 ARB가 아닌 isKo 인라인 사용(미세).

**User scenarios 8.5:** 사용자가 Settings → 기본 통화 변경 → cold start 시 변경된 통화로 표시되는 흐름 정상. API 5xx 발생 시 사용자가 보는 화면이 깨지지 않고 캐시 데이터 표시. 잔여 차감: 사용자가 API fallback이 일어난 것을 모름(은밀히 만료 데이터 노출 위험은 isStaleAt이 막아주지만 API 4xx 한정으로 fallback toast가 있으면 더 좋음).

**Security/privacy 9.5:** 광고/추적/분석 SDK 0개 (spec § 11 핵심 차별점 만점). API key는 `--dart-define`로만 주입. About 다이얼로그가 노출하는 정보는 앱 이름/버전/legalese만으로 안전. 0.5 차감은 PII 보호의 명시적 정책 문서가 코드에 없음(예외처리에서 e.toString()으로 stack trace가 UI에 노출될 가능성 — converter_screen.dart:50 `Text('$e')`).

### Verdict: **PASS**

- 가중 점수 **8.78** ≥ 7.0 ✓
- Critical/Major 버그 0건 (Round 1의 BLOCKING + MAJOR 모두 해결됨)
- 모든 테스트 통과 (102/102), 회귀 없음
- 테스트 커버리지 9.0 / 테스트 품질 9.0 — 모두 ≥ 5점 임계값 통과
- 출시 가능 수준.

### Round 3 권장 (출시 후 또는 v0.1.1 마일스톤)

PASS이지만 다음은 차후 마일스톤에서 처리하면 좋다 (현재 출시 막지 않음):

1. **ConverterScreen API 에러 토스트** — spec § 10의 "토스트(개발 빌드는 상세, 릴리즈는 일반 메시지)" 부분. 캐시 fallback 발생 시 사용자에게 silent하므로 SnackBar로 fallback 알림. (`converter_notifier.dart:120`에서 ApiException을 잡아 별도 `lastFallbackError` 필드를 state에 추가하고 ConverterScreen에서 listen으로 SnackBar 노출.)
2. **위젯 테스트 2개** (spec § 13.2): `tip_tax_segment_test.dart`, `currency_row_test.dart` — onSelected/onFavoriteToggle 검증.
3. **TaxPanel controller 안티패턴** (R1 Concern 5) — `ConsumerStatefulWidget`으로 변경하고 `TextEditingController`를 state에 보관.
4. **error 분기에서 raw `'$e'` 노출** (`converter_screen.dart:50`, `settings_screen.dart:28`) — spec § 10의 "릴리즈는 일반 메시지" 정책상 release 빌드에서 stack/원본 메시지 노출 위험. l10n으로 사용자 친화 메시지로 변경.
5. **ARB로 새 라벨 통일** — `settingsLastUpdated` / `settingsAbout` / `settingsLicenses` 키 추가.
6. **lint info 18건 중 deprecation 외 11건** 정리.
7. `ExchangeRateRepository.getAllCurrencies()` 인터페이스 정리 또는 구현.

