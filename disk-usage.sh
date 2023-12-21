#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $(basename "$0") <depth> [directory]"
	echo "Reports size of each directory on the same file system."
	exit 1

fi

OPTIONS=("--one-file-system" "--dereference-args" "--si")
OPTIONS+=("--max-depth" "${1}")

# When no depth is passed only show the total.
if [ $1 != 0 ]; then
	OPTIONS+=("--total")
fi

# Add the directory when passed or not.
if [ -z "$2" ]; then
	OPTIONS+=("$(pwd)")
else
	OPTIONS+=("${2}")
fi

du "${OPTIONS[@]}" | sort -h
