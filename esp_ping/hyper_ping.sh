#!/usr/bin/env bash

#variables 
i="0"
var="0"
IP="$1"
time_sec="$2"
time_ext="30"

#endless loop
while :
do
   # ping ESP device
   ping -c 1 -w 1 "$IP" >/dev/null 2>&1
   var="$?"

   #first success after error
   if [[ "$var" = "0" ]] && [[ "$i" = "0" ]]; then
       curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "startInstance","instance" : 1}' >/dev/null 2>&1
       curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}' >/dev/null 2>&1
       i=1
       sleep 25
       echo 'ping successful' >>bar 2>&1
   
   #second to n successful answers
   elif [[ "$var" = "0" ]] && [[ "$i" = "1" ]]; then
       echo 'ping still successful' >>bar 2>&1
   
   #no one home
   else
       echo 'no answer' >>bar 2>&1
       i=0
   fi

   [[ "$time_sec" > "0" ]] && sleep "$2" || sleep 4

done
