#!/usr/bin/env bash


#Version:1.0.0
#script for controlling instance 1/2
#in relation to instance 0
#instance 1/2 follows 0
#by Daniel Froebe


#variables
var="0"
i="0"
is_on="0"
is_on_1="0"
foo="0"
HYPERION="$1"
delay_s="$2"

#function
function instance_switch () {
#instance 1/2 on,LED on, V4l on
         {
         curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "startInstance","instance" : 1}'

         curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "startInstance","instance" : 2}'

         curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next "http://$HYPERION:8090/json-rpc" --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'

         curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "switchTo","instance" : 2}' --next "http://$HYPERION:8090/json-rpc" --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'

         curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next "http://$HYPERION:8090/json-rpc" --data '{"command":"componentstate","componentstate":{"component":"V4L","state":true}}'

         curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "switchTo","instance" : 2}' --next "http://$HYPERION:8090/json-rpc" --data '{"command":"componentstate","componentstate":{"component":"V4L","state":true}}'

         curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next "http://$HYPERION:8090/json-rpc" --data '{"command":"componentstate","componentstate":{"component":"GRABBER","state":false}}'

         curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "switchTo","instance" : 2}' --next "http://$HYPERION:8090/json-rpc" --data '{"command":"componentstate","componentstate":{"component":"GRABBER","state":false}}'
         } >/dev/null 2>&1
} 

#########################################################################
#check if hyperiond is running
while [[ $var != "active(running)" ]] && [[ $i = "5" ]]
do	
	i=$(($i+1))
	nc -zv $HYPERION 8090 -w 1 >>info 2>&1 && break
	var=$(systemctl status "hyperion*" | grep 'active (running)' | sed -e 's/Active://' -e 's/since.*ago//' | tr -d " ")
	sleep 4
done
#########################################################################


#heck for IP
if [[ ! $HYPERION =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
     delay_s="$HYPERION"
     HYPERION="localhost"
fi


#checking instance 0, switching 1
while :
do
   is_on=$(curl -s -X POST -i http://$HYPERION:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -B1 "LEDDEVICE" | grep -v name | sed -e 's/ .*"enabled": //' -e 's/,//') 

   if [[ "$is_on" = "true" ]] && [[ "$foo" = "0" ]]; then
     instance_switch && foo=1
     is_on_1="0"
     echo true 0 >>info 2>&1

   elif [[ "$is_on" = "true" ]] && [[ "$foo" = "1" ]]; then
     echo true 1 >>info 2>&1
     [[ "$is_on" != "true" ]] && foo=0
     [[ "$delay_s" > "0" ]] && sleep $delay_s || sleep 3

   else
     [[ "$is_on_1" = "0" ]] && curl -s -X POST -i http://$HYPERION:8090/json-rpc --data '{"command" : "instance","subcommand" : "stopInstance","instance" : 1}' >/dev/null 2>&1
     [[ "$is_on_1" = "0" ]] && curl -s -X POST -i http://$HYPERION:8090/json-rpc --data '{"command" : "instance","subcommand" : "stopInstance","instance" : 2}' >/dev/null 2>&1
     [[ "$is_on" != "true" ]] && foo=0
     is_on_1="1"
     echo false >>info 2>&1
     sleep 1

   fi

done
