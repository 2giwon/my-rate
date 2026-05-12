# Brownfield Context — MyRate (Greenfield 약식)

**작성일**: 2026-05-12
**대상**: 2026-05-12-myrate-design.md
**상태**: Greenfield (신규 프로젝트)이므로 영향 파일 분석 약식 수행

---

## 프로젝트 유형

**Greenfield**: 신규 디렉토리 (`~/Documents/my-rate`)에서 시작.
기존 코드베이스가 없으므로 모노레포 영향 범위 누락 리스크는 **없음**.

기존 cheezeproject 모노레포(`~/Documents/cheezeproject/*`)와 격리됨.
모노레포 가이드(CLAUDE.md의 cheezeproject 섹션)와는 무관한 독립 프로젝트.

---

## 추출 키워드 (도메인/기술)

### 도메인
- 환율 (exchange rate)
- 통화 (currency)
- 통화 코드 (currency code, ISO 4217)
- 즐겨찾기 (favorites)
- 팁/세금/할인 (tip/tax/discount)
- 변환 (conversion)
- 캐시 (cache)
- 오프라인 (offline)

### 모델
- `Currency`
- `ExchangeRateSnapshot`
- `ConversionResult`
- `TipState`, `TaxState`, `DiscountState`
- `TipTaxMode` (enum)

### 외부 의존성
- ExchangeRate-API (https://www.exchangerate-api.com)
- ISO 4217 통화 코드 데이터
- 국가 플래그 이모지 (Unicode)

---

## 영향 파일 매트릭스 (해당 없음)

| 카테고리 | 파일 경로 | 영향 종류 | 수정 필요 |
|---|---|---|---|
| - | (해당 없음, 신규 프로젝트) | - | - |

신규 생성 파일 목록은 design.md 섹션 6(폴더 구조) 및 Phase 1(writing-plans)에서 상세화.

---

## FK 영향 분석

**해당 없음** — 모바일 앱 단독, 백엔드/DB 스키마 없음.

---

## 공통 컴포넌트 consumer 분석

**해당 없음** — 신규 프로젝트, 공통 컴포넌트도 신규 작성.
다만 향후 작업 시 다음을 인지:

- `core/utils/currency_formatter.dart` — 통화 포맷팅 유틸. 모든 화면에서 import 예정.
- `domain/exchange_rate/models.dart` — 도메인 모델. data/features 양쪽 레이어에서 참조.
- `domain/exchange_rate/exchange_rate_repository.dart` — 추상 인터페이스. `data` 레이어의 impl, `features` 레이어의 provider가 의존.

이들 파일은 Phase 1 이후 변경 시 **consumer 전수 조사 규칙**(CLAUDE.md 코드 수정 시 관련 코드 전수 조사 규칙)이 적용됨.

---

## 신규 도입되는 외부 의존성 (보안/라이선스 검토 대상)

| 패키지 | 라이선스 | 용도 | 비고 |
|---|---|---|---|
| `flutter_riverpod` | MIT | 상태관리 | |
| `riverpod_annotation` | MIT | Riverpod 코드 생성 | dev_dependencies |
| `riverpod_generator` | MIT | 빌드 러너 | dev_dependencies |
| `dio` | MIT | HTTP 클라이언트 | |
| `shared_preferences` | BSD-3 | 로컬 저장 | |
| `freezed` | MIT | 불변 모델 | dev_dependencies |
| `json_serializable` | BSD-3 | JSON 직렬화 | dev_dependencies |
| `intl` | BSD-3 | 다국어, 포맷팅 | |
| `flutter_dotenv` | BSD-3 | .env 로드 | 개발용 폴백 |
| `go_router` | BSD-3 | 라우팅 | |
| `mocktail` | MIT | 테스트 모킹 | dev_dependencies |

모두 OSS-친화적 라이선스. Public 리포 배포 가능.

---

## API 키 / 시크릿 관리

- ExchangeRate-API 키 1개 필요.
- 저장 위치: `~/Documents/my-rate/.env` (gitignore).
- 빌드 타임 주입: `--dart-define=EXCHANGE_RATE_API_KEY=$KEY`.
- 리포에는 `.env.example`(키 값 비어있음)만 포함.
- README에 키 발급 절차 안내 필요.

---

## Context Score

**0.95** — 그린필드라 외부 영향 분석이 거의 무의미. 외부 API와 라이브러리 라이선스만 검토 완료.

### 미확인 영역
- 통화 161개 전체에 대한 한국어/영어 번역 데이터 출처 — Phase 2에서 결정 (i18n_currencies CSV 또는 직접 구성)
- 국가 플래그 이모지 매핑 — ISO 4217 코드 → 국가 코드 → 플래그 이모지 변환 라이브러리 또는 수동 매핑

이 두 항목은 Phase 1(writing-plans)에서 데이터 소스를 결정.

### 추가 grep 키워드 (해당 없음)
신규 프로젝트라 미해당.

---

## 다음 단계

Phase 1 (writing-plans)에서:
- 통화 데이터(코드, 이름, 플래그) 소스 결정
- API 키 발급 절차 및 README 작성 태스크 포함
- 단계별 bite-sized 태스크 작성 (TDD: Red → Green → Refactor)
