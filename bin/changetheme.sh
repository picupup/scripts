#!/usr/bin/env bash
# SCRIPT: changetheme.sh
# AUTHOR: erfankarimi
# DATE: 2024-02-25_20:39:56
# REV: 1.0
# PURPOSE: It changes or adds the themes in the ~/.wezterm.lua
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution

# Bright and dark theme
bt="config.color_scheme = 'Gruvbox (Gogh)'"
dt="config.color_scheme = 'Google Dark (Gogh)'"

if ! grep -q "${bt}\|${dt}" ${HOME}/.wezterm.lua
then
	# If there is no theme config, then add them
	echo "This is first time running this command. Adding inital thems. Run this again to switch between dark and bright theme."
	raw_lbr="$(grep -n 'return' $HOME/.wezterm.lua)" # Line before return argument
	lbr="${raw_lbr%%:*}"
	
	# Insert dark and bright theme at the line before return
	sed -i -- "${lbr}s/^/${dt}\\n--${bt}\\n\\n/" $HOME/.wezterm.lua
	exit 0

elif grep -q -- "--${bt}" ${HOME}/.wezterm.lua
then
	# If current theme is dark, change it to bright
	sed -i -- "s/--${bt}/${bt}/g" ${HOME}/.wezterm.lua
	sed -i -- "s/${dt}/--${dt}/g" ${HOME}/.wezterm.lua
elif grep -q -- "--${dt}" ${HOME}/.wezterm.lua
then
	# If current theme is bright change it to dark
	sed -i -- "s/${bt}/--${bt}/g" ${HOME}/.wezterm.lua
	sed -i -- "s/--${dt}/${dt}/g" ${HOME}/.wezterm.lua
else 
	echo -e "Couldn't reconfigure Theme. If one of following Thems exists in your ~/.wezterm.lua file, please delete them, before running this script again.\n${bt}\n${dt}"
	exit 1
fi
