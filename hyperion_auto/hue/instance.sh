#!/usr/bin/env bash


#Version:1.5.6
#script for controlling instance 1/2
#in relation to instance 0
#instance 1/2 follows 0
#by Daniel Froebe


#variables
var="0"
i="0"
x="0"
is_on="0"
is_on_1="0"
foo="0"
HUEIP="noIP" 
HYPERION="${1:-0}"
delay_s="${2:-0}" 


#variables substitution if file exists
if [[ -f "conf" ]] && [[ -z "$1" ]]; then
   HYPERION=$(cat conf | grep HYPERION_IP | cut -d= -f2)
   HUEIP=$(cat conf | grep HUE_Bridge | cut -d= -F2) 
   delay_s=$(cat conf | grep TIME_Seconds | cut -d= -f2)

   HYPERION=${HYPERION:="localhost"}
   HUEIP=${HUEIP:=noIP}
   delay_s=${delay_s:="0"}
fi


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

function instance_LED_off () {
#instance 1/2 LED off
         {
         curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next "http://$HYPERION:8090/json-rpc" --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":false}}'
        
	 curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "switchTo","instance" : 2}' --next "http://$HYPERION:8090/json-rpc" --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":false}}'
	
	 curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "stopInstance","instance" : 1}'

         curl -i -X POST "http://$HYPERION:8090/json-rpc" --data '{"command" : "instance","subcommand" : "stopInstance","instance" : 2}'
         } >/dev/null 2>&1
}


#########################################################################
#check if hyperiond is running
while [[ $var != "active(running)" ]] && [[ $i < "5" ]]
do	
	i=$(($i+1))
	nc -zv $HYPERION 8090 -w 1 >>/dev/null 2>&1 && break
	var=$(systemctl status "hyperion*" | grep 'active (running)' | sed -e 's/Active://' -e 's/since.*ago//' | tr -d " ")
	sleep 4
done
instance_switch
#########################################################################


#check for IP
if [[ ! $HYPERION =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
     delay_s="${HYPERION:=0}"
     HYPERION="localhost"
fi



#########################################################################
#hue doesn't start from time to time - fix######
if [[ $HUEIP != "noIP" ]] && [[ $x < "5" ]] 
   ping -c 1 -w 1 "$HUEIP" 
   [[ $? = "0" ]] && break
   x=$(($x+1)) 
   sleep 3
fi
instance_switch && sleep 1 && instance_LED_off && sleep 1
#end of fix#######
#########################################################################


#checking instance 0, switching 1
while :
do
   is_on=$(curl -s -X POST -i http://$HYPERION:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -B1 "LEDDEVICE" | grep -v name | sed -e 's/ .*"enabled": //' -e 's/,//') 

   if [[ "$is_on" = "true" ]] && [[ "$foo" = "0" ]]; then 
     instance_switch && foo=1
     is_on_1="0"
#    echo true 0 >>info 2>&1

   elif [[ "$is_on" = "true" ]] && [[ "$foo" = "1" ]]; then
#    echo true 1 >>info 2>&1
     [[ "$is_on" != "true" ]] && foo=0
     [[ "$delay_s" > "0" ]] && sleep $delay_s || sleep 3

   else
     [[ "$is_on_1" = "0" ]] && curl -s -X POST -i http://$HYPERION:8090/json-rpc --data '{"command" : "instance","subcommand" : "stopInstance","instance" : 1}' >/dev/null 2>&1
     [[ "$is_on_1" = "0" ]] && curl -s -X POST -i http://$HYPERION:8090/json-rpc --data '{"command" : "instance","subcommand" : "stopInstance","instance" : 2}' >/dev/null 2>&1
     [[ "$is_on" != "true" ]] && foo=0
     is_on_1="1"
#    echo false >>info 2>&1
     sleep 1

   fi

done
