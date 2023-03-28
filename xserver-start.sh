#!/bin/bash

# If mintty is running do not start the X-server.
if [[ $(pgrep mintty | wc -l) -eq 1 ]]; then
	# Start the X-server in the background.
	"${DIR}/vcxsrv.bat" 2>&1 /dev/null &
fi
