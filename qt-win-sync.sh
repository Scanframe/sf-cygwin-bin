#!/bin/bash

# Get the script directory.
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# Include WriteLog function.
source "${script_dir}/inc/WriteLog.sh"

# Prints the help.
if [[ -z "$1" || -z "$2" ]]; then
	echo "Sync Qt Windows directories using rsync
  Usage:
    $(basename "$0") <source-dir> <target-dir>
  Example:
    $(basename "$0") /cygdrive/k/Qt/ /cygdrive/p/Qt/
"
	exit 1
fi

# Make some readable variables that make sense and strip the trailing slash.
dir_src="$(realpath "$1")"
dir_trg="$(realpath "$2")"

# Check if the source directory exists.
if [[ ! -d "${dir_src}" ]]; then
	WriteLog "Source directory '${dir_src}' does not exists!"
	exit 1
fi

# Check if the source directory has Qt tools in it.
if [[ ! -d "${dir_src}/Qt" ]]; then
	WriteLog "Source directory '${dir_src}' does not Qt installed!"
	exit 1
fi

# Check if the target directory exists.
if [[ ! -d "${dir_trg}" ]]; then
	WriteLog "Target directory '${dir_trg}' does not exists!"
	exit 1
fi

WriteLog "-Syncing content of directories:
  Source: ${dir_src}/
  Target: ${dir_trg}/
 "

rsync --archive --delete --partial --progress "${dir_src}/" "${dir_trg}/"
