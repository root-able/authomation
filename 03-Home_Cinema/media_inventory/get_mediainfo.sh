#!/bin/bash


### VARIABLES ###

SERIES_FOLDER_PATH="/mnt/Media/Series"
TEMPORARY_FOLDER_PATH="/opt/scripts/var/lib/mediainfo_output"
MEDIAINFO_FOLDER_PATH="/mnt/Logs/Scripts/TayBerry/get_mediainfo"
EXTENSION_FILTER=".*\.\(mkv\|mp4\|avi\|mpeg\|mpg\)"


### ARGUMENTS  ###

if [ -z $1 ]
then
	# If no input parameter is defined, using default series path
	TARGET_FOLDER_PATH=$SERIES_FOLDER_PATH

elif [ -d $1 ]
then
	# If input was specified and is a directory path, using it instead
	TARGET_FOLDER_PATH="$1"
else
	# If no condition was already validated, exiting with error
	exit -1
fi


### MAIN ###

# Setting IFS for processing
IFS=$'\n'

# Getting a list of all videao files from series folder path
for file_path in $(find $TARGET_FOLDER_PATH -iregex $EXTENSION_FILTER)
do
	# Parsing folder details
	folder_path=$(dirname $file_path)
	base_name=$(basename $file_path)
	
	# Parsing file details
	file_name=${base_name%.*}
	file_extension="${base_name##*.}"

	# Crafting output JSON path
	output_path="$TEMPORARY_FOLDER_PATH/$file_name.xml"
       
	# Getting detailed information on media file
	mediainfo --Full $file_path --Output=XML --LogFile=$output_path
done

# Moving newly generated reports into destination folder, overriding old ones
mv -f $TEMPORARY_FOLDER_PATH/*.xml $MEDIAINFO_FOLDER_PATH/
