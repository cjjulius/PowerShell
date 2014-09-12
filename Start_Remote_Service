<# 

DESC: Checks if Service on Server is Started. 
    If FALSE: Start Service Based on Server/Service
    If TRUE : Report Service Already Started 
    
USAGE: FuncCheckService -ServiceName "ServiceToBeStarted" -Server "ServerName"

2014-06-12 - CEJ - Intial Version

#>

function FuncCheckService{
 param($ServiceName, $Server)
 $arrService = Get-Service -Name $ServiceName -ComputerName $Server
 if ($arrService.Status -ne "Running"){
 Get-Service -Name $ServiceName -ComputerName $Server | Set-Service -Status Running
 Write-Host "Starting " $ServiceName " service" 
 " ---------------------- " 
 " Service is now started"
 }
 if ($arrService.Status -eq "running"){ 
 Write-Host "$ServiceName service is already started"
 }
 }
 
FuncCheckService -ServiceName "SomeService" -Server "a.server.somewhere"
