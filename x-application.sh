#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Need argument..!"
	exit 1
fi

# Check if user was set for x-applications.
if [[ -f "${HOME}/.x-app-user" ]]; then
	source "${HOME}/.x-app-user"
fi

# When 'X_APP_USER' not set use a default.
if [[ -z "${X_APP_USER}" ]]; then
	echo "Variable 'X_APP_USER' has not been set using file '~/.x-app-user'."
fi
echo "X_APP_USER has been set to '${X_APP_USER}'."
set -x
# Check which X-server is running since the XWin server from Cygwin does not listen on a tcp-port but a socket.
if pidof XWin >/dev/null; then
	# Run the ssh command passing the DISPLAY environment variable.
	echo ssh "${X_APP_USER}" -Y -t "XCURSOR_SIZE=16 KDE_FULL_SESSION=true /bin/bash --login -i -c '$@'"
	ssh "${X_APP_USER}" -o BatchMode=yes -Y -t "XCURSOR_SIZE=16 KDE_FULL_SESSION=true /bin/bash --login -i -c '$@'"
else
	# Get the VirtualBox Host-Only Ethernet Adapter IP address and only from the first one when more exist.
	IP_HOST_ONLY="$(ipconfig /all | grep "VirtualBox Host-Only Ethernet Adapter" -A 4 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -n 1)"
	# Check if the IP was retrieved.
	if [[ -z "${IP_HOST_ONLY}" ]]; then
		echo "The VirtualBox Host-Only Ethernet Adapter IP-address was not found!"
	else
		# Run the ssh command passing the DISPLAY environment variable.
		ssh "${X_APP_USER}" -o BatchMode=yes -t "DISPLAY=${IP_HOST_ONLY}${DISPLAY} XCURSOR_SIZE=16 KDE_FULL_SESSION=true /bin/bash --login -c '$1'"
	fi
fi
