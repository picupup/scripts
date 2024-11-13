#!/usr/bin/env bash
# SCRIPT: upnpc-map-to.sh 
# AUTHOR: erfan
# DATE: 2024-09-26T16:38:08
# REV: 1.0
# PURPOSE: This will map/open a port to the ip provided. At least one input is expected. At most Three. 
# INPUTS: Name, Port public, IP, Port intern, Type (TCP, UDP).
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution

# Public port
name=${1:?"[1]:Please provide a name for this port mapping map"}
p1=${2:?"[2]:Please provide internet public port."}
p2=${4:-"${p1}"}

function getip {
	if [[ "$OSTYPE" == "linux-gnu"* ]]; then
		# For Linux
    		hostname -I | awk '{print $1}'
	elif [[ "$OSTYPE" == "darwin"* ]]; then
   		 # For macOS
    		ipconfig getifaddr en0
	else
    		echo "Unsupported OS" >&2
    		exit 1
	fi
}

ip=${3:-"$(getip)"}
echo "local network ip: $ip" 
type=${5:-"TCP"}
echo "TYPE: $type"

which upnpc &>/dev/null || { echo "Error: Please install the command 'upnpc' via 'miniupnpc'." >&2; exit 1; }

upnpc -e "${name}" -a "${ip}" ${p1} ${p2} "${type}"
