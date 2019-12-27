#!/bin/bash

SOURCE_FOLDER="/volume1/Cloudstation/Images - Index/Images - Index - Flat/"
DEST_FOLDER="/volume1/Cloudstation/Images - Index/Images - Index - Chrono/"
EXT_WHITELIST='\.(jpg|jpeg|gif|png|tif|webp)$'
PATH_PATTERN='+%Y/%m - %B/%d - %A'

OLDIFS=$IFS
IFS=$'\n'

for file in $(find "$SOURCE_FOLDER" -name '*' | grep -Ei "$EXT_WHITELIST");
do 
	file_name=$(basename "$file")
	file_ext=$(echo "$file_name" | grep -oE '[^\.]+$')

	if [[ $(echo $file_ext | grep -i mts | wc -l) -eq 0 ]]
	then
		file_date_picture=$(identify -format "%[EXIF:DateTimeOriginal]" $file | awk -F " " '{print $1}' | awk -F ":" '{print $1"-"$2"-"$3}')
	fi

	file_date_all=$(echo $file_date_picture && stat $file |  grep -oE "[0-9]{4}\-[0-9]{2}\-[0-9]{2}" | grep -v 1980)
	file_date_final=$(echo $file_date_all | tr ' ' '\n' | sort | grep -v '^1970' | head -n 1)

	file_folder="$DEST_FOLDER"$(LC_ALL="fr_FR.utf8" date --date="$file_date_final" "$PATH_PATTERN")
	file_path="$file_folder""/""$file_name"

	mkdir -p "$file_folder"
	ln -f "$file" "$file_path"

done

DEST_PERM="700"
DEST_OWNER="Paul-Administrator:users"

chmod -R "$DEST_PERM" "$DEST_FOLDER"
chown -R "$DEST_OWNER" "$DEST_FOLDER"

IFS=$OLDIFS
