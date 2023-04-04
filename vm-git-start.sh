#!/bin/bash

VM_ID='{4135ba50-f8fc-4c87-a498-9f95d85eddb7}'

function ShowHelp()
{
	cat << HEREDOC
Usage :$0 <start|stop|off>
  start : Starts the VM headless.
  stop  : Stops the VM using an ACPI signal (power button).
  off   : Kills the VM.
  ip    : Returns the VM assigned IP.
  vt    : Enables nested VT-x/AMD-V on VM.
HEREDOC
}

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

	vt)
		VBoxManage modifyvm "${VM_ID}" --nested-hw-virt on
		;;

	*)
		ShowHelp
    exit 1

esac
