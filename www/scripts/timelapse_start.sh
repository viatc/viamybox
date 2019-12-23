#!/bin/bash
## Copyright (C) 2017-2019 ViaMyBox viatc.msk@gmail.com
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

#snapshot generation and ffmpeg video
#caused viamybox/www/timelapse-start.php , viamybox/www/timelapse-andvideo-start.php

a1='/usr/bin/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi

function stoprecmjpg
{
# ps=${ps -fu root | grep mjpg-streamer-rec-video|grep bash|tr -s ' '|cut -d ' ' -f 2|xargs -r kill}
#ps aux | grep ffmpeg|grep "action=stream"|tr -s ' '|cut -d ' ' -f 2|xargs -r kill 2 > /dev/null
ps=$(ps -fu root | grep mjpg-streamer-rec-video|grep bash|tr -s ' '|cut -d ' ' -f 2)
while kill -9 $ps &> /dev/null;do sleep 0.1;done
ps=$(ps -fu root | grep ffmpeg|grep timelapse-video|tr -s ' '|cut -d ' ' -f 2)
while kill -9 $ps &> /dev/null;do sleep 0.1;done
}


function swichStartFfmpegFromSnapshotsToNo
{
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="startFfmpegFromSnapshots"
PARAM=" no"
FirstSubstInFile2 $FILE $VAR $PARAM
}

function swichStartFfmpegFromSnapshotsToYes
{
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="startFfmpegFromSnapshots"
PARAM="yes"
FirstSubstInFile2 $FILE $VAR $PARAM
}

function startMakeSnapshots {
	ret=$(ps aux | grep timelapse-video_ | wc -l)
	if [ $ret -gt 1 ]; then
		ps aux | grep ffmpeg|grep "action=stream"|tr -s ' '|cut -d ' ' -f 2|xargs -r kill
	fi
	ps=$(ps -fu root | grep snapshotmjpg|grep -v grep|tr -s ' '|cut -d ' ' -f 2)
	# ps -fu root | grep snapshotmjpg|grep -v grep
	if [ -z $ps ]; then
		/home/pi/viamybox/www/scripts/start_mjpgstrm.sh
		/home/pi/viamybox/www/scripts/startMovSensorRec.sh -a
		/home/pi/viamybox/www/scripts/snapshotmjpg.sh
	fi
}

case "$1" in
  --help)
	echo "Usage: $0 or $0 --recvideo" >&2
	;;
  --recvideo)
	swichStartFfmpegFromSnapshotsToYes
	startMakeSnapshots
	;;
  *)
	swichStartFfmpegFromSnapshotsToNo
	startMakeSnapshots
	;;
esac



exit 0 