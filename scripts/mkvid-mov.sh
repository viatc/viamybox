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


removedDays=365
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="saveDir"
saveDir=$(grep $VAR $FILE|awk '{print $2}')
StoreFoto="$saveDir/foto"
StoreVideo="$saveDir/video"
StoreAudio="$saveDir/audio"


a1='/usr/bin/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "$0 нет библиотеки функций $a1" 1>&2 ; exit 1 ; fi

function setTimestampCreateAVI() {
filename="snapshots-video_$(date '+%d-%m-%y_%HH-%MM')"
foldername=$(date '+%d-%m-%y_%HH')
i=0

while [[ 10#$(date '+%S') -ne 59 ]]; do
sleep 0.5
done
for f in `ls -tr $StoreFoto/$foldername/*|grep -v ts`
do
  timestamp=`stat -c %y $f`
  #echo $timestamp
  convert $f -fill black -fill white -pointsize 15 -draw  "text 5,15 '${timestamp:0:19}'" $f > /dev/null 2>&1
  mv $f $f'ts'.jpg
  i=$((i+1))
done

#ffmpeg -pattern_type glob -i '15*.jpg' -r 10 -vcodec mjpeg $StoreVideo/$filename.mp4
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="startFfmpegFromSnapshots"
PARAM=" yes"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result 
if [ $result = 'Y' ] ;then 
cat $StoreFoto/$foldername/*.jpg | ffmpeg -f image2pipe -r 10 -vcodec mjpeg -i - -vcodec libx264 $StoreVideo/$filename.mp4 > /dev/null 2>&1
fi
}
setTimestampCreateAVI
if [ $(date '+%d-%m-%y_%HH') != $foldername ]; then 
  if [ $(ps aux | grep snapshotmjpg.sh  | wc -l) -lt 2 ]; then
    if [ $(ps aux | grep mov.py  | wc -l) -lt 2 ]; then setTimestampCreateAVI;fi
  fi
fi

find $StoreFoto/ ! -name . -type d -mmin +$((60*24*$removedDays)) -exec rm -rf {} \; -prune
find $StoreVideo/ ! -name . -type f -mmin +$((60*24*$removedDays)) -exec rm -rf {} \; -prune
find $StoreAudio/ ! -name . -type f -mmin +$((60*24*$removedDays)) -exec rm -rf {} \; -prune

chown -R pi:pi $StoreVideo
chown -R pi:pi $StoreFoto
