#!/usr/bin/env bash


#variables
foo="0"
dir="0"

#delete dublicates
rm ./instance.sh >/dev/null 2>&1
rm ./instance2.sh >/dev/null 2>&1

#download scripts
wget -qL - https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/hue/instance.sh

#make executable
sudo chmod +x ./instance.sh

#write out current crontab
crontab -l > mycron

#delete duplicate 
cat mycron | sed -i "s|^#@reboot.*$(pwd)/instance.sh.*||" mycron
cat mycron | sed -i "s|^@reboot.*$(pwd)/instance.sh.*||" mycron

#cron double check 
cat mycron | grep "@reboot sudo bash $(pwd)/instance.sh" >/dev/null 2>&1
foo="$?"
[[ "$foo" = "0" ]] && echo && echo && echo && echo $'\033[0;32mCommand found in crontab. No update needed!' && echo && echo && echo && rm mycron && exit 0

#new cron into cron file
dir=$(pwd)/instance.sh
echo "@reboot sudo bash $dir" >> mycron

#install new cron file
crontab mycron
rm mycron
echo; echo; echo; echo; echo $'\033[0;32mI updated crontab. Everything is ready!'; echo; echo; echo
