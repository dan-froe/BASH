#!/usr/bin/env bash

# Version:0.5.5
# Script for updating Hyperion.NG on
# Raspbian/HyperBian/LibreELEC
# by Daniel Froebe

clear

# Fixed variables
api_url="https://api.github.com/repos/hyperion-project/hyperion.ng"
type wget > /dev/null 2> /dev/null
hasWget=$?
type curl > /dev/null 2> /dev/null
hasCurl=$?
rel_latest=$(curl $api_url/releases 2>&1 | grep "browser_download_url.*Hyperion-.*armv7l.deb" | head -n1 | cut -d ":" -f 2,3 | tr -d \")
rel_latest_armv6l=$(curl $api_url/releases 2>&1 | grep "browser_download_url.*Hyperion-.*armv6l.deb" | head -n1 | cut -d ":" -f 2,3 | tr -d \")
directory_compile="0"
directory_compile_test="2"
directory_last=$(pwd)
OS=$(lsb_release -i | cut -d : -f 2)
found_compile=0
jump="0"
var="0"
arch_x=$(uname -m | tr -d 'armvl')
green=$'\033[0;32m' 
red=$'\033[0;31m'
yellow=$'\033[1;33m'

if [[ "${hasWget}" -ne 0 ]]; [[ "${hasCurl}" -ne 0 ]]; then
	echo $red ' ---> Critical Error: wget or curl required'
	exit 1
fi

#Function Table
function inst_compile() {
	cd $directory_compile && git pull https://github.com/hyperion-project/hyperion.ng.git master >/dev/null 2>&1 | grep "changed.*inseration.*deletion"
        var="$?"
        git pull https://github.com/hyperion-project/hyperion.ng.git master
        var=$(("$var" + "$?"))
	if [ $var -eq "0" ]; then
		echo 'Uninstalling, this may take a few seconds'; make uninstall >/dev/null 2>/dev/null
                echo 'Installation starts...'; cmake -DCMAKE_BUILD_TYPE=Release .. && make -j $(nproc) && make install/strip
	        cd $directory_last >/dev/null 2>/dev/null
        elif [ $var -eq "1" ]; then
		echo
		echo $green'You are already up to date! No files changed!'
		cd $directory_last >/dev/null 2>/dev/null
                echo
                echo
                echo
        else
                echo $red'An error occurred. Wrong directory?'
                echo
                echo
                echo
                exit 1
	fi

}

function inst_deb() {
		echo
		echo Your version is:
		[[ -e "/usr/bin/hyperiond" ]] && echo $(/usr/bin/hyperiond --version | grep Version | sed -e 's/(.*)//') || echo 'Version number not available.'
		echo
		echo I want to install:
		echo $rel_latest | cut -d / -f9
		echo
		echo Do You want to proceed? Type yes or no to abort!
		echo
		read -p '>>> ' yes_no
		echo
		echo
		case $yes_no in
			(Yes | yes )
				sudo apt-get update; sudo apt remove hyperion -y; cd ~; wget $rel_latest;
				sudo apt-get install ./$(echo $rel_latest | cut -d / -f9) && cd $directory_last >/dev/null 2>/dev/null && sudo apt -f install && echo && echo $green'You are up to date!' && $(exit 0)
				;;
			*)
				echo
				echo $red'You decided against installing the software. No files were written!'
				echo
				exit 0
				;;
		esac
}

function inst_deb_armv6l() {
		echo
		echo Your version is:
		test -e /usr/bin/hyperiond && echo $(/usr/bin/hyperiond --version | grep Version) || echo 'Version Number not available.'
		echo
		echo I want to install:
		echo $rel_latest_armv6l | cut -d / -f9
		echo
		echo Do You want to proceed? Type Yes or no to abort!
		read -p '>>> ' yes_no
		case $yes_no in
			(Yes | yes )
				sudo apt-get update; sudo apt remove hyperion -y; cd ~; wget $rel_latest_armv6l;
				sudo apt-get install ./$(echo $rel_latest_armv6l | cut -d / -f9) && cd $directory_last >/dev/null 2>/dev/null && sudo apt -f install && echo && echo $green'You are up to date!' && $(echo 0)
				;;
			*)
				echo
				echo $red'You decided against installing the software. No files were written!'
				echo
				exit 0
				;;
		esac
}


# Set welcome message
printf %"$COLUMNS"s |tr " " "*"
echo 'This script will update Hyperion.ng for Raspbian/HyperBian/LibreELEC'
echo 'Created by Daniel Froebe.'
printf %"$COLUMNS"s |tr " " "*"


# Check that
if [ $OS != "Raspbian" ] && [ $OS != "HyperBian" ]; then
	echo $red' ---> Critical Error: We are not on Raspbian/HyperBian/RasPlex/OSMC/RetroPie/LibreELEC/Lakka -> abort'
	exit 1
fi

if [ $OS = "Raspbian" ] || [ $OS = "HyperBian" ]; then
	echo 'We are on Raspbina/HyperBian'
	echo $yellow'Checking installation... this may take a few seconds ...'      
	cd $HOME >/dev/null 2>/dev/null
	[[ -e $(find $HOME -name HyperionConfig.h.in | grep -m1 "hyperion/") ]] && directory_compile=$(find $HOME -name "hyperiond" | grep /build/bin/hyperiond | sed 's/build\/bin\/hyperiond//') && [[ -d $directory_compile ]] && cd $directory_compile &&  [ $(basename `git rev-parse --show-toplevel`) = "hyperion" ] && found_compile=1
	cd $directory_last >/dev/null 2>/dev/null
# Stop hyperion service if it is running
	sudo systemctl -q stop hyperion@.service 2>/dev/null
	sudo systemctl -q stop hyperiond@pi.service 2>/dev/null
	echo
	echo
	echo
	echo
fi


if [ $OS = "LibreELEC" ]; then
	echo $yellow'We are on LibreELEC'
# Stop hyperion service if it is running
	systemctl -q stop hyperion.service >/dev/null 2>/dev/null
	systemctl -q stop hyperiond@pi.service >/dev/null 2>/dev/null
fi


# Find out if we are on an Raspberry Pi or x86_64
CPU_RPI=`grep -m1 -c 'BCM2708\|BCM2709\|BCM2710\|BCM2835\|BCM2836\|BCM2837\|BCM2711' /proc/cpuinfo`
# Check that
if [ $CPU_RPI -ne 1 ]; then
	echo $red' ---> Critical Error: We are not on an Raspberry Pi -> abort'
	exit 1
fi


#Installation for Raspbian/HyperBian
if [ $OS = "Raspbian" ] || [ $OS = "HyperBian" ] && [ $found_compile -eq 1 ]; then
	echo $yellow 'It looks like you compiled hyperion via CompileHowTo.md'
	echo $yellow 'Is that correct? Yes or No and press enter'
	echo
	read -p '>>> ' yes_no
	echo
	echo
	echo
	case $yes_no in
		(Yes | yes)
			while [ $directory_compile_test -ge 1 ]
			do
				echo
				echo
				echo $yellow'Is this the correct directory?' ${directory_compile:-"No directory found. Type in manually."}
				echo 'Type yes if it is correct. Otherwise type in the correct path or type abort to abort. '
				read -p '>>> ' yes_no
                                yes_no=${yes_no:-abort} 
				[[ ${yes_no,,} == "yes" ]] && break
				[[ ${yes_no,,:-abort} == "abort" ]] && echo $red'you aborted' && exit 0
				directory_compile=$yes_no
                                [[ $directory_compile != "/"* ]] && directory_compile=/"${directory_compile}"
				[ -e $directory_compile ]
				directory_compile_test=$?
				[[ $directory_compile_test -ge "1" ]] && echo && echo && echo && echo $red'directory not existent'
			done
			echo
			echo
			echo
			echo $green'Input accepted! '$directory_compile
			echo
			echo
			echo
#			echo $green'Compiling the newest Version.'
			echo
			echo
			inst_compile
			jump=66
			$(exit 0)
			;;

		*)
			echo ''
			;;
	esac

fi

$(exit 1)

#Check if RaspBian and installation method and ARM
if [ $OS = "Raspbian" ] || [ $OS = "HyperBian" ] && [ $jump -eq 0 ]; then
					if [ $arch_x -eq 7 ]; then
						version_deb=$(echo $rel_latest | cut -d "/" -f 9)
						echo
						echo $yellow'Updating with package ' "$version_deb"
						echo
						inst_deb
						echo
						$(exit 0)
					elif [ $arch_x -eq 6 ]; then
						version_deb=$(echo $rel_latest_armv6l | cut -d "/" -f 9)
						echo
						echo $yellow'Updating with package ' "$version_deb"
						echo
						inst_deb_armv6l
						$(exit 0)
					fi

#Installation LibreELEC
elif [ $OS = "LibreELEC" ]; then
		echo
		rm -R /storage/hyperion; wget -qO- https://git.io/JU4Zx | bash && echo $green'Your update process is complete!'; $(exit 0)
fi

if [ $? -eq 1 ]; then
	echo $red'Something went wrong installation incomplete'
	exit 1
echo
echo 
echo $green'********** Please reboot when this skript has exited **********'
echo
echo
echo 


#Exit or File creation
# else
# 		echo
# 		echo
# 		echo $green'********** Please reboot when this skript has exited **********'
# 		echo
# 		echo
# 		echo
# 		echo $yellow'I can create the files needed for a background process. I will place them in' "$HOME"'. You have to copy them into the systemd folder yourself. I will tell you the destination, when writing the files'
# 		echo $yellow'Type Yes if you want them created'
# 		echo
# 		read -p '>>>' yes_no
# 		case $yes_no in
# 			Yes | yes )
# 				;;
# 				*)
# 				echo
# 				echo
# 				echo $green'No files created. Your are all set. Thank you for using my script!'
# 				echo
# 				echo
# 				echo
# 				echo
# 				exit 0
# 			esac
# fi
# 
# echo
# echo $yellow'The files will be created in current directory. You have to copy files into:'
# echo
# 
# if [ $OS = "Raspbian" ] || [ $OS = "HyperBian" ]; then
# #Service files for RaspBian/HyperBian
# 		echo $green'hyperiond@pi.service ---> /etc/systemd/system/multi-user.target.wants/'
# 		echo $green'hyperiond@.service -----> /etc/systemd/system/'
# 		SERVICE_CONTENT_MULTI="[Unit]
# Description=Hyperion ambient light systemd service  for user %i
# After=network.target
# 
# [Service]
# ExecStart=/usr/bin/hyperiond
# WorkingDirectory=/usr/share/hyperion/bin
# User=%i
# TimeoutStopSec=5
# KillMode=mixed
# Restart=on-failure
# RestartSec=2
# 
# [Install]
# WantedBy=multi-user.target"
# 		echo "$SERVICE_CONTENT_MULTI" > hyperion@pi.service
# 
# 		SERVICE_CONTENT="[Unit]
# Description=Hyperion ambient light systemd service  for user %i
# After=network.target
# 
# [Service]
# ExecStart=/usr/bin/hyperiond
# WorkingDirectory=/usr/share/hyperion/bin
# User=pi
# TimeoutStopSec=5
# KillMode=mixed
# Restart=on-failure
# RestartSec=2
# 
# [Install]
# WantedBy=multi-user.target"
# 		echo "$SERVICE_CONTENT" > hyperion@.service
# 		echo
# 		sleep 1
# 		echo $green'Files created.'
# 		echo
# 		echo $green'*********You should activate autologin in raspi-config before copying the files*********'
# 		echo
# 		echo $green'You are all set. Thank you for using this script.'
# 		echo
# 		echo
# 		echo
# 		exit 0
# 
# elif [ $OS = "LibreELEC" ]; then
# 		echo $green'hyperion.service ----- >/storage/.config/system.d/'
# # Service file for LibreELEC
# 		SERVICE_CONTENT="[Unit]
# Description=Hyperion ambient light systemd service
# After=network.target
# [Service]
# Environment=DISPLAY=:0.0
# ExecStart=/storage/hyperion/bin/hyperiond --userdata /storage/hyperion/
# TimeoutStopSec=2
# Restart=always
# RestartSec=10
# 
# [Install]
# WantedBy=default.target"
# 		echo "$SERVICE_CONTENT" > hyperion.service
# 		echo
# 		echo $green'File created'
# 		echo
# 		echo $green'You are all set. Thank you for using this script.'
# 		echo
# 		echo
# 		echo
# 		exit 0
# 
# else
# 		echo $red'Unsupported OS. No files created. Quitting!'
# 		echo
# 		echo
# 		exit 1
# fi
