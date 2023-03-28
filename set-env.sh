#!/bin/bash

# Get the location to the C drive in the unix environment.
if [[ -d "/cygdrive" ]]; then
	echo "Cygwin detected.."
elif [[ -d "/mnt/c" ]]; then
	echo "WSL detected.."
elif [[ -d "/c" ]]; then
	echo "GitBash detected.."
fi

# Make a copy of the original path to allow calling this script multiple times.
if [[ -z ${CYG_PATH_ORG} ]]; then
	export CYG_PATH_ORG=${PATH}
fi

QTLIBDIR="$(qt-lib-dir.sh)"

if [[ ! -z "${QTLIBDIR}" ]]; then
	#echo "Qt library: ${QTLIBDIR}"
	# Put 'Tools/mingw810_64/bin' first so resource compiler "/usr/bin/windres" from cygwin is not selected.
	echo export PATH="$(realpath "$(ls -d "${QTLIBDIR}"/../Tools/mingw* | sort --version-sort | tail -n 1)")" \
	":${CYG_PATH_ORG}"\
	":$(realpath "${QTLIBDIR}/..")/Tools/CMake_64/bin" \
	":${QTLIBDIR}/mingw_64/bin"
fi
