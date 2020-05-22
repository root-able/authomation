#!/bin/bash

BACKUP_PATH=/media/Didier
EXCLUDE_FILE=/home/paul/backup_script/rsync-exclude.txt
ip=$(cat /home/paul/vp_ip)
function alertpc() {
	ssh paul@$ip -i /home/paul/.ssh/id_rsa -p 22 "notify-send \"$1\" \"$2\" -i \"$3\""
}

#Beginning Backup
echo  "$(date +%Y-%m-%d\ %H:%M:%s) pipaul $USER: RSYNC-BACKUP - INFO - Beginning Backup" >> /var/log/rsync-backup.log
alertpc "RSYNC-BACKUP" "Beginning Backup" "information"

#Making a self backup to RPI_BACKUP
rsync -xaHv --delete-during --no-links --exclude-from=$EXCLUDE_FILE / $BACKUP_PATH/RPI_BACKUP/ 2> /var/log/rsync-backup.log

if [ $? -eq 0 ] 
then
	echo  "$(date +%Y-%m-%d\ %H:%M:%s) $HOSTNAME $USER: RSYNC-BACKUP - INFO - Synchonization successful" >> /var/log/rsync-backup.log
	alertpc "RSYNC-BACKUP"  "Backup successful" "information"
else
	echo  "$(date +%Y-%m-%d\ %H:%M:%s) $HOSTNAME $USER: RSYNC-BACKUP - ERROR - Synchonization failed" >> /var/log/rsync-backup.log
	alertpc "RSYNC-BACKUP"  "Backup error" "error"
#	/usr/bin/python3 /home/paul/mail.py "RPI Info" "Error in rsync synchronization"
fi


