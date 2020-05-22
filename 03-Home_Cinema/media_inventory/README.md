# INFORMATION : This script and Splunk application aims to analyze the state of an existing media library (quality, languages, etc...), in order to determine which files should be replaced by better versions.


# PRE-REQUISITES : In order to run this script without issuses, install the mediainfo tool.

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install mediainfo


# PROCEDURE : Add the following content to the crontab of your root user (or any other user matching sufficient permissions).

### BEGIN CRON ###

# Gathering the mediainfo statistics for library each day at 04:00
0 4  *   *   *     /opt/scripts/bin/get_mediainfo.sh

### END CRON ###
