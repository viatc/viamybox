#!/usr/bin/python3
# Import required Python libraries
import time
import RPi.GPIO as GPIO
import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
from configparser import ConfigParser



# Def
config = ConfigParser(delimiters=('=', ))
config.read('/home/pi/viamybox/conffiles/iot/mqtt-config.ini')
state_topic = config['pir'].get('topic', 'house1/room1/pir-sensor1')
print(state_topic)
auth = {
  'username': str(config['mqtt'].get('username')),
  'password': str(config['mqtt'].get('password'))
}

broker = config['mqtt'].get('ip_broker')
sensor_type = config['pir'].get('type', 'hc-sr501').lower()
# Define GPIO to use on Pi
GPIO_PIR = int(config['pir'].get('pin'))

# Use BCM GPIO references
# instead of physical pin numbers
GPIO.setmode(GPIO.BCM)

print ("PIR Module Holding Time Test (CTRL-C to exit)")

# Set pin as input
GPIO.setup(GPIO_PIR,GPIO.IN)      # Echo

Current_State  = 0
Previous_State = 0

#MQTT
client = mqtt.Client()
client.connect(broker)
               # config['mqtt'].getint('port', 1883))
client.loop_start()

try:

  print ("Waiting for PIR to settle ...")

  # Loop until PIR output is 0
  while GPIO.input(GPIO_PIR)==1:
    Current_State  = 0

  print ("Ready")
  publish.single(state_topic, 'no motion', hostname=broker, auth=auth)
  
  # Loop until users quits with CTRL-C
  while True:

    # Read PIR state
    Current_State = GPIO.input(GPIO_PIR)

    if Current_State==1 and Previous_State==0:
      # PIR is triggered
      start_time=time.time()
      print ("Motion detected!")
      publish.single(state_topic, 'motion detected', hostname=broker, auth=auth)
      # Record previous state
      Previous_State=1
    elif Current_State==0 and Previous_State==1:
      # PIR has returned to ready state
      stop_time=time.time()
      print ("Ready "),
      elapsed_time=int(stop_time-start_time)
      print ("(Elapsed time : " + str(elapsed_time) + " secs)")
      Previous_State=0
      publish.single(state_topic, 'no motion', hostname=broker, auth=auth)

except KeyboardInterrupt:
  print ("Quit")
  # Reset GPIO settings
  GPIO.cleanup()
