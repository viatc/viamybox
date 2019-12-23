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
a1='/usr/bin/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo " no function library $a1" 1>&2 ; exit 1 ; fi


function stopMovSensorRec ()
{
ps=$(ps -fu root | grep snapshotmjpg.sh |grep bash|tr -s ' '|cut -d ' ' -f 2)
while kill -9 $ps &> /dev/null;do sleep 0.1;done

/home/pi/viamybox/www/scripts/startMovSensorRec.sh -r
# file="/etc/crontab"
# str="59 *   * * *   pi      sudo /home/pi/viamybox/scripts/mkvid-mov.sh"
# export "str"
# deleteStr $file
#echo "mjpg-streamer stopping..."
#service mjpg-streamerd stop
ret=$(ps aux | grep mkvid-mov.sh | wc -l)
if [ "$ret" -eq 1 ] 
	then
	/home/pi/viamybox/scripts/mkvid-mov.sh &
fi
}

FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="MJPGStreamer"
PARAM=" noautoload"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result 
if [ $result = 'Y' ] ;then 
	/home/pi/viamybox/www/scripts/stop_mjpgstrm.sh
fi

stopMovSensorRec &
exit 0 
