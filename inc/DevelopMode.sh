
##
# Checks if development mode is enabled.
# Returns 0 when enabled and 1 when not.
function GetDevMode
{
	# Query the registry key and check the out come.
	Reg Query 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' /v 'AllowDevelopmentWithoutDevLicense' | \
	grep -E  'AllowDevelopmentWithoutDevLicense\s+REG_DWORD\s+0x1' > /dev/null
	if [[ $? == 1 ]]; then
		# Signal disabled.
		echo "disabled"
		return 1
	fi
	# Signal enabled.
	echo "enabled"
	return 0
}
