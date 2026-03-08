# Публикация сервисов в Nginx

Каждый сервис публикуется через отдельный конфигурационный файл **nginx**

Для всех публикуемых сервисов, выполните следующее:

1. Отредактируйте файл `/opt/services/z-config/nginx_sites/{service}`
2. Укажите корректное доменное имя для публикации сервиса (в двух местах)
3. Укажите корректный файл конфигурации ssl для сервиса
    - Для wildcard-сертификатов авторизованного центра: см. [TLS-сертификаты](tls.md?utm_source=support&utm_medium=system), Настройка, Шаг 2.
    - Для самоподписанных сертификатов: см. [TLS](tls.md?utm_source=support&utm_medium=system), «Как создать и настроить самоподписанный сертификат», Пункт 2.

Пример файла:

``` yaml
server {
        listen 443 ssl;
        server_name mysite.pbank.ru;          # <--- АКТУАЛЬНОЕ ДОМЕННОЕ ИМЯ
        include snippets/wildcard-pbank.ru.conf; # <--- ФАЙЛ КОНФИГУРАЦИИ SSL
        ...
}

server {
        listen 80;
        server_name mysite.pbank.ru;          # <--- АКТУАЛЬНОЕ ДОМЕННОЕ ИМЯ
        ...
}
```

После того, как все файлы в `nginx_sites` будут актуализированы, выполните скрипт:

``` bash
sudo bash -c /opt/services/z-config/update-nginx.sh
```

Проверьте доступность сервиса по доменному имени в браузере.
