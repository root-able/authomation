#!/bin/bash

###########################################################
### Author: 	:	PAB				###
### Version	: 	2				###
### Date	:	27/11/2018			###
### Description	:	Post-process Transmission files	###
###########################################################

########################
## DEFINING VARIABLES ##
########################

# Gathering input file details using Transmission environment variables
INPUT_FILE_PATH="$TR_TORRENT_DIR/$TR_TORRENT_NAME"
INPUT_FILE_NAME="$TR_TORRENT_NAME"
INPUT_FILE_LABEL="N/A"

# Defining folder paths
OUTPUT_FOLDER_SERIES="/mnt/Media/Telechargements/Files_Parsed"
OUTPUT_FOLDER_MOVIES="/mnt/Media/Films"
OUTPUT_FOLDER_MUSIC="/mnt/Media/Audio/Musique"
OUTPUT_FOLDER_UNSORTED="/mnt/Media/Telechargements/Files_Parsing"

# Defining file paths
OUTPUT_FILE_LOG="/opt/scripts/var/log/filebot.log"
OUTPUT_FILE_LIST="/opt/scripts/var/lib/post_processed_files.txt"

#######################
### RUNNING FILEBOT ###
#######################

# Logging action
echo "$(date) - transmission_postprocessing - INFO - Processing file matching arguments file_path=\"$INPUT_FILE_NAME\", file_name=\"$INPUT_FILE_PATH\" and file_label=\"$INPUT_FILE_LABEL\"" >> $OUTPUT_FILE_LOG

# If script is manually executed, try to catch input parameter containing file path
if [[ -z $INPUT_FILE_NAME ]]
then
	if [[ -f $1 ]]
	then
		INPUT_FILE_PATH="$1"
		INPUT_FILE_NAME="$(basename "$1")"
	else
		echo "$(date) - transmission_postprocessing - ERROR - No arguments were found to be parsed while processing files" >> $OUTPUT_FILE_LOG
		exit -1
	fi
fi

# Set up a workaround for java heap out of memory error
export JAVA_OPTS="-Xmx256m"

# Actually runs Filebot
filebot -r -script fn:amc -non-strict -unixfs -no-xattr -get-subtitles --action hardlink --conflict index --log fine --lang fr --encoding UTF-8 --log-file "$OUTPUT_FILE_LOG" --def unsorted=y music=y artwork=y excludeList="$OUTPUT_FILE_LIST" ut_dir="$INPUT_FILE_PATH" ut_kind="multi" ut_title="$INPUT_FILE_NAME" ut_label="$INPUT_FILE_LABEL" "seriesFormat=$OUTPUT_FOLDER_SERIES/{n}/{'Season '+s}/{fn}" "animeFormat=$OUTPUT_FOLDER_MOVIES/{n}/{fn}" "movieFormat=$OUTPUT_FOLDER_MOVIES/{n} ({y})/{fn}" "musicFormat=$OUTPUT_FOLDER_MUSIC/{n}/{album+'/'}{pi.pad(2)+'. '}{artist} - {t}" "unsortedFormat=$OUTPUT_FOLDER_UNSORTED/{fn}.{ext}"

# Exiting upon success
exit 0
