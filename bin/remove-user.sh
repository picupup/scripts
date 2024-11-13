#!/usr/bin/env bash
# SCRIPT: delete-user.sh
# AUTHOR: erfan
# DATE: 2024-02-23T16:03:19
# REV: 1.0
# PURPOSE: 
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
#
user=${1:?'Insert the user name please'}


sudo userdel -r "${user}"
sudo groupdel "${user}"

if id "${user}" &>/dev/null 
then
	echo "-- Error: Couldn't delete user compeletly."
else
	echo "-- User '${user}' successfully removed."
fi
