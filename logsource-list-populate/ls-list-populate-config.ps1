[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$sapwd
)

$configdirpath = "C:\Program Files\LogRhythm\LogRhythm Alarming and Response Manager\config\LSLP"
New-Item -ItemType "directory" -Path $configdirpath -Force | Out-null

### Encrypting LR API key
$sapwd_secure = ConvertTo-SecureString $sapwd -AsPlainText -Force
$sapwd_encrypted = ConvertFrom-SecureString $sapwd_secure
$sapwd_encrypted | out-file -FilePath "$configdirpath\sapwd.encrypted" -Force
