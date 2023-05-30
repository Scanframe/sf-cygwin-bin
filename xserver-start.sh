#!/bin/bash

# Get the bash script directory.
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
# If the batch file is running do not start the X-server.
if [[ $(pgrep vcxsrv.bat | wc -l) -eq 0 ]]; then
	# Start the X-server in the background.
	"${SCRIPT_DIR}/vcxsrv.bat" 2>&1 /dev/null &
fi
