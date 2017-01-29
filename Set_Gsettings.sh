#!/bin/bash

#set user enviroment



xhost +SI:localuser:lightdm
gsettings set com.canonical.unity-greeter draw-grid false
gsettings set com.canonical.unity-greeter draw-user-backgrounds false
gsettings set com.canonical.unity-greeter background ''
gsettings set com.canonical.unity-greeter background-logo ''

gsettings set org.gnome.settings-daemon.plugins.power active false
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false


gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
gsettings set org.gnome.desktop.screensaver lock-delay 3600
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false

setterm -blank 0 >> /dev/null
setterm -powerdown 0 >> /dev/null
xset s 0 0 >> /dev/null
xset s off >> /dev/null
xset -dpms >> /dev/null


