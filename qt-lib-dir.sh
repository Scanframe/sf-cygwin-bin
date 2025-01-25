#!/bin/bash
#set -x

# Get the bash script directory.
#SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
# Set the directory the local QT root expected.
local_qt_root="${HOME}/lib/qt"

# Writes to stderr.
#
function WriteLog()
{
	echo "$@" 1>&2;
}

# Find newest local Qt version directory.
#
function GetLocalQtDir()
{
	local local_qt_dir=""
	# Check is the Qt install can be found.
	if [[ ! -d "${local_qt_root}/" ]] ; then
		#WriteLog "Qt install directory or symbolic link '${local_qt_root}' was not found!"
		exit 1
	fi
	# Find the newest Qt library installed.
	local_qt_dir="$(/usr/bin/find "${local_qt_root}/" -maxdepth 1 -type d -regex ".*\/qt\/w64-$(uname -m)\/[0-9]+.[0-9]+.[0-9]+$" | sort --reverse --version-sort | head -n 1)"
	if [[ -z "${local_qt_dir}" ]] ; then
		WriteLog "Could not find local installed Qt directory."
		exit 1
	fi
	
	if [[ "$(uname -s)" == "CYGWIN_NT"* ]]; then
		local_qt_dir="$(realpath "${local_qt_dir}")"
	fi

	echo -n "${local_qt_dir}"
}


if ! GetLocalQtDir ; then
	exit 1
fi 
