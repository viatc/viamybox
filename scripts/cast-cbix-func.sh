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
strScreenID=""
PairCode=""

a1='/home/pi/viamybox/scripts/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi


function cast-cbix-func
{
if [ -e /home/pi/projects/bin/gotubecast ]; then
str1="Uninstall CBiX/Gotubecast"
strFunc1="uninstall-gotubecast"
startmenu="gotubecast-menu-install"
else
str1="Install CBiX/Gotubecast"
strFunc1="install-gotubecast"
startmenu="gotubecast-menu-uninstall"
fi


ps=$(systemctl show -p SubState --value gotubecast)

if [[ $ps = "running" ]];then
	str2="Stopping gotubecast"
	strFunc2="systemctl stop gotubecast.service" 
	while [[ -z $PairCode ]];do 
		sleep 0.2;
		PairCode=$(systemctl status gotubecast.service |grep "Your pairing code:" | tail -1|awk -F":" '{print $4,":",$5}')
		strPairCode="------------------------------------------------\n"$PairCode""
	done
else
	str2="Starting gotubecast"
	strFunc2="systemctl start gotubecast.service" 
	strPairCode="";PairCode=""
fi

if [ -e /etc/systemd/system/multi-user.target.wants/gotubecast.service ];then
	str3="Disabling gotubecast when system boots"
	strFunc3="systemctl disable gotubecast.service"
	else
	str3="Enabling gotubecast when system boots"
	strFunc3="systemctl enable gotubecast.service"
fi
eval $startmenu
}

function gotubecast-menu-install {
i2=1
while [ $i2 = 1 ]
do
clear
roof="-----------------------------------------------------------------------------------------------\n
Gotubecast is a small Go program which you can use to make your own YouTube TV player. \n
 It connects to the YouTube Leanback API and generates a text stream providing pairing codes,\n
 video IDs, play/pause/seek/volume change commands etc. \n
 For example, use it on a Raspberry Pi in combination with youtube-dl and  omxplayer for \n
 a DIY Chromecast clone or make a YouTube TV extension for your favorite media center software.\n
https://github.com/CBiX/gotubecast\n
 !!! After you have generated Screen ID, enter pairing code in your youtube\n 
 application (Settings -> Connect on TV ) on your phone or other device from where\n 
 you cost youtube, to determine your streaming raspberry pi\n
 $strPairCode\n
 $(echo "$strScreenID")
\n-----------------------------------------------------------------------------------------------"
echo -e $roof
PS3="
Choose paragraph of CBiX/Gotubecast settings menu : "
select castMenu in "$str1" "$str2" "$str3" "Generate Screen ID" \
"Quit"
 do
 case $castMenu in
	"$str1") $strFunc1; clear;cast-cbix-func;break
	;;
	"$str2") $strFunc2;cast-cbix-func;break
	;;
	"$str3") $strFunc3; clear;cast-cbix-func;break
	;;
	"Generate Screen ID") generate-screen-id-menu; clear;cast-cbix-func;break
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

function gotubecast-menu-uninstall {
i2=1
while [ $i2 = 1 ]
do
clear
roof="-----------------------------------------------------------------------------------------------\n
Gotubecast is a small Go program which you can use to make your own YouTube TV player. \n
 It connects to the YouTube Leanback API and generates a text stream providing pairing codes,\n
 video IDs, play/pause/seek/volume change commands etc. \n
 For example, use it on a Raspberry Pi in combination with youtube-dl and  omxplayer for \n
 a DIY Chromecast clone or make a YouTube TV extension for your favorite media center software.\n
https://github.com/CBiX/gotubecast\n
-----------------------------------------------------------------------------------------------"
echo -e $roof
PS3="
Choose paragraph of CBiX/Gotubecast settings menu : "
select castMenu in "$str1" \
"Quit"
 do
 case $castMenu in
	"$str1") $strFunc1; clear;i2=0;cast-cbix-func;break
	;;
	"Quit") clear;break;
	;;
    *) echo "Invalid parameter";
#            echo "For help, run $ ME -h";
    exit 1
    ;;
 esac
 done
 done
}


function install-gotubecast
{
sudo apt-get install bc omxplayer
cd /home/pi
#--------install golang
if [ ! -d /usr/local/go ];then
	runuser -l pi -c "wget https://dl.google.com/go/go1.13.7.linux-armv6l.tar.gz"
	tar -C /usr/local/ -xvzf go1.13.7.linux-armv6l.tar.gz
	rm go1.13.7.linux-armv6l.tar.gz
	runuser -l pi -c "mkdir -p projects/{src,pkg,bin}"
	export PATH=$PATH:/usr/local/go/bin
fi

FILE="/home/pi/.profile"
AddString="#Via-settings"
AddStrAfterInFile $FILE

AddString="#Via-settings-end"
AddStrAfterInFile $FILE

AddString="export PATH=\$PATH:/usr/local/go/bin
export GOBIN=\"/home/pi/projects/bin\"
export GOPATH=\"/home/pi/projects/src\"
export GOROOT=\"/usr/local/go\""
StrBefore="#Via-settings-end"
AddStrBeforeInFile "$FILE" "$StrBefore" "$AddString"
chown pi:pi $FILE
#--------------install gotubecast
cd /home/pi
CMD="go get github.com/CBiX/gotubecast"
runuser -l pi -c "eval $CMD"
cp /home/pi/viamybox/conffiles/gotubecast.service /lib/systemd/system/
cp /home/pi/projects/bin/gotubecast /usr/bin/
#-----------install youtube-dl
runuser -l pi -c "pip install --user youtube-dl"
runuser -l pi -c "pip install --user youtube-dl --upgrade"
#systemctl enable gotubecast.service


echo "Press Enter key";read a
}

function uninstall-gotubecast
{
EchoLine="Wold you like to uninstall CBiX/gotubecast?"
SubmitYN result
if [[ $result = 'Y' ]];then
rm -rf /home/pi/projects/bin/gotubecast
rm -rf /usr/bin/gotubecast
rm -rf /home/pi/projects/src/src/github.com/CBiX/gotubecast
systemctl disable gotubecast.service
rm -rf /lib/systemd/system/gotubecast.service

AddString="export PATH=\$PATH:/usr/local/go/bin
export GOBIN=\"/home/pi/projects/bin\"
export GOPATH=\"/home/pi/projects/src\"
export GOROOT=\"/usr/local/go\""
FILE="/home/pi/.profile"
str="$AddString"
deleteStr "$FILE"
chown pi:pi $FILE
fi

EchoLine="Wold you like to uninstall golang?"
SubmitYN result
if [[ $result = 'Y' ]];then
rm -rf /usr/local/go
fi
echo "Press Enter key";read a
}


function generate-screen-id-func {
cd /tmp
wget https://www.youtube.com/api/lounge/pairing/generate_screen_id
ID=$(cat generate_screen_id)
rm -rf generate_screen_id
FILE="/home/pi/projects/src/src/github.com/CBiX/gotubecast/examples/raspi.sh"
VARIABLE="SCREEN_ID="
PARAM="\"$ID\""
FirstSubstInFile $FILE $VARIABLE $PARAM
#cat "/home/pi/projects/src/src/github.com/CBiX/gotubecast/examples/raspi.sh"
strScreenID="------------------------------------------------\n Screen ID generated : $ID"
chown pi:pi $FILE
chmod +x $FILE
ps=$(systemctl show -p SubState --value gotubecast)
if [[ $ps = "running" ]];then
	PairCode=""
	systemctl daemon-reload
	systemctl restart gotubecast.service
fi
}

function generate-screen-id-menu {
i3=1
while [ $i3 = 1 ]
do
clear
roof="-----------------------------------------------------------------------------------------------\n
Generate a Screen ID for your TV to which your raspberry pi is connected and this\n
 will allow you to automatically connect to your TV via youtube your phone or \n
other device from which you stream youtube via raspberry.
\n-----------------------------------------------------------------------------------------------"
echo -e $roof
PS3="
Choose Generate Screen Id menu : "
select castMenu in "Generate Screen ID" \
"Quit"
 do
 case $castMenu in
	"Generate Screen ID") generate-screen-id-func;clear;i3=0;cast-cbix-func;break
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

#cast-cbix-func
