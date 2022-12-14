<### Script written by Aravind for Setting and reading values for system optimization
Applicable to version above 7.4.X to 7.10.x
Send your feedbacks to apcmakkadath@gmail.com
####>

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
set-executionpolicy unrestricted
write-output "Powershell Execution policy is" | green
get-executionpolicy | red
pause

write-output "Hostname :" | green
hostname | red
pause

Write-Output "Windows defender status" | green
Get-MpComputerStatus | red
pause

write-output "Windows Dender AV Status" | green ## Modified to show the status only
Get-MpPreference | findstr "Realtime"
pause
cls

Write-Output 'DateTime:' | green
date 
pause

Write-Output 'TimeZone' | green
Get-TimeZone
pause

Write-Output "Dot net frameowrk version:" | green
(Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Version | red
pause

ping $(Hostname)
pause

Write-Output "Disk drives" | green
Get-PSDrive
FSUTIL.EXE 8dot3name set c: 1
FSUTIL.EXE 8dot3name set d: 1 
FSUTIL.EXE 8dot3name set l: 1 
FSUTIL.EXE 8dot3name set t: 1 
FSUTIL.EXE 8dot3name set s: 1 
 
pause

write-output "IP Address(s)" | green
ipconfig 
pause

write-output "Firewall status:" | green
Get-NetFirewallProfile | findstr /r "^Name Enabled" | red
write-output "Update windows"
pause

write-output "Update windows" | green
wuauclt /update
pause

Write-Output "Turning off DEP" | green
cmd.exe /c "bcdedit.exe /set {current} nx AlwaysOff" | red
pause

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
pause

Write-Output "Service management" | green 
stop-service -force -name Themes
set-service -Name Themes -Status Stopped -StartupType Disabled
stop-service -force -name Spooler
set-service -Name Spooler -Status Stopped -StartupType Disabled
pause

write-output "Change startup" | green
msconfig

<#Write-Output "Setting up desktop" | green
copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft SQL Server Tools 17\Microsoft SQL Server Management Studio 17.lnk" "C:\Users\All Users\Desktop"
copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\LogRhythm\*.lnk" "C:\Users\All Users\Desktop"
#>
$TargetFile = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell_ise.exe"
$ShortcutFile = "$env:Public\Desktop\poweshell_ise.lnk"
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
pause
 

Write-Output "Setting UAC" | green
Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
pause

Write-Output "Reboot the System" | red




