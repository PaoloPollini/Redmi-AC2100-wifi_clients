# Redmi AC2100 wifi_clients.sh
Xiaomi Wi-Fi Router Redmi AC2100 (Padavan 3.4.3.9-099_20200507)

Срипт отслеживает изменение подключенных Wi-Fi устройств к роутеру и отправляет сообщение в Telegram

Установка:
1. В роутере должна быть настроена отправка сообщений в Telegram по [инструкции](https://bitbucket.org/padavan/rt-n56u/wiki/RU/%D0%9E%D1%82%D0%BF%D1%80%D0%B0%D0%B2%D0%BA%D0%B0%20%D1%81%D0%BE%D0%BE%D0%B1%D1%89%D0%B5%D0%BD%D0%B8%D0%B9%20%D0%B2%20Telegram)
2. Помещаем файл wifi_clients.sh в папку на роутере /etc/storage/
3. Делаем скрипт исполняемым:
>chmod +x /etc/storage/wifi_clients.sh
4. В web интерфейсе заходим: Администрирование > Сервисы > Задания планировщика (Crontab) и добавляем строку:
>*/5 * * * * sleep 10; /bin/sh /etc/storage/wifi_clients.sh >> /tmp/wifi_clients.log 2>&1
5. Готово.

Как это выглядит в Telegram:

![24652618](https://user-images.githubusercontent.com/98055908/150415596-c7baff6f-4401-4508-bcaf-5eb7d607ae1d.jpg)

Минусы:
1. Из-за использования wget в течение 30 секунд после выполнения скрипта, при попытке зайти в web интерфейс роутера, появляется сообщение:

![24652508](https://user-images.githubusercontent.com/98055908/150416994-6870a3b4-9b6d-4850-ab2f-fdd3df68f1d6.png)

2. Каждые 5 минут в папке /temp перезаписываются три файла: clients.asp, wifi_clients.inf, wifi_clients.log.
