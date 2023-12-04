#!/bin/bash

# Get the location to the C drive in the unix environment.
if [[ -d "/cygdrive" ]]; then
	echo "Cygwin detected.."
elif [[ -d "/mnt/c" ]]; then
	echo "WSL detected.."
elif [[ -d "/c" ]]; then
	echo "GitBash detected.."
fi


#P:\DOSUTILS;
#%USERPROFILE%\AppData\Local\Microsoft\WindowsApps

# Get the QT library path.
QTLIBDIR="$(qt-lib-dir.sh)"
# When QT library path was found.
if [[ ! -z "${QTLIBDIR}" ]]; then
	# Get the directory which is needed for QT apps to find the appropriate DLL's.
	QTBINDIR="${QTLIBDIR}/mingw_64/bin"
	#
	# Find the QT bin directory in the user PATH environment variable.
	#
	# Initialize the variable.
	path_cur=""
	flag=true
	# Iterate through the User registry Path value.
	while read -rd $';' dir; do
		# Check if the \Qt\ directory is part of an entry.
		if [[ "${dir}" =~ \\Qt\\ ]]; then
			# When the current Qt library os part of the PATH set the flag to false to skip setting it.
			[[ "${dir}" == "$(cygpath -w "${QTBINDIR}")" ]] && flag=false
		else
			path_cur+="${dir};"
		fi
	done < <(reg query "HKCU\Environment" /v PATH | grep " PATH " | perl -CS -pe 's/\s+PATH\s+REG_EXPAND_SZ\s+//')
	# Only when needed add the Qt library.
	if ${flag}; then
		echo "Adding found Qt library '${QTLIBDIR}' into path."
		setx PATH "${path_cur}$(cygpath -w "${QTBINDIR}");"
		# Update current shell session PATH as well because 'setx' only works for new processes.
		export PATH="${PATH}:${QTBINDIR}"
	fi
fi


