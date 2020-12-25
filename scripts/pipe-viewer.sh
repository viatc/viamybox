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
	
a1='/home/pi/viamybox/scripts/via-mybox-func.sh' ; source "$a1" ; if [ $? -ne 0 ] ; then
echo "no function library $a1" 1>&2 ; exit 1 ; fi
VIADIR="/home/pi/viamybox"
# FILECONF="/tmp/via.conf"
VIADIR="/home/pi/viamybox"
EXECFILE="/sbin/via-rec-av-c270"
FILECONF="/home/pi/viamybox/conffiles/via.conf"
StoreVideo="/home/pi/camera/video"
StoreAudio="/home/pi/camera/audio"
PARAM=" autoload"
PARAM2="noautoload"

function installPipe-viewer {
EchoLine="Would you like to install Pipe-viewer?"
export EchoLine
SubmitYN result
if [[ $result = 'N' ]]; then return 0; fi

apt-get install mpv vlc gobject-introspection libcairo-gobject-perl libgtk-3-dev libgtkmm-3.0-dev libgirepository1.0-dev \
libglib-object-introspection-perl  libncurses5-dev libncurses5 libreadline-dev libncurses-dev libterm-readline-gnu-perl libssl-dev -y

cpan Module::Build Data::Dump YAML HTTP::Request JSON   URI::Escape JSON::XS   Mozilla::CA  \
Term::ReadLine::Gnu File::ShareDir Unicode::GCString LWP::UserAgent LWP::UserAgent::Cached LWP::Protocol::https Gtk3 
cpan libwww-perl Unicode::LineBreak Glib::Object::Introspection
cd /tmp
sudo -u pi bash -c 'wget https://github.com/trizen/pipe-viewer/archive/main.zip -O pipe-viewer-main.zip'
sudo -u pi bash -c 'unzip -n pipe-viewer-main.zip'
cd pipe-viewer-main
sudo -u pi bash -c 'perl Build.PL --gtk'
./Build installdeps
./Build install
}

installPipe-viewer
