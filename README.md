# BASH  
  
&nbsp;
&nbsp;
>Bash scripts to control Hyperion.ng instances in various cases.
  
&nbsp;
&nbsp;
### Update script 

*last update: 19.04.2021*  
*works from remote: Yes*  
  
This script is work in progress. It works for Raspbian/HyperBian. Libreelec is available but isn't tested.  
  
The script tries to determine how hyperion is installed into the system (packet installation/compiling), but asks before proceeding. It basically checks for a hyperion git repository made via the compiling method described in [CompileHowto.md](https://github.com/hyperion-project/hyperion.ng/blob/master/CompileHowto.md#compiling-and-installing-hyperion).

**The compiling update process can fail if the existing repository was made with root privileges granted by ```sudo```.**  
  
```console
bash <(wget -qO - https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_update/hyper_update.sh)
```
[CODE](https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_update/hyper_update.sh) 
  
&nbsp;
&nbsp;
### Script maker  
  
*last update: 17.04.2021*  
*works from remote: Yes*  
  
This script is a simple interactive script maker to control as many instances as you like.  
  
It does not have the options to ping a microcontroller, see ESP ping script instead.  
  
The script allows to configure start/stop of an instance and USB Grabber, Platform Grabber and LED Hardware on/Off. 
It is possible to skip an instance too.Furthermore it allows to make 2 separated scripts, one for boot and another one for extern triggers e.g LIRC. 
The script can be configured for local use or with a specific IP. The boot script can be automatically added to crontab.

```console
bash <(wget -qO - https://raw.githubusercontent.com/dan-froe/BASH/master/script_maker/script_maker_hyper.sh)
```
[CODE](https://raw.githubusercontent.com/dan-froe/BASH/master/script_maker/hyper_script_maker.sh) 
  
&nbsp;
&nbsp;
### Instance 1/2 follow instance 0 - script  
  
*last update: 22.04.2021*  
*works from remote: Yes*  
  
This script let instance 1 and 2 follow the on/off Signal from instance 0.  
  
You can e.g. turn on/off a Philips Hue device in instance 1 and 2 just by switching instance 0 on or off.
It is not required to have a 3rd instance. This script works from a remote and can be configured with two variables at the end of the command. Setting variables is not required.  
  
```console
bash instance.sh IP TIME
```  
  
**IP**
With the variable IP it is possible to set the IP of the hyperion server. It has to be the first variable but can be skipped if not needed.  
  
**TIME**
When the instance is successfully switched on, the time in between the checks can be extended by adding a number(seconds) after the command.
If you want to set an IP too place TIME as the last variable. A TIME or IP is not necessary.  
  
  
crontab example:
```console
@reboot sudo bash /home/pi/instance.sh 35
```
  
This script has an installation script, which downloads the actual script to the current directory and deletes existing files. It adds the script to crontab if necessary. 
  
```console
wget -O - https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/hue/installation.sh | bash
```
  
[CODE](https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/hue/instance.sh)

[CODE INSTALLATION](https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/hue/installation.sh) 
  
&nbsp;
&nbsp;
### ESP ping script  
  
*last update: 22.04.2021*  
*works from remote: Yes*
  
This script starts LED and Grabber for any network devices after boot or if the WLAN connection is interrupted. This script is limited to 2 ESPs.

There is a full explanation in [ENGLISH](https://github.com/dan-froe/BASH/tree/master/esp_ping) or [DEUTSCH](https://github.com/dan-froe/BASH/blob/master/esp_ping/README_de.md) 
  
&nbsp;
&nbsp;
