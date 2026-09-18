# Infrastructure Monitoring Project

Учебный DevOps-проект для мониторинга доступности API, анализа
access-логов, запуска контейнеризированного echo-сервиса и проверки
изменений через GitHub Actions.

## Возможности

- проверка доступности API и HTTP-кода ответа;
- генерация и анализ тестового access-лога;
- подсчёт запросов с кодами 4xx и 5xx;
- определение трёх наиболее активных IP-адресов;
- запуск echo-сервиса и Nginx через Docker Compose;
- автоматическая проверка Bash-скриптов в Pull Request.

## Структура проекта

```text
.
├── .github/workflows/ci.yml
├── nginx/default.conf
├── analyze_logs.sh
├── check_api.sh
├── docker-compose.yml
└── README.md
```

## Требования

- Bash
- curl
- Git
- Docker
- Docker Compose

## Проверка API

```bash
./check_api.sh https://httpbin.org/status/200
echo $?
```

При ответе HTTP 200 скрипт выводит:

```text
API доступен
```

Для недоступного endpoint:

```bash
./check_api.sh https://httpbin.org/status/404
echo $?
```

Ожидается код возврата `1`.

## Анализ логов

```bash
./analyze_logs.sh
```

Скрипт создаёт `access.log` из 360 строк и выводит:

- общее количество запросов;
- топ-3 IP-адреса;
- число ответов с кодами 4xx;
- число ответов с кодами 5xx.

## Docker Compose

Проверка конфигурации:

```bash
docker compose config
```

Запуск:

```bash
docker compose up -d
```

Проверка контейнеров:

```bash
docker compose ps
```

Проверка Nginx-прокси:

```bash
curl http://localhost
```

Ожидаемый ответ:

```text
Monitoring Service Active
```

Остановка:

```bash
docker compose down
```

## CI/CD

Workflow `.github/workflows/ci.yml` запускается при создании или
обновлении Pull Request в ветку `main`.

Пайплайн выполняет:

```bash
bash -n check_api.sh
bash -n analyze_logs.sh
./check_api.sh https://httpbin.org/status/200
```

## Безопасная передача проекта по SSH и SCP

### 1. Создание SSH-ключа

На локальной машине:

```bash
ssh-keygen -t ed25519 -C "user@example.com"
```

Закрытый ключ `~/.ssh/id_ed25519` нельзя передавать другим людям или
публиковать в репозитории.

### 2. Копирование публичного ключа

```bash
ssh-copy-id deploy@example.com
```

Если `ssh-copy-id` отсутствует, публичный ключ из
`~/.ssh/id_ed25519.pub` нужно добавить на сервер в файл:

```text
~/.ssh/authorized_keys
```

Проверка соединения:

```bash
ssh deploy@example.com
```

При первом подключении необходимо проверить fingerprint сервера перед
подтверждением.

### 3. Создание архива проекта

Из корня проекта:

```bash
tar \
  --exclude='.git' \
  --exclude='access.log' \
  --exclude='evidence' \
  -czf infra-monitoring-project.tar.gz .
```

### 4. Передача архива

```bash
scp infra-monitoring-project.tar.gz deploy@example.com:/tmp/
```

### 5. Распаковка и запуск на сервере

```bash
ssh deploy@example.com
mkdir -p ~/apps/infra-monitoring-project
tar -xzf /tmp/infra-monitoring-project.tar.gz \
  -C ~/apps/infra-monitoring-project
cd ~/apps/infra-monitoring-project
docker compose up -d
docker compose ps
```

Архив также можно передать через поток без создания локального файла:

```bash
tar \
  --exclude='.git' \
  --exclude='access.log' \
  --exclude='evidence' \
  -czf - . |
ssh deploy@example.com \
  'mkdir -p ~/apps/infra-monitoring-project &&
   tar -xzf - -C ~/apps/infra-monitoring-project'
```

## Git workflow

Разработка выполнялась в ветке:

```text
feature/monitoring
```

Изменения добавляются в `main` через Pull Request после успешного CI.