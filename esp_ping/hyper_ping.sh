#!/usr/bin/env bash

#Version:1.5.2
#script for pinging a network device
#after succesful pong instance 0 LED on
#check if LED on is success
#by Daniel Froebe

#variables 
foo="0"
bar="0"
i="0"
var="0"
num="0"
ip_count="0"
HYPERION="localhost"
IP="$1"
IP2="$2"
delay_s="$3"
is_on="false"
is_on_LED="false"

#variables substitution if file exists
if [[ -f conf ]] && [[ -z $1 ]]; then
   HYPERION=$(cat conf | grep HYPERION_IP | cut -d: -f2)
   IP=$(cat conf | grep IP_Address | cut -d: -f2)
   IP2=$(cat conf | grep IP2_Address | cut -d: -f2)
   delay_s=$(cat conf | grep TIME_Seconds | cut -d: -f2)

   HYPERION=${HYPERION:="localhost"}
   IP=${IP:="ERROR"}
   IP2=${IP2:="0"}
   delay_s=${delay_s:="0"}
fi

#function
function instance_switch () {
#instance 1/2 on,LED on, V4l on
         {
         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "startInstance","instance" : 0}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "startInstance","instance" : 1}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "startInstance","instance" : 2}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 0}' --next 'http://$HYPERION:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next 'http://$HYPERION:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 2}' --next 'http://$HYPERION:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 0}' --next 'http://$HYPERION:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"V4L","state":true}}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next 'http://$HYPERION:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"V4L","state":true}}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 2}' --next 'http://$HYPERION:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"V4L","state":true}}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 0}' --next 'http://$HYPERION:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"GRABBER","state":true}}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next 'http://$HYPERION:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"GRABBER","state":false}}'

         curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 2}' --next 'http://$HYPERION:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"GRABBER","state":false}}'
         } >/dev/null 2>&1
} 

#########################################################################
#check if hyperiond is running
while [[ $foo != "active(running)" ]] && [[ $bar < "5" ]]
do	
	bar=$(($bar+1))
	nc -zv $HYPERION 8090 -w 1 >>/dev/null 2>&1 && break
	foo=$(systemctl status "hyperion*" | grep 'active (running)' | sed -e 's/Active://' -e 's/since.*ago//' | tr -d " ")
	sleep 4
done
instance_switch
#########################################################################


#endless loop
while :
do
   #ping ESP device
   if [[ $IP2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
       ping -c 1 -w 1 "$IP" >/dev/null 2>&1 && ping -c 1 -w 1 "$IP2" >/dev/null 2>&1
       var="$?"
       ip_count="2"
   else
       ping -c 1 -w 1 "$IP" >/dev/null 2>&1
       var="$?"
       [[ ! -z "$1" ]] && delay_s="$IP2"
       ip_count="1"
   fi

   #first success after error
   if [[ "$var" = "0" ]] && [[ "$i" = "0" ]]; then
       while [[ "$is_on" != "true" ]]
       do
#         is_on_LED=$(curl -s -X POST -i http://$HYPERION:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -B1 "LEDDEVICE" | grep -v name | sed -e 's/ .*"enabled": //' -e 's/,//') 
#         [[ "$is_on_LED" = "true" ]] && is_on=$(curl -s -X POST -i http://$HYPERION:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -A1 '"instance": 1,' | grep -v instance | sed -e 's/ .*"running": //' -e 's/,//')
          num=$(($(curl -s "http://$IP/json/info" | grep -c "Hyperion")+$(curl -s "http://$IP2/json/info" --connect-timeout 1 | grep -c "Hyperion")))
          [[ "$ip_count" = "$num" ]] && is_on="true" || is_on="false"
          instance_switch
          sleep 1
#         echo 'no instance' >>info 2>&1

       done
#      curl -i -X POST 'http://$HYPERION:8090/json-rpc' --data '{"command":"effect","effect":{"name":"Rainbow swirl"},"duration":2000,"priority":50,"origin":"My Fancy App"}' >/dev/null 2>&1
       i=1
       is_on="false"

#      echo 'ping successful' >>info 2>&1

   #second to n successful answers
   elif [[ "$var" = "0" ]] && [[ "$i" = "1" ]]; then

#      echo 'ping still successful' >>info 2>&1
       [[ "$delay_s" > "0" ]] && sleep $delay_s || sleep 4

   #no one home
   else

#      echo 'no answer' >>info 2>&1
       i=0
       sleep 1
   fi

done
