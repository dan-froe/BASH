#!/bin/bash
# reset-netz.sh
# joe-eis, 2021-01-19 V0.3

VDATE=`date '+%Y-%m-%d_%H:%M:%S'`


USTATE=`ip  -p address show|grep -v 'LOOPBACK' |egrep 'state UP'|tr " " ":"|cut -d: -f3|wc -l`
ASTATE=`ip  -p address show|grep -v 'LOOPBACK' |egrep 'state'|tr " " ":"|cut -d: -f3|wc -l`
NDOWN=`ip  -p address show|egrep 'state DOWN'|tr " " ":"|cut -d: -f3|wc -l`

#echo "Anzahl vorhandener Netzgeräte $ASTATE"
#echo "Anzahl Geräte in $NDOWN"

if [ "$NDOWN" -eq "$ASTATE" ]; then
    #echo "$NDOWN von $ASTATE Netzgeräte sind down" 
    echo "$VDATE: $NDOWN von $ASTATE Netzgeräte sind down" >> netz.log

    sudo ifconfig eth0 down
    sleep 5
    sudo ifconfig eth0 up
    sleep 1
    sudo ifconfig wlan0 down
    sleep 5
    sudo ifconfig wlan0 up


    echo "$VDATE: Netzgerät(e) durch gestartet" >> netz.log
    USTATE=`ip  -p address show|grep -v 'LOOPBACK' |egrep 'state UP'|tr " " ":"|cut -d: -f3|wc -l`
    echo "Es ist/sind $USTATE Netzwerk Geräte aktiv" >> netz.log

else

    ND=`ip  -p address show|egrep 'state UP'|tr " " ":"|cut -d: -f3|head -1`
    GW=`ip route |head -1|grep default|cut -d" " -f3`
    PTL=`ping -c1 $GW|grep 'packets transmitted'|tr " " ":"|cut -d: -f6|cut -d% -f1`


    #echo "Network Device is $ND" # debug
    #echo "Gateway is $GW"        # debug
    #echo "Packets transmitting loss ist $PTL %"  # debug

fi

# ENDE
