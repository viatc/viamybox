#!/bin/bash
## Copyright (C) 2017-2019 ViaMyBox viatc.msk@gmail.com
## This file is a part of ViaMyBox free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## any later version.
##
## You should have received a copy of the GNU General Public License
## along with ViaMyBox in /home/pi/COPIYNG file.
## If not, see <https://www.gnu.org/licenses/>.
##  

VIADIR="/home/pi/viamybox"
a1='/home/pi/viamybox/scripts/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi

#global
ln -s $VIADIR/scripts/via-mybox-func.sh /usr/bin/
ln -s $VIADIR/scripts/via-setup.sh /usr/bin/via-setup.sh
find  $VIADIR -name "*.sh" -exec chmod +x {} +
chown pi:pi -R  $VIADIR/*

#mjpg-streamer
cd $VIADIR/conffiles/mjpg-streamer/mjpg-streamer-experimental
make
make install
cp $VIADIR/scripts/mjpg-streamerd.sh /etc/init.d/
#update-rc.d -f mjpg-streamerd.sh defaults
update-rc.d -f mjpg-streamerd.sh remove

#gstreamer
cd $VIADIR/scripts/gstreamer-record
make install
cd ~

mkdir -p /home/pi/camera/foto
mkdir -p /home/pi/camera/video
mkdir -p /home/pi/camera/audio
chown pi:pi -R /home/pi/camera*

chmod +x $VIADIR/conffiles/viamyboxd

#kodi
# mkdir -p /home/pi/kodi/picons
# sudo cp $VIADIR/conffiles/kodi/picons /home/pi/kodi/
# sudo chown pi:pi -R  /home/pi/kodi/* 

#nginx viamybox.local
service nginx stop
mkdir -p /etc/nginx/conf
htpasswd -cbd /etc/nginx/conf/htpasswd pi raspberry
mkdir -p $VIADIR/temp/backup
sudo mv /etc/nginx/sites-enabled/default $VIADIR/temp/backup/default.bak
cp $VIADIR/conffiles/viamybox.local /etc/nginx/sites-available/ 
ln -s /etc/nginx/sites-available/viamybox.local /etc/nginx/sites-enabled/
chown www-data:www-data -R $VIADIR/www/*
service nginx start

#yandex disk
# mkdir -p /home/pi/yandex.disk/camera
# mkdir -p /home/pi/yandex.disk/camera/video
# mkdir -p /home/pi/yandex.disk/camera/foto
# chown pi:pi -R /home/pi/yandex.disk*

#init viamyboxd
mkdir -p /var/run/viamybox
cp $VIADIR/conffiles/viamyboxd /etc/init.d/
update-rc.d -f viamyboxd defaults

#add strings to sudoers file
AddString="#Via-settings
www-data ALL=(ALL) NOPASSWD: /usr/bin/python, /home/pi/viamybox/www/scripts/mov.py, \\
/home/pi/viamybox/www/scripts/switchMovSensorRec.sh, /home/pi/viamybox/www/scripts/mov.sh, \\
/home/pi/viamybox/www/scripts/via_rec_audio_gstrm.sh, /home/pi/viamybox/www/scripts/via_rec_video_gstrm.sh, \\
/home/pi/viamybox/www/scripts/stopMovSensorRec.sh, /home/pi/viamybox/www/scripts/start_mjpgstrm.sh, \\
/home/pi/viamybox/www/scripts/stop_mjpgstrm.sh, /home/pi/viamybox/www/scripts/via_rec_av_stop.sh, \\
/home/pi/viamybox/www/scripts/via_rec_av_start.sh, /home/pi/viamybox/www/scripts/via_rec_audio_start.sh, \\
/home/pi/viamybox/www/scripts/via_rec_audio_stop.sh, /home/pi/viamybox/www/scripts/start_stop_mjpgstrm.sh, \\
/home/pi/viamybox/www/scripts/on_off_radio.sh, \\
/home/pi/viamybox/scripts/mkvid-mov.sh, /home/pi/viamybox/www/scripts/via_rec_video_ffmpeg.sh, \\
/usr/bin/docker start motioneye, /usr/bin/docker stop motioneye, \\
/home/pi/viamybox/www/scripts/timelapse_start.sh, /home/pi/viamybox/www/scripts/timelapse_stop.sh"
file="/etc/sudoers"
AddStrAfterInFile $file

#-------------------------------version viamybox 0-72---------------------------------
#create viamybox menu in PIXEL
mkdir -p /usr/share/extra-xdg-menus
mkdir -p /etc/xdg/menus/applications-merged

cp /home/pi/viamybox/conffiles/pixel-menu/settings-camera.xpm /usr/share/pixmaps/
cp /home/pi/viamybox/conffiles/pixel-menu/via-mybox32.png /usr/share/pixmaps/
cp /home/pi/viamybox/conffiles/pixel-menu/motioneye.png /usr/share/pixmaps/
cp /home/pi/viamybox/conffiles/pixel-menu/home-assistant.png /usr/share/pixmaps/
cp /home/pi/viamybox/conffiles/pixel-menu/via-camera-initial.desktop /usr/share/applications/
cp /home/pi/viamybox/conffiles/pixel-menu/motioneye.desktop /usr/share/applications/
cp /home/pi/viamybox/conffiles/pixel-menu/home-assistant.desktop /usr/share/applications/
cp /home/pi/viamybox/conffiles/pixel-menu/ViaMyBox.directory /usr/share/desktop-directories/
cp /home/pi/viamybox/conffiles/pixel-menu/ViaMyBox.menu /usr/share/extra-xdg-menus/
cp /home/pi/viamybox/conffiles/pixel-menu/chromium-camera-start.desktop /usr/share/applications/
ln -s /usr/share/extra-xdg-menus/ViaMyBox.menu /etc/xdg/menus/applications-merged/ViaMyBox.menu

#omxiv for raspicast
apt-get install libjpeg8-dev libpng12-dev
cd /home/pi
sudo -u pi bash -c 'git clone https://github.com/HaarigerHarald/omxiv'
cd omxiv
sudo -u pi bash -c 'make ilclient'
sudo -u pi bash -c 'make -j4'
make install

echo "Installation Successfull"



