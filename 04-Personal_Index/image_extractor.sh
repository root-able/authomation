#!/bin/bash

SOURCE_FOLDER_LIST="$1"
DEST_FOLDER="$2"
USER="$3"
GROUP="$4"

EXT_WHITELIST='\.(jpg|jpeg|gif|png|tif|webp)$'

OLDIFS=$IFS
IFS=$'\n'

for folder in $(echo "$SOURCE_FOLDER_LIST" | tr ',' '\n')
do
	for file in $(find "$folder" -type f | grep -Ei "$EXT_WHITELIST")
	do
		file_hash=$(sha256sum "$file" | grep -oE '^[a-zA-Z0-9]+')
		file_ext=$(basename "$file" | grep -oE '[^\.]+$' | awk '{print tolower($0)}')
		
        ln -f "$file" "$DEST_FOLDER""/""$file_hash.$file_ext"

	done
done

DEST_PERM="700"
DEST_OWNER="$USER:$GROUP"

chmod -R "$DEST_PERM" "$DEST_FOLDER"
chown -R "$DEST_OWNER" "$DEST_FOLDER"

IFS=$OLDIFS
