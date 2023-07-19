#!/bin/bash

# Check for 2 arguments.
if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: $0 <source-dir> <symlink>"
	exit 1
fi

# Convert the slashes from the Windows path not using cygpath
#  since it return an abs path and unusable in a Linux VM.
SOURCE="$(echo "$1" | sed -e 's/\//\\/g')"

# Make the target symlink entry absolute since CMD current work directory.
TARGET="$(cygpath -wa "$2")"

# Detect executable.
if [[ "$(file -bi "${TARGET}")" =~ ^inode/directory\; ]]; then
	OPTIONS="/d"
else
	OPTIONS=""
fi

# Create the actual symlink in windows.
cmd /c mklink ${OPTIONS} "${TARGET}" "${SOURCE}"
