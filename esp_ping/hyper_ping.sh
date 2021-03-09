#!/usr/bin/env bash

#variables 
i="0"
var="0"
IP="$1"
time_sec="$2"
sleep_long="30"
is_on="0"

#endless loop
while :
do
   # ping ESP device
   ping -c 1 -w 1 "$IP" >/dev/null 2>&1
   var="$?"

   #first success after error
   if [[ "$var" = "0" ]] && [[ "$i" = "0" ]]; then
       while [[ "$is_on" != "true" ]]
       do
          sleep 1
          curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "startInstance","instance" : 1}' >/dev/null 2>&1
          curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}' >/dev/null 2>&1
          is_on=$(curl -s -X POST -i http://localhost:8090/json-rpc --data '{"command": "serverinfo", "tan":1}' | grep -A1 '"instance": 1' | grep -v '"instance"' | sed 's/"running": //' | tr -d ' ')
       done
       i=1
#      echo 'ping successful' >>bar 2>&1
       sleep $sleep_long

   #second to n successful answers
   elif [[ "$var" = "0" ]] && [[ "$i" = "1" ]]; then
#      echo 'ping still successful' >>bar 2>&1
       sleep $sleep_long

   #no one home
   else
#      echo 'no answer' >>bar 2>&1
       i=0
   fi

   [[ "$time_sec" > "0" ]] && sleep "$2" || sleep 4

done
