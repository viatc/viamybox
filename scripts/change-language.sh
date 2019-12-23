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

a1='/usr/bin/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi

DAEMON_DIR="/var/run/viamybox"
ERR_LOG="${DAEMON_DIR}/via-setup_error.log"
VIADIR="/home/pi/viamybox"
textfile="${VIADIR}/conffiles/RUtoEN.txt"
echo "changing files..."

function checkLanguage
{
FILE="${VIADIR}/conffiles/via.conf"
VAR="language"
PARAM="RU"
PARAM2="EN"
CheckParamInFile "$VAR" "$FILE" " $PARAM" result 
if [ $result = 'Y' ] ;then 
	command=funcRUtoEN
	FirstSubstInFile2 $FILE $VAR $PARAM2
else 
	command=funcENtoRU
	FirstSubstInFile2 $FILE $VAR $PARAM
fi
}

function funcRUtoEN {
sed -i "s/$str1/$str2/" $file
}
function funcENtoRU {
sed -i "s/$str2/$str1/" $file
}

function changeLanguage {
exec 2> $ERR_LOG
checkLanguage 
echo $command
while read str1; do 
{
 if [[ $str1 = "-EOF-" ]] ; then 
 {
 read file
 echo $file
 # if [ -e $file ];then 
	# cp $file $file.$(date +%T).bak
	# mv $file.$(date +%T).bak ${VIADIR}/temp
 # fi
 read str1
 } fi
 read str2
 if [ ! -e $file ];then
 continue
 fi
 #echo "$str1 --------------- $str2"
 $command
}
done < $textfile
}
