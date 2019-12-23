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
	ret=$(ps aux | grep motioneye | wc -l)
		if [ "$ret" -gt 1 ]
then {
	#echo "mjpg starting" #output text
    #    sleep 1  #delay
	docker stop motioneye
}
fi
	
	ret=$(ps aux | grep mjpg_streamer | wc -l)
	if [ "$ret" -eq 1 ]
then {
	echo "mjpg starting" #output text
        sleep 1  #delay
	service mjpg-streamerd stop && service mjpg-streamerd start && exit 0
}
fi