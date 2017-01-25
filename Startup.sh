#!/bin/bash 
/usr/bin/kodi&
sleep 2
x11vnc -display :0 -auth .Xauthority
sleep 15 
xset s 0 0 
xset s off 
exit 0

