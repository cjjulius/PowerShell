#--------------------
#Owner: 	Charlton E Julius
#Updated:	2023-06-27
#Version: 	1.0
#Purpose: 	Starts/Stops services on remote server. 
#           If no Start/Stop will report status.
#--------------------

<#
    .PARAMETER Server
    Server being queried

    .PARAMETER Service
    Service being queried

    .PARAMETER Start
    Start Service (if not started)

    .PARAMETER Stop
    Stop Service (if not stopped)

    .PARAMETER Timeout
    Timeout in 'HH:MM:SS' format
#>
    
param(
    [string]$Server		= '.',				
    [string]$Service	= 'MSSQLSERVER',	
    [switch]$Start		= $false,			
    [switch]$Stop		= $false,			
    [string]$Timeout	= '00:03:00'		
)

#Initialize variables:
[string]$WaitingFor = ""
[string]$Verb = ""
[string]$Result = "FAILED"

#Get service information
$svc = (get-service -computername $Server -name $Service)

If (!$Start -and !$Stop)	#If both false, just check status.
    {
    Write-host "$Service on $Server is $($svc.status)"
    }
else	#else, try to start/stop
    {
    Write-host "$Service on $Server is $($svc.status)"
    Switch ($svc.status) 
        {
        'Stopped' 
        {
            Switch($Start)
                {
                $true 
                    {
                    Write-host "Starting $Service..."
                    $Verb = "start"
                    $WaitingFor = 'Running'
                    $svc.Start()
                    }
                $false
                    {
                    Write-host "Already Stopped..."
                    }
                }
        }
        'Running' 
            {
            Switch($Stop) 
                {
                $true 
                    {
                    Write-host "Stopping $Service..."
                    $Verb = "stop"
                    $WaitingFor = 'Stopped'
                    $svc.Stop()
                    }
                $false 
                    {
                    Write-host "Already started..."
                    }
                }
            }
        Default 	#Should never get here. But if you do, do nothing.
            {
            Write-host "$Service is $($svc.status).  Taking no action."
            }
        }
    if ($WaitingFor -ne "") 	#Wait for a time
        {
        Try 
            {
            $svc.WaitForStatus($WaitingFor,$Timeout)
            } 
        Catch 
            {
            Write-host "After waiting for $Timeout, $Service failed to $Verb."
            }
        $svc = (get-service -computername $Server -name $Service)
        if ($svc.status -eq $WaitingFor) 
            {
            $Resuldt = 'SUCCESS'
            }
        Write-host "$Result`: $Service on $Server is $($svc.status)"
        }
    }
