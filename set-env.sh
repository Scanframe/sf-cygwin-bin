#!/bin/bash

if grep CYGWIN_NT /proc/version >/dev/null; then
	# Get the QT library path.
	QTLIBDIR="$(qt-lib-dir.sh)"
	# When QT library path was found.
	if [[ ! -z "${QTLIBDIR}" ]]; then
		# Get the directory which is needed for QT apps to find the appropriate DLL's.
		QTBINDIR="${QTLIBDIR}/mingw_64/bin"
		# Form the Qt Tool directory from the found Qt directory.
		QTTOOLDIR="$(realpath "${QTLIBDIR}/../Tools")"
		# Form the Qt Tool directory from the found Qt directory.
		NSISDIR="$(realpath "${QTLIBDIR}/../../NSIS/Bin")"
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
			setx PATH "${path_cur}$(cygpath -w "${QTBINDIR}");$(cygpath -w "${QTTOOLDIR}/CMake_64/bin");$(cygpath -w "${QTTOOLDIR}/Ninja");.\\lib;$(cygpath -w "${NSISDIR}")"
			# Update current shell session PATH as well because 'setx' only works for new processes.
			export PATH="${PATH}:${QTBINDIR}:${QTTOOLDIR}/CMake_64/bin:${QTTOOLDIR}/Ninja:./lib:${NSISDIR}"
		fi
	fi
elif grep WSL /proc/version >/dev/null; then
	echo "WSL detected.."
elif grep MINGW64_NT /proc/version >/dev/null; then
	echo "GitBash detected.."
fi


