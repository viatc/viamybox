# ViaMyBox 

[ViaMyBox](https://viamybox.com) is a raspberry pi project. It combines several functional ideas and the possibility of simplified management of this functionality. Functional management is carried out through the console script via-setup.sh, through the Home Assistant console as well as a mini-web interface.
In the ViaMyBox project, I combined some ideas found on the Internet that seem interesting to me and the opportunity
quick setup and management. The main functionality at the moment is video recording, a smart home based on the Home Assistant,
Kodi Home Theater, Wordpress LNMP Server.
Modules Home Assistant, MotionEye are optional; install via via-setup.sh utility.
The LNMP server is optionally installed separately (see /home/pi/viamybox/scripts/lnmp/README).

ViaMyBox distribution is assembled and tested based on 2019-09-26-raspbian-buster.The functionality provided by ViaMyBox is:

**Video Recording**:
- video recording with synchronization of sound from a usb camera using [gstreamer](https://gstreamer.freedesktop.org/) technology
- audio recording from usb camera via [gstreamer](https://gstreamer.freedesktop.org/) technology
- timelapse video recording from usb or csi camera using ffmpeg
- photo registration via mjpg-streamer
- photo recording by hc-sr501 motion sensor
- creation of a video file after photo registration
- the ability to record audio and video on yandex disk

**Smart house** - Home Assistant based on docker image https://github.com/home-assistant/hassio-installer:
- management via the console utility via-setup.sh docker containers of Home Assistant
  installation and removal of the image. Stop and start the Home Assiatnt containers
- control via the web console Home Assistant of the above video registration functions
- some raspberry pi control functions. CPU temperature control, micro sd volume,
  power supply status

**Kodi Home Theater**

**MotionEye** web management based on the docker image https://hub.docker.com/r/ccrisan/motioneye:
- web-based interface MotionEye
- management through the console utility via-setup.sh docker container
  installation and removal of the docker image and containers. Stop and start docker container.

**Web interface**:
- management of video recording functions

**Console utility via-setup.sh**:
- management of video recording functions
- managing docker images Home Assistant and MotionEye
- inadyn service management
- management of connection to a remote yandex disk based on webdav

**Python client for for sensors and IOT devices**:

The ability to connect temperature sensor DHT11HC-SR501 and motion sensor HC-SR501, relays (KY019,2PH63891A,2PH63083A,8RELAYBRD-5V) and similar to the Raspberry Pi and their remote control via Home Assistant or other mqtt broker. This is a python script that works as a Mosquito client. It is possible to connect it as a service. On the receiving side of Home Assistant mosquito broker. The relay has a "confirmed activation" mode, that is, the status of the relay operation is checked. After installing or cloning the project, change the mqtt and sensor settings in 
the configuration file:
```bash
nano ~/viamybox/conffiles/iot/mqtt-config.ini
```
Initialize the service:
```bash
cp ~/viamybox/conffiles/iot/<name>.service  /lib/systemd/system/
sudo systemctl enable <name>.service
```
Start service or python script:
```bash
sudo systemctl start <name service>
python ~/viamybox/scripts/iot/<name>.py 
```
On the Home Assistant side the sensor settings in the configuration.yaml for example:
```bash
nano ~/viamybox/conffiles/homeassistant/configuration.yaml
```

**Change your password!
Use the viamybox recording features ONLY on secure networks!**

**ViaMyBox site: https://viamybox.com**

**ViaMyBox youtube: https://www.youtube.com/channel/UC5-s-Z5MGAbLUy7ESyk7cyg**

## INSTALLATION

### Before Installation

The project uses and install nginx, mjpg-streamer, gstreamer, docker, kodi and related packages through
script ~/viamybox/scripts/prepostinstall/00install.sh The packages in this script are divided into sections.
Browse and exclude sections of packages that are not required by you functionality.

Mjpg-streamer will be installed with the script ~/viamybox/scripts/prepostinstall/01aftercopy.sh
The ViaMyBox project uses the mjpg-streamer of the jacksonliam project https://github.com/jacksonliam/mjpg-streamer
If you use another mjpg-streamer, exclude the section # mjpg-streamer from the 01aftercopy.sh file

If you are using apache web server or nginx, look in the #nginx section in the file.
ViaMyBox uses a web server at the address /home/pi/viamybox/www on port 80
If the port 80 for the web server is allocated, change the port in the file /home/pi/viamybox/conffiles/viamybox.local
before installation.

### Installation project ViaMyBox
CLONE REPOSITORY  
the project should be in the folder /home/pi:
```bash
cd /home/pi
git clone https://github.com/viatc/viamybox.git
```
OR
```bash
cd /home/pi
unzip viamybox-master.zip -d /home/pi/
mv -r viamybox-master viamybox
```
make the scripts executable:
```bash
cd viamybox/scripts/prepostinstall/
chmod +x ./*.sh
```
AFTER THAT  
installation of the necessary packages:
```bash
sudo ./00install.sh
```
setting up the ViaMyBox project:
```bash
sudo ./01aftercopy.sh
```

### Installing the LNMP server (optionally)

LNMP server, server for Wordpress site. Includes MySQL, Nginx, PHP + Wordpress shell.
Running installation scripts will allow you to start initializing the Wordpress site on raspberry pi in a few minutes.
If you want to install only the LNMP server. You can do this by installing scripts in the lnmp folder
```bash
cd /home/pi/viamybox/scripts/lnmp/
chmod +x ./*.sh
```
and run 2 scripts in turn:
```bash
sudo ./00install.sh
sudo ./01via-setup-lamp.sh
```
## After installation

Deployment removal and management of docker containers of Home Assistant is carried out through 1 menu item:
```bash
sudo via-setup.sh
```
Next, connect to the Home Assistant http://<your-ip>:8123 and install the database:
Hass.io Tab -> Snapshots
The following project is used as a source:
https://github.com/home-assistant/hassio-installer
For web access and access to the Home Assistant
default user: pi
default password: raspberry

Deployment removal and management docker containers of MotionEye is done through 2 menu items:
```bash
sudo via-setup.sh
```
Next, connect to the MotionEye console http://<your-ip>:8133
To access the MotionEye container:
user: admin
without password

Video and audio recording takes place content in the folder:
/home/pi/camera

If yandex disk is connected:
/home/pi/camera/yandex.disk

You can use WinSCP to dowload your media in Windows.

## Many thanks!
Bellerofonte Radiobox
https://github.com/bellerofonte/radiobox

Gstreamer video audio registration
https://gstreamer.freedesktop.org/

Gotubecast Youtube media access service
https://github.com/CBiX/gotubecast

Kodi Home theatre
https://kodi.tv/

Mjpg-streamer:
https://github.com/jacksonliam/mjpg-streamer

MotionEye docker image:
https://hub.docker.com/r/ccrisan/motioneye

Mps-youtube - youtube, last.fm playing and searching media engine
https://github.com/mps-youtube/mps-youtube

Home Assistant based on docker image
https://github.com/home-assistant/hassio-installer

Raspberry Pi Power Supply Checker
https://github.com/custom-components/sensor.rpi_power

© 2020 ViaMyBox Technological Studio

© 2020 GitHub, Inc.
