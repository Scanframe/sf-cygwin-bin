#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Need argument..!"
	exit 1
fi

# Get the VirtualBox Adapters IP address.
IP_HOST_ONLY="$(ipconfig /all | grep "VirtualBox Host-Only Ethernet Adapter" -A 4 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')"

# Run the ssh command passing the DISPLAY environment variable.
ssh super@kubuntu -t "DISPLAY=${IP_HOST_ONLY}:0.0 XCURSOR_SIZE=16 /bin/bash -c 'source ~/.profile && $1'"
