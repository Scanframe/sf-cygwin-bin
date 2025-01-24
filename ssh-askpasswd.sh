#!/bin/bash

if [[ -z "${DISPLAY}" ]] || ! command -v zenity >/dev/null; then
	dialog --passwordbox "SSH Password" 10 70
else
	zenity --title="Enter SSH Key Password " --window-icon="dialog-password" --password
fi
