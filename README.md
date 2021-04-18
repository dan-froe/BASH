# BASH

Bash scripts to control Hyperion.ng instances in various cases.

#### Update script

This script is work in progress. It works Raspbian/HyperBian. Libreelec is available but isn't tested.

The script tries to determine how hyperion is installed in the system, but asks before proceeding.

```bash
bash <(wget -qO - https://raw.githubusercontent.com/dan-froe/BASH/master/hyper_update.sh)
```
[CODE](https://raw.githubusercontent.com/dan-froe/BASH/master/update_hyperion.sh) 

#### Script maker

This script is a simple interactive script maker to control as many instances as you like. 
It does not have the options to ping a microcontroller, see ESP ping script instead.
The script allows to configure start/stop of an instance and USB Grabber, Platform Grabber and LED Hardware on/Off. It is possible to skip an instance too. 
Furthermore it allows to make 2 separated scripts, one for boot and another one for extern triggers e.g LIRC. The script can be configured for local use or with a specific IP. The boot script can be automatically added to crontab.

```bash
bash <(wget -qO - https://raw.githubusercontent.com/dan-froe/BASH/master/script_maker/script_maker_hyper.sh)
```
[CODE](https://raw.githubusercontent.com/dan-froe/BASH/master/script_maker/hyper_script_maker.sh) 


#### Instance 1/2 follow instance 0 - script

This script let instance 1 and 2 follow the on/off Signal from instance 0.
You can e.g. control Philips Hue device in instance 1 and 2 to turn on/off with the status of instance 0.
It is not required to have a 3rd instance.

This script has an installation script, which downloads the actual script to the current directory and deletes existing files. It adds the script to crontab if necessary. 

```bash
wget -O - https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/hue/installation.sh | bash
```
[CODE](https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/hue/instance.sh)

[CODE INSTALLATION](https://raw.githubusercontent.com/dan-froe/BASH/master/hyperion_auto/hue/installation.sh) 


#### ESP ping script 

This script starts LED and Grabber after boot for ESP devices, or other network devices after boot or if the WLAN connection is interrupted. This script is limited to ESPs in instance 1 or 2.

There is a full explanation in [ENGLISH](https://github.com/dan-froe/BASH/tree/master/esp_ping) or [DEUTSCH](https://github.com/dan-froe/BASH/blob/master/esp_ping/README_de.md) 


