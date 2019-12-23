## Copyright (C) 2017-2019 ViaMyBox viatc.msk@gmail.com
## This file is a part of ViaMyBox free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## any later version.
##																			
## ViaMyBox software is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##                                                                       
## You should have received a copy of the GNU General Public License
## along with ViaMyBox in /home/pi/COPIYNG file.
## If not, see <https://www.gnu.org/licenses/>.
##                                               

#script to starting record with movement sensor from web interface, cuased cameraframe.php

import RPi.GPIO as GPIO
import time
import os
from sys import argv, exit
import psutil

#myname = argv[0]
myname = 'mov.py'
user = 'root'
privileges1 = 'sudo'
privileges2 = 'su'
print myname
mypid = os.getpid()
print mypid

GPIO.setmode(GPIO.BCM)
PIR_PIN = 7
GPIO.setup(PIR_PIN, GPIO.IN)


try:
	print "PIR Module (CTRL+C to exit)"
	time.sleep(2)
	os.system("sudo /home/pi/viamybox/www/scripts/startMovSensorRec.sh --snapshotsWithFFmpeg")
	print "Ready"
	while True:
		if GPIO.input(PIR_PIN):
			print "Motion Detected!"
			os.system("sudo -u root /home/pi/viamybox/www/scripts/mov.sh")
			time.sleep(1)
except (SystemExit, KeyboardInterrupt):
	print " Quit"
	GPIO.cleanup()


