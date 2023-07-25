#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $(basename "$0") <depth> [directory]"
	echo "Reports size of each directory on the same file system."
	exit 1

fi

OPTIONS="--one-file-system --dereference-args --si --max-depth ${1}"
if [ $1 != 0 ]; then
	OPTIONS="--total ${OPTIONS}"
fi

if [ -z "$2" ]; then
	DIR="$(pwd)"
else
	DIR="${2}"
fi

exec du ${OPTIONS} "${DIR}" | sort -h
