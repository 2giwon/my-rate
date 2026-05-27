#!/usr/bin/env bash
# MyRate 실행 헬퍼 — .env에서 API 키를 읽어 --dart-define-from-file로 주입
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "ERROR: .env 파일이 없습니다. .env.example을 복사하고 OPEN_EXCHANGE_RATES_APP_ID를 채워주세요."
  exit 1
fi

# .env 형식 검증
if ! grep -q "^OPEN_EXCHANGE_RATES_APP_ID=." .env; then
  echo "ERROR: .env에 OPEN_EXCHANGE_RATES_APP_ID 값이 비어있습니다."
  exit 1
fi

echo "MyRate 실행 — Flutter --dart-define-from-file=.env"
exec flutter run --dart-define-from-file=.env "$@"
