##
## This script is called when elevated.
##

# Check if this user has admin rights.
if (! (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	Write-Output "This script needs elevation and the current user is no Adminstrator."
	exit 1
}

# Capability to install.
$Capability = 'OpenSSH.Server~~~~0.0.1.0'
# Check if OpenSSH is installed.
if ((Get-WindowsCapability -Online -Name $Capability).State -eq "Installed")
{
	Write-Output "Adding Windows Capability '$Capability'."
	Write-Output "Windows Capability '$Capability' already installed."
}
else
{
	Add-WindowsCapability -Online -Name $Capability
}
# Set the batch file to create the SSH-shell using Cygwin.
$CygwinBatchFile = "C:\cygwin64\Cygwin.bat"
# Check if already set to the right value.
if ((Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH").DefaultShell -eq $CygwinBatchFile)
{
	Write-Output "SSH default shell '$CygwinBatchFile' already set."
}
else
{
	Write-Output "Setting registry key to use: $CygwinBatchFile"
	# To make windows use this profile register the 'Cygwin.bat' batch file using an elevated powershell.
	New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $CygwinBatchFile -PropertyType String -Force
}

Write-Output "`nPress any key to continue..."
[System.Console]::ReadKey().Key.ToString();