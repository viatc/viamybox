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
AUTOSTARTFILE="/etc/xdg/lxsession/LXDE-pi/autostart"
CONFFILE="/home/pi/viamybox/conffiles/via.conf"
export PATH=$PATH:/home/pi/.local/bin


function mps-config-func
{
	str1="All Configuration mps-youtube"
	show_video=$(runuser -l pi -c "mpsyt set,exit|grep show_video")
	show_video=$(echo "$show_video"|awk '{print $3}')
	if [ $show_video = False ]; then 
	str2="Enable show video"
	strFunc2="True"
	else
	str2="Disable show video"
	strFunc2="False"
	fi
	mps-config-menu
}

function mps-config-menu {
i3=1
while [ $i3 = 1 ]
do
clear

roof="This project is based on mps, a terminal based program to search, stream and `
`download music. This implementation uses YouTube as a source of content and `
`can play and download video as well as audio.  \n
https://github.com/mps-youtube/mps-youtube "
function-roof-menu "$roof"
PS3="
Choose paragraph of MPS-Youtube configs menu : "
select mpsConfig in "$str1" "$str2" "Quit"
 do
 case $mpsConfig in
	"$str1") runuser -l pi -c "mpsyt set"; clear;mps-config-func;break
	;;
	"$str2") {
	runuser -l pi -c "mpsyt set show_video $strFunc2,exit"
	clear
	mps-config-func
	break
	}
	;;
	"Quit") clear;i3=0;break;
	;;
    *) echo "Invalid parameter";
#            echo "For help, run $ ME -h";
    exit 1
    ;;
 esac
 done
 done

}

function mps-youtube-func
{

if [ -e /usr/local/bin/mpsyt -o -e  /home/pi/.local/bin/mpsyt ];then
	str1="Uninstall mps-youtube"
	strFunc1="mps-uninstall"
	str2="Play mps-youtube"
	#strFunc2="runuser -l pi -c 'exec mpsyt'"
	str3="Set API Key youtube"
	strFunc3="mps-api"
	str4="Config mps-youtube"
	strFunc4="mps-config-func"
	mps-menu-play
else
	str1="Install mps-youtube"
	strFunc="mps-install"
	mps-menu-install
fi

}

function mps-menu-install {
i2=1
while [ $i2 = 1 ]
do
clear
roof="This project is based on mps, a terminal based program to search, stream and `
`download music. This implementation uses YouTube as a source of content and `
`can play and download video as well as audio.  \n
https://github.com/mps-youtube/mps-youtube "
function-roof-menu "$roof"
PS3="
Choose paragraph of MPS-Youtube settings menu : "
select mpsMenu in "$str1" \
"Quit"
 do
 case $mpsMenu in
	"$str1") $strFunc; clear;mps-youtube-func;break
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

function mps-menu-play {
i2=1
while [ $i2 = 1 ]
do
clear
roof="This project is based on mps, a terminal based program to search, stream and `
`download music. This implementation uses YouTube as a source of content and `
`can play and download video as well as audio.  \n
https://github.com/mps-youtube/mps-youtube "
function-roof-menu "$roof"
PS3="
Choose paragraph of MPS-Youtube settings menu : "
select mpsMenu in "$str1" "$str2" "$str3" "$str4" \
"Quit"
 do
 case $mpsMenu in
	"$str1") $strFunc1; clear;mps-youtube-func;break
	;;
	"$str2") rm -f /home/pi/.config/mps-youtube/cache_py*;sudo -u pi bash -c 'mpsyt'; clear;mps-youtube-func;break
	;;
	"$str3") $strFunc3; clear;mps-youtube-func;break
	;;
	"$str4") $strFunc4; clear;mps-youtube-func;break
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

function mps-uninstall {
 runuser -l pi -c "pip3 uninstall mps-youtube"
 rm -rf /usr/local/bin/mpsyt /home/pi/.local/bin/mpsyt
 rm -rf /home/pi/mps-youtube
 rm -rf /home/pi/.config/mps-youtube
 runuser -l pi -c "pip3 uninstall youtube-dl"
 echo "--------------------------------------------------------"
 echo "Please remove manually, if you don't use it other place:"
 echo "sudo apt-get uninstall mpv"
 echo "--------------------------------------------------------"
  echo "Press any key";read a
}

function mps-install {
 apt-get install mpv
 runuser -l pi -c "pip3 install --user mps-youtube"
 runuser -l pi -c "pip3 install --user youtube-dl"
 runuser -l pi -c "pip3 install --user youtube-dl --upgrade"
 #cd /home/pi
 # sudo -u pi bash -c 'git clone https://github.com/mps-youtube/mps-youtube.git'
 # cd mps-youtube
 #python3 setup.py install
 #sudo -u pi bash -c "mpsyt set show_video true"
 echo "Press any key";read a
}

function mps-api {
clear
roof="YouTube Data API will be used in this project 
			Do the following on google developer pages: 
	Login into google account 
	Visit https://console.developers.google.com/apis/ 
	Click on \"ENABLE APIS AND SERVICES\" 
	Search for \"YouTube Data API v3\" 
	Generate a new key (may require creating a new project) 

 If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.
----------------------------------------------------
We have an api key generated for testing for you:
AIzaSyBggONEC6omj5JfDGLyEV-x2nJY3X60GJs

But it can be restricted by the number of times of use, so form your key better"
function-roof-menu "$roof"
echo "Paste API here:";read api
if [ $api ]; then 
runuser -l pi -c "mpsyt set api_key "$api""
else echo "The string is empty! Press any key";read a
fi
}
