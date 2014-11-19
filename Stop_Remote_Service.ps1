<# 

DESC: Checks if Service on Server is Stopped. 
    If FALSE: Stop Service Based on Server/Service
    If TRUE : Report Service Already Stopped 
    
USAGE: FuncCheckService -ServiceName "ServiceToBeStopped" -Server "ServerName"

2014-06-12 - CEJ - Intial Version

#>

function FuncCheckService{
 param($ServiceName, $Server)
 $arrService = Get-Service -Name $ServiceName -ComputerName $Server
 if ($arrService.Status -ne "stopped"){
 Get-Service -Name $ServiceName -ComputerName $Server | Set-Service -Status stopped
 Write-Host "Stopping " $ServiceName " service" 
 " ---------------------- " 
 " Service is now Stopped"
 }
 if ($arrService.Status -eq "stopped"){ 
 Write-Host "$ServiceName service is already stopped"
 }
 }
 
FuncCheckService -ServiceName "SomeService" -Server "a.server.company"
