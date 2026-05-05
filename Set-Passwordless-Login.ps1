# SSH 'passwordless login' creating script
Clear-Host 
# Get inputs
$Linux = Read-Host "Linux server IP/Hostname"
if($Linux.Length -eq 0) {$Linux = "192.168.122.101"} 
$Username = Read-Host "Linux username"
if($Username.Length -eq 0){$Username = "logrhythm"}
Write-Host "Using Linux Server $Linux and User $Username"
pause

# Make ssh key pairs
Write-Host "Looking for ssh public keys..."
Get-ChildItem -Path "~\.ssh"
pause
Write-Host "Removing existing ssh public keys if any..."
Remove-Item "~\.ssh\*" -Force
Write-Host "Trying to create ssh key pair`nProceed with defaults and empty passworrd"
Start-Process ssh-keygen.exe #CREATE KEY PAIR

# Copy ssh public key to Linux
Write-Host "Copying ssh public key to Linux server..."
$Remote = $Username + "@" + $Linux
#$RemotePath
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh $Remote "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys" #COPY PUBLIC KEY TO LINUX SERVER
