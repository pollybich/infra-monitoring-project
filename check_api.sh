#!/usr/bin/env bash

set -u -o pipefail

if [[ $# -ne 1 ]]; then
    echo "Использование: $0 <URL>" >&2
    exit 1
fi

URL="$1"

if ! command -v curl >/dev/null 2>&1; then
    echo "Ошибка: curl не установлен" >&2
    exit 1
fi

HTTP_CODE="$(
    curl \
        --location \
        --silent \
        --show-error \
        --output /dev/null \
        --write-out '%{http_code}' \
        --connect-timeout 5 \
        --max-time 15 \
        --retry 2 \
        --retry-delay 1 \
        "$URL" 2>/dev/null
)"
CURL_EXIT_CODE=$?

if [[ $CURL_EXIT_CODE -ne 0 ]]; then
    echo "API недоступен, код ответа: 000"
    exit 1
fi

if [[ "$HTTP_CODE" == "200" ]]; then
    echo "API доступен"
    exit 0
fi

echo "API недоступен, код ответа: $HTTP_CODE"
exit 1