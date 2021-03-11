#!/usr/bin/env bash

#script for pinging a network device
#after succesful pong instance 0 LED on
#check if LED on is success
#by Daniel Froebe

#variables 
i="0"
var="0"
IP="$1"
time_sec="$2"
is_on="false"

#endless loop
while :
do
   #ping ESP device
#  while true; do ping -c1 "$IP" >/dev/null 2>&1 && break; done
   ping -c 1 -w 1 "$IP" >/dev/null 2>&1
   var="$?"

   #first success after error
   if [[ "$var" = "0" ]] && [[ "$i" = "0" ]]; then
       while [[ "$is_on" != "true" ]]
       do
          
	  curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 0}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}' >/dev/null 2>&1
          
          sleep 1

          is_on=$(curl -s -X POST -i http://localhost:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -B1 "LEDDEVICE" | grep -v name | sed -e 's/ .*"enabled": //' -e 's/,//')

#      echo 'no instance' >>bar 2>&1

       done
       curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command":"effect","effect":{"name":"Rainbow swirl"},"duration":5000,"priority":50,"origin":"My Fancy App"}' >/dev/null 2>&1
       i=1
       is_on="false"

#      echo 'ping successful' >>bar 2>&1

   #second to n successful answers
   elif [[ "$var" = "0" ]] && [[ "$i" = "1" ]]; then

#      echo 'ping still successful' >>bar 2>&1

       [[ "$time_sec" > "0" ]] && sleep "$2"

   #no one home
   else

#      echo 'no answer' >>bar 2>&1
       i=0
   fi

sleep 4

done
