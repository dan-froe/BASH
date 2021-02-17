#!/usr/bin/env bash

# Script for downloading a specific open Pull Request Artifact from Hyperion.NG on
# Raspbian/HyperBian/RasPlex/OSMC/RetroPie/LibreELEC/Lakka

clear

# Fixed variables
api_url="https://api.github.com/repos/hyperion-project/hyperion.ng"
type wget > /dev/null 2> /dev/null
hasWget=$?
type curl > /dev/null 2> /dev/null
hasCurl=$?
rel_latest=$(curl https://api.github.com/repos/hyperion-project/hyperion.ng/releases 2>&1 | grep "browser_download_url.*Hyperion-.*armv7l.deb" | head -n1 | cut -d ":" -f 2,3 | tr -d \")
rel_latest_armv6l=$(curl https://api.github.com/repos/hyperion-project/hyperion.ng/releases 2>&1 | grep "browser_download_url.*Hyperion-.*armv6l.deb" | head -n1 | cut -d ":" -f 2,3 | tr -d \")

# Stop hyperion service if it is running
sudo systemctl -q stop hyperion.service >/dev/null 2>/dev/null
sudo systemctl -q stop hyperiond@pi.service >/dev/null 2>/dev/null
sudo systemctl -q stop hyperion.service 2>/dev/null
sudo systemctl -q stop hyperiond@pi.service 2>/dev/null

if [[ "${hasWget}" -ne 0 ]] && [[ "${hasCurl}" -ne 0 ]]; then
	echo '---> Critical Error: wget or curl required to download pull request artifacts'
	exit 1
fi

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

#function request_call() {
#	if [ $hasWget -eq 0 ]; then
#		echo $(wget --quiet --header="Authorization: token ${pr_token}" -O - $1)
#	elif [ $hasCurl -eq 0 ]; then
#		echo $(curl -skH "Authorization: token ${pr_token}" $1)
#	fi
#}

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
	echo '---> Critical Error: We are not on Raspbian/HyperBian/RasPlex/OSMC/RetroPie/LibreELEC/Lakka -> abort'
	exit 1
fi

if [ $OS_RASPBIAN -eq 1 ] || [ $OS_HYPERBIAN -eq 1 ]; then
	echo 'We are on Raspbina/HyperBian'
	actual_os=1
fi

#if [ $OS_RASPLEX -eq 1 ]; then
#	echo 'We are on RASPLEX'
#	exit 0
#fi

if [ $OS_LIBREELEC -eq 1 ]; then
	echo 'We are on LibreELEC'
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
if [ $CPU_RPI -ne 1 ] && [ $CPU_x86_64 -ne 1 ]; then
	echo '---> Critical Error: We are not on an Raspberry Pi or an x86_64 CPU -> abort'
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
	arch_old="windows"
	arch_new="x68_64"
else
	echo "---> Critical Error: Target platform unknown -> abort"
	exit 1
fi

#Installation for Raspbian/HyperBian
if [ $actual_os -eq 1 ] && [ -d ~/hyperion/ ]; then
	echo 'Did you compile Hyperion on Raspbian?'
	echo 'Type Yes or No and press enter'
	read yes_no
	case $yes_no in
		(Yes | yes)
			echo 'Updating Hyperion by compiling'
#			inst_compile
			$(exit 0)
			continue
			;;

		*)
			echo ''
			;;
	esac
fi
#Check if RaspBian and installation method and ARM
if [ $actual_os -eq 1 ]; then
	if [ $(lsb_release -i | cut -d : -f 2) = "Raspbian" ]; then
			echo 'Did you install via .deb package?'
			echo 'Type Yes or No and press enter'
			read yes_no
			case $yes_no in
				(Yes | yes)
					if [ $arch_x -eq 7 ]; then
						version_deb=$(echo $rel_latest | cut -d "/" -f 9)
						echo
						echo Updating with package $version_deb
						echo
#						inst_deb && sudo apt -f install && echo && echo 'You are up to date!'
						echo
						$(exit 0)
					elif [ $arch_x -eq 6 ]; then
						version_deb=$(echo $rel_latest_armv6l | cut -d "/" -f 9)
						echo
						echo Updating with package $version_deb
						echo
#						inst_deb_armv6l && && sudo apt -f install && echo && echo 'You are up to date!'
						$(exit 0)
					fi
					;;
					*)
					echo 'I can not help you'
					exit 1
					;;
				esac
#Check if HyperBian and ARM
	elif [ $(lsb_release -i | cut -d : -f 2) = "HyperBian" ]; then
		if [ $arch_x -eq 7 ]; then
			version_deb=$(echo $rel_latest | cut -d "/" -f 9)
			echo
			echo Updating HyperBian with package $version_deb
			echo
#						inst_deb && sudo apt -f install && echo && echo 'You are up to date!'
			echo
			$(exit 0)
		elif [ $arch_x -eq 6 ]; then
			version_deb=$(echo $rel_latest_armv6l | cut -d "/" -f 9)
			echo
			echo Updating HyperBian with package $version_deb
			echo
#						inst_deb_armv6l && sudo apt -f install && echo && echo 'You are up to date!'
			$(exit 0)
		fi
	fi
fi

#Installation LibreELEC
if [ $(lsb_release -i | cut -d : -f 2) = "LibreELEC"]; then
#	rm -R /storage/hyperion; wget -qO- https://git.io/JU4Zx | bash && $(exit 0)
		if [ $? -eq 0 ]; then
			echo 'Your update process is complete!'; $(exit 0)
		else
			echo 'Something went wrong installation incomplete'
			exit 1
		fi
fi

#Exit or File creation
if [ $? -eq 0 ]; then
	echo
	echo 'Please reboot when this skript has exited'
	echo
	echo 'I can create the files needed for a backgound process for you'
	echo 'Type Yes if you want them created'
	read yes_no
	case $yes_no in
		Yes | yes )
			;;
		*)
		echo 'No files created. Your are all set. Thank you for using my script!'
		exit 0
	esac
fi

echo
echo 'These files will be created in current directory. You have to copy files into:'
echo
if [ $actual_os -eq 1 ]; then
#Service files for RaspBian/HyperBian
		echo 'hyperiond@pi.service ---> /etc/systemd/system/multi-user.target.wants/'
		echo 'hyperiond@.service -----> /etc/systemd/system/'
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
		echo 'Files created.'
		echo
		echo 'You should activate autologin in raspi-config before copying the files'
		echo
		echo 'You are all set. Thank you for using this script.'
		exit 0

elif [ $actual_os -eq 2 ]; then
		echo 'hyperion.service ----- >/storage/.config/system.d/'
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
		echo 'File created'
		echo 'You are all set. Thank you for using this script.'
		exit 0

else
		echo 'Unsupported OS. No files created. Quitting!'; exit 1
fi
