#!pwsh-shebang.sh
param(
	[Parameter(ValueFromRemainingArguments = $true)]
	[string[]]$ArgsFromCmd = @()
)


function Set-ErrorMode {
	<#
  .SYNOPSIS
      Wraps the kernel32 SetErrorMode API.
  .DESCRIPTION
      Controls whether the system or the process handles the specified serious error types.
  .PARAMETER Mode
     The mode flags (uint32). Common values:
     0x0001 (SEM_FAILCRITICALERRORS)
     0x0002 (SEM_NOGPFAULTERRORBOX)
     0x8000 (SEM_NOOPENFILEERRORBOX)
  .OUTPUTS
     UInt32. Returns the previous state of the error mode bits.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[uint32]$Mode
	)
	process {
		# Only execute when running from a bash shell.
		if ($env:SHELL -like "*bash*")
		{
			# Only add the type if it doesn't already exist
			if (-not ([System.Management.Automation.PSTypeName]'Win32.K32').Type)
			{
				Add-Type @"
using System;
using System.Runtime.InteropServices;
namespace Win32
{
  public class K32
  {
    [DllImport("kernel32.dll")]
    public static extern uint SetErrorMode(uint uMode);
  }
}
"@
			}
			return [Win32.K32]::SetErrorMode($Mode)
		}
		else
		{
			return $Mode;
		}
	}
}


if ($ArgsFromCmd.Count -eq 0)
{
	Write-Host "No command given!" -ForegroundColor Red
	exit(1)
}


# Initialize the variable to an empty string by default.
$remainingArgs = ""
# Check if there is more than one argument
if ($ArgsFromCmd.Count -gt 1)
{
	# Add the arguments when the executable was given on the command line.
	$remainingArgs = $ArgsFromCmd[1..($ArgsFromCmd.Count - 1)] -join " "
}
# The executable item.
$exe = $(Get-Item "$($ArgsFromCmd[0])")

# Set the error mode for the next command.
Set-ErrorMode(0);
# Execute the binary.
& $exe.FullName $remainingArgs
# Propagate the exit code.
exit $LASTEXITCODE


