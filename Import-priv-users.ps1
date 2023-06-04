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
$priv_groups_file = "priv_groups_file.txt"

### File existence verification
if (Test-Path "~\priv_groups_file.txt") {
        import-ad-users 
} else {
    cd ~
    New-Item -Name $priv_groups_file -ItemType File
    [System.Windows.Forms.MessageBox]::Show("Enter AD group names to file priv_groups_file.txt in $env:USERPROFILE", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

function import-ad-users {
### Read from AD groups 
foreach($line in Get-Content $priv_groups_file) {
    Get-ADGroupMember -Identity $line | select saMAccountName | Format-Table -HideTableHeaders | Out-File ~\$line.txt 
}

#### For Custom usernames
<#
$userlist = Get-ADGroupMember -Identity $line
$userlist.samaccountname | Foreach-object {$_ + "@domain.com"} | Out-File ~\priv-users.txt
#>

### Make sure to provide permission to the script running user to "C:\Program Files\LogRhythm"
Move-Item ~\$line.txt "C:\Program Files\LogRhythm\LogRhythm Job Manager\config\list_import\$line.txt" -Force
}
