<### Script written by Aravind importing the list of privileged users from AD groups 
!!!!! Pre requisite: The system running the script must be joined to the DOMAIN
!!!!! The script is expecting a file named "priv_groups_file.txt" in home directory
Applicable to version above 7.4.X to 7.10.x
Send your feedbacks to apcmakkadath@gmail.com
####>

### Import required modules
Import-Module ServerManager
Add-WindowsFeature RSAT-AD-PowerShell

### File with Privileged user groups. GROUP NAMES !!!!!
$priv_groups_file = "~\priv_groups_file.txt"

### Read from AD groups 
foreach($line in Get-Content $priv_groups_file) {
    Get-ADGroupMember -Identity $line | select saMAccountName | Format-Table -HideTableHeaders | Out-File ~\priv_users.txt -Append
}

#### For Custom usernames
<#
$userlist = Get-ADGroupMember -Identity $line
$userlist.samaccountname | Foreach-object {$_ + "@domain.com"} | Out-File ~\priv-users.txt
#>

### Make sure to provide permission to the script running user to "C:\Program Files\LogRhythm"
Move-Item ~\priv_users.txt "C:\Program Files\LogRhythm\LogRhythm Job Manager\config\list_import\priv_users.txt" -Force