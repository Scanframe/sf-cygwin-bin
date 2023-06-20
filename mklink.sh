#!/bin/bash

# Check for 2 argements.
if [[ -z "$1" || -z "$2" ]]; then
	echo "Usage: $0 <source-dir> <symlink>"
	exit 1
fi

# Covert the slashes from the Windows path not using cygpath
#  since it return an abs path and unusable in a Linux VM.
SOURCE="$(echo "$1" | sed -e 's/\//\\/g')"

# Make the target symlink entry abolute since CMD curretn work directory. 
TARGET="$(cygpath -wa "$2")"

# Create the actual symlink in windows.
cmd /c mklink /d "${TARGET}" "${SOURCE}"
