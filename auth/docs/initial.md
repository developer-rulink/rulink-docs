# Первоначальная настройка сервера аутентификации
Сервис поставляется в виде контейнера Docker, что упрощает процесс развертывания и настройки. Ниже приведены шаги для первоначальной настройки сервера аутентификации.

## Ввод сервиса в эксплуатацию

### Шаг 1. Проверка наличия контейнера
Убедитесь, что контейнер с сервисом аутентификации доступен в вашем окружении Docker. Вы можете использовать следующую команду для проверки:
Выполните команду в терминале:
```bash
sudo docker images
```
Вы должны увидеть что-то подобное:
``` bash
REPOSITORY         TAG       IMAGE ID       CREATED        SIZE
identityservice    latest    f3521e93ccbe   now            211MB
```

Если контейнер отсутствует - сделайте запрос в поддержку.

## Шаг 2. Настройка ресурсов
Для работы сервиса необходимо наличие следующих файлов:
1. appsettings.json - файл конфигурации сервиса
2. jwt_private.key - приватный ключ для подписи JWT токенов
3. jwt_public.key - публичный ключ для проверки JWT токенов (нужен для сервисов, которые будут использовать аутентификацию)


### Файл конфигурации appsettings.json
Создайте файл `appsettings.json` со следующим содержимым:
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Warning",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "ConnectionStrings": {
    "PostgresServerConnection": "Host=your_db_host;Port=5432;Database=your_db_name;Username=your_db_user;Password=your_db_password;"
  },
  "Auth": {
   "Url": "%https://your-domain-name%",
   "Jwt": {
    "PrivateKeyPath": "/opt/resources/jwt_private.key",
    "PublicKeyPath": "/opt/resources/jwt_public.key",
    "Audience": "%YourOrganizationName%"
    }
  },
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://*:9080"
      }
    }
  },
  "AllowedHosts": "*"
}
```
Замените следующие параметры:
- `your_db_host` - адрес вашего PostgreSQL сервера
- `your_db_name` - имя базы данных
- `your_db_user` - имя пользователя базы данных
- `your_db_password` - пароль пользователя базы данных
- `%https://your-domain-name%` - URL, по которому будет доступен сервис аутентификации
- `%YourOrganizationName%` - название вашей организации, которое будет использоваться в качестве аудитории JWT токенов

После замены параметров, сохраните файл `appsettings.json` в папку `/opt/services/updates/static/identity/`.

### Генерация ключей JWT
Установите OpenSSL, если он еще не установлен:
```bash
sudo apt-get install openssl
```


Для генерации пары ключей (приватного и публичного) запустите скрипт 
```bash
sudo bash /opt/services/updates/identity-generate-jwt-keys.sh
```
Вы должны увидеть что-то подобное:
``` bash
.......... ...
+++++
writing RSA key
total 16
-rw-rw-r-- 1 user user  701 Sep  6 02:10 appsettings.json
-rw------- 1 user user 1704 Sep  8 00:38 jwt_private.key
-rw-r--r-- 1 user user  451 Sep  8 00:38 jwt_public.key
-rw-rw-r-- 1 user user 1001 Sep  5 01:48 Nlog.config
```
 
### Настройка базы данных
Убедитесь, что выполнен шаг `Файл конфигурации appsettings.json`. 
Данные для подключения к базе данных будут взяты из `appsettings.json` из папки `/opt/services/updates/static/identity/`.

Выполните команду в терминале:
```bash
sudo /opt/services/updates/identity-initializer/XIdentityDbInitializer %first_user_email% %first_user_password% /opt/services/updates/static/identity/appsettings.json
```
- %first_user_email% - email пользователя, который будет создан с правами администратора
- %first_user_password% - пароль пользователя, который будет создан с правами администратора. Не менее 7 символов.

Вы должны увидеть что-то подобное:
``` bash
...
info: Microsoft.EntityFrameworkCore.Database.Command[20101]
      Executed DbCommand (4ms) [Parameters=[@p0='?', @p1='?' (DbType = Boolean), @p2='?'], CommandType='Text', CommandTimeout='30']
      INSERT INTO "IdentityRelationUserGroups" ("GroupId", "IsDefault", "UserId")
      VALUES (@p0, @p1, @p2)
      RETURNING "Id";
Пользователю 'first@user.me' добавлена роль 'admin'
root@dev-01:/opt/services/updates# mc
```

Выполните обновление и перезапуск сервиса:
```bash
/opt/services/updates/update.identityservice.sh
```
После выполнения команды, сервис аутентификации будет запущен и готов к использованию.
