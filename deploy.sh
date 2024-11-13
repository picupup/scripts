#!/usr/bin/env bash
# SCRIPT: deploy.sh
# AUTHOR: erfan
# DATE: 2024-02-26T00:21:44
# REV: 1.0
# PURPOSE: It set up or updates the script set either for the server or for the your local computer.
#
# ARGUMENTS: 
# 		1 : server | local
#		2 : <group name> default "sudo"
#
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution

cpath="$(cd $(dirname $0); pwd)"

function safe-create-group {
	if ! getent group "${group}" &>/dev/null
	then
		echo "Creating the group ${group}"
		sudo groupadd "${1:?'Insert group name'}"
		sudo usermod -aG "${group}" "${USER}"
	fi
}

# Deploy a single file
function deployf {
	file="${1:?'Please insert the file name for the deploy file function.'}"
	mode="${2:-root}"
	echo "Copying '${file}' to /usr/local/bin/"

	end="${file##*.}"
	name="${file%.*}"
	if [ "${end}" = "sh" ]
	then
		binfile="/usr/local/bin/${name}"
	else
		binfile="/usr/local/bin/${file}"
	fi

	ff="${cpath}/bin/${file}"
	sudo cp "${ff}" "${binfile}"

	if [ "${mode}" = "commen" -o ${envirment} = "local" ]
	then
		# Permissions should be -rwxr-xr-x
		sudo chmod 755 "${binfile}"
	else 
		# This will be executed only in the server envirment
		
		# Hier we create the sudoers group
		safe-create-group "${group}"
		sudo chown "root:$group" "${binfile}"
		# Permissions should be -rwxr-xr--
		sudo chmod 754 "${binfile}"
	fi
}

message="
1: Please insert envirment type 'server' or 'local' as the first argument.
2: Please insert name of the group, who should be able to run the non commen scripts, like 'sudoers' or 'l-admin'."

envirment="${1:?"$message"}"
group="${2:-"sudo"}"
if [ "$envirment" != "local" -a "$envirment" != "server" ]
then
	echo "${message}"
	exit 1
fi

# Impliments the lists from the config file
. ${cpath}/config.txt


if [ -z "$list_commen" -o -z "$list_server" -o -z "$list_local" ]
then
	echo 'One of the nessecory lists is missing.'
	exit 1
fi

if [ "$envirment" = "server" ]
then
	deploylist+=( "${list_server[@]}" )
else
	deploylist+=( "${list_local[@]}" )
fi

# Deploy commen files
for cfile in "${list_commen[@]}"
do
	deployf "$cfile" "commen"
done

# Deploy root/admin specific files
for dfile in "${deploylist[@]}"
do
	deployf "$dfile" "root"
done

if [ "$envirment" = "local" ]
then
	exit 0;
fi

for configfile in "${list_skel[@]}"
do
	echo "Copying 'skel/${configfile}' to /etc/skel/"
	sudo cp -r "${cpath}/skel/${configfile}" /etc/skel/
done
