#!/bin/bash

# Get the script directory.
script_dir="$(dirname "${BASH_SOURCE[0]}")"
# Include WriteLog function.
source "${script_dir}/inc/WriteLog.sh"
# Prints the help.
#
function show_help {
	echo "Usage: $(basename "${0}") [<options>] <directory>
  Options:
  -h, --help      : Show this help.
  -r, --recursive : Recursively iterate through all sub directories.
  -s, --show      : Show the differences.
  -d, --depth     : Maximum directory depth.
  -f, --format    : Format found files.
  directory       : Directory to start in.

  The script formats the code using the file '.clang_format' found in one of its parent directories.

  See for formatting options for configuration file:
     https://clang.llvm.org/docs/ClangFormatStyleOptions.html
"
}
# Initialize the options with the regular expression.
find_options='-iregex .*\.\(c\|cc\|cpp\|h\|hh\|hpp\)'
# Recursion is disabled by default.
flag_recursive=false
# Format file for real.
flag_format=false
# Enables show diff.
flag_show_diff=false
# Max depth is only valid when recursion is enabled.
max_depth=""

# Check if the needed commands are installed.
commands=(
	"colordiff"
	"dos2unix"
	"grep"
	"clang-format"
)
for command in "${commands[@]}"; do
	if ! command -v "${command}" >/dev/null; then
		echo "Missing command '${command}' for this script"
		exit 1
	fi
done

# Parse options.
temp=$(getopt -o 'hrfsd:' --long 'help,recursive,format,show,depth:' -n "$(basename "${0}")" -- "$@")
# shellcheck disable=SC2181
if [[ $? -ne 0 ]]; then
	show_help
	exit 1
fi
eval set -- "$temp"
unset temp
while true; do
	case "$1" in

		-h | --help)
			show_help
			exit 0
			;;

		-r | --recursive)
			flag_recursive=true
			shift 1
			;;

		-f | --format)
			flag_format=true
			shift 1
			;;

		-s | --show)
			flag_show_diff=true
			shift 1
			;;

		-d | --depth)
			flag_recursive=true
			max_depth="$2"
			shift 2
			continue
			;;

		'--')
			shift
			break
			;;

		*)
			WriteLog "Internal error on argument (${1}) !"
			exit 1
			;;
	esac
done
# Get the arguments in an array.
argument=()
while [[ $# -gt 0 ]] && ! [[ "$1" =~ ^- ]]; do
	argument=("${argument[@]}" "$1")
	shift
done
# Get the relative start directory which must exist otherwise show help and bailout.
#
if ! START_DIR="$(realpath --relative-to="$(pwd)" -e "${argument[0]}")"; then
	show_help
	exit 0
fi
# Check for recursive operation.
if ${flag_recursive}; then
	# When max directory depth is set.
	if [[ -n "${max_depth}" ]]; then
		find_options="-maxdepth ${max_depth} ${find_options}"
	fi
else
	# Only the current directory.
	find_options="-maxdepth 1 ${find_options}"
fi
# Set tab to 4 spaces.
tabs -4
# Find the cfg_file file for clang-format up the tree.
cfg_file="$("${script_dir}/find-up.sh" --type f ".clang-format")" || exit 1
# Report the format configuration file.
WriteLog "Using configuration: ${cfg_file}."
# While loop keeping used variables local to be able to update.
while read -rd $'\0' file; do
	# Compare formatted unix file with original one.
	if clang-format --style="file:${cfg_file}" "${file}" | dos2unix | diff -s "${file}" - >/dev/null; then
		WriteLog "= ${file}"
	else
		WriteLog "~ ${file}"
		# Show differences when flag is set.
		if ${flag_show_diff}; then
			clang-format --style="file:${cfg_file}" "${file}" | dos2unix | colordiff "${file}" -
			echo "==="
		fi
		if ${flag_format}; then
			# Check for DOS line endings.
			if file "${file}" | grep -q 'CRLF'; then
				# And fix it.
				dos2unix "${file}" 2>/dev/null || exit 1
			fi
			# Format C/C++ using the style config file.
			clang-format --style="file:${cfg_file}" "${file}" -i || exit 1
		fi
	fi
done < <(find "${START_DIR}" ${find_options} -print0)
