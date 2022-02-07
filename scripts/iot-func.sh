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

# EchoLine="A \"Home Assistant\" instance will need a \"network manager\" \"awahi-daemon\" packages. `
# `And therefore, we need to delete your current network instance:\"openresolv dhcpcd5\".
# Warning !!! All network connections can be lost!!!
# This script will be run in terminal, not in ssh session. You will need to manually reconfigure your network connection after installation.
# 	Proceed?"
#
# if [ $(dpkg-query -W -f='${Status}' network-manager 2>/dev/null | grep -c "ok installed") -eq 0 ];then
# 	export EchoLine
# 	SubmitYN result
# 	if [[ $result = 'N' ]]; then return 0;fi
# 	apt-get install avahi-daemon network-manager network-manager-gnome
# 	apt purge openresolv dhcpcd5
#
# 	EchoLine="Please set network settings through the network-manager tool \"nmtui\"
# 	Proceed?"
# 	export EchoLine
# 	SubmitYN result
# 	if [[ $result = 'Y' ]]; then nmtui;fi
#
# 	EchoLine="Restart your system and run this installation of \"Home Assistant\" again.
# 	Reboot now?"
# 	echo #EchoLine
# 	SubmitYN result
# 	if [[ $result = 'N' ]]; then return 0;fi
# 	reboot now
# fi
#
# apt-get install apparmor-utils apt-transport-https ca-certificates curl dbus jq socat software-properties-common

if [ $(dpkg-query -W -f='${Status}' docker-ce 2>/dev/null | grep -c "ok installed") -eq 0 ];then
	curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh
	usermod -aG docker pi
fi
sleep 5
# service docker start

EchoLine="Would you like to install any docker images and containers Home Assistant?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then return 0; fi

PATH_TO_YOUR_CONFIG=""
EchoLine="Where is be located path to your Home Assistant config? [Enter to confirm default path: /home/pi/home_assistant]:"
echo -n $EchoLine
read PATH_TO_YOUR_CONFIG
if [ -z $PATH_TO_YOUR_CONFIG ];then PATH_TO_YOUR_CONFIG="/home/pi/home_assistant";fi
echo $PATH_TO_YOUR_CONFIG


MY_TIME_ZONE=$(timedatectl|grep 'Time zone'| awk '{print $3}')
EchoLine="Please select Time Zone. [Enter to confirm default Time Zone: $MY_TIME_ZONE ]:"
echo -n $EchoLine
read MY_TIME_ZONE2
if [[ -n $MY_TIME_ZONE2 ]];then MY_TIME_ZONE="$MY_TIME_ZONE2";fi
echo "$MY_TIME_ZONE"


if [[ $(cat /proc/device-tree/model |awk '{print $3}') = '4' ]];then
	# curl -sL https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh |bash -s -- -m raspberrypi4
	docker run -d \
  --name homeassistant \
  --privileged \
  --restart=unless-stopped \
  -e TZ=$MY_TIME_ZONE \
  -v $PATH_TO_YOUR_CONFIG:/config \
  --network=host \
  ghcr.io/home-assistant/raspberrypi4-homeassistant:stable

else
	# curl -sL https://raw.githubusercontent.com/home-assistant/supervised-installer/master/installer.sh |bash -s -- -m raspberrypi3
	docker run -d \
  --name homeassistant \
  --privileged \
  --restart=unless-stopped \
  -e TZ=$MY_TIME_ZONE \
  -v $PATH_TO_YOUR_CONFIG:/config \
  --network=host \
  ghcr.io/home-assistant/raspberrypi3-homeassistant:stable
fi
#read -n 1 -s -r -p "Press any key to continue"
echo -e "ATENTION!!!...If the configuration has not been deleted user for Home Assistant is : pi \n Password is \"raspberry\" MUST BE CHANGED \n In browser connect with this line http://<ip>:8123\n"
if [ ! -d $PATH_TO_YOUR_CONFIG/camera ]; then mkdir -p $PATH_TO_YOUR_CONFIG/camera; fi
if [ ! -d $PATH_TO_YOUR_CONFIG/scripts ]; then mkdir -p $PATH_TO_YOUR_CONFIG/scripts; fi
# if [ -e $VIADIR/conffiles/homeassistant/takeSnapshotWebcam.sh ]; then
	# cp $VIADIR/conffiles/homeassistant/takeSnapshotWebcam.sh $PATH_TO_YOUR_CONFIG/scripts/
# fi
if [ -e $VIADIR/conffiles/homeassistant/backup.tar ]; then
	mkdir -p /usr/share/hassio/backup
	cp $VIADIR/conffiles/homeassistant/backup.tar /usr/share/hassio/backup/
fi
echo -e "Home Assistant installed successfully.\n
Preparing Home Assistant(web interface can take up to 20 minutes)"
echo "Press any key";read a
}

function uninstallfunc {
EchoLine="Would you like to remove any docker images and containers Home Assistant?"
export EchoLine
SubmitYN result
if [[ $result = 'Y' ]]; then
echo "Waiting... will be removed hassio docker images and containers!"
stopha
# systemctl stop hassio-supervisor.service
#systemctl stop hassio-apparmor.service
# if [[ $(docker ps |grep  hassio_dns) ]]
	# then docker container stop  hassio_dns;fi
# if [[ $(docker ps |grep  hassio_audio) ]]
	# then docker container stop  hassio_audio;fi
# if [[ $(docker ps |grep homeassistant) ]]
	# then docker container stop homeassistant;fi
# if [[ $(docker ps |grep addon_core_configurator) ]]
	# then docker container stop addon_core_configurator;fi
#systemctl disable hassio-apparmor.service

# systemctl disable hassio-supervisor.service
echo "Removed docker containers:"
# docker container rm homeassistant
docker container rm $(sudo docker ps -a | grep homeassistant | awk '{print $1}')
docker container rm $(sudo docker ps -a | grep hassio | awk '{print $1}')
if [[ $(docker ps -a|grep addon_core_configurator) ]]
	then docker container rm addon_core_configurator;fi

rm -rf /usr/sbin/hassio-supervisor
rm -rf /usr/sbin/hassio-apparmor
docker images -a | grep "homeassistant" | awk '{print $3}' | xargs docker rmi -f
fi

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
function-roof-menu "$firstMenuStr"
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
function-roof-menu "$firstMenuStr"
PS3="Choose paragraph of IoT settings menu : "
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
# service hassio-supervisor start
# service hassio-apparmor start
docker start homeassistant
}
function stopha {
# service hassio-supervisor stop
# service hassio-apparmor stop
 if [[ $(docker ps |grep homeassistant) ]]
	then docker stop $(sudo docker ps -a | grep homeassistant | awk '{print $1}');fi
	# then docker container stop homeassistant;fi
if [[ $(docker ps |grep addon_core_configurator) ]]
	then docker container stop addon_core_configurator;fi
# if [[ $(docker ps |grep  hassio_dns) ]]
	# then docker container stop  hassio_dns;fi
# if [[ $(docker ps |grep  hassio_audio) ]]
	# then docker container stop  hassio_audio;fi
if [[ $(docker ps |grep  hassio) ]]
	then docker stop $(sudo docker ps -a | grep hassio | awk '{print $1}');fi
}

function startHAwhenBoots {
# systemctl enable hassio-supervisor.service
# systemctl enable hassio-apparmor.service
# docker update --restart=always  homeassistant
docker update --restart=unless-stopped  homeassistant
}

function noStartHAwhenBoots {
# systemctl disable hassio-supervisor.service
# systemctl disable hassio-apparmor.service
docker update --restart=no  homeassistant
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
	if [[ $(systemctl list-unit-files --type=service|grep hassio-supervisor|awk '{print $2}') = 'disabled' ]] || [[ $(docker inspect -f "{{ .HostConfig.RestartPolicy.Name }}" homeassistant) = 'no' ]]
		then str3="Add Home Assistant to startup automatically"
		command3="startHAwhenBoots"
		else str3="Remove Home Assistant to startup automatically"
			command3="noStartHAwhenBoots"
	fi
	uninstalledmenu
	else
	str1="Install Home assistant docker instance"
	strFunc="installfunc"
	installedmenu
fi

}
