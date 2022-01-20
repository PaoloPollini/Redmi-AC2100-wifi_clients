#!/bin/sh

### Xiaomi Wi-Fi Router Redmi AC2100 (Padavan 3.4.3.9-099_20200507)
### Срипт отслеживает изменение подключенных Wi-Fi устройств к роутеру и отправляет сообщение в Telegram
### Задание для Cronab: */5 * * * * sleep 10; /bin/sh /etc/storage/wifi_clients.sh >> /tmp/wifi_clients.log 2>&1
### (c)saigon Dec 2021

FILE=/tmp/wifi_clients.inf 	# Файл для хранения последнего списка подключенных wi-fi устройств
MSG="%0A"                  	# Будущее сообщение в телеграм. Начинается с переноса строки.

USER=$(nvram get http_username)
PASS=$(nvram get http_passwd)
LANIP=$(nvram get lan_ipaddr)


func_mactoname()  		#Функция возвращает имя устройства по MAC
{
awk -F, -v tmac=$1 '{if ($2==tmac) {printf "%s", $3}}' /tmp/static_ip.inf
}

# Получаем актуальный список мак адресов устройств, подключенных к роутеру
wget -q -O /tmp/clients.asp http://$USER:$PASS@$LANIP/device-map/clients.asp

wificlients=`grep "var wireless" /tmp/clients.asp` 	# Находим нужную нам строку

# Парсим строку как умеем :)
wificlients="${wificlients%\"*}"    			# Отрезаем все после последнего знака "
wificlients="${wificlients//:-???/:-00}"		# Заменяем :-??? на :-00
wificlients=$(echo $wificlients | tr -cd 0-9A-F":""-")  # Удаляем лишнее 
wificlients="${wificlients//:-??/ }"			# Заменяем :-?? пробелом

echo "==> "$(date +%d/%m/%Y" "%T)	# Дата и время (для log файла)
echo "["$wificlients"]"                	# Список актуальных мак адресов (для log файла)

if [ -f "$FILE" ]; then  		# Если файл /tmp/wifi_clients.inf существует
    #echo "$FILE exists."

# Проверка устройств, подключившихся к сети
for mac in $wificlients
do
if ! grep -q "$mac" $FILE; then
    echo "Устройство" $(func_mactoname $mac) "подключилось к сети"
    MSG=$MSG$(echo "%E2%9C%85"$(func_mactoname $mac) "подключен%0A")
fi
done

# Проверка устройств, отключившихся от сети
for mac in $(cat $FILE)
do
if ! echo $wificlients | grep -q "$mac"; then
    echo "Устройство" $(func_mactoname $mac) "отключилось от сети"
    MSG=$MSG$(echo "%E2%9D%8C"$(func_mactoname $mac) "отключен%0A")
fi
done

else                                    # Если файл /tmp/wifi_clients.inf не существует
    echo "$FILE does not exist."
    echo -e $wificlients > $FILE  	# Запись списка мак адресов в файл 
    MSG="%F0%9F%9A%80%0A"               # :)
fi

if [[ "$MSG" != "%0A" ]]; then 		# Если произошли изменения в подключениях

# Проверка наличия Wi-Fi устройств
if [ -z "$wificlients" ]; then
    echo "Нет подключенных Wi-Fi устройств"
    MSG=$MSG"%E2%9E%96 Нет подключенных Wi-Fi устройств %E2%9E%96"
else 
    echo "--== Wi-Fi устройства в сети ==--"
    MSG=$MSG"%E2%9E%96%E2%9E%96 <b>Wi-Fi устройства в сети</b> %E2%9E%96%E2%9E%96%0A"

for mac in $wificlients
do
    let num++
    echo $num". "$(func_mactoname $mac)
    MSG=$MSG$num". "$(func_mactoname $mac)"%0A"
done
fi
    echo -e $wificlients > $FILE  	# Запись списка мак адресов в файл
    MSG="${MSG// H/%20H}"               # Если не сделать замену, сообщение не уходит
    /etc/storage/tg_say.sh $MSG		# Отправка сообщения в Telegram
fi