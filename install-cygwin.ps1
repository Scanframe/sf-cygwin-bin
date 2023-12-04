param (
	[string]$elevated,
	[string]$wingetexe
)

# Clear the console.
Clear

# When not set get it.
if (-not$wingetexe)
{
	#$wingetexe = Get-WGPath
	$wingetexe = (Get-Command winget).Source
}

# Sanity check on passed and invalid arguments.
if ($MyInvocation.UnboundArguments.Count)
{
	Write-Host "Error: Invalid arguments given!"
	Exit 1
}

# Local copy the current script.
$ThisScript = $MyInvocation.MyCommand.Path

function PressAnyKey
{
	Write-Host -NoNewLine 'Press any key to continue...';
	$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}

function WinStore-Open
{
	param ([string]$appName)
	$AppName = "App Installer"
	Start-Process "ms-windows-store://search?query=$appName"
	$process = Get-Process -Name WinStore.App
	if ($process -ne $null)
	{
		Write-Host "Waiting for Microsoft Store to close..."
		$process.WaitForExit()
		Write-Host "Microsoft Store has been closed."
	}
}

function Is-WinGet-PackageInstalled
{
	param ([string]$appId)
	# Get the list of installed apps
	(& "$wingetexe" list --id "$appId") | Out-Null
	if ($LASTEXITCODE -eq 0)
	{
		# The app was installed using the exact app id
		Write-Host "The app with id '$appId' was installed."
		Return $True
	}
	else
	{
		# The app was not installed using the exact app ID
		Write-Host "The app with id '$appId' was NOT installed!"
		Return $False
	}
}

function Install-Cygwin-Web
{
	param ([switch]$update)
	$rootDir = "${env:SystemDrive}\cygwin64"
	$installDir = "${env:USERPROFILE}\lib\Cygwin"
	$url = "https://www.cygwin.com/setup-x86_64.exe"
	$setupExe = "$installDir\setup-x86_64.exe"
	# When the installer already exists do nothing.
	if (-not(Test-Path -Path "$setupExe"))
	{
		Write-Host "Installing Cygwin setup into: $installDir"
		# Create directory when it does not exist.
		New-Item -ItemType Directory -Path "$installDir"
		Write-Host "Downloading ($setupExe): $url"
		#Invoke-WebRequest -Uri "$url" -OutFile "$setupExe" -UseBasicParsing
		(New-Object Net.WebClient).DownloadFile("$url", "$setupExe")
	}
	else
	{
		Write-Host "Cygwin setup exsits in: $installDir"
	}
	# When update is required do this step anyway.
	if ($update -or -not(Test-Path -Path "$rootDir"))
	{
		# Start the Cygwin setup in unattended mode
		$packages = @(
			"git",
			"wget",
			"openssh",
			"bash-completion",
			"jq",
			"psmisc", # For killall
			"procps",
			"libproc2-0",
			"joe",
			"mc",
			"xorg-server",
			"xterm"
		)
		$arguments = @(
			"--no-admin",
			"--quiet-mode",
			"--upgrade-also",
			"--local-package-dir `"$installDir\pkgs`"",
			"--packages $( $packages -join "," )",
			"http://cygwin.mirrors.hoster.net"
		)
		$process = Start-Process -Wait -FilePath "$setupExe" -ArgumentList "$( $arguments -join " " )"
		# Get the exit code and return true when zero.
		return ($process.ExitCode -eq 0)
	}
	else
	{
		Write-Host "Cygwin root '$rootDir' exists, skipping install."
	}
	return $True
}

function WinGet-InstallPackage
{
	param ([string]$appId)
	$result = Is-WinGet-PackageInstalled("$appId")
	if (-not$result)
	{
		Write-Host "$appId is not installed and is installing..."
		#& "$wingetexe" install --disable-interactivity --ignore-security-hash --exact --id "$appId"
		& "$wingetexe" install --exact --id "$appId"
		#Write-Host "Exitcode: $LASTEXITCODE"
	}
	# REturn true when the exitcode is zero.
	Return ($LASTEXITCODE -eq 0)
}

function Run-Section-Elevated
{
	param ([string]$section)
	# Check if the script is running as administrator, if not, relaunch it with elevated privileges
	if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
	{
		# Run the script with elevated privileges
		$process = Start-Process -Wait -Verb RunAs -FilePath "powershell.exe" `
			-ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$ThisScript`" -elevated `"$section`" -wingetexe `"$wingetexe`""
		# Get the exit code and return true when zero.
		return ($process.ExitCode -eq 0)
	}
}

# Check if an elevation  is provided
if ($elevated)
{
	$exit_code = 0
	Write-Host "Running elevated command with argument: $elevated"
	switch ($elevated)
	{
		"info"
		{
			# Show the winget information.
			& "$wingetexe" --info --wait
		}

		default
		{
			Write-Host "Elevation option '$elevated' is not implemented!"
			$exit_code = 1
		}
	}
	# Prompt the user when exit code is non-zero.
	if ($exit_code)
	{
		PressAnyKey
	}
	# Signal the caller.
	Exit $exit_code
}

# Function return True when winget is installed.
function Is-WinGet-Installed
{
	Return Get-Command winget -ErrorAction SilentlyContinue
}

# Check if WinGet is already installed
if (-not(Is-WinGet-Installed))
{
	# Install WinGet using the Windows store.
	Write-Host "Winget is NOT installed, starting the Windows store."
	WinStore-Open "App Installer"
}

# Check if WinGet was installed from the store.
if (-not(Is-WinGet-Installed))
{
	Write-Host "WinGet was not installed from the Windows Store, bailing out!"
	Exit 1
}

function Cygwin-Configure
{
	$repoCygwinBin = "https://github.com/Scanframe/sf-cygwin-bin.git"
	$rootDir = "${env:SystemDrive}\cygwin64"
	$filePath = "$rootDir\etc\nsswitch.conf"
	$homeDir = "${env:USERPROFILE}\cygwin"
	$binDir = "${env:USERPROFILE}\cygwin\bin"
	$line = "db_home: /cygdrive/c/Users/%u/cygwin"
	if (-not(Test-Path -Path $filePath))
	{
		Write-Host "File '$filePath' not found to append!"
		Return $False
	}
	# REad the file in an array.
	$lines = Get-Content -Path $filePath
	if (($lines | Where-Object { $_ -eq $line }).Count -eq 0)
	{
		Write-Host "Adding line for home directory to file '$filePath'."
		Add-Content -Path "$filePath" -Value "$line"
	}
	# Create cygwin home directory when it does not exist.
	if (-not(Test-Path -Path $homeDir))
	{
		Write-Host "Creating home directory '$homeDir'."
		New-Item -ItemType Directory -Path $homeDir
	}
	# Create cygwin home directory when it does not exist.
	if (-not(Test-Path -Path $binDir))
	{
		Set-Location "${homeDir}"
		& "${rootDir}\bin\bash" --login -c "/usr/bin/git clone ${repoCygwinBin} bin"
		# Check if the command was executed without an error.
		if ($LASTEXITCODE -ne 0)
		{
			Return $False
		}
		# Sanity check if the directory exists.
		if (Test-Path -Path $binDir)
		{
			Write-Host "Copying profile files to '$homeDir'."
			Copy-Item -Path "$binDir\.bash_profile", "$binDir\.bashrc" -Destination $homeDir
		}
	}
	Return $True
}

# Initialize the return value.
$retval = $True
# Install the multi tab terminal.
$retval = $retval -and (WinGet-InstallPackage "Microsoft.WindowsTerminal")
#$retval = $retval -and (Install-Cygwin-Web -update)
$retval = $retval -and (Install-Cygwin-Web)
$retval = $retval -and (Cygwin-Configure)
