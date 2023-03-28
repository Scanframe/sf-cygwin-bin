#!/bin/bash

function ShowHelp()
{
	cat << HEREDOC
Usage :$0 <start|stop|off>
  start : Starts the VM headless.
  stop  : Stops the VM using an ACPI signal (power button).
  off   : Kills the VM.
	ip    : Returns the VM assigned IP.
HEREDOC
}

VM_ID='{4135ba50-f8fc-4c87-a498-9f95d85eddb7}'

case "$1" in

	start)
		echo "Starting headless..."
    VBoxManage startvm "${VM_ID}" --type headless
    ;;

	stop)
		echo "Power button ACPI shutdown..."
		VBoxManage controlvm "${VM_ID}" acpipowerbutton
		;;

	off)
		echo "Forced powering Off VM..."
		VBoxManage controlvm "${VM_ID}" poweroff
		;;

	ip)
		VBoxManage guestproperty get "${VM_ID}" "/VirtualBox/GuestInfo/Net/0/V4/IP" | cut -d' ' -f2
		;;

	*)
		ShowHelp
    exit 1

esac
