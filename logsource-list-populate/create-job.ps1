# Script Creating task scheduler job 
function createTaskJob{
$scriptpath = ""
$taskname = "LogSourceList_Creation"

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -File `"$scriptpath`""
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10) -RepetitionDuration (New-TimeSpan -Days 1000)
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName $taskname -Action $action -Trigger $trigger -Principal $principal
}

function checkValues{

if($scriptpath -eq '' -or $taskname -eq ''){
Write-Host "Script path and Scheduled Task Name missing."
}else{
Write-Host "Script path and Scheduled Task Name found"
createTaskJob
}

}

# Main
checkValues
