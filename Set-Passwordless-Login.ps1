Clear-Host
$keyPath = "$env:USERPROFILE\.ssh\id_ed25519.pub"
if (-not (Test-Path $keyPath)) {
    Write-Host "Creating SSH keypair..." -ForegroundColor Cyan
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "ssh-keygen -t ed25519"
} else {
    Write-Host "Existing SSH public key found at: $keyPath..." -ForegroundColor Green
}

$targetserver = Read-Host "Enter Target Server (Hostname or IP)"
$targetuser = Read-Host "Enter Target Server User"
Write-Host "Execute the below in powershell..." -ForegroundColor Cyan
Write-Host @"

Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | ssh $targetuser@$targetserver "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

"@

Write-Host "$([char]0x26A0) Mind the line breaks while copying..." -ForegroundColor Yellow
