#!/bin/bash

if [[ -z "${DISPLAY}" ]]; then
	dialog --passwordbox "SSH Password" 10 70
else
	zenity --title="Enter SSH Key Password " --password
fi
