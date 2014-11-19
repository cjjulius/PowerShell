PowerShell
==========

Various Powershell Scripts

For different reasons. Scripts for starting/stopping Windows Services.

<b>Start_Remote_Service.ps1</b>

DESC: <br>
Checks if Service on Server is Started. <br>
If FALSE: Start Service Based on Server/Service<br>
If TRUE : Report Service Already Started 
    
EXAMPLE USAGE:<br> 
FuncCheckService -ServiceName "ServiceToBeStarted" -Server "ServerName"

<b>Stop_Remote_Service.ps1</b>

DESC: <br>
Checks if Service on Server is Stopped. <br>
If FALSE: Stop Service Based on Server/Service<br>
If TRUE : Report Service Already Stopped 
    
EXAMPLE USAGE: <br>
FuncCheckService -ServiceName "ServiceToBeStopped" -Server "ServerName"

<b>IIS_Connection_Watcher.ps1</b>

DESC: <br>
Checks four webservers and then returns individual load percentage based on overall number of connections. Will write to event log if load for server is greater than the max load percentage.

Params: <br>
-forceWarning [switch] Forces a write to the event log regardless of outcome.<br>
-maxLoadPer [int] Value between 1-100 for maximum load a single server can have before writing to event log.
    
EXAMPLE USAGE: <br>
IIS_Connection_Watcher -maxLoadPer 60
