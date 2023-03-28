#!/bin/bash

# Get the bash script directory.
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
# If mintty is running do not start the X-server.
if [[ $(pgrep mintty | wc -l) -eq 1 ]]; then
	# Start the X-server in the background.
	"${SCRIPT_DIR}/vcxsrv.bat" 2>&1 /dev/null &
fi
