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

StoreVideo="/home/pi/camera/video"
# via_rec_av_exec="via-rec-av-c270"
EXECFILE="/sbin/via-rec-av-c270"

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

stopRecAV(){
	SubstParamInFile '/home/pi/viamybox/www/style.css' 'background-image:' 'rec-red-av.gif' 'rec-av.png'
	chown www-data:www-data /home/pi/viamybox/www/style.css
	killall -s SIGINT $proc
	chown pi:pi $StoreVideo/*
}

proc=$(echo $EXECFILE|awk -F/ '{print $3}')
ret=$(ps aux | grep $proc | wc -l)
echo "$ret"
if [ "$ret" -gt 1 ]
then {
stopRecAV
}
fi;

exit 0 
