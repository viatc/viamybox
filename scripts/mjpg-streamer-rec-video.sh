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

# [Variables]
source_stream="http://localhost:8080/?action=stream"
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="saveDir"
saveDir=$(grep $VAR $FILE|awk '{print $2}')
destination_directory="$saveDir/video"
destination_file="timelapse-video_$(date '+%d-%m-%y_%HH-%MM')-%02d.avi"
LOG="/home/pi/camera/video/LOG_FFMPEG"
ERR_LOG="/home/pi/camera/video/ERR_LOG_FFMPEG"


trap  "{ rm -f $$; exit 255; }" TERM INT EXIT 
 # exec > $LOG
 # exec 2> $ERR_LOG
		# "-loglevel" "debug" \
while true ;do
destination_file="timelapse-video_$(date '+%d-%m-%y_%HH-%MM-%SS').avi"

ffmpeg -f mjpeg  \
		-use_wallclock_as_timestamps true \
		-i "${source_stream}" \
		-t 3600 \
		-q 10 \
		-vf "drawtext=text='cam-1 %{localtime}': \
		fontcolor=white: box=1: boxcolor=0x00000000@1" \
		"${destination_directory}/${destination_file}" \
		> /dev/null 2>&1

 done
