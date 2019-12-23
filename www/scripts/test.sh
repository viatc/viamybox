#!/bin/bash

ps -aux|grep mov
killall  python /home/www/scripts/mov.py
killall bash /home/pi/.viamybox/scripts/mkvid-mov.sh
service mjpg-streamerd stop
ps -aux|grep mov