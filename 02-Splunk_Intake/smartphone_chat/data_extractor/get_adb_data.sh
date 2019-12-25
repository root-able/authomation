#!/bin/sh


##########################
### PERFORMING IMPORTS ###
##########################

source "functions/log_message.sh"
source "functions/mount_point.sh"


##########################
### DEFINING VARIABLES ###
##########################

CURRENT_FOLDER="/home/pi/scripts"
ADB_EXE="/usr/bin/adb"
SHARE_FOLDER="/mnt/Logs"
SHARE=$(cat "$CURRENT_FOLDER/get_adb_share.txt")
CREDS_PATH="$CURRENT_FOLDER/smb_credentials.txt"
OUTPUT_EXT="adb"


##########################
### DEFINING FUNCTIONS ###
##########################

# This function is used to collect adb data from devices and store it in output files
collect_adb_data () {

	# Iterating over connected devices 
	for device in $($ADB_EXE devices -l | grep usb: | awk '{print $1}')
	do
		# Collecting adb details on current device
		adb_manufacturer=$($ADB_EXE -s $device shell getprop "ro.product.manufacturer" | sed -r 's/[\r\n]//g')
		adb_name=$($ADB_EXE -s $device shell getprop "ro.semc.product.name" | sed -r 's/[\r\n]//g')
		adb_device=$($ADB_EXE -s $device shell getprop "ro.product.name" | sed -r 's/[\r\n]//g')
	
		# Logging information
		log_result "INFO" "Currently processing device=\"$device\" from device_manufacturer=\"$adb_manufacturer\" with device_name=\"$adb_name\" an product_id=\"$adb_device\""
		# Defining output file details
		output_file_name="$adb_manufacturer - $adb_name ($adb_device)"
		output_file_path="$SHARE_FOLDER/$output_file_name.$OUTPUT_EXT"

		# Generating adb settings dump
		$ADB_EXE -s $device shell getprop >> "$output_file_path"
	done	
}

############
### MAIN ###
############

# Ensuring target folder exists
mkdir $SHARE_FOLDER 2>/dev/null

# Mounting remote samba share
/sbin/mount.cifs $SHARE $SHARE_FOLDER -o vers=2.0,credentials=$CREDS_PATH

# Checking whether destination folder was mounted
mount_check 3 1 $SHARE_FOLDER

# Actually collecting adb data
collect_adb_data $SHARE_FOLDER

# Unmounting network share
/bin/umount $SHARE_FOLDER

# Checking network share unmount
umount_check 3 1 $SHARE_FOLDER

# Exiting upon successful completion
exit 0
