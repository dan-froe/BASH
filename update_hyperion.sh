#!/usr/bin/env bash

# Script for updating Hyperion.NG on
# Raspbian/HyperBian/LibreELEC

clear

# Fixed variables
#api_url="https://api.github.com/repos/hyperion-project/hyperion.ng"
type wget > /dev/null 2> /dev/null
hasWget=$?
type curl > /dev/null 2> /dev/null
hasCurl=$?
rel_latest=$(curl https://api.github.com/repos/hyperion-project/hyperion.ng/releases 2>&1 | grep "browser_download_url.*Hyperion-.*armv7l.deb" | head -n1 | cut -d ":" -f 2,3 | tr -d \")
rel_latest_armv6l=$(curl https://api.github.com/repos/hyperion-project/hyperion.ng/releases 2>&1 | grep "browser_download_url.*Hyperion-.*armv6l.deb" | head -n1 | cut -d ":" -f 2,3 | tr -d \")

if [[ "${hasWget}" -ne 0 ]]; [[ "${hasCurl}" -ne 0 ]]; then
	echo $'\033[0;31m ---> Critical Error: wget or curl required'
	exit 1
fi

#Function Table
function inst_compile() {
	cd ~/hyperion/build/ && sudo make uninstall; sudo git pull https://github.com/hyperion-project/hyperion.ng.git master &&
	sudo cmake -DCMAKE_BUILD_TYPE=Release .. && sudo make -j $(nproc) && sudo make install/strip
}

function inst_deb() {
		sudo sudo apt update; sudo apt remove hyperion -y; curl https://api.github.com/repos/hyperion-project/hyperion.ng/releases 2>&1 | grep "browser_download_url.*Hyperion-.*armv7l.deb" | head -n1 | cut -d ":" -f 2,3 | tr -d \";
		sudo apt-get install $rel_latest
}

function inst_deb_armv6l() {
		sudo sudo apt update; sudo apt remove hyperion; curl https://api.github.com/repos/hyperion-project/hyperion.ng/releases 2>&1 | grep "browser_download_url.*Hyperion-.*armv6l.deb" | head -n1 | cut -d ":" -f 2,3 | tr -d \";
		sudo apt-get install $rel_latest_armv6l
}


# Set welcome message
echo '***************************************************************************'
echo 'This script will update Hyperion.ng for Raspbian/HyperBian/LibreELEC'
echo 'Created by Daniel Froebe.'
echo '***************************************************************************'

# Find out which system we are on
OS_RASPBIAN=`grep -m1 -c 'Raspbian\|RetroPie' /etc/issue` # /home/pi
OS_HYPERBIAN=`grep ID /etc/os-release | grep -m1 -c HyperBian` # /home/pi
OS_RASPLEX=`grep -m1 -c RasPlex /etc/issue` # /storage/
OS_OSMC=`grep -m1 -c OSMC /etc/issue` # /home/osmc
OS_LIBREELEC=`grep -m1 -c LibreELEC /etc/issue` # /storage/
OS_LAKKA=`grep -m1 -c Lakka /etc/issue` # /storage

# Check that
if [ $OS_RASPBIAN -ne 1 ] && [ $OS_HYPERBIAN -ne 1 ] && [ $OS_RASPLEX -ne 1 ] && [ $OS_LIBREELEC -ne 1 ] && [ $OS_OSMC -ne 1 ] && [ $OS_LAKKA -ne 1 ]; then
	echo $'\033[0;31m ---> Critical Error: We are not on Raspbian/HyperBian/RasPlex/OSMC/RetroPie/LibreELEC/Lakka -> abort'
	exit 1
fi

if [ $OS_RASPBIAN -eq 1 ] || [ $OS_HYPERBIAN -eq 1 ]; then
	echo 'We are on Raspbina/HyperBian'
  OS=$(lsb_release -i | cut -d : -f 2)
	found_compile=1
	cd ~ >/dev/null 2>/dev/null
	sudo find */.git -name config -exec cat {} + | grep hyperion-project/hyperion.ng.git >/dev/null && found_compile=0
	cd - >/dev/null 2>/dev/null
# Stop hyperion service if it is running
	sudo systemctl -q stop hyperion@.service 2>/dev/null
	sudo systemctl -q stop hyperiond@pi.service 2>/dev/null
	echo
	echo
	echo
	echo
	actual_os=1
fi

#if [ $OS_RASPLEX -eq 1 ]; then
#	echo 'We are on RASPLEX'
#	exit 0
#fi

if [ $OS_LIBREELEC -eq 1 ]; then
	echo 'We are on LibreELEC'
	OS=$(lsb_release -i | cut -d : -f 2)
# Stop hyperion service if it is running
	systemctl -q stop hyperion.service >/dev/null 2>/dev/null
	systemctl -q stop hyperiond@pi.service >/dev/null 2>/dev/null
	actual_os=2
fi

#if [ $OS_OSMC -eq 1 ]; then
#	echo 'We are on OSMC'
#	exit 0
#fi

#if [ $OS_LAKKA -eq 1 ]; then
#	echo 'We are on LAKKA'
#	exit 0
#fi

# Find out if we are on an Raspberry Pi or x86_64
CPU_RPI=`grep -m1 -c 'BCM2708\|BCM2709\|BCM2710\|BCM2835\|BCM2836\|BCM2837\|BCM2711' /proc/cpuinfo`
CPU_x86_64=`grep -m1 -c 'Intel\|AMD' /proc/cpuinfo`
# Check that
#if [ $CPU_RPI -ne 1 ] && [ $CPU_x86_64 -ne 1 ]; then
if [ $CPU_RPI -ne 1 ]; then
	echo $'\033[0;31m ---> Critical Error: We are not on an Raspberry Pi -> abort'
	exit 1
fi

# Check if RPi or x86_64
RPI_1_2_3_4=`grep -m1 -c 'BCM2708\|BCM2709\|BCM2710\|BCM2835\|BCM2836\|BCM2837\|BCM2711' /proc/cpuinfo`
#Intel_AMD=`grep -m1 -c 'Intel\|AMD' /proc/cpuinfo`

# Select the architecture
if [ $RPI_1_2_3_4 -eq 1 ]; then
	arch_x=$(uname -m | tr -d 'armvl')
#	arch_new="armv6l"
#elif [ $Intel_AMD -eq 1 ]; then
#	arch_old="windows"
#	arch_new="x68_64"
else
	echo $'\033[0;31m ---> Critical Error: Target platform unknown -> abort'
	exit 1
fi

#Installation for Raspbian/HyperBian
jump=0
if [ $actual_os -eq 1 ] && [ $found_compile -eq 0 ]; then
	echo $'\033[1;33m It looks like you compiled hyperion via CompileHowTo.md'
	echo $'\033[1;33m Is that correct? Yes or No and press enter'
	echo
	read -p '>>>' yes_no
	echo
	echo
	echo
	case $yes_no in
		(Yes | yes)
			echo $'\033[0;32m Updating Hyperion by compiling'
#			inst_compile
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
if [ $OS = "Raspbian" ] && [ $jump -eq 0 ]; then
#	if [ $(lsb_release -i | cut -d : -f 2) = "Raspbian" ]; then
#			echo $'\033[1;33m Did you install via .deb package?'
#			echo $'\033[1;33m Type Yes or No and press enter'
#			read -p '>>>' yes_no
#			case $yes_no in
#				(Yes | yes)
					if [ $arch_x -eq 7 ]; then
						version_deb=$(echo $rel_latest | cut -d "/" -f 9)
						echo
						echo $'\033[1;33m Updating with package ' "$version_deb"
						echo
#						inst_deb && sudo apt -f install && echo && echo $'\033[0;32m You are up to date!'
						echo
						$(exit 0)
					elif [ $arch_x -eq 6 ]; then
						version_deb=$(echo $rel_latest_armv6l | cut -d "/" -f 9)
						echo
						echo $'\033[1;33m Updating with package ' "$version_deb"
						echo
#						inst_deb_armv6l && && sudo apt -f install && echo && echo $'\033[0;32m You are up to date!'
						$(exit 0)
					fi
#					;;
#					*)
#					echo 'I can not help you'
#					exit 1
#					;;
#				esac
#Check if HyperBian and ARM
elif [ $OS = "HyperBian" ]; then
		if [ $arch_x -eq 7 ]; then
			version_deb=$(echo $rel_latest | cut -d "/" -f 9)
			echo
			echo $'\033[1;33m Updating with package ' "$version_deb"
			echo
#						inst_deb && sudo apt -f install && echo && echo 'You are up to date!'
			echo
			$(exit 0)
		elif [ $arch_x -eq 6 ]; then
			version_deb=$(echo $rel_latest_armv6l | cut -d "/" -f 9)
			echo
			echo $'\033[1;33m Updating with package ' "$version_deb"
			echo
#						inst_deb_armv6l && sudo apt -f install && echo && echo 'You are up to date!'
			$(exit 0)
		fi
	fi

#Installation LibreELEC
if [ $OS = "LibreELEC" ]; then
		echo
#		rm -R /storage/hyperion; wget -qO- https://git.io/JU4Zx | bash && echo $'\033[0;32m Your update process is complete!'; $(exit 0)
fi

if [ $? -eq 1 ]; then
	echo $'\033[0;31m Something went wrong installation incomplete'
	exit 1

#Exit or File creation
else
		echo
		echo
		echo $'\033[0;31m ********** Please reboot when this skript has exited **********'
		echo
		echo
		echo
		var_pwd=$(pwd)
		echo $'\033[1;33mI can create the files needed for a background process. I will only place them in' "$var_pwd"'. You have to copy them into the systemd folder yourself. I will tell you the destination, when writing the files'
		echo $'\033[1;33m Type Yes if you want them created'
		echo
		read -p '>>>' yes_no
		case $yes_no in
			Yes | yes )
				;;
				*)
				echo
				echo
				echo $'\033[0;32m No files created. Your are all set. Thank you for using my script!'
				echo
				echo
				echo
				echo
				exit 0
			esac
fi

echo
echo $'\033[1;33m The files will be created in current directory. You have to copy files into:'
echo
if [ $actual_os -eq 1 ]; then
#Service files for RaspBian/HyperBian
		echo $'\033[1;33m hyperiond@pi.service ---> /etc/systemd/system/multi-user.target.wants/'
		echo $'\033[1;33m hyperiond@.service -----> /etc/systemd/system/'
		SERVICE_CONTENT_MULTI="[Unit]
Description=Hyperion ambient light systemd service  for user %i
After=network.target

[Service]
ExecStart=/usr/bin/hyperiond
WorkingDirectory=/usr/share/hyperion/bin
User=%i
TimeoutStopSec=5
KillMode=mixed
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target"
		echo "$SERVICE_CONTENT_MULTI" > hyperion@pi.service

		SERVICE_CONTENT="[Unit]
Description=Hyperion ambient light systemd service  for user %i
After=network.target

[Service]
ExecStart=/usr/bin/hyperiond
WorkingDirectory=/usr/share/hyperion/bin
User=pi
TimeoutStopSec=5
KillMode=mixed
Restart=on-failure
RestartSec=2

[Install]
WantedBy=multi-user.target"
		echo "$SERVICE_CONTENT" > hyperion@.service
		echo
		sleep 1
		echo $'\033[0;32m Files created.'
		echo
		echo $'\033[1;33m *********You should activate autologin in raspi-config before copying the files*********'
		echo
		echo $'\033[0;32m You are all set. Thank you for using this script.'
		echo
		echo
		echo
		exit 0

elif [ $actual_os -eq 2 ]; then
		echo $'\033[1;33m hyperion.service ----- >/storage/.config/system.d/'
# Service file for LibreELEC
		SERVICE_CONTENT="[Unit]
Description=Hyperion ambient light systemd service
After=network.target
[Service]
Environment=DISPLAY=:0.0
ExecStart=/storage/hyperion/bin/hyperiond --userdata /storage/hyperion/
TimeoutStopSec=2
Restart=always
RestartSec=10

[Install]
WantedBy=default.target"
		echo "$SERVICE_CONTENT" > hyperion.service
		echo
		echo $'\033[0;32m File created'
		echo
		echo $'\033[0;32m You are all set. Thank you for using this script.'
		echo
		echo
		echo
		exit 0

else
		echo $'\033[0;31m Unsupported OS. No files created. Quitting!'
		echo
		echo
		exit 1
fi
