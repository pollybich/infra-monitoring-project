#!/usr/bin/env bash

set -u -o pipefail

LOG_FILE="${1:-access.log}"
IP_REGEX='^([0-9]{1,3}\.){3}[0-9]{1,3}'

: > "$LOG_FILE"

for i in $(seq 1 360); do
    case $((i % 10)) in
        0|1|2|3|4)
            IP="192.168.1.10"
            ;;
        5|6|7)
            IP="10.0.0.5"
            ;;
        8)
            IP="172.16.0.8"
            ;;
        9)
            IP="203.0.113.25"
            ;;
    esac

    case $((i % 12)) in
        0)
            METHOD="GET"
            PATH_VALUE="/api/health"
            STATUS="500"
            ;;
        1|2)
            METHOD="GET"
            PATH_VALUE="/api/missing"
            STATUS="404"
            ;;
        3)
            METHOD="POST"
            PATH_VALUE="/api/login"
            STATUS="401"
            ;;
        *)
            METHOD="GET"
            PATH_VALUE="/api/users"
            STATUS="200"
            ;;
    esac

    MINUTE=$((15 + (i / 60)))
    SECOND=$((i % 60))

    printf '%s - - [15/Aug/2026:10:%02d:%02d +0000] "%s %s HTTP/1.1" %s\n' \
        "$IP" "$MINUTE" "$SECOND" "$METHOD" "$PATH_VALUE" "$STATUS" \
        >> "$LOG_FILE"
done

TOTAL_REQUESTS="$(grep -Ec "$IP_REGEX" "$LOG_FILE")"

CLIENT_ERRORS="$(
    awk '$NF ~ /^4[0-9][0-9]$/ { count++ }
         END { print count + 0 }' "$LOG_FILE"
)"

SERVER_ERRORS="$(
    awk '$NF ~ /^5[0-9][0-9]$/ { count++ }
         END { print count + 0 }' "$LOG_FILE"
)"

echo "Файл журнала: $LOG_FILE"
echo "Общее количество запросов: $TOTAL_REQUESTS"
echo
echo "Топ-3 IP-адреса:"
grep -Eo "$IP_REGEX" "$LOG_FILE" |
    sort |
    uniq -c |
    sort -nr |
    head -n 3
echo
echo "Количество запросов с кодами 4xx: $CLIENT_ERRORS"
echo "Количество запросов с кодами 5xx: $SERVER_ERRORS"