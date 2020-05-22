#!/bin/bash

###########################################################
### Author:     :       PAB                             ###
### Version     :       1.0                             ###
### Date        :       27/12/2019                      ###
### Description :       Used to extract images          ###
###########################################################


########################
## DEFINING VARIABLES ##
########################

# Parsing arguments
SOURCE_FOLDER_LIST="$1"
DEST_FOLDER="$2"
USER="$3"
GROUP="$4"

# Defining extension and path patterns
WHITELIST_PATH="$(echo $0 | sed -r 's/\/[^\/]+$//g')""/extensions_whitelist.txt"
EXT_WHITELIST='\.('"$(cat "$WHITELIST_PATH" | tr '\n' '|' | sed -r 's/\|$//g')"')$'

# Defining access mask and ownership for output files
DEST_PERM="700"
DEST_OWNER="$USER:$GROUP"


############
### MAIN ###
############

# Performing IFS modification in order to process items line by line
OLDIFS=$IFS
IFS=$'\n'

# Initializing counters
folder_count=0
file_count=0

# Processing each folder from input list
for folder in $(echo "$SOURCE_FOLDER_LIST" | tr ',' '\n')
do
	# Iterating folder counter
	((folder_count++))

	# Processing each file found matching whitelist from current folder
	for file in $(find "$folder" -type f | grep -Ei "$EXT_WHITELIST")
	do
		# Iterating file counter
		((file_count++))
			
		# Calculating file hash and extension
		file_hash=$(sha256sum "$file" | grep -oE '^[a-zA-Z0-9]+')
		file_ext=$(basename "$file" | grep -oE '[^\.]+$' | awk '{print tolower($0)}')
		
		# Moving file from source to destination
		mv -f "$file" "$DEST_FOLDER""/""$file_hash.$file_ext"
	done
done

# Fixing permissions on output files
chmod -R "$DEST_PERM" "$DEST_FOLDER"
chown -R "$DEST_OWNER" "$DEST_FOLDER"

# Printing results of processing
echo "Processed file_count=\"$file_count\" from folder_count=\"$folder_count\""

# Restoring old IFS
IFS=$OLDIFS

# Exiting upon sucdess
exit 0
