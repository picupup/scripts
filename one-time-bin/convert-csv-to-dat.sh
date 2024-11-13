#!/usr/bin/env bash
# SCRIPT: convert-csv-to-dat.sh 
# AUTHOR: erfan-main 
# DATE: 2024-11-12T17:46:55
# REV: 1.0
# PURPOSE: Coverts csv file to dat file. Dat file is used from latex pgfplot to create a plot from table data.
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution


csvfile=${1:?'Please insert the file path.'}
outputfile="${csvfile%.*}.dat"
delimiter=" "

originalIFS="${IFS}"
IFS=','
fields=($(head -n 1 "$csvfile"))
IFS="$originalIFS"

# Check if the last character is a newline, and append one if not
if [ -n "$(tail -c 1 "$csvfile")" ]; then
    echo >> "$csvfile"  # Appends a newline if the file doesn't end with one
fi

# Empty the output file
> ${outputfile} 

for ((i = 0; i < ${#fields[@]}; ++i)); do
    # echo $i
    outputline=""
    while read line; do
        IFS=',' read -r -a line_fields <<< "$line"

        outputline+="${line_fields[$i]} ${delimiter} "
    done < $csvfile
    echo "${outputline%${delimiter}*}"  | tr -d '"' >> "${outputfile}"
done

echo "Saved in ${outputfile}"
