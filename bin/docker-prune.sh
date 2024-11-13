#!/usr/bin/env bash
# SCRIPT: docker-prune.sh 
# AUTHOR: erfan 
# DATE: 2024-03-06T03:58:39
# REV: 1.0
# PURPOSE: ...
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution


for con in $(docker container ls -qa)
do
	docker container rm -f "$con"
done

docker system prune -af

echo "Done"
