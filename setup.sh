#!/bin/bash
ServerIP=""
Gateway=""
Subnet=""
DNSServer1=""
DNSServer2=""
NL="
"
IPCOMPLETE=false
IP_MODE="unknown"
gateway=""
SERVERMODE="CLIENT"
TARGET_IP_MODE="STATIC"

theUser=$(whoami)
theLogger=$(logname)




#CurrentIF=$(nmcli --terse --fields DEVICE,STATE dev status|grep connected| cut -d\: -f1)
CurrentIF=$(ip addr | grep "state UP" | cut -d: -f2 | sed -e 's/^ *//' -e 's/ *$//')
netmask=$(/sbin/ifconfig $CurrentIF | awk '/netmask/{ print $4;} ')
read _ _ gateway _ < <(ip route list match 0/0)
CurrentIP=$(ifconfig $CurrentIF | grep "inet " | awk -F'[: ]+' '{ print $3 }')
CurrentHostname=$(hostname)

if grep $CurrentIF /etc/network/interfaces | grep iface | grep -v \# | grep -q dhcp; then
    	#echo "found dhcp"
	IP_MODE="DHCP"
else
    	#echo "did not find dhcp"
	
	if grep $CurrentIF /etc/network/interfaces | grep iface | grep -v \# | grep -q static; then
    		#echo "found static"
		IP_MODE="STATIC"
	else
		#echo "netmanager still managing"
		IP_MODE="NETMANAGER.STATIC"
		if ps ax | grep dhclient | grep -q $CurrentIF; then
			#netmamanger managed and its dhcp
			IP_MODE="NETMANAGER.DHCP"	
		fi
	fi
fi


echo "Current interface for $CurrentHostname is $CurrentIF:
Mode:$IP_MODE
IP:$CurrentIP
Mask:$netmask
GW:$gateway
" 

#echo $gateway







#gateway2=$(echo $gateway)
#echo $gateway2

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}



Get_Verify_Server () {
read -p "Enter IP for server:" ServerIP
echo $NL
#CurrentGW = $(read _ _ gateway _ < <(ip route list match 0/0))


read -n1 -r -p "Current Gateway is $gateway, use this gateway?  Y/N/Escape:" button
sleep .4s
echo $NL
case $button in
	[Yy])
	    echo "yes"
	    Gateway=$gateway
	    ;;
	[Nn])
	    echo "NO"
		read -p "Enter gateway:" Gateway
		echo $NL
	    ;;
	*) 
	    echo "OTHER - exiting"
		exit
	    return 9
	    ;;
esac

read -n1 -r -p "Current Netmask is $netmask, use this value?  Y/N/Escape:" button
sleep .4s
echo $NL
case $button in
	[Yy])
	    echo "yes"
	    Subnet=$netmask
	    ;;
	[Nn])
	    echo "NO"
		read -p "Enter netmask:" Subnet
		echo $NL
	    ;;
	*) 
	    echo "OTHER - exiting"
		exit	    
		return 9
	    ;;
esac

if valid_ip $ServerIP; then 
	echo "good IP, pinging"; 

		if ping -c 1 $ServerIP | grep -q Unreachable; then
			#ip is not taken, probably
			echo "ip is free"
		else
			echo "ip is taken"	
			exit
		fi


else 
	echo "bad IP, exiting now";
	exit 
fi

echo $NL
echo "Accept new values?
IP:$ServerIP
Mask:$Subnet
GW:$Gateway" 
echo $NL
sleep .4s
read -n1 -r -p " Y/N/Escape:" button

case $button in
	[Yy])
	    	echo "yes"
		disable_netmanager
		echo $pass | sudo -S -v
		echo "
auto lo
iface lo inet loopback

auto $CurrentIF
allow-hotplug $CurrentIF
iface $CurrentIF inet static
	address $ServerIP
	netmask $Subnet
	gateway $Gateway
" | sudo tee /etc/network/interfaces
		echo $pass | sudo -S -v
		echo $pass | sudo -S ifdown --exclude=lo -a && sudo ifup --exclude=lo -a
		echo $pass | sudo -S /etc/init.d/networking restart


	    ;;
	[Nn])
	    echo "NO"
		exit
	    ;;
	*) 
	    echo "OTHER - exiting"
		exit
	    return 9
	    ;;
esac

IPCOMPLETE=true

}





disable_netmanager () {
echo $pass | sudo -S resolvconf --disable-updates
echo $pass | sudo -S apt-get install aptitude -y
echo $pass | sudo -S apt-get remove network-manager dnsmasq -y
echo $pass | sudo -S dpkg --purge network-manager dnsmasq
sudo aptitude purge network-manager -y
echo $pass | sudo -S rm /etc/resolv.conf
echo $pass | sudo -S -v
echo "nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver $gateway" | sudo tee /etc/resolv.conf
echo $pass | sudo -S chattr +i /etc/resolv.conf
}

set_DHCP () {
echo $pass | sudo -S -v
echo "
auto lo
iface lo inet loopback

auto $CurrentIF
allow-hotplug $CurrentIF
iface $CurrentIF inet dhcp
" | sudo tee /etc/network/interfaces
echo $pass | sudo -S -v
sudo ifdown --exclude=lo -a && sudo ifup --exclude=lo -a
}

set_CURRENT () {
echo $pass | sudo -S -v
echo "
auto lo
iface lo inet loopback

auto $CurrentIF
allow-hotplug $CurrentIF
iface $CurrentIF inet static
	address $CurrentIP
	netmask $netmask
	gateway $gateway
" | sudo tee /etc/network/interfaces
echo $pass | sudo -S -v
sudo ifdown --exclude=lo -a && sudo ifup --exclude=lo -a
}







###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################

# 1

#lets figure out who the user is here, and make sure the password is correct, and that we are not root!

if [ "$theUser" == "root" ]; then
 	echo "Do not run as root, or sudo this command"
	exit
fi

sudo -K
read -s -p "Enter password for $theUser:" pass

suCheck=$(echo $pass | sudo -S /opt/ARM-Kodi-Setup/Test_SU.sh)

echo $NL

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
echo $NL
case $key in
	[Yy])
	    #echo "yes"
	    SERVERMODE="SERVER"
	    ;;
	[Nn])
	    #echo "NO"
	    SERVERMODE="CLIENT"
		read -n1 -r -p "Will this client RIP? Y/N/Escape:" key2
		echo $NL
		case $key2 in
		[Yy])
		    #echo "yes ripping client"
		    SERVERMODE="RIPCLIENT"
		    ;;
		[Nn])
		    #echo "NO"
		    SERVERMODE="CLIENT"
		    ;;
		*) 
		    echo "OTHER"
		    exit
		    ;;
		esac
	    ;;
	*) 
	    echo "OTHER"
	    exit
	    ;;
esac

echo $SERVERMODE


#IP_MODE="DHCP" #manually be able to set detected type

key2="n"
case $IP_MODE in
	*DHCP)
		case $SERVERMODE in
			CLIENT|RIPCLIENT)
				read -n1 -r -p "Clients do no need static IP, would you like to set a static IP? Y/N/Escape:" key
				echo $NL
				case $key in
				[Yy])
				    echo "yes set static"
					TARGET_IP_MODE="STATIC"
					exit
				    ;;
				[Nn])
				    echo "NO static"
					
				    	if [ "$IP_MODE" == "NETMANAGER.DHCP" ]; then
						read -n1 -r -p "It is still recomended to disable netmanager, disable now? Y/N/Escape:" key2
					fi
					echo $NL
					case $key2 in
						[Yy])
						    echo "disable netmanager and set dhcp"
							TARGET_IP_MODE="DHCP"
							disable_netmanager
							set_DHCP
							IPCOMPLETE=true
						    ;;
						[Nn])
						    echo "leave ip and netmanager alone."
							IPCOMPLETE=true
						    ;;
						*) 
						    echo "OTHER"
						    exit
						    ;;
						esac
					    ;;
				*) 
				    echo "OTHER"
				    exit
				    ;;
				esac
				;;

			SERVER)
		
				read -n1 -r -p "Servers SHOULD have a static IP, would you like to set a static IP? Y/N/Escape:" key
				echo $NL
				case $key in
				[Yy])
				    echo "yes set static"
					TARGET_IP_MODE="STATIC"
					IPCOMPLETE=false
				    ;;
				[Nn])
				    echo "NO static"
				    	if [ "$IP_MODE" == "NETMANAGER.DHCP" ]; then
						read -n1 -r -p "It is still recomended to disable netmanager, disable now? Y/N/Escape:" key2
					fi
					echo $NL
					case $key2 in
						[Yy])
						    echo "disable netmanager and set dhcp server"
						
							TARGET_IP_MODE="DHCP"
							disable_netmanager
							set_DHCP
							IPCOMPLETE=true
						    ;;
						[Nn])
						    echo "leave ip and netmanager alone. server"
							IPCOMPLETE=true
						    ;;
						*) 
						    echo "OTHER"
						    exit
						    ;;
					esac
				    ;;
				*) 
				    echo "OTHER"
				    exit
				    ;;
				esac
				;;


			*) 
		    		echo "OTHER servermode type?"
		    		exit
		    		;;
		esac
		;;
	NETMANAGER.STATIC)
		echo "ALREADY STATIC, but netmamanger"
			read -n1 -r -p "It is still recomended to disable netmanager, disable now? Y/N/Escape:" key2
			echo $NL
			case $key2 in
			[Yy])
			    echo "disable netmanager and set current IP"
				TARGET_IP_MODE="CURRENT"
				disable_netmanager
				set_CURRENT
				IPCOMPLETE=true
			    ;;
			[Nn])
			    echo "leave ip and netmanager alone. server"
				IPCOMPLETE=true
			    ;;
			*) 
			    echo "OTHER"
			    exit
			    ;;
			esac
		
		;;
	*STATIC)
		echo "ALREADY STATIC"
		IPCOMPLETE=true
		;;

	*)
		echo "OTHER ip mode type, error"
    		exit
    		;;
	
esac


if [ $IPCOMPLETE == false ] ; then
 Get_Verify_Server
	echo $IPCOMPLETE
fi

echo "passed ipcheck"


case $SERVERMODE in
	*)
		echo $pass | sudo -S setfacl -m u:$theUser:rwx /opt/ARM-Kodi-Setup/
		echo $pass | sudo -S setfacl -R -m u:$theUser:rwx /opt/
		echo $pass | sudo -S setfacl -R -m u:$theUser:rwx /mnt/media/ARM/

		xset s off
		xset -dpms
		echo $pass | sudo -S add-apt-repository ppa:heyarje/makemkv-beta -y
		echo $pass | sudo -S add-apt-repository ppa:stebbins/handbrake-releases -y 
		echo $pass | sudo -S add-apt-repository ppa:mc3man/xerus-media -y
		echo $pass | sudo -S add-apt-repository ppa:team-xbmc/ppa -y
		echo $pass | sudo -S apt-get update -y
		echo $pass | sudo -S apt dist-upgrade -y
		echo $pass | sudo -S apt upgrade -y

		#do user specific things here
		mkdir /home/$theUser/.config/autostart
		##reset the execute property, just in case

		echo $pass | sudo -S chmod +x /opt/ARM-Kodi-Setup/Startup.desktop
		echo $pass | sudo -S chmod +x /opt/ARM-Kodi-Setup/Startup.sh

		#make sure the user not root is owner
		echo $pass | sudo -S chown $theUser /opt/ARM-Kodi-Setup/Startup.desktop
		echo $pass | sudo -S chown $theUser /opt/ARM-Kodi-Setup/Startup.sh
		echo $pass | sudo -S chown $theUser /opt/ARM-Kodi-Setup/autostart/

		#send the files to $theLogger autostart dir
		echo $pass | sudo -S ln -s /opt/ARM-Kodi-Setup/Startup.desktop /home/$theUser/.config/autostart

		
		
	;;&
	CLIENT)
		echo "CLIENT only stuff"
		echo $pass | sudo -S apt install dconf-editor debconf-utils x11vnc kodi kodi-eventclients-kodi-send lightdm rar -y
		echo $pass | sudo -S ln -s /opt/ARM-Kodi-Setup/CLIENT.service /etc/avahi/services/
	;;
	SERVER|RIPCLIENT)
		echo "SERVER and RIPCLIENT stuff"
		echo $pass | sudo -S apt install makemkv-bin makemkv-oss regionset handbrake-cli handbrake-gtk libavcodec-extra abcde flac imagemagick glyrc cdparanoia at python3 python3-pip libdvd-pkg cifs-utils software-properties-common dconf-editor git libcurl4-openssl-dev libssl-dev ffmpeg ffmpegthumbnailer imagemagick tesseract-ocr tesseract-ocr-eng hwinfo gksu openssh-server nfs-kernel-server tcpdump rsync debconf-utils x11vnc kodi lightdm ack-grep hexedit rar kodi-eventclients-kodi-send -y
		echo $pass | sudo -S pip3 install --upgrade pip
		echo $pass | sudo -S pip3 install tendo pyyaml peewee
		echo $pass | sudo -S pip install tendo pyyaml peewee
		#ahnooie's stuff
		cd /opt
		echo $pass | sudo -S git clone https://github.com/ahnooie/automatic-ripping-machine.git arm
		cd arm
		echo $pass | sudo -S pip install -r requirements.txt
		echo $pass | sudo -S ln -s /opt/arm/51-automedia.rules /lib/udev/rules.d/
		#MODIFY THESE
#############
###################
		echo $pass | sudo -S ln -s /opt/arm/.abcde.conf /root/
		echo $pass | sudo -S cp config.sample config
###################
############
		echo $pass | sudo -S dpkg-reconfigure libdvd-pkg
	;;&
	SERVER)
		echo "SERVER only stuff"
		echo $pass | sudo -S mkdir -p /mnt/media
		echo $pass | sudo -S mkdir -p /mnt/media/ARM
		echo $pass | sudo -S mkdir -p /mnt/media/ARM/raw
		echo $pass | sudo -S mkdir -p /mnt/media/ARM/Music
		echo $pass | sudo -S mkdir -p /mnt/media/ARM/Movies
		echo $pass | sudo -S mkdir -p /mnt/media/ARM/Unidentified
		echo $pass | sudo -S mkdir -p /mnt/media/ARM/TV
		echo $pass | sudo -S /etc/init.d/udev restart  
		echo "/mnt/media/ARM	*(rw,sync,no_root_squash,insecure)" | sudo tee -a /etc/exports
		echo $pass | sudo -S ln -s /opt/ARM-Kodi-Setup/SERVER.service /etc/avahi/services/
	;;

	RIPCLIENT)	
		echo "RIPCLIENT only stuff"	

		##FIND SERVER AND MAP TO IT HERE 

		echo $pass | sudo -S /etc/init.d/udev restart 
		echo $pass | sudo -S ln -s /opt/ARM-Kodi-Setup/CLIENT.service /etc/avahi/services/
	;;
esac


echo $pass | sudo -S setfacl -m u:$theUser:rwx /opt/ARM-Kodi-Setup/
echo $pass | sudo -S setfacl -R -m u:$theUser:rwx /opt/
echo $pass | sudo -S setfacl -R -m u:$theUser:rwx /mnt/media/ARM/


     
#udevadm trigger --action=change 




#apt-get install 





#gsettings and dconf stuff here to set all our settings

#move all this to one file to sudo once




















		#setfacl -R -m u:arm:rwx /opt/ARM-Kodi-Setup/
		#setfacl -R -m u:arm:rwx /mnt/media/ARM/
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

kodi=$(avahi-browse _kodimediaserver._tcp -k -r -p -t)
echo $kodi


exit



echo $pass | sudo -S -v





#echo "manual" | sudo tee /etc/init/network-manager.override 

#cat /etc/network/interfaces |grep ^iface\ eth0 | awk -F ' ' '{print $4}'


#chmod +x /opt/ARM-Kodi-Setup/Screensaver_Off.sh 
#chmod +x /opt/ARM-Kodi-Setup/Screen-Saver-Off.desktop
#chmod +x /opt/ARM-Kodi-Setup/VNC.desktop





