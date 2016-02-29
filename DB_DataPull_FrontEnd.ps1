#--------------------
#Owner: Charlton E Julius
#Date: 2015-02-14
#Purpose: Builds GUI front-end for Datapull
#--------------------


#Point to Repository Instance.DB
$RepositoryInstance = '(local)'
$RepositoryDB = 'DBAdmin'

#############################
#  		XAML code Reader
#http://foxdeploy.com/2015/04/10/part-i-creating-powershell-guis-in-minutes-using-visual-studio-a-new-hope/
#Put the sanitized code here from WPF_to_PSForm.ps1
#############################
$inputXML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="DB_DataPull_FrontEnd" Height="190" Width="269">
    <Grid Margin="0,0,2,11">
        <Button Name="Bt_All_Data" Content="Full Inventory" HorizontalAlignment="Left" Margin="10,131,0,0" VerticalAlignment="Top" Width="75"/>
        <Button Name="Bt_Servers" Content="Servers" HorizontalAlignment="Left" Margin="10,39,0,0" VerticalAlignment="Top" Width="75"/>
        <Button Name="Bt_Instances" Content="Instances" HorizontalAlignment="Left" Margin="10,64,0,0" VerticalAlignment="Top" Width="75"/>
        <Button Name="Bt_Databases" Content="Databases" HorizontalAlignment="Left" Margin="10,89,0,0" VerticalAlignment="Top" Width="75"/>
        <Button Name="Bt_Services" Content="Services" HorizontalAlignment="Left" Margin="174,39,0,0" VerticalAlignment="Top" Width="75"/>
        <Button Name="Bt_Exit" Content="Exit" HorizontalAlignment="Left" Margin="174,131,0,0" VerticalAlignment="Top" Width="75"/>
        <Label Content="Inventory" HorizontalAlignment="Left" Margin="19,10,0,0" VerticalAlignment="Top"/>
        <Label Content="Other Info" HorizontalAlignment="Left" Margin="174,11,0,0" VerticalAlignment="Top"/>
    </Grid>
</Window>
"@       
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML

#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
	try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
	catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
# Load XAML Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}


#############################
#	  Run SQL Commands
#Based on: https://github.com/Proxx/PowerShell/blob/master/Network/Invoke-SQL.ps1
#############################
function Invoke-SQL {
    param
	(
        [string] $dataSource,
        [string] $database,
        [string] $sqlCommand
    )
	Write-Host $sqlCommand
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
#	  Get All Data
#############################
$WPFBt_All_Data.Add_Click(
	{
	$sqlCommand = "
	EXEC dbo.prGetInventory;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Database Inventory"
	}
)

#############################
#	Get Server Information
#############################
$WPFBt_Servers.Add_Click(
	{
	$sqlCommand = "
		EXEC dbo.prGetServers;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Server Inventory"
	}
)

#############################
#	Get Instance Information
#############################
$WPFBt_Instances.Add_Click(
	{
	$sqlCommand = "
		EXEC dbo.prGetInstances;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Instance Inventory"

	}
)

#############################
#	Get Database Information
#############################
$WPFBt_Databases.Add_Click(
	{
	$sqlCommand = "
		EXEC dbo.prGetDatabasesAndSize;
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Database and Size Inventory"
	}
)

#############################
#	Get Services Information
#############################
$WPFBt_Services.Add_Click(
	{
	$sqlCommand = "
		EXEC [dbo].[prGetServerServices];
	"

	$dataset = Invoke-SQL -datasource $RepositoryInstance -database $RepositoryDB -sqlCommand $sqlCommand
	Write-Host $dataset

	$dataset | Out-GridView -Title "Service Inventory"
	}
)

#############################
#		Close Form
#############################
$WPFBt_Exit.Add_Click(
	{
	$Form.Close()
	}
)

#############################
#		Display Form
#############################
$Form.ShowDialog() | out-null
