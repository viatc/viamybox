#!/bin/bash
## Copyright (C) 2017-2019 ViaMyBox viatc.msk@gmail.com
## This file is a part of ViaMyBox free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## any later version.
##																			
## ViaMyBox software is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##                                                                       
## You should have received a copy of the GNU General Public License
## along with ViaMyBox in /home/pi/COPIYNG file.
## If not, see <https://www.gnu.org/licenses/>.
##           

PrintTime=$(perl -e "print time")

#Substitution of one parameter for another one in file
SubstParamInFile ()
{
FILE=$1
#sudo cp $FILE $FILE.$PrintTime.viabackup
echo "Замена в $1 параметра $2 равного $3 на $4"
sed "/$2/s/$3/$4/g" $FILE > $FILE.new
mv -f $FILE.new $FILE
}

#Substitution of first parameter in file
FirstSubstInFile ()
{
FILE=$1
VARIABLE=$2
PARAM=$3
sed "0,/$VARIABLE/s/$VARIABLE.*/$VARIABLE$PARAM/" $FILE > $FILE.new
mv -f $FILE.new $FILE
}

FirstSubstInFile2 ()
{
#add parameter PARAM in FILE if VARIABLE stands in the beginning of line and separator space!
#or add a PARAM line to the VARIABLE line with a space between them (if the variables are enclosed 
# in double quotes)
# ^ from the beginning of the line; [[:space:]]* any number of tabs or spaces;
# cuts. * any number of characters
FILE="$1"
VARIABLE="$2"
PARAM="$3"
sed "s/^[[:space:]]*$VARIABLE.*/$VARIABLE\ $PARAM/" $FILE > $FILE.new
mv -f $FILE.new $FILE
}

# Adding the string '$AddString' = $3 in the file FILE = $1 before the line containing $String = $2
AddStrBeforeInFile ()
{
FILE="$1"
String="$2"
AddString="$3"
#sudo cp $FILE $FILE.$PrintTime.viabackup
echo "Adding '$AddString' in the file $1 in front of the line containing '$String'"
sed "/$2/i$AddString" $FILE > $FILE.new
mv -f $FILE.new $FILE
}


AddStrAfterInFile ()
{
FILE=$1
#sudo cp $FILE $FILE.$PrintTime.viabackup
echo "Addition in file $1 line '$AddString'"
#echo "#ViaSettings" >> $FILE
echo "$AddString" >> $FILE

#sed -e "/a\$AddString" $FILE > $FILE.new
#mv -f $FILE.new $FILE
}

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

#check of existence of line $1 in file $2 , result will be passed to variable $3
CheckStrInFile ()
{
myresult="NULL"
#for item in "$str"; do

 if grep -qF "$1" "$2"
	then
#	return 0
	local myresult='Y'
	else
#	return 1
	local myresult='N'
 fi
#done
      local  __resultvar=$3
      eval $__resultvar="'$myresult'"
}

#check of existence of var $1 with a param $3 in file $2 , result will be passed to variable $4
CheckParamInFile ()
{
myresult="NULL"
#for item in "$str"; do
 if grep "$1" "$2" |grep -q "$3"
	then
#	return 0
	local myresult='Y'
	else
#	return 1
	local myresult='N'
 fi
#done
      local  __resultvar=$4
      eval $__resultvar="'$myresult'"
}


#Substitution line string global in file $1 to line (lines) addString global
# with n-th number of times of coincidences of line string in file in parameter $2
addStrAfterStr ()
{
#FILE='/etc/nginx/sites-available/default'
i=1

numStr=$(grep -n "$string" $file| sed 's/:/ /g' | awk '{print $1}')
echo $numStr

for item in $numStr; do
if [ $i = $2 ]; then
break
fi
((i++))
done
head -n $item $1 > bar
echo "$addString" >> bar
((item++))
tail -n +$item $1 >> bar
mv bar $1
}

# create a copy of the file with the addition of the .backup extension.
createBackup ()
{
FILE=$1
sudo cp $FILE $FILE.$PrintTime.viabackup
}

#delete string to file
deleteStr ()
{
FILE=$1
grep -vF "$str" $FILE > $FILE.new; mv $FILE.new $FILE
}