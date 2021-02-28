#!/usr/bin/env bash


#silent boot
#exec >ok
#exec 2>error

#variables
var=0
i=0

#########################################################################
#check if hyperiond is running
while [[ $var != "active(running)" ]] && [[ $i < "4" ]]
do	
	i=$(($i+1))
	var=$(systemctl status hyperiond* | grep 'active (running)' | sed -e 's/Active://' -e 's/since.*ago//' | tr -d " ")
	sleep 5
done
#########################################################################


#sleep 20

curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 0}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"V4L","state":true}}'


#Diese Zeile kann auch verwendet werden, dann einfach in den crontab kopieren.
#Der Befehl wartet 20 Sekunden, damit Hyperion gestartet ist und es funktioniert. 
#Du kannst die Sekunden erhöhen oder verringern wie es am Besten passt. 
#ABER: Ohne # am Anfang eintragen! 
#@reboot sleep 20 && curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 0}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'
