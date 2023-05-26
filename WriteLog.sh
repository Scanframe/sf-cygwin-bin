# Define and use some foreground colors values when not running CI-jobs.
if [[ ${CI} ]] ; then
	fg_black=""
	fg_red=""
	fg_green=""
	fg_yellow=""
	fg_blue=""
	fg_magenta=""
	fg_cyan=""
	fg_white=""
	fg_reset=""
else
	# shellcheck disable=SC2034
	fg_black="$(tput setaf 0)"
	fg_red="$(tput setaf 1)"
	# shellcheck disable=SC2034
	fg_green="$(tput setaf 2)"
	fg_yellow="$(tput setaf 3)"
	# shellcheck disable=SC2034
	fg_blue="$(tput setaf 4)"
	fg_magenta="$(tput setaf 5)"
	fg_cyan="$(tput setaf 6)"
	# shellcheck disable=SC2034
	fg_white="$(tput setaf 7)"
	fg_reset="$(tput sgr0)"
fi

# Writes to stderr.
#
function WriteLog()
{
	# shellcheck disable=SC2034
	# shellcheck disable=SC2124
	local LAST_ARG="${@: -1}"
	local LAST_CH="${LAST_ARG:0-1}"
	local FIRST_CH="${LAST_ARG:0:1}"
	local COLOR
	# Set color based on first character of the string.
	case "${FIRST_CH}" in
		"-")
			COLOR="${fg_magenta}"
			;;
		"~")
			COLOR="${fg_yellow}"
			;;
		"#")
			COLOR="${fg_blue}"
			;;
		"=")
			COLOR="${fg_green}"
			;;
		*)
			COLOR=""
			;;
	esac
	case "${LAST_CH}" in
		"!")
			COLOR="${fg_red}"
			;;
		".")
			if [[ -z "${COLOR}" ]]; then
				COLOR="${fg_cyan}"
			fi
			;;
	esac
	echo -n "${COLOR}" >&2
	# shellcheck disable=SC2068
	echo ${@} >&2
	echo -n "${fg_reset}" >&2
}
