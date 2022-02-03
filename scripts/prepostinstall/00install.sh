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

#packets installation for viamybox

sudo apt-get install fswebcam nmon build-essential libjpeg8-dev imagemagick libv4l-dev cmake git ffmpeg	\
python-pip vlc fswebcam nmon libv4l-dev build-essential libjpeg8-dev libpng12-dev imagemagick libv4l-dev cmake git lockfile-progs \
gstreamer1.0-tools gstreamer1.0-plugins-* x264 gstreamer1.0-omx gstreamer1.0-alsa libgstreamer1.0-* gstreamer1.0-pulseaudio \
nginx apache2-utils php7.3-fpm davfs2 python-dbus -y

#kodi kodi-pvr-iptvsimple
sudo apt-get install kodi kodi-pvr-iptvsimple -y

#python install
sudo python -m pip install --upgrade pip
sudo pip install psutil

#docker install
curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi
sudo apt-get install libffi-dev libssl-dev jq -y
sudo apt-get remove python-configparser -y
sudo pip install docker-compose

#version viamybox 0-72 install
