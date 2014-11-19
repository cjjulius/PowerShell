#
#     Sets up and tears down mongoDB instance for restoration checking
#     
#     Created by Charlton Julius
#     V 1.0: 2014-11-17 - Initial Version


 param (
    [string]$restoreDir = "C:\data\db",
    [string]$mongoPath = "C:\mongo\bin",
    [string]$mongoNetPath = "\\NetworkPath\mongo\bin"
 )



#Create MongoDB Binary Directory if it doesn't exist
if (!(Test-Path $mongoPath)) {

    New-Item -Path $mongoPath -Type Directory
     
}

#Create Mongo Restore Directory if it doesn't exist.
if (!(Test-Path $restoreDir)) {

    New-Item -Path $restoreDir -Type Directory
     
}

#Check mongo, mongod and mongorestore exe's
#and copy from Network Location if they do not exist.
if(!(Test-Path $mongoPath\mongo.exe)) {

    Copy-Item $mongoNetPath\mongo.exe $mongoPath

}

if(!(Test-Path $mongoPath\mongod.exe)) {

    Copy-Item $mongoNetPath\mongod.exe $mongoPath

}

if(!(Test-Path $mongoPath\mongorestore.exe)) {

    Copy-Item $mongoNetPath\mongorestore.exe $mongoPath

}

cd $mongoPath

#Creates Event Log if it does not already exist
if (!(Get-Eventlog -LogName "Application" -Source "MongoDB Auto-Restore")){
    New-Eventlog -LogName "Application" -Source "MongoDB Auto-Restore"
 }

#Starts up mongod instance. 
#Will pause here until autoMongoRestore_Run kills the process.
CMD /C "mongod.exe --port 27017 --smallfiles --dbpath $restoreDir"

#Cleanup. Leaves logs.

#Clears Namespaces
Remove-Item $restoreDir\*.ns

#Removes mongod.lock if there is one 
#Should mongod.lock exist it will cause the restore to fail
    if (Test-Path $restoreDir\mongod.lock) {

        Remove-Item $restoreDir\mongod.lock
     
    }

#Clears database parts up to 250 pieces ~500GB
$i = 0
do {

    if (Test-Path $restoreDir\*.$i) {

        Remove-Item $restoreDir\*.$i
     
    }
    else {break}

    $i++

}
while ($i -lt 250) 
