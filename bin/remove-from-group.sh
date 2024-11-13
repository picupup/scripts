#!/usr/bin/env bash
# SCRIPT: remove-from-group.sh
# AUTHOR: erfan
# DATE: 2024-02-26T13:51:10
# REV: 1.0
# PURPOSE: If the user exists, this will remove it from the group, provided as the second argument.
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
#
message="
Error: This is how the argument set should look like:
$(basename $0) <username> <groupname>"
user=${1:?"$message"}
group=${2:?"$message"}

if id "${user}" &>/dev/null 
then
	sudo deluser "${user}" "${group}"
else
	echo "user '${user}' does not exists."
fi
