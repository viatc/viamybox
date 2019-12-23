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

# for proc in psutil.process_iter():
	# try:
		# pinfo = proc.as_dict(attrs=['pid', 'name'])
	# except psutil.NoSuchProcess:
		# pass
	# else:
		# print(pinfo)

try:
	for process in psutil.process_iter():
		if process.pid != mypid:
			print process.pid
			print process.name
			for path in process.cmdline():
			#path = process.name()
				print path
				#if privileges1 in path or myname in path:
				if privileges1 in path:
				# if path.find(privileges1) >= 0:
					print "break!"
					break
				print path.find(myname)
				if path.find(myname) >= 0:
					#print process.pid
					print "process mov.py found!"
					process.terminate()
					raise SystemExit
	print "PIR Module Test (CTRL+C to exit)"
	time.sleep(2)
	os.system("sudo bash /home/pi/viamybox/www/scripts/switchMovSensorRec.sh")
	print "Ready"
	while True:
		if GPIO.input(PIR_PIN):
			print "Motion Detected!"
			os.system("sudo -u root bash /home/pi/viamybox/scripts/mov.sh")
			time.sleep(1)
except (SystemExit, KeyboardInterrupt):
	print " Quit"
	GPIO.cleanup()
	myname2 = 'mov.sh'
	for process in psutil.process_iter():
		for path in process.cmdline():
			if path.find(myname2) > 0:
				print "process found mov.sh"
				process.terminate()
	os.system("sudo bash /home/pi/viamybox/scripts/switchMovSensorRec.sh")
except psutil.NoSuchProcess:
	pass
# except Finally:
	# print "Finally"

