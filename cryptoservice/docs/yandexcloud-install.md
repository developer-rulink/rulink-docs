# Запуск сервиса из Marketplace Yandex Cloud

Вы можете запустить собственную инсталляцию сервиса из Маркетплейса Яндекс Облака.
Страница сервиса на маркетплейсе: [xxx](xxx)

!!! tip "Время на установку"
    Время получения и настройки сервиса из Маркетплейса займёт около 13 минут.

## Что необходимо для начала работы

!!! info
    Сервис Identity и сервис Crypto должны быть в одном домене — это важно для работы механизма cookies.

1. Доменное имя для сервиса Identity (если у вас уже есть Identity-сервис от других продуктов Облакотех — можно использовать его)
2. Доменное имя для сервиса работы с электронной подписью
3. Доступный сервис баз данных **PostgreSQL 17+**
    3.1. Созданная база данных
    3.2. Учётные данные пользователя с доступом к базе данных
    3.3. Пользователь базы данных должен иметь права на создание таблиц и индексов
4. Доступный сервис **объектного хранилища S3**
    4.1. Доступ к `aws_bucket`
    4.2. Ключи доступа к `bucket`
5. Доступ к сервисам **Identity** и **CryptoService** предоставляется по **https**
    5.1. Рекомендуется использовать **wildcard-сертификат** для вашего домена
    5.2. Сервис может сгенерировать самоподписанные сертификаты для вашего домена
    5.3. Инструкция по настройке TLS-сертификатов приведена ниже

!!! info
    Инстанс PostgreSQL может быть создан в Яндекс Облаке. Инструкция: [xxx](xxx)
    Инстанс S3 может быть создан в Яндекс Облаке. Инструкция: [xxx](xxx)

## Установка и настройка

### Шаг 1. Запустите сервис из маркетплейса Яндекс Облака

#### Конфигурация и сайзинг

### Шаг 2. Настройка сервиса Identity

Если у вас еще нет настроенного сервиса Identity — настройте сервис **Identity**. Подробнее о настройке сервиса: [https://rulink.io/support/auth/initial/](https://rulink.io/support/auth/initial/)

Если у вас есть настроенный сервис Identity — перейдите к разделу Шаг 3

### Шаг 3. Настройка сервиса CryptoService

Все пользовательские параметры запуска сервиса хранятся в compose.yaml файле.
Путь к файлу: `/opt/services/z-config/rulink-compose/.env`

#### 3.1. Интеграция с Identity

Скопируйте файл публичного ключа подписи для JWT.
Получите файл `jwt_public.key` и сохраните его в директорию
`/opt/services/z-config/cryptoservice/resources/.rulink/`

ПРИМЕР содержимого файла

``` text
-----BEGIN PUBLIC KEY-----
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
XXXXXXXXXXXXXXXXDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
QQQQQQQWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
SSSSSSXCDF
-----END PUBLIC KEY-----
```

Укажите параметры работы сервиса Identity. Для этого заполните параметры запуска в `compose.yaml` файле.
Путь к файлу: `/opt/services/z-config/rulink-compose/.env`

Укажите переменные:

``` yaml
# Identity service configuration
IDENTITY_SERVICEURL=_URL_ВАШЕГО_IDENTITY_СЕРВИСА       #Например: https://identity-demo.oblakotech.ru
IDENTITY_DOMAIN=_ДОМЕН_В_КОТОРОМ_РАБОТАЮТ_ВАШ_СЕРВИС_  #Например: oblakotech.ru
IDENTITY_AUDIENCE=_НАЗВАНИЕ_КОМПАНИИ                   #Например: oblakotech Рекомендуется как домен
IDENTITY_SKIP_FINGERPRINT=true                         #Например: идентификация с дополнительным фактором защиты. Должно быть как у сервиса Identity
```

!!! info
    Переменные интеграции с сервисом Identity должны быть такими же, как у сервиса Identity.
    Если оба сервиса работают в одном docker compose — этот блок переменных будет общим для обоих сервисов.
    По умолчанию оба сервиса работают в одном docker compose. Если у вас другая конфигурация и вам требуется помощь — обратитесь в поддержку [support@rulink.io](mailto:support@rulink.io).

#### 3.2. Настройка сервиса Crypto

Для работы сервис использует:

- Базу данных
- Объектное хранилище

Переменные для подключения базы данных к сервису:

``` yaml
CS_DB_HOST=_DB_SERVERNAME_
CS_DB_PORT=_DB_SERVICEPORT_
CS_DB_NAME=_DB_NAME_
CS_DB_USER=_DB_USER_
CS_DB_PASSWORD=_DB_USERPASSWORD_
```

База данных должна быть создана.

!!! warning
    Пользователь базы данных должен иметь права на создание таблиц и индексов  
    Рекомендуется назначать пользователю минимальные права (избегайте ролей SUPERUSER, CREATEDB, CREATEROLE, избегайте прав pg_read_all_data / pg_write_all_data).

Укажите переменные для подключения к объектному хранилищу S3:

``` yaml
S3_ENDPOINT=http://localhost:9000
S3_BUCKET_NAME=_YOUR_BUCKET_NAME_
AWS_ACCESS_KEY_ID=_YOUR_ACCESSKEY_
AWS_SECRET_ACCESS_KEY=_YOUR_SECRET_KEY_
#S3_REGION=ru-center-b  #Укажите, если поддерживает ваш провайдер
```

!!! warning
    Используйте объектное хранилище только с авторизацией.

### Шаг 4. Настройка сертификатов и публикация сервисов

!!! note
    Для лучшего пользовательского опыта рекомендуется использовать сертификаты от авторизованных центров сертификации.

Подробная инструкция по настройке wildcard-сертификатов: [Настройка SSL-сертификатов](https://rulink.io/support/system/ssl/)
Подробная инструкция по созданию самоподписанных сертификатов: [Настройка SSL-сертификатов](https://rulink.io/support/system/ssl/)

### Шаг 5. Запуск сервисов

Если вы используете сервис Identity из другой поставки — отключите этот сервис в текущей поставке (см. Настройка Identity).

Выполните скрипты обновления всех настроенных сервисов:

- `update-identity.sh` — для обновления конфигурации сервиса `Identity` (если используете сервис из этой поставки)
- `update-crypto.sh` — для обновления конфигурации сервиса `CryptoService`

``` bash
sudo bash -c /opt/services/z-config/update-identity.sh
```

``` bash
sudo bash -c /opt/services/z-config/update-crypto.sh
```

Выполните скрипт `update-compose.sh` для перезапуска всех сервисов.

``` bash
sudo bash -c /opt/services/z-config/update-compose.sh
```

Если всё сконфигурировано правильно, вывод будет примерно таким:

``` bash
...
Docker compose logs:
cryptoservice-1  | 14:50:35.0816 INFO  [] Microsoft.Hosting.Lifetime Now listening on: http://[::]:8080
cryptoservice-1  | 14:50:35.0839 DEBUG [] Microsoft.AspNetCore.Hosting.Diagnostics Loaded hosting startup assembly WebApplication
cryptoservice-1  | 14:50:35.0855 INFO  [] Microsoft.Hosting.Lifetime Application started. Press Ctrl+C to shut down.
cryptoservice-1  | 14:50:35.0860 INFO  [] Microsoft.Hosting.Lifetime Hosting environment: Production
cryptoservice-1  | 14:50:35.0860 INFO  [] Microsoft.Hosting.Lifetime Content root path: /app
cryptoservice-1  | 14:50:35.0860 DEBUG [] Microsoft.Extensions.Hosting.Internal.Host Hosting started
...
identity-1       | 14:50:35.2779 WARN  [] WebApplication.LogHolder ------ First launch initialization completed ------
identity-1       | 14:50:35.4732 INFO  [] Microsoft.Hosting.Lifetime Now listening on: http://[::]:8080
identity-1       | 14:50:35.4777 INFO  [] Microsoft.Hosting.Lifetime Application started. Press Ctrl+C to shut down.
identity-1       | 14:50:35.4780 INFO  [] Microsoft.Hosting.Lifetime Hosting environment: Production
identity-1       | 14:50:35.4780 INFO  [] Microsoft.Hosting.Lifetime Content root path: /app
-------------------------------
Script completed
-------------------------------
```

### Шаг 6. Проверьте доступность сервисов

Используйте браузер для доступа к сервисам.  
Перейдите по доменному имени сервиса **Identity** в браузере. Сервис должен автоматически переключиться на протокол `https`.  
Будет открыта страница `/auth/login` с формой ввода логина и пароля. Введите логин и пароль — после успешной авторизации будет выполнен автоматический переход на страницу `/auth/account` с данными профиля пользователя.

Перейдите по доменному имени сервиса **CryptoService** в браузере. Сервис должен автоматически переключиться на протокол `https`.  
Будет открыта страница `/` с кратким описанием разделов сервиса.  
Перейдите в раздел **Проверка подписи** — этот раздел доступен без авторизации, доступа к базе данных и объектному хранилищу. Если он открывается, сервис работает.  
Перейдите в раздел **Подписание** — этот раздел доступен только для авторизованных пользователей. Если он открывается, сервис **CryptoService** успешно интегрирован с сервисом **Identity**.  
На странице **Подписание** нажмите кнопку **Новый**, создайте новый пакет документов. Заполните **Описание** и нажмите кнопку **Сохранить**. Добавьте один или несколько файлов в пакет документов. Добавленные файлы должны появиться в пакете. Обновите страницу с пакетом — данные пакета будут отображены.

Сервисы настроены!

### Шаг 7. В случае ошибки

Проверить работу сервисов можно в лог-файлах.
Лог-файлы хранятся в каталоге сервиса `/opt/services/{SERVICENAME}/logs`. Каждый файл хранит логи работы сервиса за одни сутки.

Если настроить сервис самостоятельно не удалось — обратитесь в нашу службу поддержки [support@rulink.io](mailto:support@rulink.io).
