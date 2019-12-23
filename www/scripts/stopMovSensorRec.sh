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
#make time elapsed video
#remove video and audio according to NumberOfSavedHours
#filename=$(date --rfc-3339=date)

a1='/usr/bin/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo " no function library $a1" 1>&2 ; exit 1 ; fi

function stopMovSensorRec ()
{
for KILLPID in `ps ax | grep '/home/pi/viamybox/www/scripts/mov.py' | awk ' { print $1;}'`; do 
  kill -15 $KILLPID;
done
#remove crontab job
/home/pi/viamybox/www/scripts/startMovSensorRec.sh -r

ret=$(ps aux | grep mkvid-mov.sh | wc -l)
if [ "$ret" -eq 1 ] 
	then
	/home/pi/viamybox/scripts/mkvid-mov.sh
fi
} 

stopMovSensorRec

