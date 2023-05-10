<### Script written by Aravind for rebuilding LogRhythm web indices 
Applicable to version above 7.4.X to 7.10.x
Send your feedbacks to apcmakkadath@gmail.com
####>


### Colour function
function green
{
    process { Write-Host $_ -ForegroundColor Green }
}

function red
{
    process { Write-Host $_ -ForegroundColor Red }
}

function magenta
{
    process { Write-Host $_ -ForegroundColor Magenta }
}


### SQL paramters variable declaration
Write-Output "Enter sa credentials" | magenta
$serverName = $env:computername
$DB = "LogRhythmEMDB" 
$credential = Get-Credential 
$userName = $credential.UserName.Replace("\","")  
$pass = $credential.GetNetworkCredential().password  

### Stopping Logrhythm web seervices
Write-Output "Stopping LogRhythm web services" | red
Stop-Service -DisplayName "LogRhythm Web Console API"
Stop-Service -DisplayName "LogRhythm Web Console UI"
Stop-Service -DisplayName "LogRhythm Web Indexer"
Stop-Service -DisplayName "LogRhythm Web Services Host API"

### Renaming existing indices
Write-Output "Renaming existing indices" | red
$renamedtime = (Get-Date).AddMinutes(-242).ToString("yyyy-MM-ddTHH:mm:00Z")
cd "C:\tmp\indices"
Rename-Item .\1F4779BA-307E-4F65-9947-3AFA882EE06B .\1F4779BA-307E-4F65-9947-3AFA882EE06B_$renamedtime
Rename-Item .\E3FFCBF1-7981-4916-A5AE-AAA4332D2CB5 .\E3FFCBF1-7981-4916-A5AE-AAA4332D2CB5_$renamedtime

### Deleting web indices database tables 
Write-Output "Deleting web indices database tables"
invoke-sqlcmd -query "DELETE FROM [LogRhythmEMDB].[dbo].[WebTask] WHERE [TaskID] IN ('1F4779BA-307E-4F65-9947-3AFA882EE06B','E3FFCBF1-7981-4916-A5AE-AAA4332D2CB5')" -database $DB -serverinstance $servername -username $username -password $pass
invoke-sqlcmd -query "DELETE FROM [LogRhythmEMDB].[dbo].[WebTaskToUser] WHERE [WebTaskID] IN ('1F4779BA-307E-4F65-9947-3AFA882EE06B','E3FFCBF1-7981-4916-A5AE-AAA4332D2CB5')" -database $DB -serverinstance $servername -username $username -password $pass

### Starting LogRhythm web services
Write-Output "Starting LogRhythm web services" | green
Start-Service -DisplayName "LogRhythm Web Console API"
Start-Service -DisplayName "LogRhythm Web Console UI"
Start-Service -DisplayName "LogRhythm Web Indexer"
Start-Service -DisplayName "LogRhythm Web Services Host API"
Write-Output "Web indices rebuild complete" | green

