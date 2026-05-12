# MyRate

광고 없는 환율 계산기 (Flutter).

## Features

- 실시간 환율 (ExchangeRate-API, 161개 통화)
- 팁/세금/할인 계산 통합
- 즐겨찾기 통화, 알파벳 인덱스 검색
- 오프라인 모드 (마지막 캐시 환율 사용)
- 한국어/영어 + 시스템 다크모드 자동 추종
- **광고 0개 · 추적 0개**

## Setup

1. ExchangeRate-API 키 발급: https://www.exchangerate-api.com/sign-up
2. `.env.example`을 `.env`로 복사하고 키 입력.
3. 패키지 설치:
   ```bash
   flutter pub get
   ```
4. 코드 생성 (riverpod, freezed):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. 실행 (API 키 빌드 타임 주입):
   ```bash
   flutter run --dart-define=EXCHANGE_RATE_API_KEY=<your-key>
   ```

## Tech Stack

- Flutter 3.x (Dart 3.x)
- Riverpod, Dio, shared_preferences
- freezed, json_serializable
- go_router, intl

## Docs

- 설계 문서: `docs/superpowers/specs/2026-05-12-myrate-design.md`
- 구현 계획: `docs/superpowers/plans/2026-05-12-myrate.md`

## License

MIT
