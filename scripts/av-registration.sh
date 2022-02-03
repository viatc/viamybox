#!/bin/bash
## Copyright (C) 2017-2021 ViaMyBox viatc.msk@gmail.com
## This file is a part of ViaMyBox free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## any later version.
##
## ViaMyBox software is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with ViaMyBox in /home/pi/COPIYNG file.
## If not, see <https://www.gnu.org/licenses/>.
##

VIADIR="/home/pi/viamybox"
a1='/home/pi/viamybox/scripts/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "О$ нет библиотеки функций $a1" 1>&2 ; exit 1 ; fi
# a1='/home/pi/viamybox/scripts/via-setup1.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
# echo "О$ нет библиотеки функций $a1" 1>&2 ; exit 1 ; fi
function AVInstall ()
{
  EchoLine="
Would you like to install ViaMyBox Audio/Video Registration package and:

fswebcam build-essential libjpeg8-dev imagemagick libv4l-dev cmake ffmpeg
libv4l-dev build-essential libjpeg8-dev libpng12-dev imagemagick libv4l-dev cmake git lockfile-progs \
streamer1.0-tools gstreamer1.0-plugins-* x264 gstreamer1.0-omx gstreamer1.0-alsa libgstreamer1.0-* gstreamer1.0-pulseaudio?"
  export EchoLine
  SubmitYN result
   if [[ $result = 'N' ]]; then return 0;fi
  apt-get install fswebcam build-essential libjpeg8-dev imagemagick libv4l-dev cmake ffmpeg	\
  libv4l-dev build-essential libjpeg8-dev libpng12-dev imagemagick libv4l-dev cmake git lockfile-progs \
  streamer1.0-tools gstreamer1.0-plugins-* x264 gstreamer1.0-omx gstreamer1.0-alsa libgstreamer1.0-* gstreamer1.0-pulseaudio \
  -y
  #global
  ln -s $VIADIR/scripts/via-mybox-func.sh /usr/bin/
  ln -s $VIADIR/scripts/via-setup.sh /usr/bin/via-setup.sh
  find  $VIADIR -name "*.sh" -exec chmod +x {} +
  chown pi:pi -R  $VIADIR/*


  #gstreamer
  cd $VIADIR/scripts/gstreamer-record
  make install
  cd ~

  mkdir -p /home/pi/camera/foto
  mkdir -p /home/pi/camera/video
  mkdir -p /home/pi/camera/audio
  chown pi:pi -R /home/pi/camera*

  chmod +x $VIADIR/conffiles/viamyboxd

  #init viamyboxd
  mkdir -p /var/run/viamybox
  cp $VIADIR/conffiles/viamyboxd /etc/init.d/
  update-rc.d -f viamyboxd defaults

  installViaWeb
  # read -n 1 -s -r -p "Press any key to continue"
}

function AVUninstall()
{
  EchoLine="Would you like to remove Audio/Video Registration directories and files in them:
   /home/pi/camera/foto
   /home/pi/camera/video
   /home/pi/camera/audio?
  "
  echo #EchoLine
  SubmitYN result
  if [[ $result = 'N' ]]; then return 0;fi
  rm -r /home/pi/camera/foto
  rm -r /home/pi/camera/video
  rm -t  /home/pi/camera/audio
  EchoLine="Would you like to remove ViaMyBox service?"
  echo #EchoLine
  SubmitYN result
  if [[ $result = 'N' ]]; then return 0;fi

  #viamyboxd daemon
  service viamyboxd stop
  update-rc.d -f viamyboxd remove
  rm /etc/init.d/viamyboxd
  rm -r /var/run/viamybox
}

function installViaWeb () {
  EchoLine="Would you like to install Nginx ViaMyBox Web server (http port 80)?:
  "
  echo #EchoLine
  SubmitYN result
  if [[ $result = 'N' ]]; then return 0;fi
  #nginx viamybox.local
  apt-get install nginx
  service nginx stop
  mkdir -p /etc/nginx/conf
  htpasswd -cbd /etc/nginx/conf/htpasswd pi raspberry
  mkdir -p $VIADIR/temp/backup
  sudo mv /etc/nginx/sites-enabled/default $VIADIR/temp/backup/default.bak
  cp $VIADIR/conffiles/viamybox.local /etc/nginx/sites-available/
  ln -s /etc/nginx/sites-available/viamybox.local /etc/nginx/sites-enabled/
  chown www-data:www-data -R $VIADIR/www/*
  service nginx start
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
  installMJPGStreamer
  # read -n 1 -s -r -p "Press any key to continue"
}

function uninstallViaWeb ()
{
  EchoLine="Would you like to remove ViaMyBox Web Server?"
  echo #EchoLine
  SubmitYN result
  if [[ $result = 'N' ]]; then return 0;fi
  if [ -e /etc/nginx/sites-available/viamybox.local ];then
    service nginx stop
    rm /etc/nginx/sites-available/viamybox.local
    rm /etc/nginx/sites-enabled/viamybox.local
    if [ -e $VIADIR/temp/backup/default.bak ];then
      sudo mv $VIADIR/temp/backup/default.bak /etc/nginx/sites-enabled/default
    fi
  fi
  #delete strings to sudoers file
  str="#Via-settings
  www-data ALL=(ALL) NOPASSWD: /usr/bin/python, /home/pi/viamybox/www/scripts/mov.py,
  /home/pi/viamybox/www/scripts/switchMovSensorRec.sh, /home/pi/viamybox/www/scripts/mov.sh,
  /home/pi/viamybox/www/scripts/via_rec_audio_gstrm.sh, /home/pi/viamybox/www/scripts/via_rec_video_gstrm.sh,
  /home/pi/viamybox/www/scripts/stopMovSensorRec.sh, /home/pi/viamybox/www/scripts/start_mjpgstrm.sh,
  /home/pi/viamybox/www/scripts/stop_mjpgstrm.sh, /home/pi/viamybox/www/scripts/via_rec_av_stop.sh,
  /home/pi/viamybox/www/scripts/via_rec_av_start.sh, /home/pi/viamybox/www/scripts/via_rec_audio_start.sh,
  /home/pi/viamybox/www/scripts/via_rec_audio_stop.sh, /home/pi/viamybox/www/scripts/start_stop_mjpgstrm.sh,
  /home/pi/viamybox/www/scripts/on_off_radio.sh,
  /home/pi/viamybox/scripts/mkvid-mov.sh, /home/pi/viamybox/www/scripts/via_rec_video_ffmpeg.sh,
  /usr/bin/docker start motioneye, /usr/bin/docker stop motioneye,
  /home/pi/viamybox/www/scripts/timelapse_start.sh, /home/pi/viamybox/www/scripts/timelapse_stop.sh"

  file="/etc/sudoers"
  file2="/etc/sudoers.viamybox.bak"
  cp $file $file2
  grep -v "$str" $file > temp && mv temp $file
  echo "Successfully.."

  EchoLine="Would you like to remove Nginx web service?"
  echo #EchoLine
  SubmitYN result
  # apt-get remove nginx
  # apt-get remove nginx-full nginx-light nginx-extras  nginx-common
  if [[ $result = 'N' ]]; then return 0;fi
  service nginx stop
  sudo apt-get remove --purge nginx*
  read -n 1 -s -r -p "Press any key to continue"
}

function timeElapsed ()
{
a1='/home/pi/viamybox/scripts/rec-mjpg-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "О$ нет библиотеки функций $a1" 1>&2 ; exit 1 ; fi
if [ -e  /etc/init.d/mjpg-streamerd.sh ];then
  recvideofunc
else
  MJPGMenuInstall
fi

roof="The mjpg streamer technology allows you to watch streaming video from the camera and record snapshots or take time-lapse videos and record videos with ffmpeg technology.\n
$settings4
$settings5
$settings6
$settings7"

i3=1
while [ $i3 = 1 ]
do
clear
function-roof-menu "$roof"

PS3="Choose paragraph of timelapsed settings menu : "
select timeElapsedMenu in "$str1" \
"$str2" \
"$str3" \
"The place of recording data from the camera photo and timelapsed video" \
"Initialization for yandex disk" \
"Number of days of storage photos and videos recorded on the disk" \
"$str4" \
"$str5" \
"$str6" \
"$str7" \
"Uninstall mjpg-streamer" \
"Quit"
 do
 case $timeElapsedMenu in
	"$str1") "$command1"; clear;recvideofunc;break
	;;
	"$str2") "$command2";clear;recvideofunc;break
	;;
	"$str3") "$command3";clear;recvideofunc;break
	;;
	"The place of recording data from the camera photo and timelapsed video") writeVideoDir;clear;break
	;;
 	"Initialization for yandex disk") writeYandexInit;clear;break
	;;
	"Number of days of storage photos and videos recorded on the disk") writeNumberOfHours;clear;break
	;;
	"$str4") swichRecSnapshotAutoload;clear;i2=0;timeElapsed;break
	 ;;
	"$str5") swichStartFfmpegFromSnapshots;clear;i2=0;timeElapsed;break
	 ;;
	"$str6") swichMJPGStreamerAutoload;clear;i2=0;timeElapsed;break
     ;;
	"$str7") swichRecMJPGStreamerFFMPEG;clear;i2=0;timeElapsed;break
     ;;
  "Uninstall mjpg-streamer") uninstallMJPGStreamer;clear;i2=0;MJPGMenuInstall;break
    ;;
	"Quit") clear;i3=0;av-menu;break;
	;;
    *) echo "Invalid parameter";
#            echo "For help, run $ ME -h";
    exit 1
    ;;
 esac
 done
 done
}

function gstreamerAV ()
{
a1='/home/pi/viamybox/scripts/gstreamerav.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "О$ нет библиотеки функций $a1" 1>&2 ; exit 1 ; fi
gstreamfunc

roof="Gstreamer technology records synchronized video and audio stream from a usb camera.Or recording a simple audio signal.\n
----------------------------------------------------
$settingsRecAV
$settingsRecA
$strChoiceCard"

i2=1
while [ $i2 = 1 ]
do
clear
function-roof-menu "$roof"
#function-roof-menu "$firstMenuStr"
PS3="Select the menu option for recording video and audio: "
select timeElapsedMenu in "Camera selection" \
"Audio record source selection" \
"Record file rotation time in seconds" \
"$str1" \
"$str2" \
"$str3" \
"$str4" \
"Quit"
#"Recording Screen Resolution" \
 do
 case $timeElapsedMenu in
	"Camera selection") changeCamera; clear;break
	;;
	"Audio record source selection") getGstreamerAudioSource; clear; i2=0; gstreamerAV; break
	;;
	"Record file rotation time in seconds") rotationFileInSec;clear;break
	;;
	"$str1") "$strFunc1";gstreamfunc;clear;break
	;;
	"$str2") "$strFunc2";gstreamfunc;clear;break
	;;
	"$str3") swichGstreamerRecAVAutoload;clear;i2=0;gstreamerAV;break
	;;
	"$str4") swichGstreamerRecAAutoload;clear;i2=0;gstreamerAV;break
	;;
 	# "Recording Screen Resolution") sizeScreen;clear;break
	# ;;
	"Quit") clear;i2=0;break;
	;;
    *) echo "Invalid parameter";
#            echo "For help, run $ ME -h";
    exit 1
    ;;
 esac
 done
 done
}

function av-menu-install {
i2=1
while [ $i2 = 1 ]
do
clear
roof="ViaMyBox home video recorder features:
-- Record video with synchronized audio;
-- Recording compressed (timelapsed) video;
-- Control functions of the video recording."
function-roof-menu "$roof" "--nospread"
PS3="
Choose paragraph of A/V Registration- settings menu : "
select avinstallMenu in "Installation A/V Registration packages" \
"Quit"
 do
 case $avinstallMenu in
	"Installation A/V Registration packages") AVInstall;clear;AVFunction;break
	;;
	"Quit") clear;i2=0;break;
	;;
    *) echo "Invalid parameter";
#            echo "For help, run $ ME -h";
    exit 1
    ;;
 esac
 done
 done
}

function installMJPGStreamer
{
	EchoLine="Would you like to install MJPGStreamer camera WebServer (timelapsed foto/video registration)?"
	echo #EchoLine
	SubmitYN result
	if [[ $result = 'N' ]]; then return 0;fi
	#mjpg-streamer
	cd $VIADIR/conffiles/mjpg-streamer/mjpg-streamer-experimental
	make
	make install
	cp $VIADIR/scripts/mjpg-streamerd.sh /etc/init.d/
	#update-rc.d -f mjpg-streamerd.sh defaults
	update-rc.d -f mjpg-streamerd.sh remove
  read -n 1 -s -r -p "Press any key to continue"
}

function uninstallMJPGStreamer
{
  #mjpg-streamer remove
  service mjpg-streamerd.sh stop
  update-rc.d -f mjpg-streamerd.sh disable
  rm /etc/init.d/mjpg-streamerd.sh
}

function av-menu {
  i2=1
  if [ -e /etc/nginx/sites-available/viamybox.local ];then
    str3="Uninstall ViaMyBox Web server"
    func3="uninstallViaWeb"
  else
    str3="Install ViaMyBox Web server"
    func3="installViaWeb"
  fi

  while [ $i2 = 1 ]
  do
  clear
  roof="ViaMyBox home video recorder features:
  -- Record video with synchronized audio;
  -- Recording compressed (timelapsed) video;
  -- Control functions of the video recording.
  ViaMyBox web server for A/V registration controls"
  function-roof-menu "$roof" "--nospread"
  PS3="
  Choose paragraph of A/V Registration- settings menu : "
  select avMenu in "Settings for recording compressed (time elapsed) video mjpgstreamer"\
  "Settings for recording video and audio gstreamer"\
  "$str3"\
  "Quit"
   do
   case $avMenu in
     "Settings for recording compressed (time elapsed) video mjpgstreamer") firstMJPGMenu;clear;break
     # "Settings for recording compressed (time elapsed) video mjpgstreamer") firstMJPGMenu;clear;timeElapsed;break
     ;;
     "Settings for recording video and audio gstreamer") gstreamerAV;clear;av-menu;break
     ;;
     "$str3") "$func3";clear;av-menu;break
     ;;
  	"Quit") clear;i2=0;break;
  	;;
      *) echo "Invalid parameter";
  #            echo "For help, run $ ME -h";
      exit 1
      ;;
   esac
   done
   done
}
# echo 'yes'
function firstMJPGMenu
{
  if [ -e  /etc/init.d/mjpg-streamerd.sh ];then
    recvideofunc
		timeElapsed
	else
		MJPGMenuInstall
	fi
}

function MJPGMenuInstall
{
	i3=1
	while [ $i3 = 1 ]
	do
	clear
  roof="The mjpg streamer technology allows you to watch streaming video from the camera and record snapshots or take time-lapse videos and record videos with ffmpeg technology.\n"
	function-roof-menu "$roof" "--nospread"
	PS3="
	Choose paragraph of A/V Registration- settings menu : "
	select avinstallMenu in "Installation MJPG server" \
	"Quit"
	 do
	 case $avinstallMenu in
		"Installation MJPG server") installMJPGStreamer;clear;i3=0;timeElapsed;break
		;;
		"Quit") clear;i3=0;AVFunction;break;
		;;
	    *) echo "Invalid parameter";
	#            echo "For help, run $ ME -h";
	    exit 1
	    ;;
	 esac
	 done
	 done
}

function AVFunction(){
  packages="
  fswebcam build-essential libjpeg8-dev imagemagick libv4l-dev cmake ffmpeg	\
  libv4l-dev build-essential libjpeg8-dev libpng12-dev imagemagick libv4l-dev cmake git lockfile-progs \
  gstreamer1.0-tools x264 gstreamer1.0-omx gstreamer1.0-alsa gstreamer1.0-pulseaudio \
  gstreamer1.0-plugins-bad-dbg
  gstreamer1.0-plugins-bad-doc
  gstreamer1.0-plugins-bad
  gstreamer1.0-plugins-base-apps
  gstreamer1.0-plugins-base-dbg
  gstreamer1.0-plugins-base-doc
  gstreamer1.0-plugins-base
  gstreamer1.0-plugins-good-dbg
  gstreamer1.0-plugins-good-doc
  gstreamer1.0-plugins-good
  gstreamer1.0-plugins-rtp
  gstreamer1.0-plugins-ugly-dbg
  gstreamer1.0-plugins-ugly-doc
  gstreamer1.0-plugins-ugly
  libgstreamer1.0-0"
  checkPackagesInstalled "$packages"
  # if [  $? = 1 ];then
  # if [ ! -d "/home/pi/camera" ];then
  if [  $? = 1 ] || [ ! -d "/home/pi/camera" ];then
    av-menu-install
  else
    av-menu
  fi
}

# "Installation A/V Registration packages") $strFunc1;mopidy-func;break
# ;;
# installViaWeb
