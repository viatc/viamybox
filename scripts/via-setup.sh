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

a1='/usr/bin/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi

set -e

ME=`basename $0`
function print_help() {
    echo "Work with file test_file"
    echo
    echo "Use: $ME options..."
    echo "Parameters:"
    echo " -c Creation file test_file."
    echo " -w text Record to file line text."
    echo " -r Deleting of file test_file."
    echo " -h Reference."
    echo
}

function changeWebPass() {
htpasswd -cd /etc/nginx/conf/htpasswd pi
}

function changePass() {
passwd pi
}

function writeYandexInit() {
echo "For recording photo and video to yandex disc authorization is required.."
echo -n "Put in yandex user name (user@yandex.ru):"
read user
echo -n "Put in password :"
read pass

EchoLine="Save data?"
export EchoLine
SubmitYN result
FILE='/etc/davfs2/secrets'
if [[ $result = 'Y' ]];then

str="https://webdav.yandex.ru"
#export str
#export AddString
CheckStrInFile "$str" "$FILE" result

	if [[ $result = 'N' ]]
	then
        AddString="https://webdav.yandex.ru     $user   \"$pass\""
        export AddString
        AddStrAfterInFile $FILE
	fi

	if [[ $result = 'Y' ]]
	then
         sed '/yandex/d' $FILE > $FILE.new
         mv -f $FILE.new $FILE
         AddString="https://webdav.yandex.ru     $user   \"$pass\""
         export AddString
         AddStrAfterInFile $FILE
	fi
	sudo chmod 0600 /etc/davfs2/secrets

	FILE="/etc/fstab"
	AddString="https://webdav.yandex.ru /home/pi/yandex.disk  davfs  rw,noexec,auto,user,async,_netdev,uid=pi,gid=pi  0  0"
	CheckStrInFile "$AddString" "$FILE" result
	if [[ $result = 'N' ]]
	then
    export AddString
	AddStrAfterInFile $FILE
	fi
	
	AddString='sudo mount -t davfs https://webdav.yandex.ru /home/pi/yandex.disk/ -o uid=pi,gid=pi'
	FILE='/home/pi/.profile'
	CheckStrInFile "$AddString" "$FILE" result
	if [[ $result = 'N' ]]
	then
        export AddString
        AddStrAfterInFile $FILE
	fi
	if mount -l|grep yandex.disk &>/dev/null; then umount /home/pi/yandex.disk;fi
	mount -t davfs https://webdav.yandex.ru /home/pi/yandex.disk/ -o uid=pi,gid=pi
	#mount /home/pi/yandex.disk
	mkdir -p /home/pi/yandex.disk/camera
	mkdir -p /home/pi/yandex.disk/camera/foto
	mkdir -p /home/pi/yandex.disk/camera/video
	mkdir -p /home/pi/yandex.disk/camera/audio
	chown  pi:pi /home/pi/yandex.disk/camera/*
fi
}

function writeVideoDir() {
echo " Where to record data from camera? :
1) Locally.
2) To yandex disc. "
read copydata

case "$copydata" in
1)
	EchoLine="Save data?"
	export EchoLine
	SubmitYN result
	if [[ $result = 'Y' ]];then
		FILE="/home/pi/viamybox/conffiles/via.conf"
		VAR="saveDir"
		PARAM="\/home\/pi\/camera"
		FirstSubstInFile2 $FILE $VAR $PARAM
		chown pi:pi $FILE
	fi
;;
2)
	EchoLine="Save data?"
	export EchoLine
	SubmitYN result
	if [[ $result = 'Y' ]];then
		FILE="/home/pi/viamybox/conffiles/via.conf"
		VAR="saveDir"
		PARAM2="\/home\/pi\/yandex.disk\/camera"
		FirstSubstInFile2 $FILE $VAR $PARAM2
		chown pi:pi $FILE
	fi
	;;
    *) echo "You put in wrong value."
        exit 0
        result='NULL'
        ;;
esac

}

function writeNumberOfHours () {
echo -n "Enter how many days to store the DVR records : "
read number

EchoLine="Save data?"
export EchoLine
SubmitYN result
if [[ $result = 'Y' ]];then
FILE="/home/pi/viamybox/scripts/mkvid-mov.sh"
MYVAR="removedDays="
FirstSubstInFile $FILE $MYVAR $number
chown pi:pi $FILE
fi
}


function autobootInadynService () {
read -r -p "Start automatically web service mjpg_streamer at system launch? y/n :" response
case $response in
	[yY][eE][sS]|[yY]) update-rc.d inadyn enable
	;;
	[nN][oO]|[nN]) update-rc.d inadyn disable
	;;
esac
}

function writeFreeDNS () {
#cp /etc/inadyn.conf /home/pi/viamybox/scripts/test.conf
echo -n "Put in registered user (example: usr15062) at web-site https://freedns.afraid.org: "
read name
FILE="/etc/inadyn.conf"
MYVAR="username"
EchoLine="Save data?"
export EchoLine
SubmitYN result
if [ $result = 'Y' ]; then FirstSubstInFile2 $FILE $MYVAR $name;fi

echo -n "Put in password of registered user at web-site freedns.afraid.org: "
read pass
FILE="/etc/inadyn.conf"
MYVAR="password"
EchoLine="Save data?"
export EchoLine
SubmitYN result
if [ $result = 'Y' ] ;then FirstSubstInFile2 $FILE $MYVAR $pass;fi

echo -n "Put in a chosen domain name (example: viabox15062.mooo.com) at web-site freedns.afraid.org: "
read myalias
FILE="/etc/inadyn.conf"
MYVAR="alias"
EchoLine="Save data?"
export EchoLine
SubmitYN result
if [ $result = 'Y' ] ;then FirstSubstInFile2 $FILE $MYVAR $myalias;fi




sudo chmod 0600 /etc/inadyn.conf
}



function timeElapsed ()
{
a1='/home/pi/viamybox/scripts/rec-mjpg-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
		echo "О$ нет библиотеки функций $a1" 1>&2 ; exit 1 ; fi
		recvideofunc
i=1
while [ $i = 1 ]
do
clear
PS3="Choose paragraph of timelapsed settings menu : "
select timeElapsedMenu in "$str1" \
"$str2" \
"The place of recording data from the camera photo and timelapsed video" \
"Initialization for yandex disk" \
"Number of days of storage photos and videos recorded on the disc" \
"$str3" \
"$str4" \
"$str5" \
"$str6" \
"Quit"
 do
 case $timeElapsedMenu in
	"$str1") "$command1"; clear;recvideofunc;break
	;;
	"$str2") "$command2";clear;recvideofunc;break
	;;
	"The place of recording data from the camera photo and timelapsed video") writeVideoDir;clear;break
	;;
 	"Initialization for yandex disk") writeYandexInit;clear;break
	;;
	"Number of days of storage photos and videos recorded on the disc") writeNumberOfHours;clear;break
	;;
	"$str3") swichRecSnapshotAutoload;clear;recvideofunc;break
	 ;;
	"$str4") swichStartFfmpegFromSnapshots;clear;recvideofunc;break
	 ;;
	"$str5") swichMJPGStreamerAutoload;clear;recvideofunc;break
     ;;
	"$str6") swichRecMJPGStreamerFFMPEG;clear;recvideofunc;break
     ;;
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
function changeCamera {
echo " Choose a camera :
1) Logitech c270
2) Logitech c910"
read copydata

case "$copydata" in
1) 
	EchoLine="Save data?"
	export EchoLine
	SubmitYN result
	if [[ $result = 'Y' ]];then 
	FILE="/home/pi/viamybox/www/scripts/via_rec_av_start.sh"
	MYVAR="EXECFILE="
	PARAM="\"\/sbin\/via-rec-av-c270\""
	FirstSubstInFile $FILE $MYVAR $PARAM
	chmod +x $FILE
	chown www-data:www-data $FILE
	
	FILE="/home/pi/viamybox/www/scripts/via_rec_av_stop.sh"
	MYVAR="EXECFILE="
	PARAM="\"\/sbin\/via-rec-av-c270\""
	FirstSubstInFile $FILE $MYVAR $PARAM
	chmod +x $FILE
	chown www-data:www-data $FILE
	
	FILE="/home/pi/viamybox/www/scripts/via_rec_video_gstrm.sh"
	MYVAR="EXECFILE="
	PARAM="\"\/sbin\/via-rec-av-c270\""
	FirstSubstInFile $FILE $MYVAR $PARAM
	chmod +x $FILE
	chown www-data:www-data $FILE
	
	FILE="/home/pi/viamybox/scripts/gstreamer-record/Makefile"
	STR="FILE="
	STREND="via-rec-av-c270"
	FirstSubstInFile "$FILE" "$STR" "$STREND"
	cd /home/pi/viamybox/scripts/gstreamer-record/
	make
	cd /home/pi/viamybox/scripts/gstreamer-record/
	make install
	clear
	fi
;;

2) 
	EchoLine="Save data?"
	export EchoLine
	SubmitYN result
	if [[ $result = 'Y' ]];then
	FILE="/home/pi/viamybox/www/scripts/via_rec_av_stop.sh"
	MYVAR="EXECFILE="
	PARAM="\"\/sbin\/via-rec-av-c910-2\""
	FirstSubstInFile $FILE $MYVAR $PARAM
	chmod +x $FILE
	chown www-data:www-data $FILE
	
	FILE="/home/pi/viamybox/www/scripts/via_rec_av_start.sh"
	MYVAR="EXECFILE="
	PARAM="\"\/sbin\/via-rec-av-c910-2\""
	FirstSubstInFile $FILE $MYVAR $PARAM
	chmod +x $FILE
	chown www-data:www-data $FILE
	
	FILE="/home/pi/viamybox/www/scripts/via_rec_video_gstrm.sh"
	MYVAR="EXECFILE="
	PARAM="\"\/sbin\/via-rec-av-c910-2\""
	FirstSubstInFile $FILE $MYVAR $PARAM
	chmod +x $FILE
	chown www-data:www-data $FILE

	
	FILE="/home/pi/viamybox/scripts/gstreamer-record/Makefile"
	STR="FILE="
	STREND="via-rec-av-c910-2"
	FirstSubstInFile "$FILE" "$STR" "$STREND"
	cd /home/pi/viamybox/scripts/gstreamer-record/
	make
	cd /home/pi/viamybox/scripts/gstreamer-record/
	make install
	clear
	fi
clear
;;
esac
}

function rotationFileInSec () {
echo -n "Enter the file rotation time in seconds (3600 default):"
read PARAM

EchoLine="Save data?"
export EchoLine
SubmitYN result
if [[ $result = 'Y' ]];then
FILE="/home/pi/viamybox/scripts/gstreamer-record/via-rec-av-c910-2.c"
VARIABLE="#define FILE_DURATION"
FirstSubstInFile2 "$FILE" "$VARIABLE" "$PARAM"
FILE="/home/pi/viamybox/scripts/gstreamer-record/via-rec-audio.c"
FirstSubstInFile2 "$FILE" "$VARIABLE" "$PARAM"
FILE="/home/pi/viamybox/scripts/gstreamer-record/via-rec-av-c270.c"
FirstSubstInFile2 "$FILE" "$VARIABLE" "$PARAM"
cd /home/pi/viamybox/scripts/gstreamer-record/
make
cd /home/pi/viamybox/scripts/gstreamer-record/
make install
fi
}

# function sizeScreen () {
# echo -n "Enter the resolution resolution of the recording screen:
# 1: 320x240
# 2: 960x720
# 3: 1280x960
# 4: 1920x1080
# 5: 1600x1200
# "
# read PARAM
	# EchoLine="Save data?"
	# export EchoLine
	# SubmitYN result
# if [[ $result = 'Y' ]];then

# case "$PARAM" in
	# 1)
	# PARAM1="320"
	# PARAM2="240"
	# ;;
	# 2)
	# PARAM1="960"
	# PARAM2="720"
	# ;;	
	# 3)
	# PARAM1="1280"
	# PARAM2="960"
	# ;;	
	# 4)
	# PARAM1="1920"
	# PARAM2="1080"
	# ;;
	# 5)
	# PARAM1="1600"
	# PARAM2="1200"
	# ;;
    # *) echo "You put in wrong value."
        # exit 0
        # result='NULL'
    # ;;
# esac
# fi
	
# VARIABLE1="#define WIDTH"
# VARIABLE2="#define HEIGHT"
# FILE="/home/pi/viamybox/scripts/gstreamer-record/via-rec-av-c910-2.c"
# FirstSubstInFile2 "$FILE" "$VARIABLE1" "$PARAM1"
# FirstSubstInFile2 "$FILE" "$VARIABLE2" "$PARAM2"
# cd /home/pi/viamybox/scripts/gstreamer-record/
# make
# cd /home/pi/viamybox/scripts/gstreamer-record/
# make install
	
# }

function gstreamerAV {
i=1
while [ $i = 1 ]
do
clear
PS3="Select the menu option for recording video and audio:"
select timeElapsedMenu in "Camera selection" \
"Record file rotation time in seconds" \
"Quit"
#"Recording Screen Resolution" \
 do
 case $timeElapsedMenu in
	"Camera selection") changeCamera; clear;break
	;;
	"Record file rotation time in seconds") rotationFileInSec;clear;break
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


function mainmenu { 
if [ $# = 0 ]; then print_help; fi

strmg1="Switch to Russian language"
while [ 1 = 1 ]
do
clear
PS3="Choose paragraph of settings menu ViaMyBox: "
select firstMenu in "Internet of things (IoT)" \
"MotionEye" \
"Settings for recording compressed (time elapsed) video mjpgstreamer" \
"Settings for recording video and audio gstreamer" \
"Initialization at web-site http://freedns.afraid.org for connecting service agent inadyn" \
"Automatic launch of service inadyn (dynamic renewal ip for dyndns freedns.afraid.org)" \
"Change password of web access" \
"Change user password pi" \
"$strmg1" \
"Quit"
 do
 case $firstMenu in
	"Internet of things (IoT)") {
		a1='/home/pi/viamybox/scripts/iot-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
		echo "О$ нет библиотеки функций $a1" 1>&2 ; exit 1 ; fi
		iotfunc
		clear
		break
		}
	;;
	"MotionEye") {
		a1='/home/pi/viamybox/scripts/motioneye-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
		echo "О$ нет библиотеки функций $a1" 1>&2 ; exit 1 ; fi
		motioneyefunc
		clear
		break
		}
	;;
	"Settings for recording compressed (time elapsed) video mjpgstreamer") timeElapsed;clear;break
	;;
	"Settings for recording video and audio gstreamer") gstreamerAV;clear;break
	;;
	"Initialization at web-site http://freedns.afraid.org for connecting service agent inadyn") writeFreeDNS;clear;break
	;;
	"Automatic launch of service inadyn (dynamic renewal ip for dyndns freedns.afraid.org)") autobootInadynService;clear;break
	;;
	"Change password of web access") changeWebPass;clear;break
	;; 
	"Change user password pi") changePass;clear;break
	;;
	"$strmg1") {
		a1='/home/pi/viamybox/scripts/change-language.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
		echo "О$ нет библиотеки функций $a1" 1>&2 ; exit 1 ; fi
		changeLanguage;echo "Изменен язык меню. Перезапустите пожалуйста via-setup.sh";exit 0;break
	}
	;;
	"Quit") exit 0
	;;
        *) echo "Invalid parameter";
#            echo "For help, run $ ME -h";
            exit 1
            ;;
 esac

 done
done
}

mainmenu