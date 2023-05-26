# Make the script stop on the first error.
$ErrorActionPreference = "Stop"
# Imort the WPF framework.
Add-Type -AssemblyName System.Windows.Forms

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

# Gets the start menu folder path.
function Get-DestinationFolder()
{
	#return [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop);
	return [IO.Path]::Combine([Environment]::GetFolderPath([Environment+SpecialFolder]::StartMenu), "Programs")
}

# Set the destination directory.
$destDir = Get-DestinationFolder

# Create shortcut
function Create-Shortcut([string] $exePath, [string] $arguments, [string] $target, [string] $iconPath)
{
    #New-Object : Creates an instance of a Microsoft .NET Framework or COM object.
    #-ComObject WScript.Shell: This creates an instance of the COM object that represents the WScript.Shell for invoke CreateShortCut
    $ws = New-Object -ComObject WScript.Shell
    # Create the shortcut and fill in the properties.
    $sc = $ws.CreateShortcut($target)
		# Start in minimized style.
		$sc.WindowStyle = 7
    $sc.TargetPath = $exePath
    $sc.Arguments = $arguments
    $sc.IconLocation = $iconPath
    $sc.Save()
 }

# Create Linux-VM shortcut
function Create-Bash-Shortcut([string] $name, [string] $binScript, [string] $iconFilename, [string] $targetDirectory)
{
	Write-Host "${targetDirectory}\$($name).lnk"
	Create-Shortcut """%USERPROFILE%\cygwin\bin\run-bash-script.cmd""" "${binScript}" "${targetDirectory}\$($name).lnk" "${PSScriptRoot}\img\$($iconFilename)"
}

# Create a web application shortcut.
function Create-WebApp-Shortcut([string] $name, [string] $appUrl, [string] $iconFilename, [string] $targetDirectory)
{
	# Determine the browser path trying Google Chrome first.
	$browserBin = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
	if (!(Test-Path $browserBin))
	{
		$browserBin = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
	}
	Create-Shortcut $browserBin "--app=""$($appUrl)""" "${targetDirectory}\$($name).lnk" "${PSScriptRoot}\img\$($iconFilename)"
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Application Shortcuts."
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::SizableToolWindow
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.Font = 'Arial,11'
#
$toolTip = New-Object System.Windows.Forms.ToolTip
# Create default hidden button so the escape key is closing the dialog.
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.Location = New-Object System.Drawing.Point(0, 0)
$cancelButton.Add_Click({ $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel })
$form.CancelButton = $cancelButton
# Create the tab control
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(5, 5)
$tabControl.Size = New-Object System.Drawing.Size(300, 200)
# Create the web apps tab
$tabBashApps = New-Object System.Windows.Forms.TabPage
$tabBashApps.Text = "Bash Scripts"
$tabControl.Controls.Add($tabBashApps)
# Create the bash script apps tab
$tabWebApps = New-Object System.Windows.Forms.TabPage
$tabWebApps.Text = "Web Apps"
$tabControl.Controls.Add($tabWebApps)

##
## Google-Drive
##
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "Google Drive"
$toolTip.SetToolTip($btn, 'Create a Google Drive web application shortcut in the programs menu..')
$btn.AutoSize = $true
$btn.Location = New-Object System.Drawing.Point(5, 5)
$tabWebApps.Controls.Add($btn)
$btn.Add_Click({ Create-WebApp-Shortcut "Google-Drive" "https://drive.google.com/" "google-drive.ico" "$destDir" })
##
## WhatAppWeb
##
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "WhatsAppWeb"
$toolTip.SetToolTip($btn, 'Create a WhatsApp-web application shortcut in the programs menu..')
$btn.AutoSize = $true
$btn.Location = New-Object System.Drawing.Point(5, 45)
$tabWebApps.Controls.Add($btn)
$btn.Add_Click({ Create-WebApp-Shortcut "WhatsApp" "https://web.whatsapp.com/" "whatsapp.ico" "$destDir" })

##
## X-CLion
##
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "X-CLion"
$toolTip.SetToolTip($btn, 'Create a X-CLion application shortcut in the programs menu..')
$btn.AutoSize = $true
$btn.Location = New-Object System.Drawing.Point(5, 5)
$tabBashApps.Controls.Add($btn)
$btn.Add_Click({ Create-Bash-Shortcut "X-CLion" "x-application.sh clion" "clion.ico" "$destDir" })

##
## X-VSCode
##
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "X-VSCode"
$toolTip.SetToolTip($btn, 'Create a VSCode application shortcut in the programs menu..')
$btn.AutoSize = $true
$btn.Location = New-Object System.Drawing.Point(5, 45)
$tabBashApps.Controls.Add($btn)
$btn.Add_Click({ Create-Bash-Shortcut "X-VSCode" "x-application.sh code" "vscode.ico" "$destDir" })

##
## X-Netbeans
##
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "X-Netbeans"
$toolTip.SetToolTip($btn, 'Create a X-Netbeans application shortcut in the programs menu..')
$btn.AutoSize = $true
$btn.Location = New-Object System.Drawing.Point(5, 85)
$tabBashApps.Controls.Add($btn)
$btn.Add_Click({ Create-Bash-Shortcut "X-Netbeans" "x-application.sh netbeans" "netbeans.ico" "$destDir" })

##
## X-Dolphin
##
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "X-Dolphin"
$toolTip.SetToolTip($btn, 'Create a X-Dolphin application shortcut in the programs menu..')
$btn.AutoSize = $true
$btn.Location = New-Object System.Drawing.Point(5, 125)
$tabBashApps.Controls.Add($btn)
$btn.Add_Click({ Create-Bash-Shortcut "X-Dolphin" "x-application.sh dolphin" "dolphin.ico" "$destDir" })

# Add the tab control to the form
$Form.Controls.Add($TabControl)
# Calculate the size of the form based on the content
$Form.ClientSize = $TabControl.PreferredSize + $Form.Padding.Size + $TabControl.Location + $TabControl.Location
# Allow stretching of the tab control.
$TabControl.Anchor = 'Left', 'Right', 'Top', 'Bottom'

# Get the handle of the console window
$consoleHandle = [Win32]::GetConsoleWindow()
# Hide the console window
# [Win32]::ShowWindow($consoleHandle, [Win32]::SW_HIDE)

# Show the form
$result = $Form.ShowDialog()
#Write-Host "Result: $result"

Write-Host $destDir