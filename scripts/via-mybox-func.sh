#!/bin/bash
## Copyright (C) 2017-2021 ViaMyBox viatc.msk@gmail.com
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

#function wrap text
function wrapText {
str="/n$1"
numCharsInStr=$(($(tput cols)-6))
if [ $numCharsInStr -gt 90 ];then numCharsInStr=100;fi
echo -e "$1" |sed -rne "
:begin_loop
/^.{40}!/ {b end_loop}
/.{$numCharsInStr}/! {b end_loop}
s/^(.{,$numCharsInStr})\s/\1\n/
t end_loop
:end_loop
P
D
" |
sed 's/^/   /'
}

#function wrap and spread text
function wrapAndSpread {
str="/n$1"
numCharsInStr=$(($(tput cols)-6))
if [ $numCharsInStr -gt 90 ];then numCharsInStr=100;fi
echo -e "$1" |sed -rne "
:begin_loop
/^.{40}!/ {b end_loop}
/.{$numCharsInStr}/! {b end_loop}
s/^(.{,$numCharsInStr})\s/\1\n/
t end_loop
:end_loop
P
D
" |
sed -rne "
:begin_loop
/.{40}/! {b end_loop}
/☐/ {b end_loop}
/☑/ {b end_loop}
/_no_spread_/ {b end_loop}
	/.{$numCharsInStr}/ b end_loop
	s/([^ ]) ([^ ])/\1  \2/
	t begin_loop
	s/([^ ])  ([^ ])/\1   \2/
	t begin_loop
	s/([^ ])   ([^ ])/\1    \2/
	t begin_loop
:end_loop
s/_no_spread_//
s/^/   /p
"
}


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
# FILE=$1
# VARIABLE=$2
# PARAM=$3
sed "0,/$2/s/$2.*/$2$3/" "$1" > "$1".new
mv -f "$1".new "$1"
}

FirstSubstInFile2 ()
{
#add parameter PARAM in FILE if VARIABLE stands in the beginning of line and separator space!
#or add a PARAM line to the VARIABLE line with a space between them (if the variables are enclosed
# in double quotes)
# ^ from the beginning of the line; [[:space:]]* any number of tabs or spaces;
# cuts. * any number of characters
# FILE="$1"
# VARIABLE="$2"
# PARAM="$3"
sed "s/^[[:space:]]*$2.*/$2\ $3/" "$1" > "$1".new
mv -f "$1".new "$1"
}

FirstSubstInFile3 ()
{
#find first substring $FIND in string and replace $PARAM1 in that string to $PARAM2
FILE=$1
FIND=$2
PARAM1=$3
PARAM2=$4
sed "0,/$FIND/s/$PARAM1/$PARAM2/" $FILE > $FILE.new
mv -f $FILE.new $FILE
}

# Adding the string  '$AddString' = $3 (or strings in one viariable $3)in the file FILE = $1 before the line containing $String = $2
# if string not found in file it will be added

AddStrBeforeInFile ()
{
FILE="$1"
String="$2"
AddString="$3"
#sudo cp $FILE $FILE.$PrintTime.viabackup
echo "$AddString" | while read LINE
do
	CheckStrInFile "$LINE" "$FILE" result
	if [[ $result = 'N' ]]; then
		echo "Adding '$AddString' in the file $1 in front of the line containing '$String'"
		sed "/$2/i$LINE" $FILE > $FILE.new
		mv -f $FILE.new $FILE
	fi
done
}

# Adding the string  '$AddString' = $3 (or strings in one viariable $3)in the file FILE = $1 after the line containing $String = $2
# if string not found in file it will be added
# if $3 contains many strings it add it recursively from last to first
AddStrAfterStrInFile ()
{
FILE="$1"
String="$2"
AddString="$3"
#LINE="$AddString"
#sudo cp $FILE $FILE.$PrintTime.viabackup
echo "$AddString" | while read LINE
do
	CheckStrInFile "$LINE" "$FILE" result
	if [[ $result = 'N' ]]; then
		echo "Adding '$LINE' in the file $1 after of the line containing '$String'"
		sed "/$String/a$LINE" $FILE > $FILE.new
		mv -f $FILE.new $FILE
	fi
done

#sed "/"$str"/a$strsite" $FILE > $FILE.new
}

AddStrAfterInFile ()
{
FILE="$1"
# AddString="$2"
#sudo cp $FILE $FILE.$PrintTime.viabackup
echo "Addition in file $1 line '$AddString'"
#echo "#ViaSettings" >> $FILE
	CheckStrInFile "$AddString" "$FILE" result
	if [[ $result = 'N' ]]; then
		echo "$AddString" >> $FILE
	fi
#sed -e "/a\$AddString" $FILE > $FILE.new
#mv -f $FILE.new $FILE
}

SubmitYN ()
{
myresult="NULL"
while [ $myresult = "NULL" ] ;do
echo -n "$EchoLine ... Yes/No [Yes]: "
myresult="NULL"
read item
case "$item" in
    [yY][eE][sS]|[yY]"")
        local  myresult='Y'
        ;;
		"")
        local  myresult='Y'
        ;;
    [Дд][Аа]|[Дд]"")
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

#правильное зеккоментировано (нужно проверять)
 # if grep -qE "$1" "$2"
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


#Substitution line string global in file $1 to line (lines) $addString global
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

#Substitution line string ($addStrr)  in file ($file) after String with number ($numStr)
addStrAfterNumStr ()
{
file="$1"
numStr="$2"
addStr="$3"

head -n $numStr $file > bar
echo "$addStr" >> bar
# echo $numStr
numStr=$(( $numStr + 1 ))
tail -n +$numStr $file >> bar
mv bar $file
}

# finction enable(uncomment = delete #) or add param in variable  in section (separator = [abc]) in config file
function enableParamInSection {
file=$1
section=$2
var=$3
param=$4

#определяем номер строки искомой секции $section
numStrStartSection=$(grep -n "$section" $file|sed 's/:/ /g'| awk '{print $1}')
# если секции нет выходим
if [[ -z $numStrStartSection ]]; then return 1;fi
#определяем конец (первый номер строки в поиске) искомой секции
# numStrEndSection=$(tail -n +"$numStrStartSection" $file | grep -E -n "^\[[A-Za-z0-9_-]*\]"|sed 's/:/ /g'| awk '{print $1}')
numStrEndSection=$(tail -n +$(($numStrStartSection + 1)) $file | grep -E -n "^\[[A-Za-z0-9_-]*\]"|sed 's/:/ /g'| awk '{print $1}')

for item in $numStrEndSection; do
	break
  # $item сколько строк до конца искомого блока
done

#записываем секцию $section в файл bar
tail -n +$numStrStartSection $file | head -n $item > bar
# ищем количество пустых строк в блоке и если есть пробел в конце блока отступим на одну строку вверх
numEmptyStr=$(cat bar |grep -E -n "^$"|sed 's/:/ /g'| awk '{print $1}')
for i in $numEmptyStr; do
  if [[ $i -eq $item ]]; then
    item=$(($item-1))
  fi
done

#ищем  точное незакоментированное соответствие параметра и переменной
numStr=$(cat bar |grep -E -n "^$var$param"|sed 's/:/ /g'| awk '{print $1}')
if [[ $numStr != '' ]]; then
  rm bar
	return 0
# else
fi

# есть ли любая незакоментированная переменная $var
numStr=$(cat bar |grep -E -n "^$var"|sed 's/:/ /g'| awk '{print $1}')
if [[ $numStr != '' ]]; then
	numStr=$(($numStrStartSection+$numStr -1))
	# echo "комментируем $numStr"
	c=1; while read line; do
  if [ $c -eq $numStr ]; then
		echo "#$line" >> bar1
  else
		echo $line >> bar1
  fi
  let c++; done < $file
	#++++
	mv bar1 $file
fi

# ищем закоментированную строку с точным соответствием $var = $param
numStr=$(cat bar |grep -E -n "\#$var$param"|sed 's/:/ /g'| awk '{print $1}')
rm bar
if [[ $numStr != '' ]]; then
	# echo "раскомментируем $numStr"
	numStr=$(($numStrStartSection+$numStr -1))
	c=1; while read line; do
  if [ $c -eq $numStr ]; then
		echo "$line"|sed 's/^#//' >> bar1
  else
    echo $line >> bar1
    if [[ $c -eq $(($numStr - 1)) ]];then
      str="#ViaSettings: next line will be created by ViaMyBox script"
      if [[ "$str" != "$line" ]]; then
        echo $c
        echo $str >> bar1
      fi
    fi
  fi
  let c++; done < $file
mv bar1 $file
cat $file
return 0
fi
#если все таки добрались сюда..) добавляем в конец секции нашу переменную с  параметром
numStr=$(($numStrStartSection + $item - 1))
addStr="#ViaSettings: next line will be created by ViaMyBox script"
addStrAfterNumStr "$file" "$numStr" "$addStr"
addStr=""$var""$param""
addStrAfterNumStr "$file" "$numStr" "$addStr"
# echo "$addStr"
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
	numStr=$(grep -n "$str" $FILE| sed 's/:/ /g' | awk '{print $1}')
	#удаляем строку
	grep -vE "$str" $FILE > $FILE.new; mv $FILE.new $FILE
	# grep -vF "$str" $FILE > $FILE.new; mv $FILE.new $FILE
	#проверяем если предыдущая строка комментарий ViaMyBox тогда удаляем и ее
	numStr=$(($numStr - 1))
	strBefore=$(awk 'NR == n' n=$numStr $FILE)
	if [[ $strBefore  == "#ViaSettings"* ]];then
	  sed -i.temp "${numStr}d" $FILE
	  rm $FILE.temp
	fi
}

# удалить строку по номеру строки в файле
deleteNumStr ()
{
	file=$1
	numStr=$2
	sed -i.temp "${numStr}d" $file
	rm $file.temp
	#проверяем если предыдущая строка комментарий ViaMyBox тогда удаляем и ее
	numStr=$(($numStr - 1))
	strBefore=$(awk 'NR == n' n=$numStr $file)
	if [[ $strBefore  == "#ViaSettings"* ]];then
	  sed -i.temp "${numStr}d" $file
	  rm $file.temp
	fi
}

function deleteParamInSection {
  file=$1
  section=$2
  var=$3
  param=$4
  #определяем номер строки искомой секции $section
  numStrStartSection=$(grep -n "$section" $file|sed 's/:/ /g'| awk '{print $1}')
  # если секции нет выходим
  if [[ -z $numStrStartSection ]]; then return 1;fi
  #определяем конец (первый номер строки в поиске) искомой секции
  # numStrEndSection=$(tail -n +"$numStrStartSection" $file | grep -E -n "^\[[A-Za-z0-9_-]*\]"|sed 's/:/ /g'| awk '{print $1}')
  numStrEndSection=$(tail -n +$(($numStrStartSection + 1)) $file | grep -E -n "^\[[A-Za-z0-9_-]*\]"|sed 's/:/ /g'| awk '{print $1}')

  for item in $numStrEndSection; do
  	break
    # $item сколько строк до конца искомого блока
  done

	  if [[ ! $item ]]; then
				# если следующей секции нет то считаем количество строк нашей секции до конца файла ($item)
				tail -n +$numStrStartSection $file  > bar
		else
			# если есть отсекаем след секцию и работаем дальше с bar
				tail -n +$numStrStartSection $file | head -n $item > bar
		fi
  #записываем секцию $section в файл bar
	# echo "-------------"
	# cat bar
	# echo "-------------"
  numStr=$(cat bar |grep -E -n "^$var$param"|sed 's/:/ /g'| awk '{print $1}')
  # удаляем параметр в секции если найден
  if [[ -n $numStr ]]; then
    numStr=$(($numStrStartSection + $numStr-1))
    deleteNumStr $file $numStr
    str="^$var$param"
    deleteStr bar
  fi
    # определяем пустая ли секция
    # ищем количество строк в блоке имеющих хоть один символ
    # echo "-------------"
    # cat bar
    # echo "-------------"
    numEmptyStr=$( tail bar -n +2 |grep -E -n "."|sed 's/:/ /g'| awk '{print $1}')
    # echo $numEmptyStr
    # если все пусто удаляем секцию
    if [[ ! $numEmptyStr ]]; then
      str="^\[http\]"
      deleteStr $file
    fi
  rm bar
}

function waitWhenPIDstop() {
    local PID=$1
    [[ -z $PID ]] && return 1

    local watchdog=0

    while [[ -e /proc/$PID ]]; do
        sleep 0.10
        watchdog=$((watchdog+1))
        [[ $watchdog -eq 20 ]] && kill -9 $PID
        [[ $watchdog -eq 50 ]] && return
    done
}

function checkPackagesInstalled() {
# apt list libgstreamer* --installed | grep -qE "(installed|upgradeable)"
local packages=$1
# Iterate the string variable using for loop
for val in $packages; do
	# echo $val
	# apt -qq $val  2>/dev/null | grep -qE "(installed|upgradeable)" || echo "$val Not installed"
	if [ $(dpkg-query -W -f='${Status}' $val 2>/dev/null | grep -c "ok installed") -eq 0 ];then
			echo "Not installed $val"
			# echo "$val"
			# read aaa
			return 1
		fi
	# dpkg-query -W -f='${Status}' gstreamer1.0-omx 2>/dev/null | grep -c "ok installed" || echo "$val Not installed"
done
}
