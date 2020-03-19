#!/bin/bash
#shell for cbix/gotubecast service starting

while ! ping -q -c 1 8.8.8.8 >/dev/null ; do sleep 1; done
# /home/pi/gotubecast/examples/raspi.sh
/home/pi/projects/src/src/github.com/CBiX/gotubecast/examples/raspi.sh
