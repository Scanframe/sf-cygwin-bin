#!pwsh-shebang.sh

param(
	[switch]$Enable,
	[switch]$Disable,
	[switch]$Help
)

# File name only
$script = Split-Path -Leaf $PSCommandPath
# Check if the script is running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

function Show-Help
{
	Write-Output @"
Switch Windows defender real-time protection ON or OFF.

Usefull when compiling, since Defender causes enormous overhead.

Usage:
  Show current protection status only.
    $script.ps1
  Enable real-time protection.
    $script.ps1 -enable
  Disable real-time protection.
    $script.ps1 -disable
  Show this help message.
    $script.ps1 -help

"@
}

function Get-DefenderStatus
{
	$status = Get-MpComputerStatus | Select-Object -ExpandProperty RealTimeProtectionEnabled
	if ($status)
	{
		Write-Output "Real-Time Protection is: ON"
	}
	else
	{
		Write-Output "Real-Time Protection is: OFF"
	}
}

if ($Help)
{
	Show-Help
	exit 0
}

if ($Enable -and $Disable)
{
	Write-Output "Error: Cannot use -Enable and -Disable at the same time."
	exit 1
}

function Run-Elevated
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

Get-DefenderStatus

if (-not $isAdmin -and ($Enable -or $Disable))
{
	$exit_code = Run-Elevated
	Get-DefenderStatus
	exit $exit_code
}
else
{
	if ($Enable)
	{
		Set-MpPreference -DisableRealtimeMonitoring $false
		Write-Output "Real-Time Protection: ENABLED."
	}
	elseif ($Disable)
	{
		Set-MpPreference -DisableRealtimeMonitoring $true
		Write-Output "Real-Time Protection: DISABLED."
	}
	exit 0
}
