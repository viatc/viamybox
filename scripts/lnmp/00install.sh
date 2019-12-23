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

SubmitYN ()
{
myresult="NULL"
while [ $myresult = "NULL" ] ;do
echo -n "$EchoLine (y/n): "
myresult="NULL"
read item
case "$item" in
    [yY][eE][sS]|[yY])
        local  myresult='Y'
        ;;
    [Дд][Аа]|[Дд])result='Y'
        local  myresult='Y'
        ;;
    [nN][oO]|[nN])
        local  myresult='N'
        ;;
   [Нн][Ее][Тт]|[Нн])
        local  myresult='N'
        ;;
    *) echo " yes/no y/n... :"
#	return 1
        local  myresult='NULL'
	;;
esac
done
      local  __resultvar=$1
      eval $__resultvar="'$myresult'"
}

echo "Installation wordpress nginx and mysql for LNMP server"
#echo "It is assumed that nginx already installed"
echo "ATTENTION!!! Wordpress installation will be installed in /var/www/html directory! Please ensure this directory not USED"
EchoLine="Click Yes to Continue"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]];then echo "Script stopped!"; exit 0;fi

sudo apt-get install nginx nginx apache2-utils php7.3-fpm mariadb-server-10.0 php-mysql -y
cd /hpme/pi
mkdir -p downloads
mkdir -p /var/www/html/
cd downloads
sudo wget http://wordpress.org/latest.tar.gz
sudo tar xzf latest.tar.gz
sudo mv wordpress/* /var/www/html/
cd /var/www/html/
sudo chown -R www-data: .

sudo mysql_secure_installation
echo "_______________________________________________________________________________"
echo "ATTENTION!!! After we login in to mysql,we need to create database, "
echo "and remove after that, unix_socket authentication with commands:"
echo "create database wordpress;"
echo "UPDATE mysql.user SET plugin = '' WHERE plugin = 'unix_socket';"
echo "FLUSH PRIVILEGES;"
echo "exit"
echo "_______________________________________________________________________________"
sudo mysql -u root -p
echo "Installation successfull!!"
