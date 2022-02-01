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
	
	## This is part of code based on project:
	## https://github.com/crcerror/ES-generic-shutdown/blob/master/multi_switch.sh
	## Many thanks!
	
# a1='/home/pi/viamybox/scripts/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
# echo "no function library $a1" 1>&2 ; exit 1 ; fi
VIADIR="/home/pi/viamybox"
FILECONF="/home/pi/viamybox/conffiles/via.conf"

set -e

# ---------------------------------------------------------------------------------------------
# -------------------------------------- KODI PROCESSES----------------------------------------
# ---------------------------------------------------------------------------------------------

adddate() {
datetime=$(date '+%Y-%m-%d %H:%M:%S%:z')
}

function check_kodirun() {
    local KODI_PID="$(pgrep -f "kodi-standalone")"
    echo $KODI_PID
}

function startKodi () {
# kodi-standalone &
# datetime=$(date '+%Y-%m-%d %H:%M:%S%:z')
adddate
DISPLAY=:0 su -c - pi "echo -ne $datetime'\t' 1>&2; kodi-standalone &" 
}

function stopKodi () {
	kodi-send --action="Quit"
    # wait_forpid $KODI_PID
}

# ---------------------------------------------------------------------------------------------
# --------------------------------- EMULATIONSTATION PROCESSES---------------------------------
# ---------------------------------------------------------------------------------------------


# This is code based on project:
# https://github.com/crcerror/ES-generic-shutdown/blob/master/multi_switch.sh

# Abolish sleep timer! This one is much better!
# I added watchdog to kill emu-processes with sig 9 level after 2.0s
# If emulator PID ist active after 5.0s, return to call
# I will prevent ES from being termed with level 9 for sake of safe shutdown
function wait_forpid() {
    local PID=$1
    [[ -z $PID ]] && return 1

    local RC_PID=$(check_emurun)
    local watchdog=0

    while [[ -e /proc/$PID ]]; do
        sleep 0.10
        watchdog=$((watchdog+1))
        [[ $watchdog -eq 20 ]] && [[ $RC_PID -gt 0 ]] && kill -9 $PID
        [[ $watchdog -eq 50 ]] && [[ $RC_PID -gt 0 ]] && return
    done
}

# Emulator currently running?
# If yes return PID from runcommand.sh
# due caller funtion
function check_emurun() {
    local RC_PID="$(pgrep -f -n runcommand.sh)"
    echo $RC_PID
}

# Emulationstation currently running?
# If yes return PID from ES binary
# due caller funtion
function check_esrun() {
    local ES_PID="$(pgrep -f "/opt/retropie/supplementary/.*/emulationstation([^.]|$)")"
    echo $ES_PID
}

function stopEmulationstation {
 
ES_PID=$(check_esrun)
if [[ -n $ES_PID ]]; then
    kill $ES_PID
    wait_forpid $ES_PID
    exit
fi
}

function startEmulationstation {
DISPLAY=:0 su -c - pi "emulationstation &" 
}

# ---------------------------------------------------------------------------------------------
# ----------------------------------------MAIN-------------------------------------------------
# ---------------------------------------------------------------------------------------------

case "$1" in
  --help)
	echo "Usage: $0 or $0 --recvideo" >&2
	;;
  --startkodi|-sk)
    KODI_PID=$(check_kodirun)
	if [[ -n $KODI_PID ]]; then
		echo "Kodi is already running!"
		exit
	fi
	startKodi
	;;
  --stopkodi|-kk)
	stopKodi
	;;
  --startemulationstation|-ses)
    ES_PID=$(check_esrun)
	if [[ -n $ES_PID ]]; then
		echo "Emulationstation is already running!"
		exit
	fi
	startEmulationstation
	;;
  --stopemulationstation|-kes)
	stopEmulationstation
	;;
  *)
	echo "Usage: $0 [OPTIONS]
	OPTIONS:
	
	-sk, --startkodi 
	-kk, --stopkodi 
	-ses, --startemulationstation 
	-kes, --stopemulationstation
		" >&2
	;;
esac
