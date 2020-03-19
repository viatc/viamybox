#!/bin/bash
#before run this script, please download and unzip package 072
if [ -d /home/pi/viamybox/.git ] ; then
	cd /home/pi/viamybox
	git pull origin master
fi
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

