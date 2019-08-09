# 
# To Debug this script in PowerShell ISE you need to change the execution policy
# by executing this command in an elevated PowerShell.
#      Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine
#

function Create-Shortcut([string] $exePath, [string] $arguments, [string] $target, [string] $iconPath)
{
    #New-Object : Creates an instance of a Microsoft .NET Framework or COM object.
    #-ComObject WScript.Shell: This creates an instance of the COM object that represents the WScript.Shell for invoke CreateShortCut
    $ws = New-Object -ComObject WScript.Shell
    # Create the shortcut and fill in the properties.
    $sc = $ws.CreateShortcut($target)
    $sc.TargetPath = $exePath
    $sc.Arguments = $arguments
    $sc.IconLocation = $iconPath
    $sc.Save()
 }

# Must be more then one entry befor the foreach loop does what it should do. %$Q!!@%$1342
$links = @( 
    ("Google-Drive", "https://drive.google.com/", "google-drive.ico"), 
    ("WhatsApp", "https://web.whatsapp.com/", "whatsapp.ico") 
)

$chromePath = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
$desktopDir= [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop);

foreach ($lnk in $links)
{
    Create-Shortcut $chromePath "--app=""$($lnk[1])""" "${desktopDir}\$($lnk[0]).lnk" "${PSScriptRoot}\img\$($lnk[2])"
}

exit 0
