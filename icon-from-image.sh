#!/bin/bash

# Command needed.
CMD_BIN="/usr/bin/convert"

# Check if the command exists.
if ! command -v "${CMD_BIN}" > /dev/null ; then
	echo "Command '${CMD_BIN}' is not installed!"
	exit 1
fi

# Check if the amount of arguments are passed
if [[ -z "$1" || -z "$2" ]] ; then
	echo  "Usage: $(basename "$0") <imput-image> <output-ico-file>"
	exit 1
fi

# Execute the command
"${CMD_BIN}" -verbose -define icon:auto-resize=256,64,48,32,16 "$(cygpath -w "$1")" "$(cygpath -w "$2")"
