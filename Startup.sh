#!/bin/bash 
/usr/bin/kodi&
sleep 2
x11vnc -display :0 -auth .Xauthority&
sleep 15 
setterm -powerdown 0 >> /dev/null
xset s 0 0 >> /dev/null
xset s off >> /dev/null
xset -dpms >> /dev/null
exit 0

