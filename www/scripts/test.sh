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

echo "exit 55"
echo "exit 555"
# EXECFILE="/sbin/via-rec-av-c270"
# $EXECFILE &
#exit code 151 service is already running
exit 151
