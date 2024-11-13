#!/usr/bin/env bash
# SCRIPT: install-fail2ban.sh 
# AUTHOR: erfan
# DATE: 2024-09-14T02:14:26
# REV: 1.0
# PURPOSE: It installs the fail2ban
set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
# set -e

pyenv=~/.pyenv

touch $pyenv

pw=$PWD
function I {
	sudo apt-get install -y "$@"
}

type -f python &>/dev/null || I python
type -f python3-venv &>/dev/null || I python3-venv

ed="$(cat ${pyenv})"

if [ -z "$ed" ]; then 
	ed=$(mktemp -d)
	echo $ed > $pyenv
fi
mkdir -p ${ed}

echo Envirment path is ${ed}

python3 -m venv ${ed}
source $ed/bin/activate
pip3 install -r "${pw}/requirements.txt"


mkdir -p ~/repos
cd ~/repos

git clone https://github.com/fail2ban/fail2ban.git || echo Repo exists
cd fail2ban
sudo python setup.py install 

sudo cp build/fail2ban.service /etc/systemd/system/
sudo cp files/debian-initd /etc/init.d/fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban


deactivate

# rm -rf "${ed}"

