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
# export GST_DEBUG_FILE="/home/pi/viamybox/www/scripts/gst-av.log"
# export GST_DEBUG=*:3

VIADIR="/home/pi/viamybox"
FILECONF="/home/pi/viamybox/conffiles/via.conf"
StoreAudio="/home/pi/camera/video"
EXECFILE="/sbin/via-rec-av-c270"
# via_rec_av_exec="via-rec-av-c270"
#recording video in mkv via gstreamer via-rec-audio.c
# wait_param=$(echo "scale=4;0.04" | bc)
# logfile="/home/pi/viamybox/www/scripts/test.log"
# echo START $(date) > logfile
# echo "$PWD" >> logfile

SubstParamInFile ()
{
FILE=$1
echo "Замена в $1 параметра $2 равного $3 на $4"
sudo sed "/$2/s/$3/$4/g" $FILE > $FILE.new
sudo mv -f $FILE.new $FILE
}

function checkSoundUsbCameraIsBusy {
numCaptureDevice=$(grep "audioCaptureDevice" $FILECONF |awk '{print $2}')
arecord --device plughw:"$numCaptureDevice",0 -s 1 /dev/null 
if [ $? -eq 1 ]; then 
	echo "USB camera sound IS BUSY. Reload usb devices..."
	$VIADIR/scripts/resetusb
fi
}

startRecAV(){
	SubstParamInFile '/home/pi/viamybox/www/style.css' 'background-image:' 'rec-av.png' 'rec-red-av.gif'
	chown www-data:www-data /home/pi/viamybox/www/style.css
	checkSoundUsbCameraIsBusy
	$EXECFILE
}

stopRecAV(){
	SubstParamInFile '/home/pi/viamybox/www/style.css' 'background-image:' 'rec-red-av.gif' 'rec-av.png'
	chown www-data:www-data /home/pi/viamybox/www/style.css
	killall -s SIGINT $EXECFILE
	chown pi:pi $StoreAudio/*
}

ret=$(ps aux | grep mjpg_streamer | wc -l)
if [ "$ret" -gt 1 ]
then {
	echo "mjpg starting" #output text
	service mjpg-streamerd stop
}
fi;

ret=$(ps aux | grep motioneye | wc -l)
if [ "$ret" -gt 1 ]
then {
	#echo "mjpg starting" #output text
    #    sleep 1  #delay
	docker stop motioneye
}
fi

proc=$(echo $EXECFILE|awk -F/ '{print $3}')
ret=$(ps aux | grep $proc | wc -l)
echo "$ret"
if [ "$ret" -eq 1 ]
then {
startRecAV
}
fi;

exit 0 
