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

VIADIR="/home/pi/viamybox"
EXECFILE="/sbin/via-rec-av-c270"
FILECONF="/home/pi/viamybox/conffiles/via.conf"
StoreVideo="/home/pi/camera/video"
StoreAudio="/home/pi/camera/audio"
PARAM=" autoload"
PARAM2="noautoload"

#check choice of audio capture device
function checkChoice()
{
result='NULL'
#echo $numOfCards
while [ $result='NULL' ]
do
read choiceOfCard
case "$choiceOfCard" in
    [0-$numOfCards]"")
        return 0
    ;;
    *) echo "not guess... [0 - "$numOfCards"] :"
	;;
esac
done
}

#set audio capture device in C
function setChoice(){
PARAM=$(echo "\"plughw:"$choiceOfCard",0\"")
VARIABLE="#define AUDIOSOURCE"
FILE="/home/pi/viamybox/scripts/gstreamer-record/via-rec-av-c910-2.c"
FirstSubstInFile2 "$FILE" "$VARIABLE" "$PARAM"
FILE="/home/pi/viamybox/scripts/gstreamer-record/via-rec-av-c270.c"
FirstSubstInFile2 "$FILE" "$VARIABLE" "$PARAM"
FILE="/home/pi/viamybox/scripts/gstreamer-record/via-rec-audio.c"
FirstSubstInFile2 "$FILE" "$VARIABLE" "$PARAM"
cd /home/pi/viamybox/scripts/gstreamer-record/
make && make install

}


function getGstreamerAudioSource () {
cat /proc/asound/cards|awk '/^.[0-9]/ {print $0 }'> /tmp/via-cards
echo ""
cat /tmp/via-cards
numOfCards=$(cat /tmp/via-cards|wc -l)
numOfCards=$(($numOfCards-1))
echo -n "
Please choose a number of sound capture device: [0 - "$numOfCards"] :"
checkChoice
#add to via.conf audio capture card
numstrChoiceOfCard=$((choiceOfCard+1))
strChoiceCard=$(sed "${numstrChoiceOfCard}q;d" /tmp/via-cards)
VAR="audioCaptureDevice"
FirstSubstInFile2 $FILECONF $VAR "$strChoiceCard"
strChoiceCard="_no_spread_Captured audio card :"$strChoiceCard
setChoice
}


function checkMutuallyRunningProc ()
{
ret=$(ps aux | grep via-rec-av  | wc -l)

if [ "$ret" -gt 1 ];then
	echo "Attention!!!  Recording Gstreamer A/V stream wil be deactivating. Mutually exclusive modes."
	EchoLine="Confirm Deactivation?"
	export EchoLine
	SubmitYN result
	if [[ $result = 'Y' ]];then
		a1='/home/pi/viamybox/scripts/gstreamerav.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
		echo "no function library $a1" 1>&2 ; exit 1 ;fi
		stopGstrmAV
		statusConfirm="Yes"
		else statusConfirm="NO";return 0
	fi
fi

ret=$(ps aux | grep via-rec-audio | wc -l)
if [ "$ret" -gt 1 ];then
	echo "Attention!!!  Recording Audio stream when will be deactivating. Mutually exclusive modes."
	EchoLine="Confirm Deactivation?"
	export EchoLine
	SubmitYN result
	if [[ $result = 'Y' ]];then
		a1='/home/pi/viamybox/scripts/gstreamerav.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
		echo "no function library $a1" 1>&2 ; exit 1 ;fi
		stopGstrmA
		statusConfirm="Yes"
		else statusConfirm="NO";return 0
	fi
fi
statusConfirm="Yes"
}

function checkMutuallyProcessesA {

VAR="GstreamerRecAV"
statusConfirm="YES"
CheckParamInFile "$VAR" "$FILECONF" "$PARAM" result
if [ $result = 'Y' ] ;then
	echo "Attention!!!  Starting Audio/Video Recording with Gstreamer, when system start wil be deactivating. Mutually exclusive modes."
	EchoLine="Confirm Deactivation?"
	export EchoLine
	SubmitYN result
		if [[ $result = 'Y' ]];then
			FirstSubstInFile2 $FILECONF $VAR $PARAM2
		else statusConfirm="NO";return 0
		fi
fi
}


function checkSoundUsbCameraIsBusy {
numCaptureDevice=$(grep "audioCaptureDevice" $FILECONF |awk '{print $2}')
arecord --device plughw:"$numCaptureDevice",0 -s 1 /dev/null
if [ $? -eq 1 ]; then
	echo "USB camera sound IS BUSY. Reload usb devices..."
	$VIADIR/scripts/resetusb
fi
}

function checkMutuallyProcessesAV {
VAR="snapshotmjpg.sh"
CheckParamInFile "$VAR" "$FILECONF" "$PARAM" result

statusConfirm="YES"
if [ $result = 'Y' ] ;then
	echo "Attention!!!  Starting snapshots recording when system start wil be deactivating. Mutually exclusive modes."
	EchoLine="Confirm Deactivation?"
	export EchoLine
	SubmitYN result
		if [[ $result = 'Y' ]];then
			FirstSubstInFile2 $FILECONF $VAR $PARAM2
		else statusConfirm="NO";return 0
		fi
	fi

VAR="mjpg-streamer-rec-video.sh"
CheckParamInFile "$VAR" "$FILECONF" "$PARAM" result

if [ $result = 'Y' ] ;then
	echo "Attention!!!  Starting video ffmpeg recording when system start wil be deactivating. Mutually exclusive modes."
	EchoLine="Confirm Deactivation?"
	export EchoLine
	SubmitYN result
		if [ $result = 'Y' ];then
			FirstSubstInFile2 $FILECONF $VAR $PARAM2
		else statusConfirm="NO";return 0
		fi
	fi

VAR="MJPGStreamer"
CheckParamInFile "$VAR" "$FILECONF" "$PARAM" result

if [ $result = 'Y' ] ;then
	echo "Attention!!!  Starting mjpg-streamer when system start wil be deactivating. Mutually exclusive modes."
	EchoLine="Confirm Deactivation?"
	export EchoLine
	SubmitYN result
	if [[ $result = 'Y' ]];then
		update-rc.d -f mjpg-streamerd.sh remove &
		FirstSubstInFile2 $FILECONF $VAR $PARAM2
	else statusConfirm="NO";return 0
	fi
fi

}


function stopGstrmAV {
	SubstParamInFile '/home/pi/viamybox/www/style.css' 'background-image:' 'rec-red-av.gif' 'rec-av.png'
	chown www-data:www-data /home/pi/viamybox/www/style.css
	killall -s SIGINT $EXECFILE
	chown pi:pi $StoreVideo/*
}

function startGstrmAV {
checkMutuallyRunningProc
checkSoundUsbCameraIsBusy
if [[ $statusConfirm = 'Yes' ]];then
	ret=$(ps aux | grep mjpg_streamer | wc -l)
	if [ "$ret" -gt 1 ]
		then
		echo "mjpg starting" #output text
		service mjpg-streamerd stop
	fi

	ret=$(ps aux | grep motioneye | wc -l)
	if [ "$ret" -gt 1 ]
	then {
		docker stop motioneye
	}
	fi
fi

SubstParamInFile '/home/pi/viamybox/www/style.css' 'background-image:' 'rec-av.png' 'rec-red-av.gif'
chown www-data:www-data /home/pi/viamybox/www/style.css
$EXECFILE > /dev/null 2>&1 &

}

function startGstrmA {
checkMutuallyRunningProc
checkSoundUsbCameraIsBusy

if [[ $statusConfirm = 'Yes' ]];then
	ret=$(ps aux | grep via-rec-audio  | wc -l)
	echo "$ret"
	if [ "$ret" -eq 1 ]
	then
		SubstParamInFile '/home/pi/viamybox/www/style.css' 'background-image:' 'rec-a.png' 'rec-red-a.gif'
		chown www-data:www-data /home/pi/viamybox/www/style.css
	# exec /sbin/via-rec-audio /dev/null 2>&1 &
	# (trap "" SIGINT; exec -a via-rec-audio /sbin/via-rec-audio & > /dev/null 2>&1)
		/sbin/via-rec-audio > /dev/null 2>&1 &
	fi
fi
}

function stopGstrmA {
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
}

function swichGstreamerRecAVAutoload
{
VAR="GstreamerRecAV"
CheckParamInFile "$VAR" "$FILECONF" "$PARAM" result

if [ $result = 'Y' ] ;then
	PARAM2="noautoload"
	FirstSubstInFile2 $FILECONF $VAR $PARAM2
 else
	checkMutuallyProcessesAV

	if [ $statusConfirm = "YES" ];then
		VAR="GstreamerRecAV"
		FirstSubstInFile2 $FILECONF $VAR $PARAM
		VAR="GstreamerRecAudio"
		FirstSubstInFile2 $FILECONF $VAR $PARAM2
	fi

fi
}

function swichGstreamerRecAAutoload
{
VAR="GstreamerRecAudio"
CheckParamInFile "$VAR" "$FILECONF" "$PARAM" result

if [ $result = 'Y' ] ;then
	FirstSubstInFile2 $FILECONF $VAR $PARAM2
 else
		VAR="GstreamerRecAudio"
		FirstSubstInFile2 $FILECONF $VAR $PARAM
		VAR="GstreamerRecAV"
		FirstSubstInFile2 $FILECONF $VAR $PARAM2
	# fi
fi
}


function gstreamfunc {

proc=$(echo $EXECFILE|awk -F/ '{print $3}')
ret=$(ps aux | grep $proc  | wc -l)
echo "$ret"

if [ "$ret" -eq 1 ]
then
	str1="Start Recording Audio/Video"
	strFunc1="startGstrmAV"
else
	str1="Stop Recording Audio/Video"
	strFunc1="stopGstrmAV"
fi

ret=$(ps aux | grep via-rec-audio  | wc -l)
# echo "$ret"
if [ "$ret" -gt 1 ]
then
	str2="Stop Recording Audio"
	strFunc2="stopGstrmA"
else
	str2="Start Recording Audio"
	strFunc2="startGstrmA"
fi

VAR="GstreamerRecAV"
CheckParamInFile "$VAR" "$FILECONF" "$PARAM" result
if [ $result = 'Y' ] ;then
	settingsRecAV="☑ Recording Gstreamer Audio/Video enabled at startup"
	str3="Disable Recording Audio/Video at startup"
 else
	settingsRecAV="☐ Recording Gstreamer Audio/Video enabled at startup"
	str3="Enable Recording Audio/Video at startup"
fi


VAR="GstreamerRecAudio"
CheckParamInFile "$VAR" "$FILECONF" "$PARAM" result
if [ $result = 'Y' ] ;then
	settingsRecA="☑ Recording Gstreamer Audio enabled at startup"
	str4="Disable Recording Sound at startup"
 else
	settingsRecA="☐ Recording Gstreamer Audio enabled at startup"
	str4="Enable Recording Sound at startup"
fi

#Read parameter audioCaptureDevice from via.conf
strChoiceCard=$(awk '/^audioCaptureDevice/ {print $0 }' $FILECONF|sed "s/audioCaptureDevice//")
strChoiceCard="_no_spread_Captured audio card :"$strChoiceCard
}

if [ -n $1  ]; then

a1='/home/pi/viamybox/scripts/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi

case "$1" in
  --help)
	echo "Usage: $0 or $0 --recvideo" >&2
	;;
  --startGstrmAV|-sav)
	startGstrmAV
	;;
  --startGstrmA|-sa)
	startGstrmA
	;;
	*)
	# echo "Usage: $0 [OPTIONS]
	# OPTIONS
	# -sav, --startGstrmAV
		# Start Gstreamer Recording Audio/Video form USB Camera
	# -sa, --startGstrmA
		# Start Gstreamer Recording Audio form USB Camera " >&2
	;;
esac

fi

function menu()
{
	a1='/home/pi/viamybox/scripts/gstreamerav.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
	echo "О$ нет библиотеки функций $a1" 1>&2 ; exit 1 ; fi
	gstreamfunc

	roof="Gstreamer technology records synchronized video and audio stream from a usb camera.`
	`Or recording a simple audio signal.\n
	----------------------------------------------------
	$settingsRecAV
	$settingsRecA
	$strChoiceCard"

	i=1
	while [ $i = 1 ]
	do
	clear
	function-roof-menu "$roof"
	#function-roof-menu "$firstMenuStr"
	PS3="Select the menu option for recording video and audio: "
	select timeElapsedMenu in "Camera selection" \
	"Audio record source selection" \
	"Record file rotation time in seconds" \
	"$str1" \
	"$str2" \
	"$str3" \
	"$str4" \
	"Quit"
	#"Recording Screen Resolution" \
	 do
	 case $timeElapsedMenu in
		"Camera selection") changeCamera; clear;break
		;;
		"Audio record source selection") getGstreamerAudioSource; clear; i=0; gstreamerAV; break
		;;
		"Record file rotation time in seconds") rotationFileInSec;clear;break
		;;
		"$str1") "$strFunc1";gstreamfunc;clear;break
		;;
		"$str2") "$strFunc2";gstreamfunc;clear;break
		;;
		"$str3") swichGstreamerRecAVAutoload;clear;i=0;gstreamerAV;break
		;;
		"$str4") swichGstreamerRecAAutoload;clear;i=0;gstreamerAV;break
		;;
	 	# "Recording Screen Resolution") sizeScreen;clear;break
		# ;;
		"Quit") clear;i=0;break;
		;;
	    *) echo "Invalid parameter";
	#            echo "For help, run $ ME -h";
	    exit 1
	    ;;
	 esac
	 done
	 done
}

menu
