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
Write-Output "Stopping LogRhythm web services..." | red
Stop-Service -DisplayName "LogRhythm*Web*" 
Get-Service -DisplayName "LogRhythm*Web*" | select DisplayName,Status
pause

### Renaming existing indices
Write-Output "Renaming existing indices..." | red
$renamedtime = (Get-Date).AddMinutes(-242).ToString("yyyy-MM-ddTHH-mm-00Z")
cd "C:\tmp\indices"
Rename-Item .\1F4779BA-307E-4F65-9947-3AFA882EE06B .\1F4779BA-307E-4F65-9947-3AFA882EE06B_$renamedtime #Alarm
Rename-Item .\E3FFCBF1-7981-4916-A5AE-AAA4332D2CB5 .\E3FFCBF1-7981-4916-A5AE-AAA4332D2CB5_$renamedtime #Events
Rename-Item .\4585D33E-C058-4AFA-89CE-ED2BF4B7823D .\4585D33E-C058-4AFA-89CE-ED2BF4B7823D_$renamedtime #Known values
Rename-Item .\689D0EF7-5F6A-412E-A47B-315472948C08 .\689D0EF7-5F6A-412E-A47B-315472948C08_$renamedtime #Case history
Rename-Item .\0F2ABEC2-CC9F-4833-838D-7A177001A037 .\0F2ABEC2-CC9F-4833-838D-7A177001A037_$renamedtime #Report metadata
Rename-Item .\990F503D-D5C5-46A8-BEE0-306165F67830 .\990F503D-D5C5-46A8-BEE0-306165F67830_$renamedtime #Global state index
pause

### Deleting web indices tables from LogRhythmEMDB 
Write-Output "Deleting web indices database tables..."
invoke-sqlcmd -query "DELETE FROM [LogRhythmEMDB].[dbo].[WebTask] WHERE [TaskID] IN ('1F4779BA-307E-4F65-9947-3AFA882EE06B','E3FFCBF1-7981-4916-A5AE-AAA4332D2CB5','4585D33E-C058-4AFA-89CE-ED2BF4B7823D','689D0EF7-5F6A-412E-A47B-315472948C08','0F2ABEC2-CC9F-4833-838D-7A177001A037','990F503D-D5C5-46A8-BEE0-306165F67830')" -database $DB -serverinstance $servername -username $username -password $pass
invoke-sqlcmd -query "DELETE FROM [LogRhythmEMDB].[dbo].[WebTaskToUser] WHERE [WebTaskID] IN ('1F4779BA-307E-4F65-9947-3AFA882EE06B','E3FFCBF1-7981-4916-A5AE-AAA4332D2CB5','4585D33E-C058-4AFA-89CE-ED2BF4B7823D','689D0EF7-5F6A-412E-A47B-315472948C08','0F2ABEC2-CC9F-4833-838D-7A177001A037','990F503D-D5C5-46A8-BEE0-306165F67830')" -database $DB -serverinstance $servername -username $username -password $pass
pause

### Starting LogRhythm web services
Write-Output "Starting LogRhythm web services..." | green
Start-Service -DisplayName "LogRhythm*Web*" 
Get-Service -DisplayName "LogRhythm*Web*" | select DisplayName,Status
Write-Output "Web indices rebuild complete" | green
