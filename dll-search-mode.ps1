#!pwsh-shebang.sh

# Manage SafeDllSearchMode registry value
# Run PowerShell as Administrator

param(
    [switch]$Enable,
    [switch]$Disable,
    [switch]$Status
)

# File name only
$script = Split-Path -Leaf $PSCommandPath
# Check if the script is running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

$regPath = "HKLM:\System\CurrentControlSet\Control\Session Manager"
$regName = "SafeDllSearchMode"

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

function Get-Status {
    if (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue) {
        $val = (Get-ItemProperty -Path $regPath -Name $regName).$regName
        switch ($val) {
            1 { Write-Output "SafeDllSearchMode is ENABLED (value = 1)" }
            0 { Write-Output "SafeDllSearchMode is DISABLED (value = 0)" }
            default { Write-Output "SafeDllSearchMode has unexpected value: $val" }
        }
    }
    else {
        Write-Output "The SafeDllSearchMode registry value does not exist."
    }
}

if (-not $isAdmin -and ($Enable -or $Disable))
{
	$exit_code = Run-Elevated
	exit $exit_code
}
else
{
	if ($Enable) {
		Set-ItemProperty -Path $regPath -Name $regName -Value 1 -Type DWord
		Write-Output "SafeDllSearchMode ENABLED (value set to 1)"
		Get-Status
	}
	elseif ($Disable) {
		Set-ItemProperty -Path $regPath -Name $regName -Value 0 -Type DWord
		Write-Output "SafeDllSearchMode DISABLED (value set to 0)"
		Get-Status
	}
	elseif ($Status) {
		Get-Status
	}
	else {
		Show-Help
	}
	exit 0
}
