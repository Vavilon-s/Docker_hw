#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
PROJECT="docker-hw-check-$(date +%s)-$$"
STAGE=подготовка
BACKUP="$ROOT/backups/$PROJECT.tar"
export APP_PORT=0 GREETING='Docker homework check'

dc() {
    docker compose -p "$PROJECT" -f "$ROOT/compose.yaml" "$@"
}

step() {
    STAGE=$1
    printf '\n[%s]\n' "$STAGE"
}

cleanup() {
    local result=$?
    trap - EXIT
    if [ "$result" -ne 0 ]; then
        printf 'FAIL: этап «%s»\n' "$STAGE" >&2
    fi
    if ! dc down -v --remove-orphans --timeout 10; then
        printf 'FAIL: очистка тестового проекта\n' >&2
        result=1
    fi
    if [ "$result" -eq 0 ]; then
        printf 'PASS: все проверки пройдены, тестовый проект и volume удалены.\n'
        printf 'Резервная копия: %s\n' "$BACKUP"
    fi
    exit "$result"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

request() {
    local response status
    response=$(curl --noproxy '*' -sS --connect-timeout 2 --max-time 5 \
        -X "$1" -w $'\n%{http_code}' "$URL$2")
    status=${response##*$'\n'}
    BODY=${response%$'\n'*}
    printf '%s %s → HTTP %s %s\n' "$1" "$2" "$status" "$BODY"
    [ "$status" = "$3" ]
}

check_count() {
    printf '%s' "$BODY" | dc exec -T app python -c \
        'import json,sys; n=json.load(sys.stdin)["count"]; assert n==int(sys.argv[1]), f"count={n}, expected={sys.argv[1]}"' "$1"
}

step '1. Запуск отдельного проекта с пустым хранилищем'
printf 'Проект: %s\n' "$PROJECT"
dc up -d --build --wait --wait-timeout 90
URL="http://$(dc port app 8000)"

step '2. Начальный счётчик 0 и три увеличения'
request GET / 200
check_count 0
for n in 1 2 3; do
    request POST /increment 200
    check_count "$n"
done

step '3. Пересоздание только приложения'
dc up -d --no-deps --force-recreate --wait --wait-timeout 90 app
URL="http://$(dc port app 8000)"
request GET / 200
check_count 3

step '4. Отключение и восстановление Redis'
dc stop --timeout 10 redis
request GET /healthz 200
request GET /readyz 503
request POST /increment 503
dc start --wait --wait-timeout 90 redis
request GET / 200
check_count 3
request POST /increment 200
check_count 4

step '5. Согласованная резервная копия'
dc stop --timeout 10 app
dc stop --timeout 10 redis
mkdir -p "$ROOT/backups"
dc run --rm --no-deps -T redis tar -C /data -cpf - . > "$BACKUP"

step '6. Удаление тестового проекта через trap'
