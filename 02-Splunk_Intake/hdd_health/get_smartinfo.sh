#!/bin/bash

# Setting IFS to allow proper parsing of command outputs
IFS=$'\n'

# Defining output folder where outputs will be stored
OUTPUT_FOLDER="/mnt/Logs/Scripts/LoganBerry/get_smartctl/"
LOG_FILE="$OUTPUT_FOLDER/get_smartctl.log"

# Iterating over all SATA devices
for device in $(find /dev -regex "/dev/sd[a-z]")
do
	# Getting device serial number
	device_serial=$(/usr/local/sbin/smartctl -i $device | grep "Serial Number:" | awk '{print $3;}')

	# Logging info
	echo "$(date '+%Y-%m-%d %H:%M:%S%z') - $(basename $0) - Getting information from device_path=\"$device\" with serial_number=\"$device_serial\"" >> $LOG_FILE

	# Defining lsblk output file and filling it with command output
	lsblk_path="$OUTPUT_FOLDER""$device_serial""_lsblk.json"
	/bin/lsblk $device -O -J > $lsblk_path

	# Defining smartctl output file and filling it with command output
	smartctl_path="$OUTPUT_FOLDER""$device_serial""_smartctl.json"
	/usr/local/sbin/smartctl -a $device -j > $smartctl_path
done
