#!/usr/bin/env bash
# SCRIPT: changetheme.sh
# AUTHOR: erfankarimi
# DATE: 2021-08-25T20:39:56
# REV: 1.0
# ARGUMENTS: [1: Optional -f adds function and Main section to the script]
#
# PURPOSE: Creates bash script if the file name ends with '.sh' or nothing.
# 	  And adds user and time specific comments at the beginning.
#
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution

function extra {
	cat >> ${1} << END

# ${line}
# ${space}FUNCTIONS
# ${line}

# ${line}
# ${space}MAIN
# ${line}
END

}


##########################################################################################

fi=$1
flag="$2"
line="============================================================"
space="			"

cat > ${fi} << END 
#!/usr/bin/env bash
# SCRIPT: $(basename $fi) 
# AUTHOR: ...
# DATE: $(date '+%FT%T')
# REV: 1.0
# ARGUMENTS: [1:        ][2:		][3:		][4:        ]
#
# PURPOSE: ...
#
# set -x # Uncomment to debug
# set -n # Uncomment to check script syntax without execution
# set -e # Break on the first failure
END

# F stands for the full version or extra information
if [ "$flag" =  "-f" ]
then
	extra "$fi"
fi

chmod u+x $fi

# vim -c '$' $fi
vim +8 $fi
