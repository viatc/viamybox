#!/bin/bash
	## Copyright (C) 2017-2021 ViaMyBox viatc.msk@gmail.com
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
wget -q -O - https://apt.mopidy.com/mopidy.gpg | sudo apt-key add -
wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/buster.list
apt update
apt install mopidy
python3 -m pip install Mopidy-MusicBox-Webclient
python3 -m pip install Mopidy-Autoplay
python3 -m pip install Mopidy-TuneIn
# runuser -l pi -c "python3 -m pip install Mopidy-MusicBox-Webclient"
# runuser -l pi -c "python3 -m pip install Mopidy-Autoplay"
# runuser -l pi -c "python3 -m pip install Mopidy-TuneIn"
adduser mopidy video
# cp /home/pi/viamybox/conffiles/mopidy.service /lib/systemd/system/
# systemctl enable mopidy.service
ret=$(ps aux | grep mpc  | wc -l)
# echo "$ret"
if [ "$ret" -gt 1 ]
then {
	killall  mpc
}
fi

runuser -l pi -c "mopidy &"
sleep 4
PID="$(pgrep -f "mopidy([^\.]sh|\s|$)")"
killall -s SIGTERM mopidy
waitWhenPIDstop "$PID"
enableWebInterfaceInMopidyConfig
# runuser -l pi -c "mopidy &"
systemctl start mopidy.service
}

function uninstallMopidy {
 EchoLine="Would you like to remove Mopidy?"
 echo #EchoLine
 SubmitYN result
 if [[ $result = 'N' ]]; then return 0;fi
 killall -s SIGTERM mopidy
 waitWhenPIDstop "$PID"
 apt-get remove mopidy
 rm -r /var/lib/mopidy
 rm -r /usr/bin/mopidy
 rm -r /var/log/mopidy
 rm -r /home/pi/.local/bin/mopidy
}

function installMopidyTuneIn {
EchoLine="Would you like to install Mopidy with TuneIn?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then return 0; fi
apt-get install mopidy gstreamer1.0-libav streamer1.0-plugins-bad gstreamer1.0-plugins-ugly
runuser -l pi -c "python3 -m pip install --upgrade pip"
runuser -l pi -c "python3 -m pip install Mopidy-TuneIn"
# runuser -l pi -c "mopidy &"
}

function uninstallMopidyTuneIn {
 EchoLine="Would you like to remove TuneIn Mopidy extention?"
 echo #EchoLine
 SubmitYN result
 if [[ $result = 'N' ]]; then return 0;fi
 # python3 -m pip uninstall Mopidy-TuneIn
 runuser -l pi -c "python3 -m pip uninstall Mopidy-TuneIn"
 python3 -m pip uninstall Mopidy-TuneIn
}

function installMopidyAutoplay {
EchoLine="Would you like to install Mopidy with Autoplay?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then return 0; fi
runuser -l pi -c "python3 -m pip install --upgrade pip"
runuser -l pi -c "python3 -m pip install Mopidy-Autoplay"
}

function uninstallMopidyAutoplay {
 EchoLine="Would you like to remove Autoplay extention?"
 echo #EchoLine
 SubmitYN result
 if [[ $result = 'N' ]]; then return 0;fi
 	runuser -l pi -c "python3 -m pip uninstall Mopidy-Autoplay"
  python3 -m pip uninstall Mopidy-Autoplay
}

function installMopidyMusicBox {
EchoLine="Would you like to install Mopidy with MusicBox Web client?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then return 0; fi
apt-get install mopidy
runuser -l pi -c "python3 -m pip install --upgrade pip"
# runuser -l pi -c "python3 -m pip install Mopidy-Autoplay"
runuser -l pi -c "python3 -m pip install Mopidy-MusicBox-Webclient"
}

function uninstallMopidyMusicBox {
 EchoLine="Would you like to remove MusicBox Web client extention?"
 echo #EchoLine
 SubmitYN result
 if [[ $result = 'N' ]]; then return 0;fi
 runuser -l pi -c "python3 -m pip uninstall Mopidy-MusicBox-Webclient"
 python3 -m pip uninstall Mopidy-MusicBox-Webclient
}


function startMopidy {
 # runuser -l pi -c "mopidy &"
 systemctl start mopidy.service
}

function stopMopidy {
# killall -s SIGTERM mopidy
# waitWhenPIDstop "$PID"
 systemctl stop mopidy.service
}

function enableMopidyService {
systemctl enable mopidy.service
}
function disableMopidyService {
systemctl disable mopidy.service
}

function mopidy-func
{
command="mopidy-menu-play"
# if [ -e  /usr/bin/mopidy -o -e /home/pi/.local/bin/mopidy ];then

PID="$(pgrep -f "mopidy([^\.]sh|\s|$)")"
if [[ -n $PID ]]; then
  str1="Stop Mopidy"
  strFunc1="stopMopidy"
else
  str1="Start Mopidy"
  strFunc1="startMopidy"
fi

if [ -e /etc/systemd/system/multi-user.target.wants/mopidy.service ];then
	str2="Disabling Mopidy Radio TuneIn when system boots"
	strFunc2="systemctl disable mopidy.service"
	else
	str2="Enabling Mopidy Radio TuneIn when system boots"
	strFunc2="systemctl enable mopidy.service"
fi

file="/usr/share/mopidy/conf.d/mopidy.conf"
str="hostname = 0.0.0.0"
if grep -qE "^$str" "$file";then
	str3="Disabling Mopidy Web Interface in local network"
	strFunc3="disableWebInterfaceInMopidyConfig"
	else
	str3="Enabling Mopidy Web Interface in local network"
	strFunc3="enableWebInterfaceInMopidyConfig"
fi


if [ -e  /usr/bin/mopidy ];then
	str4="Uninstall Mopidy"
	strFunc4="uninstallMopidy"
	# str2="Start Mopidy music server"
else
	str1="Install Mopidy and Radio TuneIn (Mopidy extension)"
	strFunc1="installMopidy"
  command="mopidy-menu-install"
fi

# var=$(pip -q show Mopidy-TuneIn &> /dev/null 2>&1)
var=$(sudo -u pi bash -c "pip3 show Mopidy-TuneIn &> /dev/null 2>&1")
# sudo -u pi bash -c "pip3 list|grep Mopidy-TuneIn"
if [ $? -eq 0 ];then
	str5="Uninstall Mopidy TuneIn extention"
	strFunc5="uninstallMopidyTuneIn"
else
	str5="Install Mopidy TuneIn extention"
	strFunc5="installMopidyTuneIn"
fi
# var=$(pip -q show Mopidy-Autoplay &> /dev/null 2>&1)
# sudo -u pi bash -c "pip3 list|grep Mopidy-Autoplay"
var=$(sudo -u pi bash -c "pip3 show Mopidy-Autoplay &> /dev/null 2>&1")
if [ $? -eq 0 ];then
	str6="Uninstall Mopidy Autoplay extention"
	strFunc6="uninstallMopidyAutoplay"
else
	str6="Install Mopidy Autoplay extention"
	strFunc6="installMopidyAutoplay"
fi

$command
}

function enableWebInterfaceInMopidyConfig {
file="/home/pi/.config/mopidy/mopidy.conf"
section="\[http\]"
var="hostname = "
param="0.0.0.0"

enableParamInSection "$file" "$section" "$var" "$param"
chown pi:pi $file

file="/usr/share/mopidy/conf.d/mopidy.conf"
enableParamInSection "$file" "$section" "$var" "$param"
# если секция отсутствует добавляем в конец файла
if [  $?=1 ];then
section="
[http]
#ViaSettings: next line will be created by ViaMyBox script
hostname = 0.0.0.0"

echo -e "$section" >> "$file"
fi
}

function disableWebInterfaceInMopidyConfig {
  file="/home/pi/.config/mopidy/mopidy.conf"
	cp $file $file.bak

	section="\[http\]"
  var="hostname = "
  param="0.0.0.0"
  str="hostname = 0.0.0.0"
  # grep -vF "$var$param" $file > $file.new; mv $file.new $file
	deleteParamInSection "$file" "$section" "$var" "$param"
  # deleteStr $file
  chown pi:pi $file

	file="/usr/share/mopidy/conf.d/mopidy.conf"
	# file2="/usr/share/mopidy/conf.d/mopidy.conf.bak"
	cp $file $file.bak
	deleteParamInSection "$file" "$section" "$var" "$param"
  # grep -vF "$var$param" $file > $file.new; mv $file.new $file
  # deleteStr $file
}

function mopidy-menu-install {
i2=1
while [ $i2 = 1 ]
do
clear
roof="Mopidy is an extensible music server written in Python. Mopidy plays music from local disk, Spotify, SoundCloud, TuneIn, and more. You can edit the playlist from any phone, tablet, or computer using a variety of MPD and web clients.  \n
https://mopidy.com"
function-roof-menu "$roof"
PS3="
Choose paragraph of Mopidy Radio TuneIn - settings menu : "
select mopidyMenu in "$str1" \
"Quit"
 do
 case $mopidyMenu in
	"$str1") $strFunc1;mopidy-func;break
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

function mopidy-menu-play {
i2=1
while [ $i2 = 1 ]
do
clear
roof="Mopidy is an extensible music server written in Python. Mopidy plays music from local disk, Spotify, SoundCloud, TuneIn, and more. You can edit the playlist from any phone, tablet, or computer using a variety of MPD and web clients.  \n
https://mopidy.com

_no_spread_Address to Mopidy access: http://127.0.0.1:6680 or http://<local_IP>:6680
"
function-roof-menu "$roof"
PS3="
Choose paragraph of Mopidy Radio TuneIn settings menu : "
select mopidyMenu in "$str1" "$str2" "$str3" "$str4" "$str5" "$str6" \
"Quit"
 do
 case $mopidyMenu in
	"$str1") $strFunc1;mopidy-func;break
	;;
	"$str2") $strFunc2;mopidy-func;break
	;;
	"$str3") $strFunc3;mopidy-func;break
	;;
	"$str4") $strFunc4;mopidy-func;break
	;;
	"$str5") $strFunc5;mopidy-func;break
	;;
	"$str6") $strFunc6;mopidy-func;break
	;;
	"Quit") clear;i2=0;break;
	;;
    *) echo "Invalid parameter";
           echo "For help, run $ ME -h";
    exit 1
    ;;
 esac
 done
 done
}

# enableWebInterfaceInMopidyConfig
