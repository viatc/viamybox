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

# [Varables]
foldername=$(date '+%d-%m-%y_%HH')
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="saveDir"
saveDir=$(grep $VAR $FILE|awk '{print $2}')
StoreFoto="$saveDir/foto"

sourcestream="http://localhost:8080/?action=stream"
#time to sleep between shoots (sleeptime 0 = +-3-5 shots in 1 second----> sleeptime 0,7 = +-1 shoot in 1 seconds etc)
sleeptime=0.1
i=0

makefoldername(){
if [ ! -d $StoreFoto/$foldername ]; then mkdir $StoreFoto/$foldername; fi 
cd $StoreFoto/$foldername
}

makefoldername

while [ TRUE ]; do
	filename=$(date +"%T:")$(printf %06d $i)
	i=$((i+1))
	curl -sS http://localhost:8080/?action=snapshot > $filename #-o /dev/null 2>&1
	if [ ! -d $StoreFoto/$(date '+%d-%m-%y_%HH') ]; then
	   foldername=$(date '+%d-%m-%y_%HH')
	   makefoldername
	fi
	
	sleep $sleeptime
done



