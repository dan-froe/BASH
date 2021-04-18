# BASH

Bash scripts to control Hyperion.ng instances in various cases.

#### Update script

This script is work in progress. It works Raspbian/HyperBian. Libreelec isn't currently tested.

The script tries to determine how hyperion is installed in the system, but asks before proceeding.

```bash
bash <(wget -qO - https://raw.githubusercontent.com/dan-froe/BASH/master/hyper_update.sh)
```
[CODE](https://raw.githubusercontent.com/dan-froe/BASH/master/update_hyperion.sh) 

#### script maker

This script is a simple interactive script maker to control as many instances as you like. 
It does not have the options to ping a microcontroller, see ESP ping script instead.
The script allows to configure start/stop of an instance and USB Grabber, Platform Grabber and LED Hardware on/Off. It is possible to skip an instance too. 
Furthermore it allows to make 2 separated scripts, one for boot and another one for extern triggers e.g LIRC. The script can be configured for local use or with a specific IP. The boot script can be automatically added to crontab.

```bash
bash <(wget -qO - https://raw.githubusercontent.com/dan-froe/BASH/master/script_maker/script_maker_hyper.sh)
```
[CODE](https://github.com/dan-froe/BASH/blob/master/script_maker/hyper_script_maker.sh) 
