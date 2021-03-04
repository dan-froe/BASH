#!/usr/bin/env bash

i=0

while [[ "$i" < "3" ]]
do
	
	echo -n ">"
	read -a instance_"$i"_conf_
#	var="$(eval echo \${instance_"$i"_conf_[1]})"
	eval echo \${instance_"$i"_conf_[@]} | grep -q "on"
	hash_var="$?"
	if [[ "$hash_var" -eq "0" ]]; then
		var="$(eval echo \${instance_"$i"_conf_[1]})"
	else
		var="$(eval echo \${instance_"$i"_conf_[0]})"
	fi

 	[[ "$var"  = "1" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"LEDDEVICE\",\"state\":true}}'

        " | tee -a "instance_boot" "instance_shortcut"


        [[ "$var"  = "0" ]] && echo "curl -i -X POST 'http://localhost:8090/json-rpc' --data '{\"command\" : \"instance\",\"subcommand\" : \"switchTo\",\"instance\" : $i}' --next 'http://localhost:8090/json-rpc' --data '{\"command\":\"componentstate\",\"componentstate\":{\"component\":\"LEDDEVICE\",\"state\":false}}'

        "| tee -a "instance_boot" "instance_shortcut"

        i=$(($i+1))	


#	var_corr="$(eval echo \${instance_"$i"_conf_[@]})"
echo
done
