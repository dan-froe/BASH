#!/usr/bin/env bash


#variables
foo="0"
dir="0"


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
while [[ "$foo" = "0" ]] 
do
  cat mycron | grep "#@reboot sudo bash $(pwd)/instance.sh" >/dev/null 2>&1
  foo="$?"
  [[ "$foo" = "0" ]] && cat mycron | sed -i s/#.*instance.sh.*// mycron
done

cat mycron | grep $(pwd)/instance.sh >/dev/null 2>&1
foo="$?" 
[[ "$foo" = "0" ]] && echo && echo && echo && echo $'\033[0;32mCommand found in crontab. No update needed!' && echo && echo && echo && rm mycron && exit 0

#[[ $(cat mycron | grep instance.sh | cut -d " " -f 4,4 | cut -d "/" -f 4,4) = "instance.sh" ]] && echo && echo && echo && echo $'\033[0;32mCommand found in crontab. No update needed!' && echo && echo && echo && rm mycron && exit 0

#new cron into cron file
dir=$(pwd)/instance.sh
echo "@reboot sudo bash $dir >/dev/null 2>&1" >> mycron

#install new cron file
crontab mycron
rm mycron
echo; echo; echo; echo; echo $'\033[0;32mI updated crontab. Everything is ready!'; echo; echo; echo
