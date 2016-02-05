#--------------------
#Owner: Charlton E Julius
#Date: 2015-12-21
#Purpose: Fills Repository with server\instance.database information
#--------------------

cls

$RepositoryInstance = '(local)'
$RepositoryDB = 'DBAdmin'

Write-Host "Starting Up..."

#############################
#  CONVERT WMI TO DATATABLE
#	Source: https://github.com/Proxx/PowerShell/blob/master/Common/Get-Type.ps1
#############################

function Get-Type 
{ 
    param($type) 
 
	$types = @( 
	'System.Boolean', 
	'System.Byte[]', 
	'System.Byte', 
	'System.Char', 
	'System.Datetime', 
	'System.Decimal', 
	'System.Double', 
	'System.Guid', 
	'System.Int16', 
	'System.Int32', 
	'System.Int64', 
	'System.Single', 
	'System.UInt16', 
	'System.UInt32', 
	'System.UInt64') 
 
    if ( $types -contains $type ) 
	{ 
        Write-Output "$type" 
    } 
    else 
	{ 
        Write-Output 'System.String' 
    } 
} 

#############################
#CONVERT WMI-OBJ TO DATATABLE
#	Source: http://poshcode.org/2119
#############################

function Out-DataTable 
{ 
    [CmdletBinding()] 
    param([Parameter(Position=0, Mandatory=$true, ValueFromPipeline = $true)] [PSObject[]]$InputObject) 
 
    Begin 
    { 
        $dt = new-object Data.datatable   
        $First = $true  
    } 
    Process 
    { 
        foreach ($object in $InputObject) 
        { 
            $DR = $DT.NewRow()   
            foreach($property in $object.PsObject.get_properties()) 
            {   
                if ($first) 
                {   
                    $Col =  new-object Data.DataColumn   
                    $Col.ColumnName = $property.Name.ToString()   
                    if ($property.value) 
                    { 
                        if ($property.value -isnot [System.DBNull]) 
						{ 
                            $Col.DataType = [System.Type]::GetType("$(Get-Type $property.TypeNameOfValue)") 
                        } 
                    } 
                    $DT.Columns.Add($Col) 
                }   
                if ($property.Gettype().IsArray) 
				{ 
                    $DR.Item($property.Name) =$property.value | ConvertTo-XML -AS String -NoTypeInformation -Depth 1 
                }   
                else 
				{ 
                    $DR.Item($property.Name) = $property.value 
                } 
            }   
            $DT.Rows.Add($DR)   
            $First = $false 
        } 
    }    
    End 
    { 
        Write-Output @(,($dt)) 
    } 
}

#############################
#	  Run SQL Commands
#	Based on: https://github.com/Proxx/PowerShell/blob/master/Network/Invoke-SQL.ps1
#############################
function Invoke-SQL 
{
    param
	(
        [string] $dataSource,
        [string] $database,
        [string] $sqlCommand
    )
    $connectionString = "Data Source=$dataSource; " +
            "Integrated Security=SSPI; " +
            "Initial Catalog=$database"

    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $connection.Open()

    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataSet) | Out-Null

    $connection.Close()
    $dataSet.Tables

}

#############################
#	  GET INSTANCE INFO
#############################

Write-Host "Collecting Instance Information..."

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
EXEC dbo.prGetConnectionInformation;
"

foreach ($Row in $ConnectionString.Rows)
{ 
	Try
	{
		$SubConnection = $($Row[0]) -replace '\\MSSQLSERVER',''
	  	$InstanceID = $($Row[2])
	  	Write-Debug $InstanceID
	  	Write-Debug $SubConnection
	  	$Version = Invoke-SQL -datasource $SubConnection -database master -sqlCommand  "
		SELECT  SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition'), @@VERSION
		"		
	}
	Catch [System.Data.SqlClient.SqlException]
	{
		Write-Host "Cannot Collect Information on $SubConnection"
		Write-Debug "$_"
	}

	foreach ($Row in $Version.Rows)
	{ 
		$MSSQLVersion = $($Row[0])
		$MSSQLServicePack = $($Row[1])
		$MSSQLEdition = $($Row[2])
		$MSSQLVersionLong = $($Row[3])
		Write-Debug $MSSQLVersionLong
		Write-Debug $MSSQLVersion
		Write-Debug $MSSQLServicePack
		
		Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand "
		EXEC dbo.prUpdateInstanceList 
			 @MSSQLVersionLong = '$MSSQLVersionLong'
			,@MSSQLVersion = '$MSSQLVersion'
			,@MSSQLEdition = '$MSSQLEdition'
			,@MSSQLServicePack = '$MSSQLServicePack'
			,@InstanceId = $InstanceID	
	"
	}
}

#############################
#	 GET DATABASE INFO
#############################

Write-Host "Collecting Database Information..."

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
TRUNCATE TABLE dbo.DatabaseList;
EXEC dbo.prGetConnectionInformation;
"

foreach ($Row in $ConnectionString.Rows)
{ 
	Try
	{
		$SubConnection = $($Row[0]) -replace '\\MSSQLSERVER',''
	  	$InstanceID = $($Row[2])
	  	Write-Debug $InstanceID
	  	Write-Debug $SubConnection
	  	$DataPull = Invoke-SQL -datasource $SubConnection -database master -sqlCommand  "
		with fs
		as
		(
		    select database_id, type, size * 8.0 / 1024 size
		    from sys.master_files
		)
		select 
			$InstanceID AS 'InstanceId',
			name,
		    (select sum(size) from fs where type = 0 and fs.database_id = db.database_id) AS DataFileSizeMB
		from sys.databases db
		ORDER BY DataFileSizeMB
		"		
	}
	Catch [System.Data.SqlClient.SqlException]
	{
		Write-Host "Cannot Collect Information on $SubConnection"
		Write-Debug "$_"
	}

	foreach ($Row in $DataPull.Rows)
	{ 
		$Size = $Row[2]
		$DatabaseName = $($Row[1])
		$InstanceListId = $Row[0]
		Write-Debug $DatabaseName
		Write-Debug $InstanceListId

		Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand "
		EXEC dbo.prInsertDatabaseList
			 @DatabaseName = '$DatabaseName'
			,@InstanceListId = '$InstanceListId'
			,@Size = $Size
		
		"
	}
}

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
TRUNCATE TABLE dbo.ServiceList;
EXEC prGetServerNames;
"

#############################
#		GET SERVICE INFO
#############################

Write-Host "Collecting Server Information..."

foreach ($Row in $ConnectionString.Rows)
{ 
	If (Test-Connection  $($Row[0]) -Count 1 -Quiet){
	$ServerInfo = Get-WmiObject win32_Service -Computer $Row[0] |
    where {$_.DisplayName -match "SQL Server"} | 
    select SystemName, DisplayName, Name, State, StartMode, StartName | Out-DataTable

	foreach ($Service in $ServerInfo)
		{
		$ServerName = $Service[0]
		$ServiceDisplayName = $Service[1]
		$ServiceName = $Service[2] 
		$ServiceState =  $Service[3] 
		$ServiceStartMode =  $Service[4] 
		$ServiceStartName =  $Service[5] 
		
		$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
		EXEC dbo.prInsertServiceList
			@ServerName = '$ServerName'
			,@ServiceDisplayName = '$ServiceDisplayName'
			,@ServiceName = '$ServiceName'
			,@ServiceState = '$ServiceState'
			,@ServiceStartMode = '$ServiceStartMode'
			,@ServiceStartName = '$ServiceStartName';
		"
		}
	}
	else
	{
	Write-Host "Cannot Collect Service Information on $ServerName."
	}
}

#############################
#		GET SERVER INFO
#############################

$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  " 
EXEC prGetServerNames;
"

foreach ($Row in $ConnectionString.Rows)
{ 
	$Server = $($Row[0])
	
	If (Test-Connection  $Server -Count 1 -Quiet)
		{
		$ips = [System.Net.Dns]::GetHostAddresses($($Row[0]))
		
		$OSName = $((Get-WmiObject -comp $($Row[0]) -class Win32_OperatingSystem ).Caption)
		$OSServicePack = $((Get-WmiObject -comp $($Row[0]) -class Win32_OperatingSystem ).ServicePackMajorVersion)
		
		$ConnectionString = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand  "
		EXEC dbo.prUpdateServerList 
			 @IPAddress = '$ips'
			,@OSName = '$OSName'
			,@OSServicePack = '$OSServicePack'
			,@ServerName = '$Server'
		"
		}
	else
		{
		Write-Host "Cannot Collect Information on $Server."
		}
}
Write-Host "Done."
