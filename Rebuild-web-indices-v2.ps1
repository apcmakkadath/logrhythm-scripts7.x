<### Script written by Aravind for rebuilding LogRhythm web indices 
Applicable to version above 7.4.X to 7.12
Tested against LR 7.12 version 
Added Error handling
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

### Indices folder path
function indices_path {
Write-Output "Web index folder path?" | magenta
$indices_path = Read-Host
$valid_indices_path = Test-Path $indices_path
If ($valid_indices_path -eq "True") {
cd $indices_path
Write-Output "Proceed with rebuilding web indices.." | green

identify_indices
get-sql-cred
stop-web-services
rename_indice
delete_webindice_table
start-web-services

pause
}
Else {
Write-Output "Path not valid. Exiting!" | red
}
}

### Identifying existing indices
function identify_indices {
$alarms = @("1F4779BA-307E-4F65-9947-3AFA882EE06B","Alarms")
$events = @("E3FFCBF1-7981-4916-A5AE-AAA4332D2CB5","Events")
$known_values = @("4585D33E-C058-4AFA-89CE-ED2BF4B7823D","Known Values")
$cases = @("689D0EF7-5F6A-412E-A47B-315472948C08","Cases")
$reportmeta = @("0F2ABEC2-CC9F-4833-838D-7A177001A037","Report Meta Data")
$globalstate = @("990F503D-D5C5-46A8-BEE0-306165F67830","Global State Index")

$default_indices = @($alarms,$events,$known_values,$cases,$reportmeta,$globalstate)
$live_indices = @()

for ($i=0; $i -lt $default_indices.Length; $i++){
$a = Test-Path $default_indices[$i][0]
IF ($a -eq "True") {
Write-Output $default_indices[$i][1] "index exist" | green
$j=0
$live_indices += $default_indices[$i][0]
$j++
} 
ELSE {
Write-Output $default_indices[$i][1] "index does not exist" | red
}
}
pause
}

### SQL paramters variable declaration
function get-sql-cred {
Write-Output "Enter sa credentials" | magenta
$serverName = $env:computername
$DB = "LogRhythmEMDB" 
$credential = Get-Credential 
$userName = $credential.UserName.Replace("\","")  
$pass = $credential.GetNetworkCredential().password  
}

### Stopping Logrhythm web seervices
function stop-web-services {
Write-Output "Stopping LogRhythm web services..." | magenta
$startJob = Start-Job -ScriptBlock{
    Stop-Service -DisplayName "LogRhythm*Web*" 
}
Wait-Job $startJob.Name
pause
}

### Renaming existing indices
function rename_indice {
Write-Output "Renaming existing indices..." | magenta
$renamedtime = (Get-Date).AddMinutes(-242).ToString("yyyy-MM-ddTHH-mm-00Z")
cd $indices_path
for ($i=0; $i -lt $live_indices.Length; $i++){
try { 
Rename-Item $live_indices[$i] $renamedtime-$live_indices[$i] -ErrorAction Stop
}
catch {
Write-Output $live_indices[$i] "Index Rename unsuccessful" | red
}
}
pause
}

### Deleting web indices database tables 
function delete_webindice_table {
Write-Output "Deleting web indices database tables..."
for($i=0; $i -lt $live_indices.Length; $i++){
try {
invoke-sqlcmd -query "DELETE FROM [LogRhythmEMDB].[dbo].[WebTask] WHERE [TaskID] IN ('$live_indices[$i]')" -database $DB -serverinstance $servername -username $username -password $pass
invoke-sqlcmd -query "DELETE FROM [LogRhythmEMDB].[dbo].[WebTaskToUser] WHERE [WebTaskID] IN ('live_indices')" -database $DB -serverinstance $servername -username $username -password $pass
}
catch {
Write-Output $live_indices[$i] "Deleting table failed" | red
}
}
pause
}

### Starting LogRhythm web services
function start-web-services {
Write-Output "Starting LogRhythm web services..." | green
$startJob = Start-Job -ScriptBlock{
    Start-Service -DisplayName "LogRhythm*Web*" 
}
Wait-Job $startJob.Name
pause
Write-Output "Web indices rebuild complete. Please wait for services to start.." | green
Get-Service -DisplayName "LogRhythm*Web*" | select DisplayName,Status
pause
}

### Functions calling
cls
indices_path
