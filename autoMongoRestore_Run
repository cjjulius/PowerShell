#
#     Restores test instance and tests. Kills mongoDB when done
#     
#     Created by Charlton Julius
#     V 1.0: 2014-11-17 - Initial Version


param (
    [string]$dumpDir = "C:\data\dump\test\",
    [string]$mongoPath = "C:\mongodb\bin"
)

#Removes mongod.lock from dump if included.
if (Test-Path $dumpDir\mongod.lock) {

 Remove-Item $dumpDir\mongod.lock

}

cd $mongoPath

#Restore files. Does stderr trickery to make PS report CMD errors
$someerror = CMD /C "mongorestore.exe --port 27017 $dumpDir --quiet" 2>&1


#Shutdown the server so autoMongoRestore_Start can continue
CMD /C "mongo admin --port 27017 --eval `"db.shutdownServer()`""


#If error, report it
if($someerror) {
    Write-EventLog -LogName Application -Source "MongoDB Auto-Restore" -EntryType Warning -EventId 10010 -Message "Mongo Auto-Restore: `n$someerror"
}
