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

function installfunc {
EchoLine="Would you like to install any docker images and containers Home Assistant?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then break; fi
curl -sL https://raw.githubusercontent.com/home-assistant/hassio-installer/master/hassio_install.sh | bash -s -- -m raspberrypi3
#read -n 1 -s -r -p "Press any key to continue"
echo -e "ATENTION!!!...If the configuration has not been deleted user for Home Assistant is : pi \n Password is 123#Qwer! MUST BE CHANGED \n In browser connect with this line http://<ip>:8123\n"
if [ ! -d /usr/share/hassio/homeassistant/camera ]; then mkdir -p /usr/share/hassio/homeassistant/camera; fi
if [ ! -d /usr/share/hassio/homeassistant/scripts ]; then mkdir -p /usr/share/hassio/homeassistant/scripts; fi
# if [ -e $VIADIR/conffiles/homeassistant/takeSnapshotWebcam.sh ]; then
	# cp $VIADIR/conffiles/homeassistant/takeSnapshotWebcam.sh /usr/share/hassio/homeassistant/scripts/
# fi
if [ -e $VIADIR/conffiles/homeassistant/backup.tar ]; then
	mkdir -p /usr/share/hassio/backup
	cp $VIADIR/conffiles/homeassistant/backup.tar /usr/share/hassio/backup/
fi 
echo "Home Assistant installed successfully"
}

function uninstallfunc {
EchoLine="Would you like to remove any docker images and containers Home Assistant?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then break; fi 
echo "Waiting... will be removed hassio docker images and containers!"
systemctl stop hassio-supervisor.service
#systemctl stop hassio-apparmor.service
if [[ $(docker ps |grep  hassio_dns) ]]
	then docker container stop  hassio_dns;fi
if [[ $(docker ps |grep homeassistant) ]]
	then docker container stop homeassistant;fi
if [[ $(docker ps |grep addon_core_configurator) ]]
	then docker container stop addon_core_configurator;fi
systemctl disable hassio-supervisor.service
#systemctl disable hassio-apparmor.service
echo "Removed docker containers:"
docker container rm homeassistant hassio_supervisor hassio_dns 2>/dev/null
if [[ $(docker ps -a|grep addon_core_configurator) ]]
	then docker container rm addon_core_configurator;fi

rm -rf /usr/sbin/hassio-supervisor
rm -rf /usr/sbin/hassio-apparmor
docker images -a | grep "homeassistant" | awk '{print $3}' | xargs docker rmi -f

#docker volume rm $(docker volume ls -qf dangling=true)


EchoLine="Would you like to delete Home assistant config files in directory /usr/share/hassio/?"
export EchoLine
SubmitYN result
if [[ $result = 'Y' ]]; then rm -rf /usr/share/hassio/ ; fi
#read -n 1 -s -r -p "Press any key to continue"
}

function installedmenu {
while [ $i = 1 ]
do
clear
PS3="Choose paragraph of IoT settings menu : "
select menu in "$str1" \
"Quit"
 do
 case $menu in
	"$str1") $strFunc; clear;iotfunc;break
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
PS3="Choose paragraph of IoT settings menu : "
select Menu in "$str1" "$str2" "$str3" "Quit"
 do
 case $Menu in
	"$str1") $strFunc; clear;motioneyefunc;break
	;;
	"$str2") echo "Waiting...";$command2; clear;iotfunc;break
	;;
	"$str3") echo "Waiting...";$command3; clear;iotfunc;break
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

function installedmenu {
while [ $i = 1 ]
do
clear
PS3="Choose paragraph of IoT settings menu : "
select timeElapsedMenu in "$str1" \
"Quit"
 do
 case $timeElapsedMenu in
	"$str1") $strFunc; clear;iotfunc;break
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
PS3="Choose paragraph of Home Assistant settings menu : "
select Menu in "$str1" "$str2" "$str3" "Quit"
 do
 case $Menu in
	"$str1") $strFunc; clear;iotfunc;break
	;;
	"$str2") echo "Waiting...";$command2; clear;iotfunc;break
	;;
	"$str3") echo "Waiting...";$command3; clear;iotfunc;break
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

function startha {
service hassio-supervisor start
docker start homeassistant
}
function stopha {
service hassio-supervisor stop
if [[ $(docker ps |grep homeassistant) ]]
	then docker container stop homeassistant;fi
if [[ $(docker ps |grep addon_core_configurator) ]]
	then docker container stop addon_core_configurator;fi
if [[ $(docker ps |grep  hassio_dns) ]]
	then docker container stop  hassio_dns;fi
}

function iotfunc
{
i=1

if [[ $(docker ps -a|grep homeassistant) ]]; then 
	str1="Uninstall Home Assistant docker instance"
	strFunc="uninstallfunc"
	if [[ $(docker ps |grep homeassistant) ]]
	then str2="Stop Home Assistant"
		command2="stopha"
		else str2="Start Home Assistant"
			command2="startha"
	fi
	if [[ $(systemctl list-unit-files --type=service|grep hassio-supervisor|awk '{print $2}') = 'disabled' ]]
		then str3="Add Home Assistant to startup automatically"
		command3="systemctl enable hassio-supervisor.service"
		else str3="Remove Home Assistant to startup automatically"
			command3="systemctl disable hassio-supervisor.service"
	fi
	uninstalledmenu
	else 
	str1="Install Home assistant docker instance"
	strFunc="installfunc"
	installedmenu
fi

}