###1. Datei erstellen "nano usb_an.sh

###2. Inhalt reinkopieren. 

###3. Ausführbar machen sudo chmod +x usb_an.sh

###4. Der Eintrag in crontab: crontab -e. 
###Ich gehe davon aus du hast die Datei im Login Verzeichnis erstellt. 
###Ansonsten das Verzeichnis für ~ eintragen. 
### @reboot sudo bash ~/usb_an.sh


###ANFANG###
#!/usr/bin/env bash

#variables
var=0
i=0

#########################################################################
#check if hyperiond is running
while [[ $var != "active(running)" ]] && [[ $i < "4" ]]
do	
	i=$(($i+1))
	var=$(systemctl status hyperiond* | grep 'active (running)' | sed -e 's/Active://' -e 's/since.*ago//' | tr -d " ")
	sleep 5
done
#########################################################################


#sleep 20

curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 0}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"V4L","state":true}}'


###ENDE###


#Diese Zeile kann auch verwendet werden, dann einfach in den crontab kopieren.
#Der Befehl wartet 20 Sekunden, damit Hyperion gestartet ist und es funktioniert. 
#Du kannst die Sekunden erhöhen oder verringern wie es am Besten passt. 
#ABER: Ohne # am Anfang eintragen! 
#@reboot sleep 20 && curl -i -X POST 'http://localhost:8090/json-rpc' --data '{"command" : "instance","subcommand" : "switchTo","instance" : 0}' --next 'http://localhost:8090/json-rpc' --data '{"command":"componentstate","componentstate":{"component":"LEDDEVICE","state":true}}'
