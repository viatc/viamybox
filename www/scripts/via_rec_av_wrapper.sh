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

StoreAudio="/home/pi/camera/video"
via_rec_av_exec="via-rec-av-c270"
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

startRecAV(){
	SubstParamInFile '/home/pi/viamybox/www/style.css' 'background-image:' 'rec-av.png' 'rec-red-av.gif'
	ret=$(ps aux | grep mjpg_streamer | wc -l)
	if [ "$ret" -eq 2 ] 
		then 
		service mjpg-streamerd stop 
		fi
	/sbin/$via_rec_av_exec
}

stopRecAV(){
	SubstParamInFile '/home/pi/viamybox/www/style.css' 'background-image:' 'rec-red-av.gif' 'rec-av.png'
	killall -s SIGINT $via_rec_av_exec
	chown pi:pi $StoreAudio/*
}

ret=$(ps aux | grep $via_rec_av_exec | wc -l)
echo "$ret"
if [ "$ret" -eq 1 ]
then {
startRecAV
}
else {
stopRecAV
}
fi

exit 0 
