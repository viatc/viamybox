import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
import time
import datetime
from configparser import ConfigParser
import json
import RPi.GPIO as GPIO
import signal
import sys

config = ConfigParser(delimiters=('=', ))
config.read('/home/pi/viamybox/conffiles/iot/mqtt-config.ini')

pinlist=json.loads(config.get("relay","pinlist"))
topic_sublist = json.loads(config['relay'].get('topic_sublist'))
topic_publist = json.loads(config['relay'].get('topic_publist'))
topic_availablelist = json.loads(config['relay'].get('topic_availablelist'))
relay_type = config['relay'].get('type')

if relay_type == "KY-019":
   num_channels=1
   zero_is_ON = False
elif relay_type == "2PH63891A":
   num_channels=2
   zero_is_ON = True
elif relay_type == "2PH63083A":
   num_channels=4
   zero_is_ON = True
elif relay_type == "8RELAYBRD-5V":
   num_channels=8
   zero_is_ON = True

GPIO.setmode(GPIO.BCM)
i=0
while i < num_channels :
   GPIO.setup(pinlist[i], GPIO.OUT)
   i+=1

broker = config['mqtt'].get('ip_broker')
auth = {
  'username': str(config['mqtt'].get('username')),
  'password': str(config['mqtt'].get('password'))
}

def on_log(client, userdata, level, buf):
    print("log: ",buf)

def on_connect(client, userdata, flags, rc):
	print("Connected with result code "+str(rc))
	i=0
	while i < num_channels :
		client.subscribe(topic_sublist[i])
		client.subscribe(topic_publist[i])
		client.subscribe(topic_availablelist[i])
		client.publish(topic_availablelist[i], "ONLINE")
		i+=1

def set_state(pin_state):
	if pin_state == 1:
		if zero_is_ON:
			return("OFF")
		else:
			return("ON")
	else:
		if zero_is_ON:
			return("ON")
		else:
			return("OFF")

def on_message(client, userdata, msg):
	if msg.topic in topic_sublist:
		channel_index=topic_sublist.index(msg.topic)
		print(str(datetime.datetime.now())+" "+msg.topic+" "+str(msg.payload))
		if msg.payload == "ON" :
			if zero_is_ON :
				GPIO.output(pinlist[channel_index], GPIO.LOW)
			else:
				GPIO.output(pinlist[channel_index], GPIO.HIGH)
			time.sleep(.1)
			client.publish(topic_publist[channel_index],set_state(GPIO.input(pinlist[channel_index])),0,0)
			print("OUT 1 ON")
		if msg.payload == "OFF" :
			if zero_is_ON :
				GPIO.output(pinlist[channel_index], GPIO.HIGH)
			else:
				GPIO.output(pinlist[channel_index], GPIO.LOW)
			time.sleep(.1)
			client.publish(topic_publist[channel_index],set_state(GPIO.input(pinlist[channel_index])),0,0)
			print("OUT 1 OFF")

class GracefulKiller:
  kill_now = False
  def __init__(self):
    signal.signal(signal.SIGINT, self.exit_gracefully)
    signal.signal(signal.SIGTERM, self.exit_gracefully)

  def exit_gracefully(self,signum, frame):
    i=0
    while i < num_channels :
        client.publish(topic_availablelist[i], "OFFLINE")
        i+=1
    client.loop_stop()
    client.disconnect()
    self.kill_now = True

def main():
	global client
	client = mqtt.Client()
	client.on_log=on_log
	client.on_connect = on_connect
	client.on_message = on_message

	client.username_pw_set(config['mqtt'].get('username'), config['mqtt'].get('password'))
	client.connect(config['mqtt'].get('hostname', 'homeassistant'),
				   config['mqtt'].getint('port', 1883),
				   config['mqtt'].getint('timeout', 60))
	client.loop_forever()



if __name__ == "__main__":
   killer = GracefulKiller()
   while not killer.kill_now:
    main()

