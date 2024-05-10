<### Script written by Aravind for Setting and reading values for system optimization
Applicable to version above 7.6
Send your feedbacks to apcmakkadath@gmail.com
####>


function setxm{
### Setting OR reading values for system optimization
set-executionpolicy -scope LocalMachine unrestricted -Force

### Disable 8dot3name (Shortname creation)
FSUTIL.EXE 8dot3name set c: 1
FSUTIL.EXE 8dot3name set d: 1 
FSUTIL.EXE 8dot3name set l: 1 
FSUTIL.EXE 8dot3name set t: 1 
FSUTIL.EXE 8dot3name set s: 1 

### Set firewall rules
New-NetFirewallRule -DisplayName "LogRhythm required connections tcp" -Direction Inbound -Protocol TCP -LocalPort 443, 1433, 8300, 8301, 8501, 8076  -Action Allow -Profile @("Domain", "Private", "Public")
New-NetFirewallRule -DisplayName "LogRhythm required connections udp" -Direction Inbound -Protocol UDP -LocalPort 443, 1433, 8300, 8301, 8501, 8076  -Action Allow -Profile @("Domain", "Private", "Public")
Set-NetFirewallRule -DisplayName "File and Printer Sharing*" -Enabled True -Profile Domain, Private, Public

### Update windows
Write-Host "Update windows" -ForegroundColor Green
wuauclt /update

### Turn off DEP
Write-Host "Turning off DEP" -ForegroundColor Green
cmd.exe /c "bcdedit.exe /set {current} nx AlwaysOff"

### Set VFX
Write-Host 'Adjusting vfx for best performance' -ForegroundColor Green
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

### Set services
Write-Host "Setting service startup" -ForegroundColor Green
stop-service -force -name Themes
set-service -Name Themes -Status Stopped -StartupType Disabled
stop-service -force -name Spooler
set-service -Name Spooler -Status Stopped -StartupType Disabled
set-service -Name WinRM -StartupType Automatic
start-service -name WinRM
stop-service -force -name Audiosrv
set-service -Name Audiosrv -Status Stopped -StartupType Disabled
stop-service -force -name BTAGService
set-service -Name BTAGService -Status Stopped -StartupType Disabled
stop-service -force -name bthserv
set-service -Name bthserv -Status Stopped -StartupType Disabled

### Startup config
Write-Host "Change startup" -ForegroundColor Green
msconfig

### Set shortcuts
Write-Host "Set shortcuts" -ForegroundColor Green
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

### Set UAC
Write-Host "Setting UAC" -ForegroundColor Green
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0

### Set Network
Write-Host "Attempting TCP/IP Reset" -ForegroundColor Green
ipconfig /flushdns
ipconfig /registerdns
write-host "------------------------------------------------------------------------------`n`n" -ForegroundColor Magenta
pause
clear-host
}

function showresult{
###collecting values
$psexecpolicy = Get-ExecutionPolicy
$datetime = date 
$tz = Get-TimeZone
$dotnetversion = (Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Version
$pingresult = ping $(Hostname) -n 1 | findstr "from"
### showing results
Write-Host "Powershell Execution policy: $psexecpolicy" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------`n" -ForegroundColor Yellow

Write-Host "Computer Name: $env:ComputerName" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------`n" -ForegroundColor Yellow

Write-Host "Defender status:"-ForegroundColor Cyan
Get-MpComputerStatus | select *enabled
Write-Host "--------------------------------------------------------------`n" -ForegroundColor Yellow

Write-Host "RealTime Monitoring Status" -ForegroundColor Cyan
Get-MpPreference | findstr "Realtime"
Write-Host "--------------------------------------------------------------`n" -ForegroundColor Yellow

Write-Host "DateTime: $datetime" -ForegroundColor Red
Write-Host "Timezone is $tz.StandardName" -ForegroundColor Red
Write-Host "--------------------------------------------------------------`n" -ForegroundColor Yellow

Write-Host "Dot net version: $dotnetversion" -ForegroundColor Red
Write-Host "--------------------------------------------------------------`n" -ForegroundColor Yellow

Write-Host "Ping result $pingresult" -ForegroundColor Yellow
Write-Host "--------------------------------------------------------------`n" -ForegroundColor Yellow

Write-Host "Disk drives" 
$driveletters=@("C:","D:","L:","T:","S:")
$drives = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3 -and $_.FileSystem -ne $null}

foreach ($letter in $driveletters) {
    if ($drives.DeviceID -contains $letter) {
        Write-Host "$letter is present." -ForegroundColor Green
    } else {
        Write-Host "$letter is not present." -ForegroundColor Red
    }
}
Write-Host "--------------------------------------------------------------`n" -ForegroundColor Yellow
Write-Host "Disk space" -ForegroundColor Yellow
foreach ($drive in $drives) {
   Write-Host "$($drive.DeviceID) Drive $([math]::Round($drive.FreeSpace / 1GB, 2))GB Free of $([math]::Round($drive.Size / 1GB, 2))GB" -ForegroundColor Yellow
}
Write-Host "--------------------------------------------------------------`n" -ForegroundColor Yellow

Write-Host "IPv4 Address(es)" -ForegroundColor Yellow
$ips = Get-NetIPAddress
$ips | ForEach-Object {if($_.AddressFamily -eq "IPv4"){Write-Host $_.IPAddress}}
Write-Host "--------------------------------------------------------------`n" -ForegroundColor Yellow

Write-Host "Firewall Rules Enabled" -ForegroundColor Yellow
Get-NetFirewallProfile | findstr /r "^Name Enabled" 

Write-Host "Review results" -ForegroundColor Cyan
pause
}

setxm
showresult
