#!/usr/bin/env python

# import sys
# import os

# try:
        # os.kill(int(sys.argv[1]), 0)
        # print "Running"
# except:
        # print "Not running"
		
#!/usr/bin/env python

import sys
import os
import subprocess
import errno

#id = 1  -> search for pid
#id = 0  -> search for name (default)

def process_exists(proc, id = 0):
   # ps = subprocess.Popen("ps -A", shell=True, stdout=subprocess.PIPE)
   # cmd_line= "pgrep -f " + proc
   cmd_line= "ps -eaf | grep " + proc
   ps = subprocess.Popen("ps -A", shell=True, stdout=subprocess.PIPE)
   # ps = subprocess.Popen("pgrep -f -n % proc", shell=True, stdout=subprocess.PIPE)
   ps_pid = ps.pid
   output = ps.stdout.read()
   ps.stdout.close()
   ps.wait()
   print(output)
   # print(output)
   for line in output.split("\n"):
      if line != "" and line != None:
        fields = line.split()
        pid = fields[0]
        pname = fields[3]
        if(id == 0):
            if(pname == proc):
				print("AAA"+pid)
				return True
        else:
            if(pid == proc):
		print("BBB")
		return True
   return False

proc = "kodi-standalone"
process_exists(proc,0)