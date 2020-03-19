#!/bin/bash
#created https://pimylifeup.com/raspberry-pi-kiosk/
#modified viamybox

VIADIR="/home/pi/viamybox"

xset s noblank
xset s off
xset -dpms

unclutter -idle 0.5 -root &

sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/pi/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/pi/.config/chromium/Default/Preferences

#add a list of sites to the variable from the via.conf file
sites=$(sed -n '/#kiosk sites/,/#/ p' $VIADIR/conffiles/via.conf | sed '/^#/ d')

chromium-browser  --noerrdialogs --disable-infobars --kiosk $sites &

while true; do
	# xdotool keydown ctrl+Tab; xdotool keyup ctrl+Tab;
	sleep 3600
done

