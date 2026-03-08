# Система документации проектов

MkDocs — система документации проектов на статическом генераторе сайтов.
**ВАЖНО:** система использует расширенный Markdown.

## Как создать документацию нового проекта

1. Добавить папку с названием проекта в корневой каталог репозитория.
2. Добавить папку `docs` в папку проекта.
3. Добавить index.md в папку `docs`.

## Проекты документации

1. auth - сервис Identity  
2. cadastral - сервис кадастровой информации
3. cryptoservice - сервис работы с электронными подписями
4. examples - не публичный проект, примеры оформления
5. images - изображения, опубликованы по url:`https://rulink.io/images/{filename}`
6. legal - страницы с соглашениями и политиками компании
7. pki - внутренний сервис, информация об удостоверяющих центрах
8. static - legacy проект, сейчас не используется
9. system - документация по настройке системных параметров, одинаковая для разных сервисов.
10. pdfservice - инструменты для работы с PDF

## UTM marks

Метки для сайтов поддержки

``` bash
?utm_source=support&utm_medium=[site]&utm_campaign=[page]

?utm_source=support&utm_medium=pdfservice&utm_campaign=yc-install


?utm_source=share&utm_medium=support
<meta property="og:url" content="https://rulink.io/support/[SITE]?utm_source=share&utm_medium=support">
```

``` md
    <meta property="og:image" content="https://rulink.io/images/cover-system.png">
    <meta name="twitter:card" content="https://rulink.io/images/cover-system.png">
    <meta name="twitter:image" content="https://rulink.io/images/cover-system.png">
```
