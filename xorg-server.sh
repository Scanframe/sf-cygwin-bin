#!/bin/bash

# Command to use an check.
CMD_BIN="XWin"

# Check if the command exists.
if ! command -v "${CMD_BIN}" > /dev.null ; then
	echo "Command '${CMD_BIN}' is not installed!"
	exit 1
fi

# Bailout when already running.
if pgrep "${CMD_BIN}" >/dev/null ; then
	echo "Process '${CMD_BIN}' is already running."
	exit 0
fi

# Set the Display (port) to default ':0' tcp port 6000.
if [[ "%DISPLAY%"=="" ]]; then
	DISPLAY=:0
fi	

# Execute the X-server using the correct options.
"${CMD_BIN}" "${DISPLAY}" -dpi 96 -ac -lesspointer -multiwindow -multimonitors -hostintitle -clipboard -noprimary -fp built-ins +bs -nounixkill -nowinkill -silent-dup-error -wgl

# This options creates clipboard problems when selecting in Windows.
# -noclipboardprimary
