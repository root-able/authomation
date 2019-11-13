#!/bin/bash

##########################
### DEFINING VARIABLES ###
##########################

SHARE_LIST="/root/rsync_backup/rsync_shares.txt"
SHARE_PATH="/mnt"
CREDS_PATH="/root/rsync_backup/smb_credentials.txt"
HDD_PATH="/media/pi/e3029fc5-7f70-4a71-bbeb-c963f8744961"
BACKUP_PATH="$HDD_PATH/Rsync_Backups"
API_URL=$(head -n 1 /root/rsync_backup/rsync_api.txt)

##########################
### DEFINING FUNCTIONS ###
##########################

# Function used to log informations
log_result () {
	/bin/echo $(date '+%Y-%m-%d %H:%M:%S') - $0 - $1 - $2
	}
# Function used to check whether a folder is mounted or not
mount_check () {

	# Defining variables and collecting input
	retry_counter=1
	retry_limit=$1
	retry_sleep=$2
	folder_path=$3

	# Waiting for share folder to be available
	while [ $retry_counter -le $retry_limit ] && [ $(mount -l | grep $folder_path | wc -l) -ne 1 ] 
	do
		# Logging result
		log_result "INFO" "Trying to reach share_path=\"$folder_path\", attempt retry_counter=\"$retry_counter\" out of retry_limit=\"$retry_limit\""
		
		# Sleeping for specified duration
		/bin/sleep $retry_sleep

		# Iterating attempts counter
		((retry_counter++))
	done	

	# If loop exited with a retry number greater than the limit, finding folder failed
	if [ $retry_counter -gt $retry_limit ]
	then
		# Logging result and exiting
		log_result "ERROR" "Failed trying to reach share_path=\"$folder_path\" after reaching retry_limit=\"$retry_counter\" attempts, return_value=\"-1\""
		exit -1
	else
		# Logging result
		log_result "INFO" "Successfully found share_path=\"$folder_path\" at attempt retry_counter=\"$retry_counter\", return_value=\"0\""
	fi

}

# Function used to check whether a folder is umounted or not
umount_check () {

	# Defining variables and collecting input
	retry_counter=1
	retry_limit=$1
	retry_sleep=$2
	folder_path=$3

	# Waiting for share folder to become unavailable
	while [ $retry_counter -le $retry_limit ] && [ $(mount -l | grep $folder_path | wc -l) -ne 0 ] 
	do
		# Logging result
		log_result "INFO" "Trying to reach share_path=\"$folder_path\", attempt retry_counter=\"$retry_counter\" out of retry_limit=\"$retry_limit\""
		
		# Sleeping for specified duration
		sleep $retry_sleep

		# Iterating attempts counter
		((retry_counter++))
	done	

	# If loop exited with a retry number greater than the limit, folder unmount failed
	if [ $retry_counter -gt $retry_limit ]
	then
		# Logging result and exiting
		log_result "ERROR" "Target share_path=\"$folder_path\" is still mounted after reaching retry_limit=\"$retry_counter\" attempts, return_value=\"-1\""
		exit -1
	else
		# Logging result
		log_result "INFO" "Target share_path=\"$folder_path\" successfully umounted after attempt retry_counter=\"$retry_counter\", return_value=\"0\""
	fi

}

# This function is used to perform a backup of a given share
backup_share () {

	# Gathering arguments
	share_list=$1
	share_path=$2
	backup_path=$3

	# Iterating over shares to backup
	for share in $(cat $share_list)
	do
		# Getting share name and folder name
		share_name=$(echo $share | cut -d '/' -f 4)
		share_folder=$share_path"/"$share_name
	
		# Ensuring target folder exists
		mkdir $share_folder

		# Mounting remote samba share
		/sbin/mount.cifs $share $share_folder -o vers=2.0,credentials=$CREDS_PATH

		# Checking whether destination folder was mounted
		mount_check 3 1 $share_folder

		# Logging information of progress
		log_result "INFO" "Currently Backuping share_name=\"$share_name\", to backup_path=\"$backup_path\" out of share_count=\"$(echo $share | cut -d '/' -f 4 | wc -l)\""
	
		# Performing actual backup
		rsync_result=$(/usr/bin/rsync -auv --numeric-ids --delete --backup --exclude '#recycle' --backup-dir=$backup_path"/archives/$(date +%Y-%m-%d)" $share_folder $backup_path 2>&1)

		# Checking whether rsync was successfull
		rsync_status=$?
		if [ $rsync_status -ne 0 ]
		then
			# If an error occure, logging information without exiting
			log_result "ERROR" "Something went wrong when performing rsync command, terminated with return_code=$rsync_status. More logs below"
			echo $rsync_result
		else
			# Else, logging success
			log_result "INFO" "Successfully backed up share_name=\"$share_name\", into backup_path=\"$backup_path\""
		fi

		# Unmounting network share
		/bin/umount $share_folder

		# Checking network share unmount
		umount_check 3 1 $share_folder
	done
}

############
### MAIN ###
############

# Powering up external HDD tray through Jeedom API call
/usr/bin/curl -s $API_URL"1374"

# Checking whether external HDD was sucessfully mounted
mount_check 5 10 $HDD_PATH

# Performing actual backup
backup_share $SHARE_LIST $SHARE_PATH $BACKUP_PATH

# Unmounting esternal HDD
/bin/umount $HDD_PATH

# Checking external HDD unmount
umount_check 5 2 $HDD_PATH

# Powering off external HDD tray through Jeedom API call
/usr/bin/curl -s $API_URL"1373"
