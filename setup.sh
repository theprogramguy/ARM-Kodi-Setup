#!/bin/bash
ServerIP=""
Gateway=""
Subnet=""
DNSServer1=""
DNSServer2=""
NL="
"
IPCOMPLETE=false
gateway=""

CurrentIF=$(nmcli --terse --fields DEVICE,STATE dev status|grep connected| cut -d\: -f1)

echo "nameserver 192.168.0.1" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf




#gateway2=$(echo $gateway)
#echo $gateway2

Get_Verify_Server () {
read -p "Enter IP for server:" ServerIP
#CurrentGW = $(read _ _ gateway _ < <(ip route list match 0/0))
read _ _ gateway _ < <(ip route list match 0/0)
echo $gateway

read -n1 -r -p "Current Gateway is $gateway, use this gateway?  Y/N/Escape: $NL" button
case $button in
Y)
    ;&
y)
    echo "yes"
    Gateway=$gateway
    ;;
n)
    ;&
N)
    echo "NO"
	read -p "Enter gateway: $NL" Gateway
    ;;
*) 
    echo "OTHER - exiting"
    return 9
    ;;
esac










IPCOMPLETE=true

}



#echo "manual" | sudo tee /etc/init/network-manager.override 
#ps ax | grep dhclient | grep enp3s0
#cat /etc/network/interfaces |grep ^iface\ eth0 | awk -F ' ' '{print $4}'












#lets figure out who the user is here, and make sure the password is correct, and that we are not root!
theUser=$(whoami)
theLogger=$(logname)
SERVER=false
if [ "$theUser" == "root" ]; then
 	echo "Do not run as root, or sudo this command"
	exit
fi

sudo -K
read -s -p "Enter password for $theUser: $NL" pass

suCheck=$(echo $pass | sudo -S ./Test_SU.sh)

echo "
"

if [ "$theUser" == "root" ]; then
 	echo "Do not run as root -- you will never get here, why dont I remove this?"
else
	if [ "$theUser" == "$suCheck" ]; then
 		echo "# Password verified #"
	else
		echo "Userpassword is wrong"
		exit
	fi
fi

read -n1 -r -p "Is this the server? Y/N/Escape:" key
echo ""
case $key in
Y)
    ;&
y)
    echo "yes"
    SERVER=true
    ;;
n)
    ;&
N)
    echo "NO"
    ;;
*) 
    echo "OTHER"
    exit
    ;;
esac

echo $SERVER

echo $CurrentIF

while [ $IPCOMPLETE==false ]; do
	result=$( Get_Verify_Server )
done


exit
exit
exit

echo $pass | sudo -S setfacl -m u:$theUser:rwx /opt/ARM-Kodi-Setup/

#early, set screensaver to not come on

xset s off
xset -dpms

#apt-get install ------- get filebot 


sudo apt-get remove network-manager
sudo dpkg --purge network-manager


echo $pass | sudo -S add-apt-repository ppa:heyarje/makemkv-beta -y
echo $pass | sudo -S add-apt-repository ppa:stebbins/handbrake-releases -y 
echo $pass | sudo -S add-apt-repository ppa:mc3man/xerus-media -y
echo $pass | sudo -S add-apt-repository ppa:team-xbmc/ppa -y
echo $pass | sudo -S apt-get update -y
echo $pass | sudo -S apt dist-upgrade -y
echo $pass | sudo -S apt upgrade -y

echo $pass | sudo -S apt install makemkv-bin makemkv-oss regionset handbrake-cli handbrake-gtk libavcodec-extra abcde flac imagemagick glyrc cdparanoia at python3 python3-pip libdvd-pkg cifs-utils software-properties-common dconf-editor git libcurl4-openssl-dev libssl-dev ffmpeg ffmpegthumbnailer imagemagick tesseract-ocr tesseract-ocr-eng hwinfo gksu openssh-server nfs-kernel-server tcp-dump rsync debconf-utils x11vnc kodi lightdm -y

echo $pass | sudo -S pip3 install --upgrade pip
echo $pass | sudo -S pip3 install tendo pyyaml peewee
echo $pass | sudo -S pip install tendo pyyaml peewee


#ahnooie's stuff
cd /opt
echo $pass | sudo -S git clone https://github.com/ahnooie/automatic-ripping-machine.git arm
cd arm
echo $pass | sudo -S pip install -r requirements.txt
echo $pass | sudo -S ln -s /opt/arm/51-automedia.rules /lib/udev/rules.d/
echo $pass | sudo -S ln -s /opt/arm/.abcde.conf /root/
echo $pass | sudo -S cp config.sample config



echo $pass | sudo -S mkdir /mnt/media
echo $pass | sudo -S mkdir -p /mnt/media/ARM/raw
echo $pass | sudo -S mkdir -p /mnt/media/ARM/music
echo $pass | sudo -S mkdir -p /mnt/media/ARM/movies
echo $pass | sudo -S mkdir -p /mnt/media/ARM/unidentified
echo $pass | sudo -S mkdir -p /mnt/media/ARM/tv
echo $pass | sudo -S /etc/init.d/udev restart       
#udevadm trigger --action=change 



#do user specific things here
mkdir /home/$theUser/.config/autostart
##reset the execute property, just in case

#chmod +x /opt/ARM-Kodi-Setup/Screensaver_Off.sh 
#chmod +x /opt/ARM-Kodi-Setup/Screen-Saver-Off.desktop
#chmod +x /opt/ARM-Kodi-Setup/VNC.desktop

echo $pass | sudo -S chmod +x /opt/ARM-Kodi-Setup/Startup.desktop
echo $pass | sudo -S chmod +x /opt/ARM-Kodi-Setup/Startup.sh

#make sure the user not root is owner
echo $pass | sudo -S chown $theUser /opt/ARM-Kodi-Setup/Startup.desktop
echo $pass | sudo -S chown $theUser /opt/ARM-Kodi-Setup/Startup.sh
echo $pass | sudo -S chown $theUser /opt/ARM-Kodi-Setup/autostart/

#send the files to $theLogger autostart dir
echo $pass | sudo -S ln -s /opt/ARM-Kodi-Setup/Startup.desktop /home/$theUser/.config/autostart

#apt-get install 



echo $pass | sudo -S dpkg-reconfigure libdvd-pkg

#gsettings and dconf stuff here to set all our settings

#move all this to one file to sudo once

xhost +SI:localuser:lightdm
gsettings set com.canonical.unity-greeter draw-grid false
gsettings set com.canonical.unity-greeter draw-user-backgrounds false
gsettings set com.canonical.unity-greeter background ''
gsettings set com.canonical.unity-greeter background-logo ''
gsettings set org.gnome.desktop.screensaver idle-activation-enabled 0

gsettings set org.gnome.desktop.screensaver lock-delay 3600
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
setterm -blank 0
setterm -powerdown 0 
xset s off
xset -dpms



















#these are notes, ignore from here down


#ffmpegthumbnailer -i"/mnt/media/ARM/raw/First Sunday (2008)_20170113_081658/First_Sunday_t00.mkv" -o"/home/arm/Desktop/1.png" -s0 -q10 -t10

#mkdir frames
#ffmpeg -i First_Sunday_t00.mkv  -r .2 'frames/frame-%03d.jpg'
#/usr/share/kodi/addons/skin.confluence
#/opt/arm/thumb.sh "${DEST}" "${DEST}/Main.${DEST_EXT}"


#echo "dconf-editor"
#echo "com.canonical.unity-greeter background,draw-grid,draw-user-backgroundd"



#su lightdm -s /bin/bash
#dconf-editor
#com.canonical.unity-greeter background,draw-grid,draw-user-backgroundd



