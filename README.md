PowerShell
==========

Various Powershell Scripts

For different reasons. Scripts for starting/stopping Windows Services.

Start_Remote_Service

DESC: Checks if Service on Server is Started. 
    If FALSE: Start Service Based on Server/Service
    If TRUE : Report Service Already Started 
    
USAGE: FuncCheckService -ServiceName "ServiceToBeStarted" -Server "ServerName"

Stop_Remote_Service

DESC: Checks if Service on Server is Stopped. 
    If FALSE: Stop Service Based on Server/Service
    If TRUE : Report Service Already Stopped 
    
USAGE: FuncCheckService -ServiceName "ServiceToBeStopped" -Server "ServerName"
