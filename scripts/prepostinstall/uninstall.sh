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

#uninstallation viamybox
echo "removing viamybox..."
VIADIR="/home/pi/viamybox"
a1='/home/pi/viamybox/scripts/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi

#global
rm  /usr/bin/via-mybox-func.sh
rm  /usr/bin/via-setup.sh

#mjpg-streamer
service mjpg-streamerd.sh stop
update-rc.d -f mjpg-streamerd.sh disable
rm /etc/init.d/mjpg-streamerd.sh

#viamyboxd daemon
service viamyboxd stop
update-rc.d -f viamyboxd remove
rm /etc/init.d/viamyboxd
rm -r /var/run/viamybox


#nginx viamybox.local
service nginx stop
rm /etc/nginx/sites-available/viamybox.local
rm /etc/nginx/sites-enabled/viamybox.local

#delete strings to sudoers file
str="#Via-settings
export "str"
www-data ALL=(ALL) NOPASSWD: /usr/bin/python, /home/pi/viamybox/www/scripts/mov.py, \\
/home/pi/viamybox/www/scripts/switchMovSensorRec.sh, /home/pi/viamybox/www/scripts/mov.sh, \\
/home/pi/viamybox/www/scripts/via_rec_audio_gstrm.sh, /home/pi/viamybox/www/scripts/via_rec_video_gstrm.sh, \\
/home/pi/viamybox/www/scripts/stopMovSensorRec.sh, /home/pi/viamybox/www/scripts/start_mjpgstrm.sh, \\
/home/pi/viamybox/www/scripts/stop_mjpgstrm.sh, /home/pi/viamybox/www/scripts/via_rec_av_stop.sh, \\
/home/pi/viamybox/www/scripts/via_rec_av_start.sh, /home/pi/viamybox/www/scripts/via_rec_audio_start.sh, \\
/home/pi/viamybox/www/scripts/via_rec_audio_stop.sh, /home/pi/viamybox/www/scripts/start_stop_mjpgstrm.sh, \\
/home/pi/viamybox/scripts/mkvid-mov.sh, /home/pi/viamybox/www/scripts/via_rec_video_ffmpeg.sh, \\
/usr/bin/docker start motioneye, /usr/bin/docker stop motioneye, \\
/home/pi/viamybox/www/scripts/timelapse_start.sh, /home/pi/viamybox/www/scripts/timelapse_stop.sh"
file="/etc/sudoers"
deleteStr $file

cd /home/pi
rm -r /home/pi/viamybox
rm viamybox.zip
echo "Successfull"



