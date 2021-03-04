#!/usr/bin/env bash


#variables
i="0"
number="0"
set_boot_init="0"
instance_boot="instance.sh"
instance_shortcut=instance_"$RANDOM".sh
ip="localhost"
n="1"


#ip address
echo
echo
echo
echo "What is the IP of Hyperion.ng?"
echo "Hit enter if the script runs locally."

while [[ $n -eq "1" ]] 
do
        echo
        echo -n ">"
        read ip
        echo
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then

                echo "Valid ip."
                echo
                n="0"

        elif [[ $ip =~ ^[0-9]+$ ]] || [[ $ip =~ ^[0-9]+\..*+$ ]]; then
   
                echo "You entered $ip!"
                echo
                echo "Please enter a valid IP-address"
                n="1"
       
        else 
                ip="localhost"
                echo "IP is $ip"
                n="0"
                echo
                echo
        fi
done


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
while [[ $number -eq "0" ]]
do
        echo
        echo 'How many instances do you want to control?'
        echo
        echo -n ">"
        read number
        echo
        [[ $number -eq "0" ]] || [[ -z $number ]] && echo -e "\e[4m\e[31mYou have to enter at least 1\e[0m" && number="0"
done


#array configuration
while [[ "$i" < "$number" ]]
do
        echo
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



##configuration loops##
{
#instances on/off
i=0
while [[ "$i" < "$number" ]]
do
	i=$(($i+1))
	var="$(eval echo \${instance_"$i"_conf_[0]})"

	[[ "$var"  = "on" ]] || [[ "$var" =~ ^[0-9]+$ ]] && echo "curl -i -X POST 'http://$ip:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"startInstance\",\"instance\" : $i}'
	
	" | tee -a "$instance_boot" "$instance_shortcut"

	[[ "$var"  = "off" ]] && echo "curl -i -X POST 'http://$ip:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"stopInstance\",\"instance\" : $i}'
       
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

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://$ip:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"LEDDEVICE\",\"state\":true}}' 
	
	" | tee -a "$instance_boot" "$instance_shortcut"


	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://$ip:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"LEDDEVICE\",\"state\":false}}' 

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

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://$ip:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"V4L\",\"state\":true}}'

        " | tee -a "$instance_boot" "$instance_shortcut"



	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://$ip:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"V4L\",\"state\":false}}'

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

	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://$ip:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"GRABBER\",\"state\":true}}'

        " | tee -a "$instance_boot" "$instance_shortcut"



	[[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://$ip:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"GRABBER\",\"state\":false}}'

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

     #write new cron into file
	dir=$(pwd)/instance.sh
	echo "@reboot sudo bash $dir >ok >error" >> mycron

     #install new cron file
	crontab mycron

     #remove mycron
	rm mycron
	echo; echo; echo; echo; echo $'\033[0;32mThe file "instance.sh" is added to crontab and will be executed during boot. Everything is ready!\e[0m'; echo; echo; echo
fi

echo
echo
echo -e "The name of your script is \e[1m\e[32m$instance_shortcut."
echo
echo
