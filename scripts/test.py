#!/usr/bin/env python

import sys
import os
import subprocess
import errno
import json

#id = 1  -> search for pid
#id = 0  -> search for name (default)

# proc = subprocess.run(["curl", "http://192.168.226.60/test.php"],shell=True, stdout=subprocess.PIPE)
# proc = subprocess.Popen(["curl","-k", "http://192.168.226.60/test.php"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
# proc = subprocess.run(["curl", "http://192.168.226.60/rec-av-start.php"],stdout=subprocess.PIPE,stderr=subprocess.PIPE)
# print(proc)
# script_response = proc.stdout.read()
# streamdata = proc.communicate()[0]
# rc = proc.returncode
# print(proc.stdout) 
# print(proc.stderr) 
# print(rc) 
# if proc.stdout.decode('utf-8') == "Process via_rec_av_start.sh is already running\n":
	# print(proc.stdout.decode('utf-8'))
# with subprocess.Popen(["curl", "http://192.168.226.60/test.php"],stdout=subprocess.PIPE,stderr=subprocess.PIPE) as process:
	# log.write(process.stdout.read())

# code = process.wait()

	# with open('/tmp/file.txt', 'a') as f:
		# f.writelines(line)
		# print("yes")
	# print(line)
# print(process)
# print(data)
# process.stdout.decode('utf-8')
		# line=process.stdout.decode('utf-8')
		# f.write('blah')
		# line="aaa"
# j = json.loads(proc.decode("utf-8"))
# print(json.dumps(j, indent=4, sort_keys=True))

def speech(text):
    global o
    o["speech"] = {"text": text}

# get json from stdin and load into python dict
o = json.loads(sys.stdin.read())

intent = o["intent"]["name"]

if intent == "StartARecord":
	process = subprocess.Popen(["curl","-s", "http://192.168.226.60/test.php"],stdout=subprocess.PIPE,encoding='utf-8')
	data = process.communicate()
	print(data)
	for line in data:
		if line == "Process via_rec_audio_start.sh is already running\n":
			with open('/tmp/file.txt', 'a') as f:
				f.writelines(line)
				print(json.dumps(o))

