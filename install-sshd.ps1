#!pwsh-shebang.sh

# Stop script on first error.
$ErrorActionPreference = "Inquire"
# Name of the sshd service in Windows.
$sshdServiceName = "sshd"

# Function wrapping the the installing of the sshd service using Cygwin bash prompt.
function Install-Sshd-Service
{
	# Ask for installing.
	$choice = ($Host.UI.PromptForChoice("Install sshd service using Cygwin", 'Are you sure you want to proceed?', ('&No', '&Yes'), 0))
	if ($choice -eq 0 -or $choice -ne 1)
	{
		Return 1
	}
	# Only in version 7 the $IsWindows and $IsLinux exists.
	if ($PSVersionTable.PSVersion.Major -lt 7)
	{
		$IsWindows = $True
		$IsLinux = $False
	}
	# Check if this is Windows and bailout for this section.
	if (!$IsWindows)
	{
		Write-Host "This script can only be run on Windows."
		Return 1
	}
	else
	{
		# Form the '.profile' filepath for the sshd process.
		$bashProfilePath = $env:USERPROFILE + [IO.Path]::DirectorySeparatorChar + ".profile"
		# Notify...
		Write-Host "Writing or updating: $bashProfilePath"
		# Write the file content in needed Unix(LF) format.
		Set-Content -Path $bashProfilePath -NoNewline -Value @'
#
# File for in Windows users directory 'C:\Users\<user-name>\.profile'
#

# Correct the home directory.
export HOME="$(pwd)/cygwin"
# Move to the home directory and load the .bash_profile
cd
# Source the .bash_profile to have the same environment as Cygwin gets on the system itself.
source .bash_profile
# End of script.
'@
		# Check if this user has admin rights.
		if (! (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
		{
			Write-Host "This script needs elevation and the current user is no Adminstrator."
			exit 1
		}
		# Capability to install.
		$sshCapability = 'OpenSSH.Server~~~~0.0.1.0'
		Write-Host "Adding Windows Capability '$sshCapability'."
		# Check if OpenSSH is installed.
		if ((Get-WindowsCapability -Online -Name $sshCapability).State -eq "Installed")
		{
			Write-Host "Windows Capability '$sshCapability' already installed."
		}
		else
		{
			Add-WindowsCapability -Online -Name $sshCapability
		}
		# Set the batch file to create the SSH-shell using Cygwin.
		$cygwinBatchFile = "$env:SystemDrive\cygwin64\Cygwin.bat"
		Write-Host "Creating file '$cygwinBatchFile'."
		# Check if already set to the right value.
		if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH").DefaultShell -eq $cygwinBatchFile)
		{
			Write-Host "SSH default shell '$cygwinBatchFile' already set."
		}
		else
		{
			Write-Host "Setting registry key to use: $cygwinBatchFile"
			# To make windows use this profile register the 'Cygwin.bat' batch file using an elevated powershell.
			New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $cygwinBatchFile -PropertyType String -Force
		}
		# Create the file if it doesn't exist
		$sshdBatchfile = "$env:SystemDrive\cygwin64\sshd.bat"
		if (Test-Path $sshdBatchfile)
		{
			Write-Host "SSH default shell '$cygwinBatchFile' already set."
		}
		else
		{
			Write-Host "SSH default shell is to be created..."
			# Write the content to the file
			Set-Content -Path $sshdBatchfile -Value @'
@echo off
set HOME=%HOMEDRIVE%%HOMEPATH%\cygwin
call %~dp0Cygwin.bat
'@
		}
		# Notify...
		Write-Host "Adding firewall rule for VirtualBox VM."
		foreach ($interface in Get-NetIPAddress | Where-Object { $_.InterfaceAlias -match "^Ethernet" -and $_.IPAddress -match "^192.168.56." })
		{
			$ruleName = "Allow Any Access from 192.168.56.1 to $( $interface.IPAddress )"
			$remoteIP = "192.168.56.1"
			Write-Host "Rule name: $ruleName"
			if (Get-NetFirewallRule -DisplayName $ruleName -ErrorAction Ignore)
			{
				Write-Host "Firewall rule '$( $ruleName )' already exists and is updated."
				Set-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol Any -RemoteAddress $remoteIP -LocalAddress $interface.IPAddress -Action Allow -Profile Domain,Private,Public
			}
			else
			{
				Write-Host "Firewall rule '$( $ruleName )' does not exist and is created."
				New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol Any -RemoteAddress $remoteIP -LocalAddress $interface.IPAddress -Action Allow -Profile Domain,Private,Public
			}
		}
		# Enable automatic startup for 'sshd' service.
		Write-Host "Enable automatic startup and restarting service '$sshdServiceName'."
		if (Set-Service $sshdServiceName -ErrorAction Ignore)
		{
			Set-Service $sshdServiceName -startuptype automatic
			Restart-Service $sshdServiceName
		}
		# Assemble the configuration file.
		$sshdConfigFile = ${env:ProgramData} + [IO.Path]::DirectorySeparatorChar + "ssh" + [IO.Path]::DirectorySeparatorChar + "sshd_config"
		# When the file does not exist bailout.
		if (!(Get-Item $sshdConfigFile -ErrorAction Ignore))
		{
			Write-Host "File '$sshdConfigFile' should exist at this point!"
			Return 1
		}
		# Check if a backup has been mede already.
		$sshdConfigFileOriginal = ($sshdConfigFile + ".original")
		if (!(Get-Item $sshdConfigFileOriginal -ErrorAction  Ignore))
		{
			Write-Host "Backing up original configuration file to: $sshdConfigFileOriginal"
			Copy-Item -Path $sshdConfigFile -Destination $sshdConfigFileOriginal
		}
		# Notify...
		Write-Host "Modifying sshd configuration file: $sshdConfigFile"
		# Define the lines to insert
		$linesToInsert = @(
			""
			"# Use cygwin home directory '.ssh ' subdirectory to look for authorized keys."
			"AuthorizedKeysFile %h/cygwin/.ssh/authorized_keys"
		)
		# Read the content of the file into an array, with each element being a line.
		$fileContent = Get-Content -Path $sshdConfigFile
		# Initialize the
		$flagModified = $False
		# Loop through each line, find the match, and modify the next two lines.
		for ($i = 0; $i -lt $fileContent.Count; $i++)
		{
			# Check for the starting line and also if there is still a line after it.
			if ($fileContent[$i] -match "^Match Group administrators" -and (($i + 1) -lt $fileContent.Count))
			{
				# Modify the matched line and the next.
				$fileContent[$i] = "#" + $fileContent[$i]
				$fileContent[$i + 1] = "#" + $fileContent[$i + 1]
				$insertAt = $i + 2
				# Insert the lines or add then depending on the position of insertion.
				if ($insertAt -ge $fileContent.Count)
				{
					$fileContent += $linesToInsert
				}
				else
				{
					$fileContent = $fileContent[0..($insertAt - 1)] + $linesToInsert + $fileContent[$insertAt..($fileContent.Count - 1)]
				}
				# Set flag to write the modified content to file.
				$flagModified = $True
				# Exit the loop after modifying the found lines.
				break
			}
		}
		# Write the modified content back to the file when the content changed.
		if ($flagModified)
		{
			$fileContent | Set-Content -Path $sshdConfigFile
			# Restart the service so it hase effect.
			Restart-Service $sshdServiceName
		}
		else
		{
			Write-Host "Modification sshd configuration is already done."
		}
	}
	# All went okay.
	Return 0
}

function Run-Elevated
{
	# Check if the script is running as Administrator
	$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
	$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
	if (-not $isAdmin)
	{
		# The script is not running as Administrator, relaunch it with elevation
		Write-Host "Elevating script execution..."
		# Relaunch the script with Administrator privileges
		$process = Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -PassThru
		# Wait for the elevated process to exit
		$process.WaitForExit()
		# Return the exit code of the elevated process.
		Return $process.ExitCode
	}
	else
	{
		$exitCode = Install-Sshd-Service
		if ($exitCode -ne 0)
		{
			Write-Host "`Installing service sshd failed`nPress any key to continue..."
			[System.Console]::ReadKey() > $null
		}
	}
}

# Run this script elevated.
$exitCode = Run-Elevated
$service = Get-Service $sshdServiceName
# Show the running service.
Write-Host "$($service.DisplayName)($($service.Name)) = $($service.Status)"
# Check if the service is running and when not change the exit code.
if ($exitCode -eq 0 -and $service.Status -ne "Running")
{
	$exitCode = 1
}
# Return the exit code.
Exit $exitCode
