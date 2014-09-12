PowerShell
==========

Various Powershell Scripts

For different reasons. Scripts for starting/stopping Windows Services.

<b>Start_Remote_Service</b>

DESC: Checks if Service on Server is Started. 
    If FALSE: Start Service Based on Server/Service
    If TRUE : Report Service Already Started 
    
USAGE: FuncCheckService -ServiceName "ServiceToBeStarted" -Server "ServerName"

<b>Stop_Remote_Service</b>

DESC: Checks if Service on Server is Stopped. 
    If FALSE: Stop Service Based on Server/Service
    If TRUE : Report Service Already Stopped 
    
USAGE: FuncCheckService -ServiceName "ServiceToBeStopped" -Server "ServerName"
