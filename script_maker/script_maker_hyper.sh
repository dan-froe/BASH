#!/usr/bin/env bash


#variables
i="0"
number="0"
set_boot_init="0"
instance_boot="instance.sh"
instance_shortcut=instance_"$RANDOM".sh

#boot script
echo
echo "Do you nedd a boot script? Type yes or no. "
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
	var=\$(systemctl status hyperion* | grep 'active (running)' \| sed -e 's/Active://' -e 's/since.*ago//' | tr -d \" \")
	sleep 5
done
#########################################################################


" >>"$instance_boot"
        set_boot_init="1"
else
	echo "#!/usr/bin/env bash

	" >>"$instance_shortcut"
	instance_boot="/dev/null"
	echo
fi

#instances count
echo
echo 'How many instances do you want to control?'
read number
echo
echo

#array configuration
while [[ "$i" < "$number" ]]
do
	i=$(($i+1))
        echo
	echo 'Instance' "$i" 'configuration. First write on or off and hit space. 
For LED, USB, Platform write 0 for off and 1 for on, seperated by space. e.g. "on 1 0 1"'
	echo
        read -a instance_"$i"_conf_
        echo
        echo
done

{
#instances on/off
i=0
while [[ "$i" < "$number" ]]
do
	i=$(($i+1))
	var="$(eval echo \${instance_"$i"_conf_[0]})"

	[[ "$var"  = "on" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"startInstance\",\"instance\" : $i}'
	
	" | tee -a "$instance_boot" "$instance_shortcut"

	[[ "$var"  = "off" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"stopInstance\",\"instance\" : $i}'
       
	" | tee -a "$instance_boot" "$instance_shortcut"

done

#instance LEDDEVICE
i=0
while [[ "$i" < "$number" ]]
do
	i=$(($i+1))
	var="$(eval echo \${instance_"$i"_conf_[1]})"

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"LEDDEVICE\",\"state\":true}}' 
	
	" | tee -a "$instance_boot" "$instance_shortcut"


	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"LEDDEVICE\",\"state\":false}}' 

        "| tee -a "$instance_boot" "$instance_shortcut"

done

#instance USB
i=0
while [[ "$i" < "$number" ]]
do
        i=$(($i+1))
	var="$(eval echo \${instance_"$i"_conf_[2]})"

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"V4L\",\"state\":true}}'

        " | tee -a "$instance_boot" "$instance_shortcut"



	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"V4L\",\"state\":false}}'

        " | tee -a "$instance_boot" "$instance_shortcut"

done

#instance PLATFORM
i=0
while [[ "$i" < "$number" ]]
do
	i=$(($i+1))
	var="$(eval echo \${instance_"$i"_conf_[3]})"

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"GRABBER\",\"state\":true}}'

        " | tee -a "$instance_boot" "$instance_shortcut"



	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"GRABBER\",\"state\":false}}'

        " | tee -a "$instance_boot" "$instance_shortcut"

done
} >/dev/null

echo
echo
echo
echo "The name of your script is $instance_shortcut. "
echo
echo

##crontab installation and check
if [[ $set_boot_init -eq 1 ]]; then

#read current crontab into file 
    crontab -l > mycron
#test for duplication
    [[ $(cat mycron | grep instance.sh | cut -d " " -f 4,4 | cut -d "/" -f 4,4) = "instance.sh" ]] && echo && echo && echo && echo $'\033[0;32mCommand found in crontab. No update needed!' && echo && echo && echo && rm mycron && exit 0
#echo new cron into cron file
    dir=$(pwd)/instance.sh
    echo "@reboot sudo bash $dir >ok >error" >> mycron
#install new cron file
    crontab mycron
#rm mycron
    echo; echo; echo; echo; echo $'\033[0;32mThe file "instance.sh is added to crontab and will be executed during boot. Everything is ready!'; echo; echo; echo
fi
