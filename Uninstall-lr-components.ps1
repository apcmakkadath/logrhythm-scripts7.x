<### Script written by Aravind for automating the uninstallation of LogRhythm components
Applicable to version above 7.4.X to 7.10.x
!!!!! IMPORTANT: Change the IP Address hard coded in the script
Send your feedbacks to apcmakkadath@gmail.com
####>


## Get-WmiObject -Class Win32_Product | Select-Object -Property Name ## To get list of all products installed
## https://redmondmag.com/articles/2019/08/27/powershell-to-uninstall-an-application.aspx
Write-Output "Attempting uninstall LogRhythm Notification Service"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Notification Service"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Search API"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Search API"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Infrastructure Installer"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Infrastructure Installer"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Metrics Web UI"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Metrics Web UI"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm SQL Service"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm SQL Service"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Admin API"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Admin API"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Web Indexer"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Web Indexer"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Metrics Database"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Metrics Database"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Configuration Manager"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Configuration Manager"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Service Registry"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Service Registry"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Threat Intelligence API"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Threat Intelligence API"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm System Monitor Service"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm System Monitor Service"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Metrics Collection"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Metrics Collection"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm API Gateway"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm API Gateway"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm AI Engine Cache Drilldown"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm AI Engine Cache Drilldown"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Alarming Manager"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Alarming Manager"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Diagnostics"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Diagnostics"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Job Manager"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Job Manager"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Web Console UI"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Web Console UI"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Case API"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Case API"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Web Services Host API"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Web Services Host API"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Windows Authentication Service"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Windows Authentication Service"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Web Console API"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Web Console API"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Diagnostics Agent"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Diagnostics Agent"}
$MyApp.Uninstall()
Write-Output "Attempting uninstall LogRhythm Authentication API"
$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "LogRhythm Authentication API"}
$MyApp.Uninstall()

### MS SQL Uninstall
$sqlsetuppath = Read-Host "MS SQL setup.exe path[setup.exe in installation folder]?"
$sqluninstall = $sqlsetuppath + " /qs /ACTION=Uninstall /FEATURES=SQLEngine /INSTANCENAME=MSSQLSERVER"
Write-Output "Attempting uninstall MS SQL Server"
powershell.exe $sqluninstall