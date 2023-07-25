#!/bin/bash

# Get the script directory.
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# Include GetDevelopMode function.
source "${SCRIPT_DIR}/inc/DevelopMode.sh"
# Include WriteLog function.
source "${SCRIPT_DIR}/inc/WriteLog.sh"

# Check if develop mode is enabled.
if ! GetDevelopMode; then
	WriteLog "Windows Developer mode is NOT enabled but is needed for the 'MKLINK' command!"
	exit 1
fi

# Check for 2 arguments.
if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: $(basename "$0") <source-dir> <symlink>"
	exit 1
fi

# Convert the slashes from the Windows path not using cygpath
#  since it returns an abs path and unusable in a Linux VM.
SOURCE="$(echo "$1" | sed -e 's/\//\\/g')"

# Make the target symlink entry absolute since CMD current work directory.
TARGET="$(cygpath -wa "$2")"

# Detect executable using the 'file' command.
if [[ "$(file -bi "${TARGET}")" =~ ^inode/directory\; ]]; then
	OPTIONS="/d"
else
	OPTIONS=""
fi

# Create the actual symlink in Windows.
cmd /c mklink ${OPTIONS} "${TARGET}" "${SOURCE}"
