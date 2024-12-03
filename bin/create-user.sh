#!/usr/bin/env bash
# SCRIPT: create-user.sh
# AUTHOR: erfan
# DATE: 2024-02-23T15:41:09
# REV: 1.0
# PURPOSE: 
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
#

user=${1:?'Please insert the user.'}

if test ! -d "/home/${user}" && ! getent passwd "${user}" &>/dev/null
then
	sudo groupdel "${user}" &> /dev/null # Something while recreating the user. It's user might still exits from past.
	sudo useradd -m -d /home/${user} -s /bin/bash ${user}
	sudo chmod 755 /home/${user}
else
	echo "user $user exists"
	exit 
fi


echo "-- Creating ssh identity"
# sudo -u ${user} ssh-keygen -N "" -f /home/${user}/.ssh/id_rsa
sudo -u "${user}" ssh-keygen -t ed25519 -N "" -f /home/${user}/.ssh/id_ed25519 <<<"y"

[ -z "$(which pwgen)" ] 2>/dev/null &&  { echo "-- pwgen does not exists. Will install it."; sudo apt-get install pwgen; }
password="$(pwgen 12 1)"
echo "${user}:${password}" | sudo chpasswd

echo -e "password for user '$user' is:\n$password"
