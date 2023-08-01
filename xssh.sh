#!/bin/bash

if [[ -z "${DISPLAY}" ]]; then 
	echo "Needed 'DISPLAY' enviroment variable not present@"
	exit 1
fi

# Create tunnel for XServer using the current DISPLAY (:10) env var to determin the port offset.
ssh $* -R "6010:localhost:$((6000 + ${DISPLAY:1}))" -t "DISPLAY=:10 KDE_FULL_SESSION=true XCURSOR_SIZE=16 /bin/bash"


