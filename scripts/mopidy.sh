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
	
a1='/home/pi/viamybox/scripts/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi
VIADIR="/home/pi/viamybox"
# FILECONF="/tmp/via.conf"
VIADIR="/home/pi/viamybox"
EXECFILE="/sbin/via-rec-av-c270"
FILECONF="/home/pi/viamybox/conffiles/via.conf"
StoreVideo="/home/pi/camera/video"
StoreAudio="/home/pi/camera/audio"
PARAM=" autoload"
PARAM2="noautoload"

function installMopidy {
EchoLine="Would you like to install Mopidy?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then return 0; fi
apt-get install mopidy
}

function uninstallMopidy {
 EchoLine="Would you like to remove Mopidy?"
 echo #EchoLine
 SubmitYN result
 if [[ $result = 'N' ]]; then return 0;fi
 apt-get remove mopidy
 sudo rm ~/.local/bin/mopidy
 sudo rm -r /var/lib/mopidy
 sudo rm -r /var/log/mopidy
}

function installMopidyTuneIn {
EchoLine="Would you like to install Mopidy with TuneIn?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then return 0; fi
apt-get install mopidy gstreamer1.0-libav streamer1.0-plugins-bad gstreamer1.0-plugins-ugly
runuser -l pi -c "python3 -m pip install --upgrade pip"
runuser -l pi -c "python3 -m pip install Mopidy-TuneIn"
read a
}

function uninstallMopidyTuneIn {
 EchoLine="Would you like to remove TuneIn Mopidy extention?"
 echo #EchoLine
 SubmitYN result
 if [[ $result = 'N' ]]; then return 0;fi
 # python3 -m pip uninstall Mopidy-TuneIn
 runuser -l pi -c "python3 -m pip uninstall Mopidy-TuneIn"
}

function installMopidyAutoplay {
EchoLine="Would you like to install Mopidy with Autoplay?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then return 0; fi
apt-get install mopidy
runuser -l pi -c "python3 -m pip install --upgrade pip"
runuser -l pi -c "python3 -m pip install Mopidy-Autoplay"
}

function uninstallMopidyAutoplay {
 EchoLine="Would you like to remove Autoplay extention?"
 echo #EchoLine
 SubmitYN result
 if [[ $result = 'N' ]]; then return 0;fi
 runuser -l pi -c "python3 -m pip uninstall Mopidy-Autoplay"
}

function mopidy-func
{

if [ -e  /usr/bin/mopidy -o -e /home/pi/.local/bin/mopidy ];then
	str1="Uninstall Mopidy"
	strFunc1="uninstallMopidy"
	# str2="Start Mopidy music server"
else
	str1="Install Mopidy"
	strFunc1="installMopidy"
fi
# var=$(pip -q show Mopidy-TuneIn &> /dev/null 2>&1)
var=$(sudo -u pi bash -c "pip3 show Mopidy-TuneIn &> /dev/null 2>&1")
# sudo -u pi bash -c "pip3 list|grep Mopidy-TuneIn"
if [ $? -eq 0 ];then
	str2="Uninstall Mopidy TuneIn extention"
	strFunc2="uninstallMopidyTuneIn"
else
	str2="Install Mopidy TuneIn extention"
	strFunc2="installMopidyTuneIn"
fi
# var=$(pip -q show Mopidy-Autoplay &> /dev/null 2>&1)
# sudo -u pi bash -c "pip3 list|grep Mopidy-Autoplay"
var=$(sudo -u pi bash -c "pip3 show Mopidy-Autoplay &> /dev/null 2>&1")
if [ $? -eq 0 ];then
	str3="Uninstall Mopidy Autoplay extention"
	strFunc3="uninstallMopidyAutoplay"
else
	str3="Install Mopidy Autoplay extention"
	strFunc3="installMopidyAutoplay"
fi
mopidy-menu-play

}

function mopidy-menu-play {
i2=1
while [ $i2 = 1 ]
do
clear
roof="Mopidy is an extensible music server written in Python. Mopidy plays music from local disk, Spotify, SoundCloud, TuneIn, and more. You can edit the playlist from any phone, tablet, or computer using a variety of MPD and web clients.  \n
https://github.com/mps-youtube/mps-youtube "
function-roof-menu "$roof"
PS3="
Choose paragraph of mopidy-Youtube settings menu : "
select mopidyMenu in "$str1" "$str2" "$str3" \
"Quit"
 do
 case $mopidyMenu in
	"$str1") $strFunc1;mopidy-func;break
	;;
	"$str2") $strFunc2;mopidy-func;break
	;;
	"$str3") $strFunc3;mopidy-func;break
	;;
	"Quit") clear;i2=0;break;
	;;
    *) echo "Invalid parameter";
#            echo "For help, run $ ME -h";
    exit 1
    ;;
 esac
 done
 done
}

mopidy-func
