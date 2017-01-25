#!/bin/bash

#set user enviroment



xhost +SI:localuser:lightdm
gsettings set com.canonical.unity-greeter draw-grid false
gsettings set com.canonical.unity-greeter draw-user-backgrounds false
gsettings set com.canonical.unity-greeter background ''
gsettings set com.canonical.unity-greeter background-logo ''
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
gsettings set org.gnome.desktop.screensaver lock-delay 3600
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
setterm -blank 0
setterm -powerdown 0 
xset s off
xset -dpms

