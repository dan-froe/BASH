#!/usr/bin/env bash


#variables
i="0"
number="0"
set_boot_init="0"
instance_boot="instance.sh"
instance_shortcut=instance_"$RANDOM".sh
ip="localhost"
n="1"

#boot script
echo
echo "Do you nedd a boot script? Type yes or no. "
echo
echo -n ">"
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
	echo "#!/usr/bin/env bash

	" >>"$instance_shortcut"
	echo

else
	echo "#!/usr/bin/env bash

	" >>"$instance_shortcut"
	instance_boot="/dev/null"
	echo
fi

#instances count
echo
echo 'How many instances do you want to control?'
echo
echo -n ">"
read number
echo
echo

#ip address 
echo "What is the IP of Hyperion.ng?"
echo "Hit enter if the script runs locally."
echo

while [[ $n -eq "1" ]] 
do

        echo -n ">"
        read ip
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then

                echo "Valid ip." && n="0"

        elif
                [[ $ip =~ ^[0-9]+$ ]] && echo "Not a valid ip." && echo "please enter a valid IP-address" && n="1"
        else 
                ip="localhost" && echo "IP is localhost" && n="0"
                echo
                echo
        fi
done

#array configuration
while [[ "$i" < "$number" ]]
do
#	i=$(($i+1))
        echo
	[[ "$i" == "0" ]] && echo -e 'Instance'" \e[32m$(($i+1)) - Main Instance\e[0m "'configuration. 
You can' "\e[4m\e[31mnot\e[0m" 'switch off or on this instance. For LED, USB, Platform write 0 for off  and 1 for on, seperated by space.' "\e[32me.g."' "1 0 1"'"\e[0m"'. Hit enter if you want skip an instance.' || echo -e 'Instance'" \e[32m$(($i+1))\e[0m "'configuration. 
First write on or off and hit space. For LED, USB, Platform write 0 for off  and 1 for on, seperated by space.' "\e[32me.g. "on 1 0 1"\e[0m"'. Hit enter if you want skip an instance.'
	echo
	echo -n ">"
        read -a instance_"$i"_conf_
	i=$(($i+1))
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

	[[ "$var"  = "on" ]] || [[ "$var" =~ ^[0-9]+$ ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"startInstance\",\"instance\" : $i}'
	
	" | tee -a "$instance_boot" "$instance_shortcut"

	[[ "$var"  = "off" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"stopInstance\",\"instance\" : $i}'
       
	" | tee -a "$instance_boot" "$instance_shortcut"

done

#instance LEDDEVICE
i=0
while [[ "$i" < "$number" ]]
do
      eval echo \${instance_"$i"_conf_[@]} | grep -q "on"
	hash_var="$?"

	if [[ "$hash_var" -eq "0" ]]; then
		var="$(eval echo \${instance_"$i"_conf_[1]})"
	else
		var="$(eval echo \${instance_"$i"_conf_[0]})"
	fi

#	var="$(eval echo \${instance_"$i"_conf_[1]})"

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"LEDDEVICE\",\"state\":true}}' 
	
	" | tee -a "$instance_boot" "$instance_shortcut"


	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"LEDDEVICE\",\"state\":false}}' 

        "| tee -a "$instance_boot" "$instance_shortcut"

	i=$(($i+1))
done

#instance USB
i=0
while [[ "$i" < "$number" ]]
do
        
      eval echo \${instance_"$i"_conf_[@]} | grep -q "on"
	hash_var="$?"

	if [[ "$hash_var" -eq "0" ]]; then
		var="$(eval echo \${instance_"$i"_conf_[2]})"
	else
		var="$(eval echo \${instance_"$i"_conf_[1]})"
	fi

#	var="$(eval echo \${instance_"$i"_conf_[2]})"

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"V4L\",\"state\":true}}'

        " | tee -a "$instance_boot" "$instance_shortcut"



	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"V4L\",\"state\":false}}'

        " | tee -a "$instance_boot" "$instance_shortcut"

	i=$(($i+1))
done

#instance PLATFORM
i=0
while [[ "$i" < "$number" ]]
do

      eval echo \${instance_"$i"_conf_[@]} | grep -q "on"
	hash_var="$?"

	if [[ "$hash_var" -eq "0" ]]; then
		var="$(eval echo \${instance_"$i"_conf_[3]})"
	else
		var="$(eval echo \${instance_"$i"_conf_[2]})"
	fi

#	var="$(eval echo \${instance_"$i"_conf_[3]})"

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"GRABBER\",\"state\":true}}'

        " | tee -a "$instance_boot" "$instance_shortcut"



	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"GRABBER\",\"state\":false}}'

        " | tee -a "$instance_boot" "$instance_shortcut"

	i=$(($i+1))

done
} >/dev/null

##crontab installation and check
if [[ $set_boot_init -eq 1 ]]; then

#read current crontab into file 
	crontab -l > mycron

#test for duplication
	[[ $(cat mycron | grep -m1 instance.sh | cut -d " " -f 4,4 | sed -e 's\/.*/\\') ]] && echo && echo && echo && echo $'\033[0;32mCommand found in crontab. No update needed!\e[0m' && echo && echo && echo && rm mycron && echo -e "The name of your script is \e[1m\e[32m$instance_shortcut." && echo && echo&& echo && exit 0

#echo new cron into cron file
	dir=$(pwd)/instance.sh
	echo "@reboot sudo bash $dir >ok >error" >> mycron

#install new cron file
	crontab mycron

#rm mycron
	rm mycron
	echo; echo; echo; echo; echo $'\033[0;32mThe file "instance.sh" is added to crontab and will be executed during boot. Everything is ready!\e[0m'; echo; echo; echo
fi

echo
echo
echo -e "The name of your script is \e[1m\e[32m$instance_shortcut."
echo
echo
