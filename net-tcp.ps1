[CmdletBinding()]
param (
    [Alias("p")]
    [int]$PortNumber,

    [Alias("h")]
    [switch]$ShowHelp
)

function Get-NetTCPConnectionWithProcess 
{
    param 
    (
        [Parameter(ValueFromPipeline = $true)]
        [psobject]$connection
    )

    begin 
    {
        $filteredConnections = @()
    }

    process 
    {
				if ($PortNumber -and ($connection.LocalPort -eq $PortNumber -or $connection.RemotePort -eq $PortNumber)) 
        {
            $filteredConnections += $connection
        } 
        elseif (-not ($PortNumber -or $ProcessNamePattern)) 
        {
            $filteredConnections += $connection
        }
    }

    end 
    {
        foreach ($connection in $filteredConnections) 
				{
            $process = Get-WmiObject -Class Win32_Process -Filter "ProcessId = $($connection.OwningProcess)" -ErrorAction SilentlyContinue

            if ($process) 
            {
                $processInfo = @{
                    PID = $process.ProcessId
                    ProcessName = $process.Name
                    CommandLine = $process.CommandLine
                }
                $connection | Add-Member -NotePropertyMembers $processInfo
                $connection
            }
        }
    }
}

if ($ShowHelp) 
{
    Write-Host "Usage: net-tcp.ps1 [-p <port>] [-h]"
    Write-Host "Options:"
    Write-Host "  -p <port>                 Filter connections by the specified port number local or remote."
    Write-Host "  -h                        Show this help message."
    exit
}

Get-NetTCPConnection | Get-NetTCPConnectionWithProcess | Format-Table -AutoSize -Property LocalAddress, LocalPort, RemoteAddress, RemotePort, State, PID, ProcessName, CommandLine
