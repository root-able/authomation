#!/bin/bash

###########################################################
### Author: 	:	PAB				###
### Version	: 	1.0				###
### Date	:	17/11/2019			###
### Description	:	Clean Transmission Torrents	###
###########################################################


########################
## DEFINING VARIABLES ##
########################

# Defining folder and files path
CONF_DIR="/opt/scripts/etc/transmission_cleaner"
CONF_FILE_TORRENT="$CONF_DIR/private_torrents.txt"
CONF_FILE_AUTH="$CONF_DIR/auth.txt"

LOG_FILE="/opt/scripts/var/log/transmission_cleaner.log"
TMISSION_BIN="/usr/bin/transmission-remote"

# Gathering authentication information from separate file
TMISSION_AUTH=$(cat $CONF_FILE_AUTH)

# Defining remote auth IP and port
TMISSION_LINK="localhost:9091"


##########################
### DEFINING FUNCTIONS ###
##########################
log_result () {
	/bin/echo $(date '+%Y-%m-%d %H:%M:%S') - $0 - $1 - $2 >> $LOG_FILE
	}


############################
### RUNNING TRANSMISSION ###
############################

# Manipulating IFS to handle results line per line
OLDIFS=$IFS
IFS=$'\n'

# Getting a list of all torrent ids from Transmission
torrent_id_list=$($TMISSION_BIN $TMISSION_LINK --auth $TMISSION_AUTH --list | awk '{print $1;}' | grep -oE '[0-9]+')

# Iterating over each torrent from list
for torrent_id in $torrent_id_list
do
	# Gathering name from torrent
	torrent_name=$($TMISSION_BIN $TMISSION_LINK --auth $TMISSION_AUTH -t $torrent_id -i | grep 'Name:' | cut -d : -f '2' | sed -r 's/[\%\s\t ]+//g')

	# Logging information
	log_result "INFO" "Processing torrent with torrent_id=\"$torrent_id\", and torrent_name=\"$torrent_name\""

	# Gathering information on trackers
	torrent_tracker=$($TMISSION_BIN $TMISSION_LINK --auth $TMISSION_AUTH -t $torrent_id -it | grep ygg | wc -l)

	# Determining whether the tracker is private or public
	if [[ $torrent_tracker -gt 0 ]]
	then
		# If tracker is private, nothing to do, since torrent should be kept in seeding state
		log_result "INFO" "Tracker for torrent_id=\"$torrent_id\" is torrent_tracker=\"private\""
	else
		# If tracker is public, it is eligible for suppression
		log_result "INFO" "Tracker for torrent_id=\"$torrent_id\" is torrent_tracker=\"public\""

		# Determining the state of torrent 
		torrent_state=$($TMISSION_BIN $TMISSION_LINK --auth $TMISSION_AUTH -t $torrent_id -i | grep -oP "Percent Done:\s+([0-9\.]+)%" | cut -d : -f '2' | sed -r 's/[\%\s\t ]+//g' | cut -d '.' -f 1)
		
		# Logging result
		log_result "INFO" "State for torrent_id=\"$torrent_id\" is torrent_state=\"$torrent_state\""

		# If torrent state is finished
		if [[ $torrent_state -eq 100 ]]
		then
			# Logging result
			log_result "INFO" "Removing torrent_id=\"$torrent_id\" upon completion"

			# Removing torrent and associated files
			$TMISSION_BIN $TMISSION_LINK --auth $TMISSION_AUTH -t $torrent_id --remove-and-delete 2>&1 >> /dev/null
		fi
	fi
done

# Restoring IFS
IFS=$OLDIFS

# Exiting upon success
exit 0
