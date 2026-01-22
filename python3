#!/bin/bash 

# Bailout on first error.
set -e -o pipefail

# Get the script directory.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Include WriteLog function.
source "${script_dir}/inc/WriteLog.sh"

# Get the python script to execute.
script="$(cygpath -wa "$1")"
shift 1

# Cygpath to the Windows Python executable expected location.
python="$(cygpath "${LOCALAPPDATA}")/Programs/Python/Python312/python.exe"

# Check if the python executable exists.
if [[ -f  "${python}" ]]; then 
	"${python}" "${script}" "${@}"
else
	WriteLog "Windows Python3 '${python}' not found!"
	read -r -p "Install Python3.12 using WinGet? [y/N] " response
	if [[ "$response" =~ ^[yY]$ ]]; then
		winget install --disable-interactivity --accept-source-agreements --accept-package-agreements --exact --id Python.Python.3.12
	fi
	exit 1
fi
