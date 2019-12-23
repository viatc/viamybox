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
#add job mkvid-mov.sh to crontab
#filename=$(date --rfc-3339=date)

a1='/usr/bin/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo " no function library $a1" 1>&2 ; exit 1 ; fi
file="/etc/crontab"
croncmd="/home/pi/viamybox/scripts/mkvid-mov.sh"
cronjob="59 *   * * *      $croncmd"

function swichStartFfmpegFromSnapshotsToYes
{
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="startFfmpegFromSnapshots"
PARAM="yes"
FirstSubstInFile2 $FILE $VAR $PARAM
}

function startMovSensorRec ()
{

( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -

} 

function stopMovSensorRec ()
{
( crontab -l | grep -v -F "$croncmd" ) | crontab -

ret=$(ps aux | grep mkvid-mov.sh | wc -l)
if [ "$ret" -eq 1 ] 
	then
	bash /home/pi/viamybox/scripts/mkvid-mov.sh
fi

} 


case "$1" in
  --help)
	echo "Usage: $0 or $0 --recvideo" >&2
	;;
  --addcronjob|-a)
	startMovSensorRec
	;;
  --rmcronjob|-r)
	stopMovSensorRec
	;;
  --snapshotsWithFFmpeg)
    swichStartFfmpegFromSnapshotsToYes
	startMovSensorRec
	;;
	
	*)
	echo "Usage: $0 [OPTIONS]
	OPTIONS
	-a, --addcronjob 
		Add job to cron : $cronjob
	-r, --rmcronjob 
		Remove job to cron : $cronjob" >&2
	;;
esac


crontab -l

