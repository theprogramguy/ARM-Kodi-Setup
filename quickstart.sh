#!/bin/bash
#bootstrap file
sudo apt-get install aptitude git -y
cd /opt
echo $pass | sudo -S git clone https://github.com/theprogramguy/ARM-Kodi-Setup.git ARM-Kodi-Setup
sudo chmod +x /opt/ARM-Kodi-Setup/setup.sh
sudo chmod +x /opt/ARM-Kodi-Setup/Test_SU.sh
/opt/ARM-Kodi-Setup/setup.sh
