------------------------------------------Проект ViaMyBox это------------------------------------------------
ViaMyBox это raspberry pi проект. Он объединяет в себе несколько функциональных идей и возможность упрощенного управления этим функционалом.  
Управление функционалом осуществляется через консольный скрипт via-setup.sh , через Home Assistant консоль а так же мини-вэб интерфейс.
Я объединил в проекте ViMyBox некоторые идеи, найденные на просторах интернета, которые кажутся мне интересными, и возможностью 
быстрой настройки и управления ими. Основной функционал на данный момент это видеорегистрация, умный дом на основе Home Assistant,
домашний кинотеатр kodi, Wordpress сервер LNMP. 
Модули Home Assistant, MotionEye являются опциональными, устанавливаюся через утилиту via-setup.sh.
LNMP сервер является опциональным устанавливается отдельно (см /home/pi/viamybox/scripts/lnmp/README).

Дистрибутив ViaMyBox собран и проверен на основе 2019-09-26-raspbian-buster. 

Функционал представляемый пакетом ViaMyBox это:
Видеорегистрация:
- видео запись с синхронизацией звука с usb камеры с помощью gstreamer технологии
- аудио записи с usb камеры через gstreamer технологии
- timelapse видео запись с usb или csi камеры с помощью ffmpeg
- фоторегистрация через mjpg-streamer
- фоторегистраация по датчику движения hc-sr501
- формирование видео файла после фоторегистрации
- возможность записи аудио и видео на yandex диск

Умный дом Home Assistant на основе docker образа https://github.com/home-assistant/hassio-installer:
- управление через консольную утилиту via-setup.sh docker образом Home Assistant
  инсталляция и удаление образа. Остановка и старт контейнера Home Assiatnt  
- управление через вэб консоль Home Assistant вышеописанными функциями видеорегистрации
- некоторые функции контроля за рraspberry pi. Контроль за температурой процессора,объемом micro sd,
  состоянием источника питания

Домашний кинотеатр Kodi

MotionEye вэб управление на основе docker образа https://hub.docker.com/r/ccrisan/motioneye:
- управление через консольную утилиту via-setup.sh docker образом 
  инсталляция и удаление образа. Остановка и старт docker образа   
- вэб интерфейс видеорегистрации MotionEye

Вэб интерфейс
- управление функциями видеорегистрации

Консольная утилита via-setup.sh
- управление функциями видеорегистрации
- управление docker образами Home Assistant и MotionEye
- управление сервисом inadyn
- управление подключением к удаленному диску yandex на основе webdav

Смените пароль! 
Используйте функции записи viamybox ТОЛЬКО в защищенных сетях!

--------------------------------------Инсталляция проекта ViaMyBox------------------------------------------

-----------Перед инсталляцией-----------------

В проекте используются и будут проинсаллированы nginx mjpg-streamer gstreamer docker kodi и сопутсвующие им пакеты, через
скрипт ~/viamybox/scripts/prepostinstall/00install.sh Пакеты в данном скрипте разбиты на секции.
Просмотрите и исключите секции пакетов не требуемым вам функционалом.

Mjpg-streamer будет проинсталлирован скриптом ~/viamybox/scripts/prepostinstall/01aftercopy.sh
В проекте ViaMyBox используется mjpg-streamer проекта jacksonliam https://github.com/jacksonliam/mjpg-streamer
Если вы используете другой mjpg-streamer исключите из файла 01aftercopy.sh секцию #mjpg-streamer

Если вы используете apache веб сервер или nginx просмотрите в файле секцию #nginx
В проекте ViaMyBox используется веб сервер по адресу /home/pi/viamybox/www по 80 порту
Если 80 порт для веб сервера у вас занят измените порт в файле /home/pi/viamybox/conffiles/viamybox.local
перед инсталляцией.

-------Инсталляция проекта ViaMyBox
УСТАНОВКА ИЗ РЕПОЗИТОРИЯ

cd /home/pi
git clone https://github.com/viatc/viamybox.git

ИЛИ

cd /home/pi
Проект должен быть в папке /home/pi:
unzip viamybox-master.zip -d /home/pi 
mv -r viamybox-master viamybox

ДАЛЕЕ

cd viamybox/scripts/prepostinstall/
Делаем скрипты исполняемыми:
chmod +x ./*.sh
Инсталляция необходимых пакетов:
sudo ./00install.sh
Настройка проекта ViaMyBox:
sudo ./01aftercopy.sh

-------Инсталляция LNMP сервера (опционально)-----------

LNMP сервер, сервер для Wordpress сайта. Включает в себя MySQL, Nginx, PHP + Wordpress оболочка.
Запуск скриптов инсталляции позволит через несколько минут начать инициализацию Wordpress сайта на raspberry pi.
Если вы желаете установить только LNMP сервер. Вы сможете это сделать инсталляцией скриптов в папке lnmp
cd /home/pi
Проект должен быть в папке /home/pi:
unzip viamybox.zip -d /home/pi
cd viamybox/scripts/lnmp/
и запустить 2 скрипта по очереди:
sudo ./00install.sh
sudo ./01via-setup-lamp.sh

-----------После инсталляции---------------
Увеличте размер файловой системы:
sudo raspi-config -> Advanced options -> Expand Filesystem
Обновите ViaMyBox:
sudo via-setup.sh 
Развертывание  удаление и управление docker образом Home Assistant осуществляется через 1 пункт меню :
sudo via-setup.sh 
Далее, подключитесь к Home Assistant http://<ip>:8123 и установите базу:
Вкладка Hass.io -> Snapshots
В качестве источника используется следующий проект:
https://github.com/home-assistant/hassio-installer
Для веб доступа и доступа к Home Assistant
Пользователь по умолчанию pi
Пароль по умолчанию raspberry

Развертывание удаление и управление docker образом MOtionEye осуществляется через 2 пункт меню:
sudo via-setup.sh 
Далее, подключитесь к MotionEye консоли http://<ip>:8133 
Для доступа к MotionEye контейнеру:
Пользователь admin без пароля

Запись видео аудио контента производится в папку:
/home/pi/camera
если подключен yandex disk
/home/pi/camera/yandex.disk 


