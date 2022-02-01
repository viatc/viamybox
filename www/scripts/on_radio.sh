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
#on off bellerofonte radiobox

VIADIR="/home/pi/viamybox"
BELLEROFONTEDIR="/home/pi/bellerofonte-radiobox"

# a1='/usr/bin/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
# echo "no function library $a1" 1>&2 ; exit 1 ; fi

process=$(ps -aux | grep -i 'nodejs index.js --no-gpio' |grep -v "grep"|tr -s ' '|cut -d ' ' -f 2)
if [ ! $process ]; then 
	cd $BELLEROFONTEDIR/target
	sudo -u pi bash -c  'nodejs index.js --no-gpio &'
	# echo "yes"
fi