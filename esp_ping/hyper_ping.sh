#!/usr/bin/env bash

#variables 
i="0"
var="0"


while
do
   ping 192.168.178.20
   var="$?"
   if [[ "var" = "0" ]] && [[ "i" = "0" ]]; then
       curl
       i=1
   elif [[ "var" = "0" ]] && [[ "i" = "1" ]]; then
       echo 
   else
       i=0
   fi
   sleep 5
done
