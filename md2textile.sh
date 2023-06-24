#!/bin/bash

# Command needed.
CMD_BIN="pandoc"

# Check if the amount of arguments are passed
if [[ -z "$1" || -z "$2" ]] ; then
	echo  "Usage: $(basename $0) <markdown-file> <textile-file>"
	exit 1
fi

# Execute the command
"${CMD_BIN}" "$(cygpath -w "$1")" -f markdown -t textile -o "$(cygpath -w "$2")"

