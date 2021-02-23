#!/usr/bin/env bash

#delete dublicates
rm ./instanzen.sh >/dev/null 2>&1
rm ./instanzen2.sh >/dev/null 2>&1
#download scripts
wget -qL - https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/instanzen.sh
wget -qL - https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/instanzen2.sh
#make executable
sudo chmod +x ./instanzen.sh
sudo chmod +x ./instanzen2.sh
#write out current crontab
crontab -l > mycron
#test for duplication
[[ $(cat mycron | grep instanzen.sh | cut -d " " -f 4,4 | cut -d "/" -f 4,4) = "instanzen.sh" ]] && echo && echo && echo && echo $'\033[0;32mCommand found in crontab. No update needed!' && echo && echo && echo && rm mycron && exit 0
#echo new cron into cron file
dir=$(pwd)/instanzen.sh
echo "@reboot sudo bash $dir >ok >error" >> mycron
#install new cron file
crontab mycron
rm mycron
echo; echo; echo; echo; echo $'\033[0;32mI updated crontab. Everything is ready!'; echo; echo; echo
