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
BELLEROFONTEDIR="/home/pi/bellerofonte-radiobox"

function installFunc {
echo "This program turns your Raspberry Pi into internet-radio box. It wraps MPD and provides Web-UI for controlling it's playback and volume."
echo "Waiting... will be installed bellerofonte/radiobox!"

#curl -sL https://deb.nodesource.com/setup_11.x | bash -

#apt-get install npm 
apt-get install mpd mpc nodejs git npm
usermod -a -G pi mpd
cd /home/pi/
git clone https://github.com/bellerofonte/radiobox.git
mv  radiobox bellerofonte-radiobox
chown pi:pi -R $BELLEROFONTEDIR
cd $BELLEROFONTEDIR
#sudo -u pi bash -c 'npm install -g npm'
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
echo "You may need to reboot! Press enter to continue..."
read n
# EchoLine="Need to reboot.. reboot now?"
# export EchoLine
# SubmitYN result
# if [[ $result = 'Y' ]]; then reboot now & exit 0; fi
}

function uninstallFunc {
EchoLine="Wold you like to uninstall Bellerofonte Radio?"
SubmitYN result
if [[ $result = 'Y' ]];then
	cd $BELLEROFONTEDIR
	npm prune --production
	cd /home/pi
	rm -r $BELLEROFONTEDIR
	echo "------------------------------------------------------------------------------------------------------"
	echo -e "ATENTION!!!... Manually remove packages: npm npc nodejs , if you are not using them in other projects"
	echo "Press enter to continue..."
	echo "------------------------------------------------------------------------------------------------------"
	#apt remove --purge nodejs npm
	read n
	mpc stop
fi
}

function installedmenu {

while [ $i = 1 ]
do
clear
roof="This stuff turns your Raspberry Pi into internet-radio box. It wraps MPD and provides
Web-UI for controlling it's playback and volume.\n
When radio started in menu, connect in browser with this line http://<paste your ip>:8143"
function-roof-menu "$roof"
PS3="Choose paragraph of Bellerofonte Radio settings menu : "
select bellMenu in "$str1" \
"Quit"
 do
 case $bellMenu in
	"$str1") $strFunc; clear;bellfunc;break
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

function uninstalledmenu {
while [ $i = 1 ]
do
clear
roof="This stuff turns your Raspberry Pi into internet-radio box. It wraps MPD and provides`
`Web-UI for controlling it's playback and volume.\n
When radio started in menu, connect in browser with this line http://<paste your ip>:8143"
function-roof-menu "$roof"
PS3="Choose paragraph of Bellerofonte Radio settings menu : "
select Menu in "$str1" "$str2" "Quit"
 do
 case $Menu in
	"$str1") $strFunc; clear;bellfunc;break
	;;
	"$str2") echo "Waiting...";$command2; clear;bellfunc;break
	;;
	# "$str3") echo "Waiting...";$command3; clear;bellfunc;break
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

function startradio {
cd $BELLEROFONTEDIR/target
sudo -u pi bash -c  'nodejs index.js --no-gpio &'
}

function stopradio {
#process=$(ps aux | grep -i 'nodejs index.js --no-gpio' | grep -v grep|tr -s ' '|cut -d ' ' -f 2)
kill -9 $process
mpc stop
}

function bellfunc
{
i=1

 if [[ -e $BELLEROFONTEDIR ]]; then  
	str1="Uninstall bellerofonte-radiobox"
	strFunc="uninstallFunc"
	#ps -aux | grep -i 'nodejs index.js --no-gpio' |grep -v grep > /dev/null 2>&1
	#if [[ $? == 0 ]]; then 
	process=$(ps -aux | grep -i 'nodejs index.js --no-gpio' |grep -v "grep"|tr -s ' '|cut -d ' ' -f 2)
	if [ $process ]; then 
	str2="Stop Radiobox ( ☑ Enabled at startup )"
		command2="stopradio"
		uninstalledmenu
	else 
		str2="Start Radiobox  ( ☐ Enabled at startup )"
		command2="startradio"
		uninstalledmenu
	fi
 else
	str1="Install bellerofonte-radiobox"
	strFunc="installFunc"
	installedmenu

 fi

}