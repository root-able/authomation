#!/bin/bash

###########################################################
### Author:     :       PAB                             ###
### Version     :       1.0                             ###
### Date        :       27/12/2019                      ###
### Description :       Used to sort image by date      ###
###########################################################


########################
## DEFINING VARIABLES ##
########################

# Parsing arguments 
SOURCE_FOLDER="$1"
DEST_FOLDER="$2"
USER="$3"
GROUP="$4"

# Defining extension and path patterns
WHITELIST_PATH="$(echo $0 | sed -r 's/\/[^\/]+$//g')""/extensions_whitelist.txt"
EXT_WHITELIST='\.('"$(cat "$WHITELIST_PATH" | tr '\n' '|' | sed -r 's/\|$//g')"')$'
PATH_PATTERN='+%Y/%m - %B/Semaine %W'

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
file_count=0

# Processing each file found matching whitelist from input folder
for file in $(find "$SOURCE_FOLDER" -name '*' | grep -Ei "$EXT_WHITELIST");
do 
	# Iterating folder counter
	((file_count++))

	# Extracting file name and extension
	file_name=$(basename "$file")
	file_ext=$(echo "$file_name" | grep -oE '[^\.]+$')

	# Performing action only if input file is not a "mts" extension file
	if [[ $(echo $file_ext | grep -i mts | wc -l) -eq 0 ]]
	then
		# Extracting photo date from EXIF data in file
		file_date_picture=$(identify -format "%[EXIF:DateTimeOriginal]" $file | awk -F " " '{print $1}' | awk -F ":" '{print $1"-"$2"-"$3}')
	fi

	# Getting all dates from file metadata and retaining older one
	file_date_all=$(echo $file_date_picture && stat $file |  grep -oE "[0-9]{4}\-[0-9]{2}\-[0-9]{2}" | grep -v 1980)
	file_date_final=$(echo $file_date_all | tr ' ' '\n' | sort | grep -v '^1970' | head -n 1)

	# Defining output file name and path
	file_folder="$DEST_FOLDER""/"$(LC_ALL="fr_FR.utf8" date --date="$file_date_final" "$PATH_PATTERN")
	file_path="$file_folder""/""$file_name"

	# Creating destination path and actually moving file
	mkdir -p "$file_folder"
	mv -f "$file" "$file_path"

done

# Fixing permissions on output files
chmod -R "$DEST_PERM" "$DEST_FOLDER"
chown -R "$DEST_OWNER" "$DEST_FOLDER"

# Printing results of processing
echo "Processed file_count=\"$file_count\""

# Restoring old IFS
IFS=$OLDIFS

# Exiting upon sucdess
exit 0
