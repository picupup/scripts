#!/usr/bin/env bash
# SCRIPT: create-group.sh
# AUTHOR: erfan
# DATE: 2024-02-26T02:32:59
# REV: 1.0
# PURPOSE: 
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution


group="${1:?'Please provide name of the group.'}"

shift

if [ "$#" = "0" ] 
then
       	echo 'Please insert at least one user after the group name to include in the group.';
       	exit 1;
fi
sudo groupadd "${group}"

for user in "$@"
do
	create-user ${user} || { echo 'create-user.sh failed'; exit 1; }
	sudo usermod -aG "${group}" "${user}"
done

echo Done
