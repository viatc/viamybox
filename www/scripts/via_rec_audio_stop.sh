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
#recording video in mkv via gstreamer via-rec-audio.c



StoreAudio="/home/pi/camera/audio"
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

ret=$(ps aux | grep via-rec-audio  | wc -l)
echo "$ret"
if [ "$ret" -gt 1 ]
then {
	SubstParamInFile '/home/pi/viamybox/www/style.css' 'background-image:' 'rec-red-a.gif' 'rec-a.png'
	chown www-data:www-data /home/pi/viamybox/www/style.css
	killall -s SIGINT via-rec-audio
	chown pi:pi $StoreAudio/*
}
fi

exit 0 
