#!pwsh-shebang.sh

param (
	[switch]$debug
)

# Clear the console.
Clear

# Local copy the current script.
$ThisScript = $MyInvocation.MyCommand.Path

# Switch on debug printing when env var 'DBG_PRINT' equals '1'.
if ($debug -or ("${env:DBG_PRINT}" -eq "1"))
{
	$DebugPreference = 'Continue'
}

# Location of winget executable.
$wingetexe = (Get-Command winget).Source

# Sanity check on passed and invalid arguments.
if ($MyInvocation.UnboundArguments.Count)
{
	Write-Host "Error: Invalid arguments given!"
	Exit 1
}

# Returns the name of the calling function.
function Get-FunctionName([int]$StackNumber = 1)
{
	return [string]$( Get-PSCallStack )[$StackNumber].FunctionName
}

function PressAnyKey
{
	Write-Host -NoNewLine 'Press any key to continue...';
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

# Open the Windows store.
function WinStore-Open
{
	param ([string]$appName)
	$AppName = "App Installer"
	$process = Start-Process -PassThru "ms-windows-store://search?query=$appName"
	if ($process -ne $null)
	{
		Write-Host "Waiting for Microsoft Store to close..."
		$process.WaitForExit()
		Write-Host "Microsoft Store has been closed."
	}
}

function Cygwin-WebInstall
{
	param ([switch]$update)
	$rootDir = "${env:SystemDrive}\cygwin64"
	$installDir = "${env:USERPROFILE}\lib\Cygwin"
	$setupDir = "${rootDir}\etc\setup"
	$setupFile = "${setupDir}\setup.rc"
	$url = "https://www.cygwin.com/setup-x86_64.exe"
	$setupExe = "$installDir\setup-x86_64.exe"
	# When the installer already exists do nothing.
	if ($update -or -not (Test-Path -Path $setupExe))
	{
		Write-Host "Installing Cygwin setup into: ${installDir}"
		if (-not (Test-Path -Path $installDir))
		{
			# Create directory when it does not exist.
			New-Item -ItemType Directory -Path $installDir
		}
		# When updating remove the current setup executable.
		if ($update -and (Test-Path -Path $setupExe))
		{
			Write-Debug "$( Get-FunctionName ): Removing old file: ${setupExe}"
			Remove-Item $setupExe
		}
		Write-Host "Downloading ($setupExe): $url"
		#Invoke-WebRequest -Uri "$url" -OutFile "$setupExe" -UseBasicParsing
		(New-Object Net.WebClient).DownloadFile($url, $setupExe)
	}
	else
	{
		Write-Debug "$( Get-FunctionName ): Cygwin setup exists in: $installDir"
	}
	# When update is required do this step anyway.
	if ($update -or -not (Test-Path -Path "${rootDir}/Cygwin.bat"))
	{
		# Start the Cygwin setup in unattended mode
		$packages = @(
			"git",
			"wget",
			"openssh",
			"bash-completion",
			"xorg-server",
			"joe",
			"vim",
			"mc",
			"xterm",
			"psmisc",
			"procps",
			"procps-ng",
			"libproc2-0",
			# Needed for building CMake projects using shell script.
			"jq",
			"dialog",
			"perl-Image-ExifTool"
		)
		$arguments = @(
			"--no-admin",
			"--quiet-mode",
			"--upgrade-also",
			"--local-package-dir `"$installDir\pkgs`"",
			"--packages $( $packages -join "," )",
			"--site http://ftp.snt.utwente.nl/pub/software/cygwin/"
		)
		# The '-PassThru' options is needed to make it return the 'System.Diagnostics.Process' object.
		$process = Start-Process -Wait -PassThru -FilePath $setupExe -ArgumentList "$( $arguments -join " " )"
		Write-Debug "$( Get-FunctionName ): Exit-code: 0x$($process.ExitCode.ToString("X") )"
		# Get the exit code and return true when zero.
		return ($process.ExitCode -eq 0)
	}
	else
	{
		Write-Host "Cygwin is installed exists, skipping install."
	}
	return $True
}

# Checks if a WinGet package is installed.
function WinGet-IsPackageInstalled
{
	param ([string]$appId)
	Write-Debug "$( Get-FunctionName ): Checking if application with id '${appId}' is installed."
	<#
	# Get the list the installed app from the list.
	$process = Start-Process -Wait -PassThru -Verb RunAs -FilePath $wingetexe -ArgumentList "list --accept-source-agreements --exact --id `"$appId`""
	$exitcode = $process.ExitCode
#>
	# Get the list the installed app from the list.
	(& "$wingetexe" list --disable-interactivity --accept-source-agreements --exact --id "$appId") | Out-Null
	$exitcode = $LASTEXITCODE
	# Get the exit code and return true when zero.
	Write-Debug "$( Get-FunctionName ): Exitcode 0x$($exitcode.ToString("X") )"
	if ($exitcode -eq 0)
	{
		# The app was installed using the exact app id
		Write-Host "The app with id '$appId' is installed."
		Return $True
	}
	# The app was not installed using the exact app ID
	Write-Host "The app with id '$appId' is NOT installed."
	Return $False
}

# Installs a WinGet package when not installed already.
function WinGet-InstallPackage
{
	param (
		[switch]$update,
		[string]$appId
	)
	$result = (WinGet-IsPackageInstalled "$appId")
	if (-not $result)
	{
		Write-Host "Installing '${appId}' ..."
		&"$wingetexe" install --disable-interactivity --accept-source-agreements --accept-package-agreements --exact --id "$appId"
		$result = $LASTEXITCODE -eq 0
		Write-Debug "$( Get-FunctionName ): Exitcode 0x$($LASTEXITCODE.ToString("X") )"
		# Check for error 'APPINSTALLER_CLI_ERROR_SOURCE_AGREEMENTS_NOT_ACCEPTED'.
		if ("0x$($LASTEXITCODE.ToString("X") )" -eq "0x8A150046")
		{
			Write-Host "$( Get-FunctionName ): Failed, please Run 'winget' to accept the agreemment first for winget?"
		}
	}
	else
	{
		if ($update)
		{
			Write-Host "Upgrading '${appId}' ..."
			& "$wingetexe" update --disable-interactivity --exact --id "$appId"
			$result = $LASTEXITCODE -eq 0
		}
	}
	Return $result
}

# Function return True when winget is installed.
function WinGet-IsInstalled
{
	Return ((Get-Command -ErrorAction SilentlyContinue winget) -ne $Null)
}

# Check if WinGet is already installed
if (-not (WinGet-IsInstalled))
{
	# Install WinGet using the Windows store.
	Write-Host "Winget is NOT installed, starting the Windows store."
	WinStore-Open "App Installer"
	# Check if WinGet was installed from the store.
	if (-not (WinGet-IsInstalled))
	{
		Write-Host "WinGet was not installed from the Windows Store, bailing out!"
		Exit 1
	}
}
# When installed check the minimal version.
else
{
	# Match the version string.
	if (-not ((& "${wingetexe}" --version) -match "^v(.+)$"))
	{
		Write-Host "Could not determine WinGet version, bailing out!"
	}
	else
	{
		$winget_ver = $matches[1];
		Write-Host "Winget installed version '${winget_ver}'."
		# Compare needed winget version with what is needed.
		if ([System.Version]$winget_ver -lt [System.Version]"1.6.3133")
		{
			Write-Host "Winget version '${matches[1]}' less than '1.6.3133', upgrade winget first!"
		}
	}
}

# Installs Cygwin and configures it.
function Cygwin-Configure
{
	param ([switch]$update)
	$repoCygwinBin = "https://github.com/Scanframe/sf-cygwin-bin.git"
	$rootDir = "${env:SystemDrive}\cygwin64"
	$filePath = "$rootDir\etc\nsswitch.conf"
	$homeDir = "${env:USERPROFILE}\cygwin"
	$binDir = "${env:USERPROFILE}\cygwin\bin"
	$line = "db_home: /cygdrive/c/Users/%u/cygwin"
	if (-not (Test-Path -Path $filePath))
	{
		Write-Host "File '$filePath' not found to append!"
		Return $False
	}
	Write-Debug "$( Get-FunctionName ): Checking file '$filePath'."
	# Read the file in an array.
	$lines = Get-Content -Path $filePath
	if (($lines | Where-Object { $_ -eq $line }).Count -eq 0)
	{
		Write-Host "Adding line for home directory to file '$filePath'."
		Add-Content -Path "$filePath" -Value "$line"
	}
	else
	{
		Write-Host "Line for home directory already exists in file '$filePath'."
	}
	# Create cygwin home directory when it does not exist.
	if (-not (Test-Path -Path $homeDir))
	{
		Write-Host "Creating home directory '$homeDir'."
		New-Item -ItemType Directory -Path $homeDir
	}
	else
	{
		Write-Host "Home directory '$homeDir' exists."
	}
	# Create cygwin home directory when it does not exist.
	if (-not (Test-Path -Path $binDir))
	{
		Write-Host "Cloning 'bin' repository to create '${homeDir}\bin' directory."
		& "${rootDir}\bin\bash" --login -c "/usr/bin/git clone ${repoCygwinBin} ~/bin"
		# Check if the command was executed without an error.
		if ($LASTEXITCODE -ne 0)
		{
			Return $False
		}
	}
	# When the directory exists and update is requested.
	elseif ($update)
	{
		Write-Host "Pulling '${homeDir}\bin' repository to update."
		& "${rootDir}\bin\bash" --login -c "/usr/bin/git -C ~/bin pull"
		# Check if the command was executed without an error.
		if ($LASTEXITCODE -ne 0)
		{
			Return $False
		}
	}
	# Sanity check if the directory exists.
	if (Test-Path -Path $binDir)
	{
		Write-Host "Checking profile files in '$homeDir'."
		if (-not (Test-Path -Path "${homeDir}\.bash_profile"))
		{
			Write-Host "Copying '.bash_profile'."
			Copy-Item -Path "$binDir\.bash_profile" -Destination $homeDir
		}
		if (-not (Test-Path -Path "${homeDir}\.bashrc"))
		{
			Write-Host "Copying '.bashrc'."
			Copy-Item -Path "$binDir\.bashrc" -Destination $homeDir
		}
	}
	Write-Debug "$( Get-FunctionName ): Cygwin user configuration done."
	Return $True
}

# Fix for allowing winget to install from the msstore.
function FixWingetMicrosoftStore
{
	$keyLocationLong = "HKEY_LOCAL_MACHINE"
	$keyLocationShort = "HKLM:"
	$keyPath = '\SOFTWARE\Policies\Microsoft\Windows\AppInstaller'
	$keyName = 'EnableBypassCertificatePinningForMicrosoftStore'
	$value = Get-ItemPropertyValue -Path "${keyLocationShort}${keyPath}" -Name $keyName -ErrorAction SilentlyContinue
	if ($value -eq $null)
	{
		Write-Host "Key '${keyLocationShort}${keyPath} ${keyName}' does not exist yet."
		# This command needs elevation and is not possible in a simple way.
		#New-ItemProperty -Path $key -Name $keyName -Value 1 -PropertyType DWORD -Force
		# Create a temporary file.
		$regFilePath = New-TemporaryFile
		# Write a registry file to be imported using regedit.
		Out-File -FilePath $regFilePath -Encoding UTF8 -InputObject @"
Windows Registry Editor Version 5.00

[${keyLocationLong}${keyPath}]
"${keyName}"=dword:00000001

"@
		Write-Host "Creation of registry key to enable installing from the Microsoft Store using Winget."
		# Run the registry editor to import the given file.
		$process = Start-Process -Wait -PassThru -Verb RunAs -FilePath regedit.exe -ArgumentList "/s ${regFilePath}"
		# Signal success or failure.
		if ($process.ExitCode -ne 0)
		{
			Return $False
		}
		# Check if the key was created properly.
		$value = Get-ItemPropertyValue -Path "${keyLocationShort}${keyPath}" -Name $keyName -ErrorAction SilentlyContinue
		if ($value -ne 1)
		{
			Write-Host "Registry key failed to create."
			Return $False
		}
		Write-Host "Registry key '${keyLocationShort}${keyPath}>${keyName}' is created."
		Return $True
	}
	Write-Host "Registry key '${keyLocationShort}${keyPath}>${keyName}' already exists."
	Return $True
}


# Add a Cygwin profile to the Windows Terminal settings JSON-file.
function WindowsTerminal-CygwinProfile
{
	# Settings file used by the terminal.
	$filepath = "${env:LOCALAPPDATA}\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
	# Check if the settings file exists.
	if (-not (Test-Path -Path $filepath))
	{
		@'
#################################################
##
## Please close the 'Windows Terminal' to continue.
##
#################################################
'@ | Write-Host

		# Run the terminal to let the app create the settings.json file.
		Start-Process -Wait -PassThru -NoNewWindow -FilePath "wt.exe" -ArgumentList "--version"
		# Check for the 2nd time.
		if (-not (Test-Path -Path $filepath))
		{
			Write-Error "Windows Terminal settings file not found '${filepath}'!"
			Return $False
		}
	}
	# Created a saved copy whenit does not exists yet.
	if (-not (Test-Path -Path "${filepath}-saved"))
	{
		Write-Debug "$( Get-FunctionName ): Creating saved copy of Terminal settings file."
		Copy-Item -Path $filepath -Destination "${filepath}-saved"
	}
	$json = ConvertFrom-Json -InputObject (Get-Content -Raw "${filepath}")
	# GUID used for the new Cygwin entry.
	$guid = "{33b60e88-5fba-42a1-8dff-bc5ab4520fc6}"
	# Check if the GUID Cygwin entry exists.
	if (($json.profiles.list | where { $_.guid -eq "$guid" }) -eq $null)
	{
		Write-Debug "$( Get-FunctionName ): Terminal Cywin entry not found, adding it..."
		# Add entry to the list.
		$obj = @'
{
	"guid": "",
	"commandline": "",
	"hidden": false,
	"name": "Cygwin",
	"font": {
		"face": "Lucida Console",
		"size": 11.0
	},
	"icon": ""
}
'@ | ConvertFrom-Json
		# Update the object properties.
		$obj.guid = $guid
		$obj.commandline = "${env:SystemDrive}\cygwin64\Cygwin.bat"
		$obj.icon = "${env:SystemDrive}\cygwin64\Cygwin-Terminal.ico"
		# Append the new object to the profile list.
		$json.profiles.list = $json.profiles.list + $obj
		# Make the new entry the default one.
		$json.defaultProfile = $guid
		# Convert to json adding depth because without it the objects are not converted corerctly.
		(ConvertTo-Json -Depth 32 -InputObject $json).Replace("`r`n", "`n")  | Out-File -Encoding UTF8 -Filepath $filepath -NoNewline
		Write-Debug "$( Get-FunctionName ): Making new Cygwin entry the default."
	}
	Return $True
}

$choice = ($Host.UI.PromptForChoice("Cygwin Installation", 'Are you sure you want to proceed?', ('&No', '&Yes', '&Update'), 0))
if ($choice -ne 0)
{
	Write-Host "Installing Cygwin and related applications..."
	Write-Debug "Winget location: ${wingetexe}"
	# Initialize the return value.
	$retval = $True
	# Install Cygwin using the web download.
	if ($retval -and $choice -eq 2)
	{
		# Install Cygwin using the web download doing an update.
		$retval = Cygwin-WebInstall -update
	}
	else
	{
		# Install Cygwin using the web download.
		$retval = Cygwin-WebInstall
	}
	# Configure Cygwin for this user.
	if ($retval -and $choice -eq 2)
	{
		$retval = Cygwin-Configure -update
	}
	else
	{
		$retval = Cygwin-Configure
	}
	# Fix the winget for installing from the Microsoft Store.
	if ($retval)
	{
		$retval = FixWingetMicrosoftStore
	}
	# Install the multi tab Windows terminal.
	if ($retval -and $choice -eq 2)
	{
		$retval = WinGet-InstallPackage -update "Microsoft.WindowsTerminal"
	}
	else
	{
		$retval = WinGet-InstallPackage "Microsoft.WindowsTerminal"
	}
	# Add the Cygwin profile and make it the default.
	if ($retval -and (WinGet-IsPackageInstalled "Microsoft.WindowsTerminal"))
	{
		$retval = WindowsTerminal-CygwinProfile
	}
<#
	# The notepad++ shell script installs it when not present.
	if ($retval -and $choice -eq 2)
	{
		$retval = WinGet-InstallPackage -update "Notepad++.Notepad++"
	}
	else
	{
		$retval = WinGet-InstallPackage "Notepad++.Notepad++"
	}
#>
	#
	if (-not $retval)
	{
		Write-Error "Failed installing!"
		Exit 1
	}
	Exit 0
}
else
{
	Write-Host 'Cygwin installation is cancelled.'
}

