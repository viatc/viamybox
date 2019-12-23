import RPi.GPIO as GPIO
import time
import os
from sys import argv, exit
import psutil

myname = "mov.py"
#print myname
mypid = os.getpid()
#print mypid

for process in psutil.process_iter():
	if process.pid != mypid:
		#print process.cmdline()
		#print line
		#print "!!!!!!!!!!!!!!!!!!!"
		for path in process.cmdline():
			if path == myname :
				print process.pid
				print path
				print "process found!!!!!!!!!!!!!!!!!!!!!"
				process.terminate()
			#GPIO.cleanup()
			
	# else:
		# continue
		# print process.pid
		# for path in process.cmdline():
			# if myname in path:
				# print ("myname=" + myname)
				#process.kill()
print "EXIT"
exit()
  
# def get_process_by_name(name):
    # for proc in psutil.process_iter():
        # try:
            # if proc.name() == name:
                # return proc
        # except psutil.NoSuchProcess:
            # continue
    # raise KeyError("Process {name!r} not found".format(name=name))
  
# def kill_process_by_name(name):
    # get_process_by_name(name).kill()

# a = 'mov.py'
# get_process_by_name(a)




