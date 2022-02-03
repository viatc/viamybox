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

#functions recording ffmpeg video and make snapshots from mjpg_streamer
#may be called by via-setup.sh

VIADIR="/home/pi/viamybox"

function checkMutuallyProc ()
{
ret=$(ps aux | grep via-rec-av  | wc -l)

if [ "$ret" -gt 1 ];then
	echo "Attention!!!  Recording Gstreamer A/V stream when MJPG streamer start will be deactivating. Mutually exclusive modes."
	EchoLine="Confirm Deactivation?"
	export EchoLine
	SubmitYN result
	if [[ $result = 'Y' ]];then
		a1='/home/pi/viamybox/scripts/gstreamerav.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
		echo "no function library $a1" 1>&2 ; exit 1 ;fi
		stopGstrmAV
		else statusConfirm="NO";return 0
	fi
fi
statusConfirm="Yes"
}

function startMJPGStreamer ()
{
checkMutuallyProc
	if [[ $statusConfirm = 'Yes' ]];then
	/home/pi/viamybox/scripts/start_mjpgstrm.sh
	fi
}

function stopMJPGStreamer () {
/home/pi/viamybox/www/scripts/stop_mjpgstrm.sh
}
function startRecSnapshots ()
{
checkMutuallyProc
if [[ $statusConfirm = 'Yes' ]];then
	ret=$(ps aux | grep timelapse-video_ | wc -l)
	if [ $ret -gt 1 ]; then
		ps aux | grep ffmpeg|grep "action=stream"|tr -s ' '|cut -d ' ' -f 2|xargs -r kill
	fi
	/home/pi/viamybox/scripts/start_mjpgstrm.sh
	/home/pi/viamybox/scripts/startMovSensorRec.sh --addcronjob
	/home/pi/viamybox/scripts/snapshotmjpg.sh &
fi
}

function stoptRecSnapshots ()
{

if [ $# != 0 ]; then
if [ $* = "norestartmjpg" ]; then
echo ""
fi
else
	FILE="/home/pi/viamybox/conffiles/via.conf"
	VAR="MJPGStreamer"
	PARAM=" noautoload"
	CheckParamInFile "$VAR" "$FILE" "$PARAM" result
	if [ $result = 'Y' ] ;then
		/home/pi/viamybox/www/scripts/stop_mjpgstrm.sh
	fi
fi

ps=$(ps -fu root | grep snapshotmjpg.sh |grep bash|tr -s ' '|cut -d ' ' -f 2)
while kill -9 $ps &> /dev/null;do sleep 0.1;done

# file="/etc/crontab"
# str="59 *   * * *   pi      sudo /home/pi/viamybox/scripts/mkvid-mov.sh"
# export "str"
# deleteStr $file
/home/pi/viamybox/scripts/startMovSensorRec.sh --rmcronjob
ret=$(ps aux | grep mkvid-mov.sh | wc -l)
if [ "$ret" -eq 1 ]
	then
	/home/pi/viamybox/scripts/mkvid-mov.sh &
fi
}

function stoprecmjpg
{
# ps=${ps -fu root | grep mjpg-streamer-rec-video|grep bash|tr -s ' '|cut -d ' ' -f 2|xargs -r kill}
#ps aux | grep ffmpeg|grep "action=stream"|tr -s ' '|cut -d ' ' -f 2|xargs -r kill 2 > /dev/null
ps=$(ps -fu root | grep mjpg-streamer-rec-video|grep bash|tr -s ' '|cut -d ' ' -f 2)
while kill -9 $ps &> /dev/null;do sleep 0.1;done
ps=$(ps -fu root | grep ffmpeg|grep timelapse-video|tr -s ' '|cut -d ' ' -f 2)
while kill -9 $ps &> /dev/null;do sleep 0.1;done
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="MJPGStreamer"
PARAM=" noautoload"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result
if [ $result = 'Y' ] ;then
	/home/pi/viamybox/www/scripts/stop_mjpgstrm.sh
fi
}

function startrecmjpg
{
checkMutuallyProc
	if [[ $statusConfirm = 'Yes' ]];then
	stoptRecSnapshots norestartmjpg
	/home/pi/viamybox/scripts/start_mjpgstrm.sh
	/home/pi/viamybox/scripts/mjpg-streamer-rec-video.sh &
fi
}

function checkSnapshotmjpgAutoload
{
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="snapshotmjpg.sh"
PARAM=" autoload"
PARAM2="noautoload"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result
if [ $result = 'Y' ] ;then
	str4="Deactivating snapshots recording when system start"
	settings4="☑ Recording Snapshots enabled at startup"
else
	str4="Activating snapshots recording when system start"
	settings4="☐ Recording Snapshots enabled at startup"
fi

}

function checkStartFfmpegFromSnapshots
{
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="startFfmpegFromSnapshots"
PARAM=" yes"
PARAM2="no"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result
if [ $result = 'Y' ] ;then
	str5="Deactivating creation from snapshots video mp4 file using ffmpeg every hour"
	settings5="☑ Creation timelapsed video from snapshots using ffmpeg"
else
	str5="Activating creation from snapshots video mp4 file using ffmpeg every hour"
	settings5="☐ Creation timelapsed video from snapshots using ffmpeg"
fi
}

function checkMJPGStreamerAutoload
{
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="MJPGStreamer"
PARAM=" autoload"
PARAM2="noautoload"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result
if [ $result = 'Y' ] ;then
	str6="Dectivating automatic launch of the mjpg-streamer service"
	settings6="☑ View Camera with MJPG enabled at startup"
else
	str6="Activating automatic launch of the mjpg-streamer service"
	settings6="☐ View Camera with MJPG enabled at startup"
fi
}

function checkMJPGStreamerRecFmpegAutoload
{
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="mjpg-streamer-rec-video.sh"
PARAM=" autoload"
PARAM2="noautoload"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result
if [ $result = 'Y' ] ;then
	str7="Dectivating automatic launch of ffmpeg video recording"
	settings7="☑ Recording FFMPEG video enabled at startup"
else
	str7="Activating automatic launch of ffmpeg video recording"
	settings7="☐ Recording FFMPEG video enabled at startup"
fi
}

function swichMJPGStreamerAutoload
{

FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="MJPGStreamer"
PARAM=" autoload"
PARAM2="noautoload"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result
if [ $result = 'Y' ] ;then
	update-rc.d -f mjpg-streamerd.sh remove &
	FirstSubstInFile2 $FILE $VAR $PARAM2
 else
	update-rc.d -f mjpg-streamerd.sh defaults
	FirstSubstInFile2 $FILE $VAR $PARAM
	VAR="GstreamerRecAV"
	CheckParamInFile "$VAR" "$FILE" "$PARAM2" result
	if [ $result = 'N' ] ;then
		echo "Attention!!!  Starting A/V Gstreamer recording when system start (p.6) wil be deactivating. Mutually exclusive modes. Press any key"
		read
		FirstSubstInFile2 $FILE $VAR $PARAM2
	fi
fi
}

#automatic start ffmpeg recording when system start
function swichRecMJPGStreamerFFMPEG
{
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="mjpg-streamer-rec-video.sh"
PARAM=" autoload"
PARAM2="noautoload"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result
if [ $result = 'Y' ] ;then
FirstSubstInFile2 $FILE $VAR $PARAM2
VAR="MJPGStreamer"
FirstSubstInFile2 $FILE $VAR $PARAM2
update-rc.d -f mjpg-streamerd.sh remove &
 else
	FirstSubstInFile2 $FILE $VAR $PARAM
	VAR="MJPGStreamer"
	FirstSubstInFile2 $FILE $VAR $PARAM
	update-rc.d -f mjpg-streamerd.sh defaults
	VAR="snapshotmjpg.sh"
	CheckParamInFile "$VAR" "$FILE" "$PARAM2" result
	if [ $result = 'N' ] ;then
		echo "Attention!!!  Starting snapshots recording when system start (p.6) wil be deactivating. Mutually exclusive modes. Press any key"
		read
		FirstSubstInFile2 $FILE $VAR $PARAM2
	fi
	VAR="GstreamerRecAV"
	CheckParamInFile "$VAR" "$FILE" "$PARAM2" result
	if [ $result = 'N' ] ;then
		echo "Attention!!!  Starting A/V Gstreamer recording when system start (p.6) wil be deactivating. Mutually exclusive modes. Press any key"
		read
		FirstSubstInFile2 $FILE $VAR $PARAM2
	fi

fi

}


function swichRecSnapshotAutoload
{
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="snapshotmjpg.sh"
PARAM=" autoload"
PARAM2="noautoload"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result
if [ $result = 'Y' ] ;then
FirstSubstInFile2 $FILE $VAR $PARAM2

VAR="MJPGStreamer"
PARAM="noautoload"
FirstSubstInFile2 $FILE $VAR $PARAM
update-rc.d -f mjpg-streamerd.sh remove &

 else
	FirstSubstInFile2 $FILE $VAR $PARAM

	VAR="MJPGStreamer"
	PARAM="autoload"
	FirstSubstInFile2 $FILE $VAR $PARAM
	update-rc.d -f mjpg-streamerd.sh defaults

	FILE="/home/pi/viamybox/conffiles/via.conf"
	VAR="mjpg-streamer-rec-video.sh"
	PARAM=" autoload"
	PARAM2="noautoload"
	CheckParamInFile "$VAR" "$FILE" "$PARAM" result
	if [ $result = 'Y' ] ;then
		echo "Attention!!!  Starting video ffmpeg recording when system start (p.9) wil be deactivating. Mutually exclusive modes. Press any key"
		read
		FirstSubstInFile2 $FILE $VAR $PARAM2

	fi
	VAR="GstreamerRecAV"
	CheckParamInFile "$VAR" "$FILE" "$PARAM2" result
	if [ $result = 'N' ] ;then
		echo "Attention!!!  Starting A/V Gstreamer recording when system start (p.6) wil be deactivating. Mutually exclusive modes. Press any key"
		read
		FirstSubstInFile2 $FILE $VAR $PARAM2
	fi

fi
}

function swichStartFfmpegFromSnapshots
{
FILE="/home/pi/viamybox/conffiles/via.conf"
VAR="startFfmpegFromSnapshots"
PARAM=" yes"
PARAM2="no"
CheckParamInFile "$VAR" "$FILE" "$PARAM" result
if [ $result = 'Y' ] ;then
FirstSubstInFile2 $FILE $VAR $PARAM2
 else
	FirstSubstInFile2 $FILE $VAR $PARAM
fi

}

function recvideofunc
{
if [[ $(ps -ax|grep "snapshotmjpg"|wc -l) -gt 1 ]]; then
	str1="Stop recording snapshots from mjpg-streamer"
	command1="stoptRecSnapshots"
	else
	str1="Start recording snapshots from mjpg-streamer"
	command1="startRecSnapshots"
fi
if [[ $(ps -aux|grep ffmpeg|grep "action=stream") ]]; then
	str2="Stop recording video from mjpg-streamer"
	command2="stoprecmjpg"
	else
	str2="Start recording video from mjpg-streamer"
	command2="startrecmjpg"
fi
if [[ $(ps -aux|grep "mjpg_streamer"|wc -l) -gt 1 ]]; then
	str3="Stop view mode camera mjpg-streamer"
	command3="stopMJPGStreamer"
	else
	str3="Start view mode camera mjpg-streamer"
	command3="startMJPGStreamer"
fi


checkSnapshotmjpgAutoload
checkStartFfmpegFromSnapshots
checkMJPGStreamerAutoload
checkMJPGStreamerRecFmpegAutoload

}
