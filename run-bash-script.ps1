param (
    [Parameter(Mandatory=$true)][string] $shellScript,
    [Parameter(Mandatory=$false)][string] $argument1
)
# Make the script stop on the first error.
$ErrorActionPreference = "Stop"
# 
# To Debug this script in PowerShell ISE you need to change the execution policy
# by executing this command in an elevated PowerShell.
#      Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine
#

# Import the necessary Windows API functions
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 
    {
        [DllImport("kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();
        
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  
        public const int SW_HIDE = 0;
    }
"@
# Get the handle of the console window
$consoleHandle = [Win32]::GetConsoleWindow()
# Hide the console window
[Win32]::ShowWindow($consoleHandle, [Win32]::SW_HIDE)
# Bash executable path.
$executablePath = "C:\cygwin64\bin\bash.exe"
# Run the shell script.
& $executablePath --login -c "$`{HOME}/bin/${shellScript} ${argument1}"
