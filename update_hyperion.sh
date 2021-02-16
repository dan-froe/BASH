!#/usr/bin/env bash

# Script for downloading a specific open Pull Request Artifact from Hyperion.NG on
# Raspbian/HyperBian/RasPlex/OSMC/RetroPie/LibreELEC/Lakka

# Fixed variables
api_url="https://api.github.com/repos/hyperion-project/hyperion.ng"
pr_token="a1ef79fcd73a28b893752e498296fb0d28d0f0e1"
type wget > /dev/null 2> /dev/null
hasWget=$?
type curl > /dev/null 2> /dev/null
hasCurl=$?

if [[ "${hasWget}" -ne 0 ]] && [[ "${hasCurl}" -ne 0 ]]; then
	echo '---> Critical Error: wget or curl required to download pull request artifacts'
	exit 1
fi

#function request_call() {
#	if [ $hasWget -eq 0 ]; then
#		echo $(wget --quiet --header="Authorization: token ${pr_token}" -O - $1)
#	elif [ $hasCurl -eq 0 ]; then
#		echo $(curl -skH "Authorization: token ${pr_token}" $1)
#	fi
#}

# Set welcome message
echo '*******************************************************************************'
echo 'This script will download a specific open Pull Request Artifact from Hyperion.NG'
echo 'Created by Paulchen-Panther - hyperion-project.org - the official Hyperion source.'
echo '*******************************************************************************'

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
	echo 'We are on Raspbina/HYperBIAN'
	exit 1
fi

if [ $OS_RASPBIAN -ne 1 ] && [ $OS_HYPERBIAN -ne 1 ] && [ $OS_RASPLEX -ne 1 ] && [ $OS_LIBREELEC -ne 1 ] && [ $OS_OSMC -ne 1 ] && [ $OS_LAKKA -ne 1 ]; then
	echo '---> Critical Error: We are not on Raspbian/HyperBian/RasPlex/OSMC/RetroPie/LibreELEC/Lakka -> abort'
	exit 1
fi

if [ $OS_RASPBIAN -ne 1 ] && [ $OS_HYPERBIAN -ne 1 ] && [ $OS_RASPLEX -ne 1 ] && [ $OS_LIBREELEC -ne 1 ] && [ $OS_OSMC -ne 1 ] && [ $OS_LAKKA -ne 1 ]; then
	echo '---> Critical Error: We are not on Raspbian/HyperBian/RasPlex/OSMC/RetroPie/LibreELEC/Lakka -> abort'
	exit 1
fi

if [ $OS_RASPBIAN -ne 1 ] && [ $OS_HYPERBIAN -ne 1 ] && [ $OS_RASPLEX -ne 1 ] && [ $OS_LIBREELEC -ne 1 ] && [ $OS_OSMC -ne 1 ] && [ $OS_LAKKA -ne 1 ]; then
	echo '---> Critical Error: We are not on Raspbian/HyperBian/RasPlex/OSMC/RetroPie/LibreELEC/Lakka -> abort'
	exit 1
fi

if [ $OS_RASPBIAN -ne 1 ] && [ $OS_HYPERBIAN -ne 1 ] && [ $OS_RASPLEX -ne 1 ] && [ $OS_LIBREELEC -ne 1 ] && [ $OS_OSMC -ne 1 ] && [ $OS_LAKKA -ne 1 ]; then
	echo '---> Critical Error: We are not on Raspbian/HyperBian/RasPlex/OSMC/RetroPie/LibreELEC/Lakka -> abort'
	exit 1
fi

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
Intel_AMD=`grep -m1 -c 'Intel\|AMD' /proc/cpuinfo`

# Select the architecture
if [ $RPI_1_2_3_4 -eq 1 ]; then
	arch_old="armv6hf"
	arch_new="armv6l"
elif [ $Intel_AMD -eq 1 ]; then
	arch_old="windows"
	arch_new="x68_64"
else
	echo "---> Critical Error: Target platform unknown -> abort"
	exit 1
fi
