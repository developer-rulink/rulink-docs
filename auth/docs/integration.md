# Интеграция с сервисом Identity

!!! tip "Highloads"
    Если число пользователей больше 500, рекомендуется использовать сервис на выделенных ресурсах.

## Что надо для интеграции

1. URL вашего сервиса Identity — для подключения к сервису
2. Параметры JWT — для проверки JWT-токена
3. Публичный ключ — для проверки подписи JWT-токена

## Шаг 1. Получить параметры сервиса Identity

Найдите параметры запуска сервиса Identity (в файле `/opt/services/z-config/rulink-compose/.env`) и скопируйте параметры

``` yaml
# Identity service configuration
IDENTITY_SERVICEURL=_URL_ВАШЕГО_IDENTITY_СЕРВИСА       #Например: https://identity-demo.oblakotech.ru
IDENTITY_DOMAIN=_ДОМЕН_В_КОТОРОМ_РАБОТАЮТ_ВАШ_СЕРВИС_  #Например: oblakotech.ru
IDENTITY_AUDIENCE=_НАЗВАНИЕ_КОМПАНИИ                   #Например: oblakotech Рекомендуется как домен
IDENTITY_SKIP_FINGERPRINT=true                         #Например: идентификация с дополнительным фактором защиты. Должно быть как у сервиса Identity
```

Параметры сервиса:

- **IDENTITY_SERVICEURL** — адрес, по которому сервис будет доступен в вашей организации. Используется для отображения параметров интеграции.
- **IDENTITY_DOMAIN** — домен, для которого будет формироваться cookie.
- **IDENTITY_AUDIENCE** — аудитория, для которой будет сформирован JWT. Обычно — название компании.
- **IDENTITY_SKIP_FINGERPRINT** — отключение усиленной проверки JWT. Если удалить параметр, усиленная проверка включится. Рекомендуется `IDENTITY_SKIP_FINGERPRINT=true`.

## Шаг 2. Скопировать открытый ключ подписания JWT токена

Найдите публичный ключ подписи Identity (в файле `/opt/services/z-config/identity/.rulink/jwt_public.key`) и скопируйте файл в директорию сервиса
`/opt/services/z-config/{ВАШ СЕРВИС}/.rulink/jwt_public.key`).

## Шаг 3. Перезапустите сервис

Заполните другие параметры сервиса и перезапустите **docker-compose**.

Выполните скрипт для запуска `docker compose` с новыми переменными:
`update-compose.sh` — для перезапуска сервисов с новыми переменными окружения

``` bash
sudo bash -c /opt/services/z-config/update-compose.sh
```

!!! info
    Переменные интеграции с сервисом Identity должны быть такими же, как у сервиса Identity.
    Если целевой сервис и сервис Identity работают в одном docker compose — этот блок переменных будет общим для обоих сервисов.
