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
function installFunc {
echo "Waiting... will be installed ccrisan/motionEye docker!"
docker run --name="motioneye" \
    -p 8133:8765 \
	-p 8134:8081 \
    --hostname="motioneye" \
    -v /etc/localtime:/etc/localtime:ro \
    -v /etc/motioneye:/etc/motioneye \
    -v /var/lib/motioneye:/var/lib/motioneye \
    --restart="no" \
    --detach=true \
	--device=/dev/video0 \
    ccrisan/motioneye:master-armhf
#read -n 1 -s -r -p "Press any key to continue"
echo -e "ATENTION!!!... user for motionEye is : admin \n Password is empty! \n In browser connect with this line http://<ip>:8133\n"
echo "Press enter to continue..."
read n
# EchoLine="Need to reboot.. reboot now?"
# export EchoLine
# SubmitYN result
# if [[ $result = 'Y' ]]; then reboot now & exit 0; fi
}

function uninstallFunc {
EchoLine="Would you like to remove any docker images and containers motionEye?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then break; fi 
EchoLine="Waiting... will be removed ccrisan/motionEye docker  images and containers!\n"
docker stop motioneye

echo "Removed image motionEye..."
docker ps -a | grep "motioneye" | awk '{print $2}' | xargs docker rmi -f 
echo "Removed docker containers:"
docker container rm -f motioneye

sudo docker volume rm $(docker volume ls -qf dangling=true)

EchoLine="Would you like to delete Motion all config and motion files in directories /etc/motioneye /var/lib/motioneye?"
export EchoLine
SubmitYN result
if [[ $result = 'Y' ]]; then rm -rf {/var/lib/motioneye,/etc/motioneye} ; fi
#read -n 1 -s -r -p "Press any key to continue"
}

function installedmenu {
while [ $i = 1 ]
do
clear
PS3="Choose paragraph of motionEye settings menu : "
select timeElapsedMenu in "$str1" \
"Quit"
 do
 case $timeElapsedMenu in
	"$str1") $strFunc; clear;motioneyefunc;break
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
PS3="Choose paragraph of motionEye settings menu : "
select Menu in "$str1" "$str2" "$str3" "Quit"
 do
 case $Menu in
	"$str1") $strFunc; clear;motioneyefunc;break
	;;
	"$str2") echo "Waiting...";$command2; clear;motioneyefunc;break
	;;
	"$str3") echo "Waiting...";$command3; clear;motioneyefunc;break
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

function motioneyefunc
{
i=1

if [[ $(docker ps -a|grep motioneye) ]]; then 
	str1="Uninstall ccrisan/motionEye docker instance"
	strFunc="uninstallFunc"
	if [[ $(docker ps |grep motioneye) ]]
		then str2="Stop motionEye"
			command2="docker stop motioneye"
		else str2="Start motionEye"
			command2="docker start motioneye"
	fi
	if [[ $(docker inspect -f "{{ .HostConfig.RestartPolicy.Name }}" motioneye) = 'no' ]]
		then str3="Add motionEye to startup automatically"
			command3="docker update --restart=always motioneye"
		else str3="Remove motionEye to startup automatically"
			command3="docker update --restart=no motioneye"
	fi
	uninstalledmenu
	else 
	str1="Install ccrisan/motionEye (docker container)"
	strFunc="installFunc"
	installedmenu
fi


}