#!/usr/bin/env bash

#variables 
i="0"
var="0"


while :
do
   ping 192.168.178.20
   var="$?"
   if [[ "var" = "0" ]] && [[ "i" = "0" ]]; then
       curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "startInstance","instance" : 1}'
       curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 1}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'
       i=1
   elif [[ "var" = "0" ]] && [[ "i" = "1" ]]; then
       echo 
   else
       i=0
   fi
   sleep 5
done
