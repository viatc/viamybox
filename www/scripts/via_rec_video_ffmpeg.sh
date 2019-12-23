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
#recording video in mkv via gstreamer via-rec-video.c

a1='/usr/bin/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi

function stoptRecSnapshots ()
{

if [ $# != 0 ]; then
if [ $* = "norestartmjpg" ]; then
echo ""
fi
else 
	FILE="/home/pi/viamybox/conffiles/via.conf"
	VAR="MJPGStreamer"
	PARAM=" noautoload"
	CheckParamInFile "$VAR" "$FILE" "$PARAM" result 
	if [ $result = 'Y' ] ;then 
		/home/pi/viamybox/www/scripts/stop_mjpgstrm.sh
	fi
fi

ret=$(ps aux | grep snapshotmjpg.sh  | wc -l)
if [ "$ret" -gt 1 ];then
	killall -s 15 snapshotmjpg.sh
	ret=$(ps aux | grep mkvid-mov.sh | wc -l)
	if [ "$ret" -eq 1 ] 
		then
		sudo /home/pi/viamybox/scripts/mkvid-mov.sh &
	fi
fi

} 


function startrecmjpg
{
# ps=$(ps -fu root | grep "ffmpeg -f mjpeg"|grep bash|tr -s ' '|cut -d ' ' -f 2)
# ps=$(ps -fu root | grep "ffmpeg -f mjpeg|grep bash")
# if [ -n $ps ]; then
# fi
ps=$(ps -fu root | grep ffmpeg|grep timelapse-video|tr -s ' '|cut -d ' ' -f 2)
if [ -z $ps ]; then
stoptRecSnapshots norestartmjpg
/home/pi/viamybox/scripts/start_mjpgstrm.sh 
/home/pi/viamybox/scripts/mjpg-streamer-rec-video.sh &
fi
}

function stoprecmjpg
{
# ps=${ps -fu root | grep mjpg-streamer-rec-video|grep bash|tr -s ' '|cut -d ' ' -f 2|xargs -r kill}
#ps aux | grep ffmpeg|grep "action=stream"|tr -s ' '|cut -d ' ' -f 2|xargs -r kill 2 > /dev/null
ps=$(ps -fu root | grep mjpg-streamer-rec-video|grep bash|tr -s ' '|cut -d ' ' -f 2)
while kill -9 $ps &> /dev/null;do sleep 0.1;done
ps=$(ps -fu root | grep ffmpeg|grep timelapse-video|tr -s ' '|cut -d ' ' -f 2)
while kill -9 $ps &> /dev/null;do sleep 0.1;done
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="MJPGStreamer"
PARAM=" noautoload"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result 
if [ $result = 'Y' ] ;then 
	/home/pi/viamybox/www/scripts/stop_mjpgstrm.sh
fi
}

case "$1" in
  start)
	startrecmjpg
    ;;
  stop)
    stoprecmjpg
    ;;
  restart|reload|force-reload)
    echo "Error: argument '$1' not supported" >&2
    exit 3
    ;;
  *)
    echo "Usage: $0 start|stop" >&2
    exit 3
    ;;
esac



exit 0 
