#!/usr/bin/env bash


#silent boot
#exec >ok
#exec 2>error

#variables
var=0
i=0
is_on=0
foo=1

#function
function instance_switch () {
#instance 1/2 on,LED on, V4l on
curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "startInstance","instance" : 1}'

curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "startInstance","instance" : 2}'

curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'

curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 2}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'

curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"V4L","state":true}}'

curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 2}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"V4L","state":true}}'

curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"GRABBER","state":false}}'

curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 2}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"GRABBER","state":false}}'
} 

#########################################################################
#check if hyperiond is running
while [[ $var != "active(running)" ]] && [[ $i < "4" ]]
do	
	i=$(($i+1))
	var=$(systemctl status "hyperion*" | grep 'active (running)' | sed -e 's/Active://' -e 's/since.*ago//' | tr -d " ")
	sleep 5
done
#########################################################################


#sleep 20

#calling function
#instance_switch

#checking instance 0, switching 1
while :
do
   sleep=1
   is_on=$(curl -s -X POST -i http://localhost:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -B1 "LEDDEVICE" | grep -v name | sed -e 's/ .*"enabled": //' -e 's/,//') 
#  is_on=$(curl -s -X POST -i http://localhost:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -A1 '"instance": 0,' | grep -v instance | sed -e 's/ .*"running": //' -e 's/,//')
 
   if [[ "$is_on" = "true" ]] && [[ "$foo" = "0" ]]; then
     instance_switch && foo=1
     echo true 0
#    is_on=$(curl -s -X POST -i http://localhost:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -A1 '"instance": 0,' | grep -v instance | sed -e 's/ .*"running": //' -e 's/,//')
   
   elif [[ "$is_on" = "true" ]] && [[ "$foo" = "1" ]]; then
#    is_on=$(curl -s -X POST -i http://localhost:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -A1 '"instance": 0,' | grep -v instance | sed -e 's/ .*"running": //' -e 's/,//')
     echo true 1
     [[ "$is_on" != "true" ]] && foo=0

   else
#    is_on=$(curl -s -X POST -i http://localhost:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -A1 '"instance": 0,' | grep -v instance | sed -e 's/ .*"running": //' -e 's/,//')
     [[ "$is_on" != "true" ]] && foo=0
     echo false

   fi

done

#is_on=$(curl -s -X POST -i http://localhost:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -A1 '"instance": 0,' | grep -v instance | sed -e 's/ .*"running": //' -e 's/,//') 
