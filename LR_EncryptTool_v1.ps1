### LR Ecrypt tool Simple GUI###

### Load Modules
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

### Encrypting function
function encrypt
{
### Switching to right directory
cls
cd "C:\Program Files\LogRhythm\LogRhythm System Monitor"

### Reading secret key/id
$securePwd = Read-Host "Enter password" -AsSecureString

### Convert secure string into normal plain text.
$plainPwd =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd))
### Formatting the encrypted value output
.\lrcrypt.exe -e $plainPwd | Out-File ~\AppData\Local\Temp\encvaluetmp.txt -Force
$encrypted_value = (Get-Content -path ~\AppData\Local\Temp\encvaluetmp.txt -Raw) -replace 'LogRhythm|Password|Encryption|Utility|Encrypted|password|\s|:',''
Remove-Item ~\AppData\Local\Temp\encvaluetmp.txt

### Displaying Encrypted Value
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Encrypted Value'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,20)
$textBox.Text = $encrypted_value
$form.Controls.Add($textBox)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,120)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$form.ShowDialog()

}

### Verifying if LogRhythm SysMon is installed or not
if (Test-Path "C:\Program Files\LogRhythm\LogRhythm System Monitor\lrcrypt.exe") {
    encrypt
} else {
    [System.Windows.Forms.MessageBox]::Show("Run the Script from a System where LogRhythm SysMon Agent is installed.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

