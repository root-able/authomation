#!/bin/sh


##########################
### DEFINING FUNCTIONS ###
##########################

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
