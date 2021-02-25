#!/usr/bin/env bash

#delete dublicates
rm file

#variables
i=0
number=0
instance_boot="instance.sh"
instance_shortcut=instance_"$RANDOM".sh

#adjust the script
echo
echo "Do you nedd a boot script?"
echo
read yes_no
echo
if [ "$yes_no" = "yes" ]; then
	[[ -e ./instance.sh ]] && mv ./instance.sh ./instance_backup"$RANDOM".sh
	echo "#!/usr/bin/env bash

#variables
var=0
i=0

#########################################################################
#check if hyperiond is running
while [[ \$var != \"active\(r\unning\)\" ]] && [[ \$i < \"4\" ]]
do
	i=\$((\$i+1))
	var=\$(systemctl status hyperiond* | grep 'active (running)' \| sed -e 's/Active://' -e 's/since.*ago//' | tr -d \" \")
	sleep 5
done
#########################################################################" >>"$instance_boot"
else
	echo "#!/usr/bin/env bash

	" >>"$instance_shortcut"
	instance_boot="/dev/null"
	echo
fi

echo
echo 'How many instances do you want to control?'
read number
echo
echo

while [[ "$i" < "$number" ]]
do
	i=$(($i+1))
	echo 'Instance' "$i" 'configuration?'
	read -a instance_"$i"_conf_
done

echo "#!/usr/bin/env bash

" >>"$instance_shortcut"

echo ${instance_1_conf_[@]}
echo ${instance_2_conf_[@]}
echo ${instance_3_conf_[@]}

i=0
while [[ "$i" < "$number" ]]
do
	i=$(($i+1))
	var="$(eval echo \${instance_"$i"_conf_[0]})"
	[[ "$var"  = "on" ]] && echo curl -i -X POST 'http://localhost:8090/json-rpc' --data "{"command" : "instance","subcommand" : "startInstance","instance" : $i}" >>"$instance_boot" >>"$instance_shortcut"

done


i=0
while [[ "$i" < "$number" ]]
do
	i=$(($i+1))
	var="$(eval echo \${instance_"$i"_conf_[5]})"

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : "$i"}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'" >>"$instance_boot" >>"$instance_shortcut"

	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : "$i"}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":false}}'" >>"$instance_boot" >>"$instance_shortcut"

done

i=0
while [[ "$i" < "$number" ]]
do                                                                                   i=$(($i+1))                                                                  var="$(eval echo \${instance_"$i"_conf_[5]})"

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : "$i"}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"V4L","state":true}}'" >>file      
	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : "$i"}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"V4L","state":false}}'" >>"$instance_boot" >>"$instance_shortcut"

done


i=0
while [[ "$i" < "$number" ]]
do                                                                                   i=$(($i+1))                                                                  var="$(eval echo \${instance_"$i"_conf_[5]})"

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : "$i"}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"GRABBER","state":true}}'" >>"$instance_boot" >>"$instance_shortcut"

	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : "$i"}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"GRABBER","state":false}}'" >>"$instance_boot" >>"$instance_shortcut"
	
done

#write out current crontab
#crontab -l > mycron
#test for duplication
#[[ $(cat mycron | grep instanzen.sh | cut -d " " -f 4,4 | cut -d "/" -f 4,4) = "instanzen.sh" ]] && echo && echo && echo && echo $'\033[0;32mCommand found in crontab. No update needed!' && echo && echo && echo && rm mycron && exit 0
#echo new cron into cron file
#dir=$(pwd)/instanzen.sh
#echo "@reboot sudo bash $dir >ok >error" >> mycron
#install new cron file
#crontab mycron
#rm mycron
#echo; echo; echo; echo; echo $'\033[0;32mI updated crontab. Everything is ready!'; echo; echo; echo
