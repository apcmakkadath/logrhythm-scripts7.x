<### Script written by Aravind for Setting and reading values for system optimization
Applicable to version above 7.6
Send your feedbacks to apcmakkadath@gmail.com
####>

function setxm{
### function color
function green
{
    process { Write-Host $_ -ForegroundColor Green }
}

function red
{
    process { Write-Host $_ -ForegroundColor Red }
}

### Setting OR reading values for system optimization
set-executionpolicy -scope LocalMachine unrestricted -Force


FSUTIL.EXE 8dot3name set c: 1
FSUTIL.EXE 8dot3name set d: 1 
FSUTIL.EXE 8dot3name set l: 1 
FSUTIL.EXE 8dot3name set t: 1 
FSUTIL.EXE 8dot3name set s: 1 

New-NetFirewallRule -DisplayName "LogRhythm required connections tcp" -Direction Inbound -Protocol TCP -LocalPort 443, 1433, 8300, 8301, 8501, 8076  -Action Allow -Profile @("Domain", "Private", "Public")
New-NetFirewallRule -DisplayName "LogRhythm required connections udp" -Direction Inbound -Protocol UDP -LocalPort 443, 1433, 8300, 8301, 8501, 8076  -Action Allow -Profile @("Domain", "Private", "Public")

write-output "Update windows" | green
wuauclt /update

Write-Output "Turning off DEP" | green
cmd.exe /c "bcdedit.exe /set {current} nx AlwaysOff" | red

Write-Output 'Adjusting vfx for best performance' | green
$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects'
try {
    $s = (Get-ItemProperty -ErrorAction stop -Name visualfxsetting -Path $path).visualfxsetting 
    if ($s -ne 2) {
        Set-ItemProperty -Path $path -Name 'VisualFXSetting' -Value 2  
        }
    }
catch {
    New-ItemProperty -Path $path -Name 'VisualFXSetting' -Value 2 -PropertyType 'DWORD'
    }

Write-Output "Setting service startup" | green 
stop-service -force -name Themes
set-service -Name Themes -Status Stopped -StartupType Disabled
stop-service -force -name Spooler
set-service -Name Spooler -Status Stopped -StartupType Disabled
stop-service -force -name WinRM
set-service -Name WinRM -Status Stopped -StartupType Disabled
stop-service -force -name Audiosrv
set-service -Name Audiosrv -Status Stopped -StartupType Disabled
stop-service -force -name BTAGService
set-service -Name BTAGService -Status Stopped -StartupType Disabled
stop-service -force -name bthserv
set-service -Name bthserv -Status Stopped -StartupType Disabled

write-output "Change startup" | green
msconfig

Write-Output "Set shortcuts" | green
$TargetFile = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell_ise.exe"
$ShortcutFile = "$env:Public\Desktop\poweshell_ise.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
$TargetFile = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$ShortcutFile = "$env:Public\Desktop\poweshell.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()
$TargetFile = "$env:SystemRoot\System32\cmd.exe"
$ShortcutFile = "$env:Public\Desktop\cmd.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Save()

Write-Output "Setting UAC" | green
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

Write-Output "Attempting TCP/IP Reset" | green
ipconfig /flushdns
ipconfig /registerdns
#netsh winsock reset #Possibly Resets the NIC card and IP settings
#netsh int ip reset #Possibly Resets the NIC card and IP settings
Write-Output "Reboot the System" | red
write-output "Fetching results" | green
write-output "------------------------------------------------------------------------------"
pause
}

function showresult{
###collecting values
$psexecpolicy = Get-ExecutionPolicy
$datetime = date 
$tz = Get-TimeZone
$dotnetversion = (Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Version
$pingresult = ping $(Hostname) -n 1 | findstr "from"
### showing results
write-output "Powershell Execution policy: $psexecpolicy"
write-output "Computer Name: $env:ComputerName"
write-output "Defender status:"
Get-MpComputerStatus | select *enabled
Get-MpPreference | findstr "Realtime"
Write-Output "DateTime: $datetime" 
Write-Output "Timezone is $tz"
Write-Output "Dot net version: $dotnetversion"
Write-Output "Ping result $pingresult"
Write-Output "Disk drives" 
$drives = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3 -and $_.FileSystem -ne $null}
foreach ($drive in $drives) {
   write-output "$($drive.DeviceID) Drive $([math]::Round($drive.FreeSpace / 1GB, 2))GB Free of $([math]::Round($drive.Size / 1GB, 2))GB"
}
ipconfig | findstr "Address"
ipconfig /all | findstr "Gateway"
ipconfig /all | findstr "DNS"
Get-NetFirewallProfile | findstr /r "^Name Enabled" 
write-output "Review results"
pause
}

setxm
showresult
