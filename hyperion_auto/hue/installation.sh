#!/usr/bin/env bash


#variables
foo="0"
dir="0"
bar="2"


#delete dublicates
rm ./instance.sh >/dev/null 2>&1
rm ./instance2.sh >/dev/null 2>&1

#download scripts
wget -qL - https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/hue/instance.sh

#make executable
sudo chmod +x ./instance.sh

#write out current crontab
crontab -l > mycron

#test for duplication
while [[ "$foo" = "0" ]] 
do
  cat mycron | grep "#@reboot sudo bash $(pwd)/instance.sh" >/dev/null 2>&1
  foo="$?"
  [[ "$foo" = "0" ]] && cat mycron | sed -i "s|^#@reboot.*$(pwd)/instance.sh.*||" mycron
done

bar=$(cat mycron | grep -c "@reboot sudo bash $(pwd)/instance.sh")
while [[ "$bar" > "1" ]]
do
  cat mycron | sed -n "0,|^@reboot.*$(pwd)/instance.sh.*| s|^@reboot.*$(pwd)/instance.sh.*||" mycron
  bar=$(cat mycron | grep -c "@reboot sudo bash $(pwd)/instance.sh")
done 

cat mycron | grep "@reboot sudo bash $(pwd)/instance.sh" >/dev/null 2>&1
foo="$?"
[[ "$foo" = "0" ]] && echo && echo && echo && echo $'\033[0;32mCommand found in crontab. No update needed!' && echo && echo && echo && mycron && exit 0

#new cron into cron file
dir=$(pwd)/instance.sh
echo "@reboot sudo bash $dir >/dev/null 2>&1" >> mycron

#install new cron file
crontab mycron
rm mycron
echo; echo; echo; echo; echo $'\033[0;32mI updated crontab. Everything is ready!'; echo; echo; echo
