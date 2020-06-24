#!/usr/bin/env python2

import paho.mqtt.client as mqtt
import time
import Adafruit_DHT
from configparser import ConfigParser
import json

config = ConfigParser(delimiters=('=', ))
config.read('/home/pi/viamybox/conffiles/iot/mqtt-config.ini')

sensor_type = config['dht'].get('type', 'dht22').lower()

if sensor_type == 'dht22':
    sensor = Adafruit_DHT.DHT22
elif sensor_type == 'dht11':
    sensor = Adafruit_DHT.DHT11
elif sensor_type == 'am2302':
    sensor = Adafruit_DHT.AM2302
else:
    raise Exception('Supported sensor types: DHT22, DHT11, AM2302')

pin = config['dht'].get('pin', 10)

topic = config['dht'].get('topic', 'temperature/dht22')
decim_digits = config['dht'].getint('decimal_digits', 2)
sleep_time = config['dht'].getint('interval', 60)


# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code {}".format(rc))

client = mqtt.Client()
client.on_connect = on_connect
client.username_pw_set(config['mqtt'].get('username'), config['mqtt'].get('password'))
# client.username_pw_set("mqtt", "mqtt!")
client.connect(config['mqtt'].get('hostname', 'homeassistant'),
               config['mqtt'].getint('port', 1883),
               config['mqtt'].getint('timeout', 60))
client.loop_start()

while True:

    humidity, temperature = Adafruit_DHT.read_retry(sensor, pin)
    if humidity is not None and temperature is not None:
        data = {'temperature': round(temperature, decim_digits),
                'humidity': round(humidity, decim_digits)}
        print(data) 
        client.publish(topic, json.dumps(data))

        print('Published. Sleeping ...')
    else:
        print('Failed to get reading. Skipping ...')

    time.sleep(sleep_time)
