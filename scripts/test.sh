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

#uninstallation viamybox
VIADIR="/home/pi/viamybox"
a1='/home/pi/viamybox/scripts/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi

# PATH_TO_YOUR_CONFIG=""
# EchoLine="Where is be located path to your Home Assistant config? [Please Enter to confirn default path: /home/pi/home_assistant]:"
# echo -n $EchoLine
# read PATH_TO_YOUR_CONFIG
# if [ -z $PATH_TO_YOUR_CONFIG ];then PATH_TO_YOUR_CONFIG="/home/pi/home_assistant";fi
# echo $PATH_TO_YOUR_CONFIG


 if [[ $(docker inspect -f "{{ .HostConfig.RestartPolicy.Name }}" homeassistant) = 'no' ]];then
   echo 'yes'
 fi
