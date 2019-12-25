#!/bin/sh

##########################
### DEFINING FUNCTIONS ###
##########################

# Function used to log informations
log_result () {
	/usr/bin/logger -t $0 "$1 - $2"
	}
