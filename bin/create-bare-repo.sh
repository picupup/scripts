#!/usr/bin/env bash
# SCRIPT: create-bare.sh
# AUTHOR: erfan
# DATE: 2024-02-23T16:29:48
# REV: 1.0
# PURPOSE: It does three things. Creates user if not exists. Create group and creates the bare repo.
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
#

# arguments 1:repo name 2: group 3-: users to be added to the group
if test -z "$(groups $USER | grep sudo)"; then
        echo 'You can run this script, only if you have the sudo rights.'
        exit 1
fi

rpname=${1:?'Please provide the name of the repo as 1 argument group as 2 argument and users as 3 and above'}
gn=${2:?'Please provide the group name'}


# Safely create user git if not exists
if ! getent passwd git &>/dev/null 
then
	if [ -d "/home/git" ] 
	then
		echo 'User git exists but the home path does not exists'
		exit 1
	fi

	echo "-- User git does not exists. Creating the user git."

	create-user git

	echo "-- Adding config"
	gitconfig='[user]
	email = git@no-admin.de
	name = Git USER'
	echo "${gitconfig}" | sudo -u git tee -a /home/git/.gitconfig > /dev/null
fi

rppath="/home/git/${rpname}.git"
if test -d ${rppath}
then
        echo "repo ${rppath} already exits"
        exit 1
fi

echo '-- Create group'
sudo groupadd $gn

# git_gid="$(getent group git | tr -dc '0-9')"
git_group_members="git $(getent group git | cut -d: -f4 | sed 's/,/ /g')"
for member in ${git_group_members}
do
        echo "--- Adding parent member '${member}' to group '$gn'"
        sudo usermod -aG "$gn" "${member}"
done


shift 2

echo '-- create user if not exists'
for user in "$@"
do
        create-user ${user}
        sudo usermod -aG ${gn} ${user}
done
#git config --global init.defaultBranch main

sudo mkdir -m 2770 "${rppath}"
sudo git init --bare --shared=group -b main "${rppath}"

# This allows the user to squash or force push
sudo git -C "${rppath}" config --bool receive.denyNonFastForwards false
sudo chown -R "git:${gn}" "${rppath}"
# sudo -u git git -C "${rppath}" symbolic-ref HEAD refs/heads/main

echo '-- Create a temporary directory'
tmpdir=$(sudo -u git mktemp -d)

echo '-- Clone the bare repository into the temporary directory'
sudo -u git git clone "${rppath}" "${tmpdir}";

echo '-- Initialize the main branch with an empty commit'
sudo -u git git -C "${tmpdir}" checkout -b main
sudo -u git git -C "${tmpdir}" commit --allow-empty -m "Initial commit"

echo '-- Push the main branch to the bare repository'
sudo -u git git -C "${tmpdir}" push origin main

echo '-- Clean up the temporary directory'
sudo -u git rm -rf "${tmpdir}"
