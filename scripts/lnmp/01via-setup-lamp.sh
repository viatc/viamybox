#!/bin/bash
## Copyright (C) 2017-2019 ViaMyBox viatc.msk@gmail.com
## This file is a part of ViaMyBox free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## any later version.
##																			
## You should have received a copy of the GNU General Public License
## along with ViaMyBox in /home/pi/COPIYNG file.
## If not, see <https://www.gnu.org/licenses/>.
##   
clear
ifconfig
ip=$(ifconfig wlan0|grep 'inet '|awk '{print $2}')
#|awk -F":" '{print $2}'
#echo "$?"
if [[ -z "$ip" ]] ; then
	echo "!!! нет wifi соединения " 1>&2 
	ip=$(ifconfig eth0|grep 'inet '|awk '{print $2}')
fi
echo "The script adds ip correspondence to the site in the /etc/hosts file \
and forms a file /etc/nginx/sites-available/<mysite.com>."

echo -n "Enter the internal static ip address [default $ip]:"
read ip2
if [[ $ip2 ]] ; then ip="$ip2"; fi 
#echo $ip
echo -n "Вenter the name of your site [example mysite.com]:"
read nameMysite
str="$ip		$nameMysite"
#cp /etc/hosts /home/pi/hosts
file="/etc/hosts"
echo "Add in file $file string "$str":"
echo "$str" >> $file
cat $file

file="/home/pi/viamybox/scripts/lnmp/conf/mysite.profile"
sed "s/mysite/$nameMysite/g" $file > "/etc/nginx/sites-available/$nameMysite"
echo "File generated /etc/nginx/sites-available/$nameMysite :"
#cat /etc/nginx/sites-available/$nameMysite
ln -s /etc/nginx/sites-available/$nameMysite /etc/nginx/sites-enabled/$nameMysite

echo "Wait... restartnig mysql and nginx services"
rm /etc/nginx/sites-enabled/default
service mysql restart
service nginx restart
echo "____________________________________________________________________________"
echo "Connect to the wordpress site to further initialize http://$ip"
echo "The default connection port is 80. Change it to the one you need if necessary."
echo "in file /etc/nginx/sites-available/$nameMysite"
echo "___________________________________________________________________________ "