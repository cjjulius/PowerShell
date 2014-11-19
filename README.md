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

Parameters:	<br>
-forceWarning [switch] Forces a write to the event log regardless of outcome.<br>
-maxLoadPer [int] Value between 1-100 for maximum load a single server can have before writing to event log.
    
EXAMPLE USAGE: <br>
IIS_Connection_Watcher -maxLoadPer 60


autoMongoRestore
=================

DESC: <br>
autoMongoRestore is a set of scripts designed to set up a temporary mongo environment in Windows, restore a mongodump file and verify there is no corruption. Any errors generated are placed in the Event Log for handling. _Start should be loaded first and then a few minutes later _Run.

Requirements: <br>
•	Powershell 3.x or later installed.<br>
•	User with Local Admin permissions and Network access.

<b>autoMongoRestore_Start.ps1</b>

DESC:
Sets up environment capable of sustaining a mongod restore and Event Logging, starts the mongod instance, and then cleans up afterwards.

Parameters:	<br>
-restoreDir	Directory where mongod will temporarily store database files. Will be created if it does not exist.<br>
-mongoPath	Directory containing the mongo binary files. Will be created if it does not exist. Binary files will be pulled from the -mongoNetPath parameter if they do not exist. <br>
-mongoNetPath	Network Directory containing the mongo binary files to populate –mongoPath parameter.<br>

EXAMPLE USAGE: <br>
autoMongoRestore_Start -restoreDir C:\Dir\for\Temp\DB -mongoPath C:\mongo\bin -mongoNetPath \\\Server\with\binaries\

<b>autoMongoRestore_Run.ps1</b>

DESC:<br>
Restores mongodb from backup, reports errors to the Event Log and then shuts down mongod instance.

Parameters:	<br>
-dumpDir	Directory containing the mongodump files to be used in restore.<br>
-mongoPath	Directory containing the mongo binary files.<br>

EXAMPLE USAGE: <br>
autoMongoRestore_Run -dumpDir C:\Dir\with\mongodump -mongoPath C:\mongo\bin

