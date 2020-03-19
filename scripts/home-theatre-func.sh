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

function installFunc {
echo "This stuff turns your Raspberry Pi into internet-radio box. It wraps MPD and provides Web-UI for controlling it's playback and volume."
echo "Waiting... will be installed bellerofonte/radiobox!"

#curl -sL https://deb.nodesource.com/setup_11.x | bash -
apt-get install npm mpd mpc nodejs
usermod -a -G pi mpd
cd /home/pi/
git clone https://github.com/bellerofonte/radiobox.git
mv  radiobox bellerofonte-radiobox
chown pi:pi -R $BELLEROFONTEDIR
cd $BELLEROFONTEDIR
sudo -u pi bash -c 'npm install'
sudo -u pi bash -c 'npm run prod'

FILE="target/index.js"
FIND="server.listen"
PARAM1="8001 : 80"
PARAM2="8001 : 8143"
FirstSubstInFile3 "$FILE" "$FIND" "$PARAM1" "$PARAM2"
chown pi:pi $FILE

#read -n 1 -s -r -p "Press any key to continue"
echo -e "ATENTION!!!... Bellerofonte Radio ready to go.. Please start radio in menu and connect in browser with this line http://<ip>:8143\n"
echo "Press enter to continue..."
read n
# EchoLine="Need to reboot.. reboot now?"
# export EchoLine
# SubmitYN result
# if [[ $result = 'Y' ]]; then reboot now & exit 0; fi
}

function uninstallFunc {
cd $BELLEROFONTEDIR
npm prune --production
cd /home/pi
rm -r $BELLEROFONTEDIR
echo "------------------------------------------------------------------------------------------------------"
echo -e "ATENTION!!!... Manually remove packages: npm npc nodejs , if you are not using them in other projects"
echo "Press enter to continue..."
echo "------------------------------------------------------------------------------------------------------"
read n
mpc stop
}

function addKodi
{
AddString="#Via-settings"
CheckStrInFile $AddString $AUTOSTARTFILE result
if [[ $result = 'N' ]]
	then
	AddStrAfterInFile $AUTOSTARTFILE
	AddString="#Via-settings-end"
	AddStrAfterInFile $AUTOSTARTFILE
fi
CheckStrInFile $AddString $AUTOSTARTFILE result

AddString="@kodi"
CheckStrInFile $AddString $AUTOSTARTFILE result
if [[ $result = 'N' ]]
	then
	StrBefore="#Via-settings-end"
	AddStrBeforeInFile $AUTOSTARTFILE $StrBefore $AddString
fi

systemctl disable kiosk
}

function removeKodi
{
file="via.test"
str="@kodi"
deleteStr $AUTOSTARTFILE
}


function kodimenu {
i2=1
while [ $i2 = 1 ]
do
clear
roof="----------------------------------------------------------------------------------------------\n
This is autoload settings for Home Theatre Kodi in your Raspberry Pi \n
$settings\n
$settings2\n
-----------------------------------------------------------------------------------------------"
echo -e $roof
PS3="
Choose paragraph of Kodi settings menu : "
select bellMenu in "$str1" \
"Quit"
 do
 case $bellMenu in
	"$str1") $strFunc; clear;kodifunc;break
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

function kioskmenu {
i1=1
while [ $i1 = 1 ]
do
clear
roof="----------------------------------------------------------------------------------------------\n
Web browser Chromium will be started in “kiosk” mode, that is to say to \n
launch in full screen, without any window border, toolbar or notifications\n
$settings\n
$settings2\n
-----------------------------------------------------------------------------------------------"
echo -e $roof
PS3="
Choose paragraph of Kiosk settings menu : "
select kioskMenu in "$str1" \
"$str2" \
"Quit"
 do
 case $kioskMenu in
	"$str1") $strFunc;kioskfunc;break
	;;
	"$str2") $str2Func;kioskfunc;break
	;;
	"Quit") clear;i1=0;break;
	;;
    *) echo "Invalid parameter";
#            echo "For help, run $ ME -h";
    exit 1
    ;;
 esac
 done
 done
}


function addKiosk {
systemctl enable kiosk
removeKodi
}

function removeKiosk {
systemctl disable kiosk
}


function kodifunc
{

AddString="@kodi"
file="/etc/xdg/lxsession/LXDE-pi/autostart"
CheckStrInFile $AddString $AUTOSTARTFILE result

if [[ -e  /etc/systemd/system/graphical.target.wants/kiosk.service ]]; then 
	settings2="☑ Kiosk enabled at startup"
else
	settings2="☐ Kiosk enabled at startup"
fi

if [[ $result = 'N' ]]; then
	str1="Run Kodi at startup "
	settings="☐ Kodi enabled at startup"
	strFunc="addKodi"
else
	str1="Disable Kodi at startup "
	strFunc="removeKodi"
	settings="☑ Kodi enabled at startup"
fi
kodimenu

}

function opensitesmenu {
i2=1

while [ $i2 = 1 ]
do
clear
roof="-----------------------------------------------------------------------------------------------\n
Selected sites for kiosk mode: \n"
echo -e $roof
sed -n '/#kiosk sites/,/#/ p' $VIADIR/conffiles/via.conf |grep -v "#"
echo -e "\n Caution!!! many sites significantly increase the CPU load."
roofend="-----------------------------------------------------------------------------------------------"
echo $roofend
PS3="Determine (add/remove) which sites to open in kiosk mode : "
select kioskMenu in "YouTube" "Facebook" "Twitter" "Instagram" "Telegram" "SoundCloud" "Yandex Music" \
"Reddit" "Twitch" "Spotify" "Google Music" "Deezer" "Netflix" "Live365" "Allmusic" "Iheart" "Tiktok" \
"Amazon" "Tidal" \
"Quit"
 do
 case $kioskMenu in
	"YouTube") {
	strsite="https://youtube.com/tv"
	addremovesite
	break
	}
	;;
	"Facebook"){
	strsite="https://www.facebook.com/"
	addremovesite
	break
	}
	;;
	"Twitter"){
	strsite="https://help.twitter.com/"
	addremovesite
	break
	}
	;;
	"Instagram"){
	strsite="https://www.instagram.com/"
	addremovesite
	break
	}
	;;
	"Telegram"){
	strsite="https://telegram.org/"
	addremovesite
	break
	}
	;;
	"SoundCloud"){
	strsite="https://soundcloud.com/"
	addremovesite
	break
	}
	;;
	"Yandex Music"){
	strsite="https://music.yandex.ru/home"
	addremovesite
	break
	}
	;;
	"Reddit"){
	strsite="https://www.reddit.com/"
	addremovesite
	break
	}
	;;
	"Twitch"){
	strsite="https://www.twitch.tv/"
	addremovesite
	break
	}
	;;
	"Spotify"){
	strsite="https://open.spotify.com/"
	addremovesite
	break
	}
	;;
	"Google Music"){
	strsite="https://play.google.com/music"
	addremovesite
	break
	}
	;;
	"Deezer"){
	strsite="https://www.deezer.com/"
	addremovesite
	break
	}
	;;
	"Netflix"){
	strsite="https://www.netflix.com/"
	addremovesite
	break
	}
	;;
	"Live365"){
	strsite="https://live365.com/"
	addremovesite
	break
	}
	;;
	"Allmusic"){
	strsite="https://www.allmusic.com/"
	addremovesite
	break
	}
	;;
	"Iheart"){
	strsite="https://www.iheart.com/podcast/"
	addremovesite
	break
	}
	;;
	"Tiktok"){
	strsite="https://www.tiktok.com/"
	addremovesite
	break
	}
	;;
	"Amazon"){
	strsite="https://www.amazon.com/ref=nav_logo"
	addremovesite
	break
	}
	;;
	"Tidal"){
	strsite="https://tidal.com/"
	addremovesite
	break
	}
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

function addremovesite {
AddString=$strsite
AfterStr="#kiosk sites"

CheckStrInFile $AddString $CONFFILE result
if [[ $result = 'N' ]]
	then
	AddStrAfterStrInFile "$CONFFILE" "$AfterStr" "$AddString"
else 
	if [[ $(sed -n '/#kiosk sites/,/#/ p' $VIADIR/conffiles/via.conf |grep -c -v "#") -eq 1 ]]; then
	echo "As a minimum one site should be in the browser bar!!! Press any key";read
	else
	str=$strsite
	deleteStr $CONFFILE
	fi
fi

}

function kioskfunc
{

AddString="@kodi"
file="/etc/xdg/lxsession/LXDE-pi/autostart"
CheckStrInFile $AddString $AUTOSTARTFILE result
if [[ $result = 'N' ]]; then
	settings="☐ Kodi enabled at startup"
else
	settings="☑ Kodi enabled at startup"
fi

if [[ -e  /etc/systemd/system/graphical.target.wants/kiosk.service ]]; then 
	settings2="☑ Kiosk enabled at startup"
	str1="Disable Kiosk chromium mode at startup "
	strFunc="removeKiosk"
else
	settings2="☐ Kiosk enabled at startup"
	str1="Run Kiosk chromium mode at startup "
	strFunc="addKiosk"
fi

str2="Open Sites in the browser"
str2Func="opensitesmenu"

kioskmenu
}