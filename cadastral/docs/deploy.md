# Развертывание сервиса

## Получить docker image

Загрузите docker image с приложением.

Для загрузки образа потребуется `authorize token`.  
Для получения токена обратитесь в службу поддержки

- email: [hello@rulink.io](mailto:hello@rulink.io)  
- telegram: @rulinkio

Используйте скрипт установки `authorize token` и загрузки образа из registry

``` bash
#!/usr/bin/env bash
set -euo pipefail

IMAGEPATH="cr.yandex/crp9et2dv05vocv8pagt/cadastralservice:latest"

read -rsp 'Введите IAM-токен: ' TOKEN
echo

printf '%s' "$TOKEN" | sudo docker login \
  --username iam \
  --password-stdin \
  cr.yandex
unset TOKEN

sudo docker pull "$IMAGEPATH"
```

!!! note  
    `authorize token` действует около 40 минут, используйте его сразу после получения

Проверьте, что образ получен

``` bash
sudo docker images
```

## Настройка docker container

Для запуска и корректной работы необходимо настроить запуск `docker container`  

1. подключить `docker volume`
2. указать переменные окружения для запуска сервиса

### docker volume

Приложение использует `docker volume` для хранения данных и логов. Выделите каталог на хосте для подключения, как `docker volume`.  

Предоставьте права доступа на каталог.  
Права необходимо предоставить пользователю от имени которого запускается приложение в контейнере (UID=1654)

```bash
sudo chown -R 1654:1654 /path/on/host
```

Каталог подключается к контейнеру в точку монтирования `/opt`

``` yaml
volumes:
- /path/on/host:/opt
```

Для старта приложения необходимо предоставить файлы `appsettings.json` и `nlog.config` в каталоге `resources/` volume на хосте.

Приложение ожидает найти файлы в каталоге `/opt/resources/`:

- `/opt/resources/appsettings.json` — файл конфигурации. Загрузить тут: [https://rulink.io/public/resources/appsettings.json](https://rulink.io/public/resources/appsettings.json)  
- `/opt/resources/nlog.config` — конфигурация логирования. Загрузить тут: [https://rulink.io/public/resources/nlog.config](https://rulink.io/public/resources/nlog.config)

### Переменные окружения

Переменные задаются через `env_file: .env` (файл `.env` в одном каталоге с `compose.yaml`).  
Образец файла `.env`:

```text
# CadastralService settings
CADASTRALSRV_APIKEY=01a0dafe-6d52-7776-aad2-2c4823e01a28

# CadastralService Open API configuration
CADASTRALSRV_CONTACT_NAME="ПОДДЕРЖКА ОБЛАКОТЕХ"
CADASTRALSRV_CONTACT_EMAIL=support@rulink.io
CADASTRALSRV_CONTACT_URL=https://rulink.io/support/cadastral

# CadastralService PROXY FOR BROWSER 
#CADASTRALSRV_PROXY_URL = https://myproxy.example.com:8080
#CADASTRALSRV_PROXY_USERNAME=myusername
#CADASTRALSRV_PROXY_PASSWORD=mypassword

# CAPTCHAService
CAPTCHA_SERVICE_URL=https://ocr.rulink.io/api/v1/
```

#### `cadastralservice`

| Переменная | Обязательна | Назначение |
|---|---|---|
| `CADASTRALSRV_APIKEY` | да | API-ключ для начальной аутентификации |
| `CAPTCHA_SERVICE_URL` | да | URL сервиса распознавания CAPTCHA (используйте `https://ocr.rulink.io/api/v1/`) |
| `CADASTRALSRV_CONTACT_NAME` | нет | Имя контакта в документации OpenAPI |
| `CADASTRALSRV_CONTACT_EMAIL` | нет | Email контакта в документации OpenAPI |
| `CADASTRALSRV_CONTACT_URL` | нет | URL контакта в документации OpenAPI |
| `CADASTRALSRV_PROXY_URL` | нет | Прокси для исходящих запросов |
| `CADASTRALSRV_PROXY_USERNAME` | нет | Логин прокси |
| `CADASTRALSRV_PROXY_PASSWORD` | нет | Пароль прокси |

### Пример `docker compose`

```yaml
services:
  cadastralservice:
    image: "cadastralservice:latest"
    ports:
      - "127.0.0.1:8080:8080"
    volumes:
      - /path/on/host:/opt
    init: true
    restart: unless-stopped
    shm_size: "1gb"
    mem_limit: 3g
    mem_reservation: 1g
    cpus: 2.0
    pids_limit: 200
    logging:
      driver: "journald"
      options:
        tag: "cadastralservice"
    env_file: .env

```

!!! note  
    Приложение использует браузерный движок Playwright, который может потреблять значительные ресурсы.  
    Рекомендуется ограничить ресурсы контейнера
    (`shm_size`, `mem_limit`, `mem_reservation`, `cpus`, `pids_limit`).

## Запуск docker container

Запустите контейнеры как сервис в фоновом режиме

```bash
sudo docker compose up -d
```

Проверьте, что контейнеры запущены

```bash
sudo docker ps
```

Проверьте логи

```bash
sudo docker compose logs -f
```

## Публикация сервиса

### Доменное имя

Укажите DNS-запись (A-запись), ведущую на публичный IP-адрес сервера.

### Reverse Proxy (Nginx)

Nginx выступает reverse proxy перед контейнерами: `cadastralservice` на `127.0.0.1:8080`.

```nginx
server {
    listen 443;
    server_name <domain>;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Проверьте конфигурацию и перезагрузите nginx

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### SSL сертификаты

Настройте SSL-сертификат, например, через Let's Encrypt / certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d <domain>
```

## Исходящие соединения

Для работы сервису требуется доступ к следующим внешним ресурсам:

- ocr.rulink.io — сервис распознавания CAPTCHA
- rosreestr.ru — сервисы Росреестра

## Проверка работы

### healthbeat

```bash
curl -s http://127.0.0.1:10009/api/heartbeat   
```

### web

```bash
curl -s https://<domain>/
```

### api

```bash
curl -s https://<domain>/api/openapi
```

## Интеграция по API

Развернутый сервис предоставляет REST API для интеграции с внешними системами.  
Описание API: [https://cadastral.rulink.io/api/openapi](https://cadastral.rulink.io/api/openapi?utm_source=support&utm_medium=cadastral)  

Сервис предоставляет элементарную авторизацию по API-ключу.  
API-ключ доступа задается переменной окружения `CADASTRALSRV_APIKEY` в файле `.env`.

Если вам необходимо запустить надежную авторизацию для REST API - обратитесь в службу поддержки.

## Ссылки

Сервис: [https://cadastral.rulink.io](https://cadastral.rulink.io?utm_source=support&utm_medium=cadastral)  
Описание сервиса: [https://promo.rulink.io/cadastral](https://promo.rulink.io/cadastral?utm_source=support&utm_medium=cadastral)  
Поддержка по сервису: [https://rulink.io/support/cadastral](https://rulink.io/support/cadastral?utm_source=support&utm_medium=cadastral)  
API: [https://cadastral.rulink.io/api/openapi](https://cadastral.rulink.io/api/openapi?utm_source=support&utm_medium=cadastral)