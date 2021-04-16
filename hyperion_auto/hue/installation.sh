#!/usr/bin/env bash

#delete dublicates
rm ./instance.sh >/dev/null 2>&1
rm ./instance2.sh >/dev/null 2>&1

#download scripts
wget -qL - https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/hue/instance.sh
#wget -qL - https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/hue/instance2.sh

#make executable
sudo chmod +x ./instance.sh
#sudo chmod +x ./instance2.sh

#write out current crontab
crontab -l > mycron

#test for duplication
[[ cat mycron | grep "#@reboot sudo bash /home/pi/instance.sh" ]] 
[[ "!?" = "0" ]] && cat mycron | sed -i s/.instance.sh.// mycron

[[ cat mycron | grep instance.sh ]] 
[[ "!?" = "0" ]] && echo && echo && echo && echo $'\033[0;32mCommand found in crontab. No update needed!' && echo && echo && echo && rm mycron && exit 0

#[[ $(cat mycron | grep instance.sh | cut -d " " -f 4,4 | cut -d "/" -f 4,4) = "instance.sh" ]] && echo && echo && echo && echo $'\033[0;32mCommand found in crontab. No update needed!' && echo && echo && echo && rm mycron && exit 0

#new cron into cron file
dir=$(pwd)/instance.sh
echo "@reboot sudo bash $dir >ok >error" >> mycron

#install new cron file
crontab mycron
rm mycron
echo; echo; echo; echo; echo $'\033[0;32mI updated crontab. Everything is ready!'; echo; echo; echo
