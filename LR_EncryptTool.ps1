### LR Ecrypt tool

### Switching to right directory
cls
cd "C:\Program Files\LogRhythm\LogRhythm System Monitor"

### Encrypting function
function encrypt
{
### Reading secret key/id
$securePwd = Read-Host "Enter password" -AsSecureString

### Convert secure string into normal plain text.
$plainPwd =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd))
### Formatting the encrypted value output
.\lrcrypt.exe -e $plainPwd | Out-File ~\AppData\Local\Temp\encvaluetmp.txt -Force
$encrypted_value = (Get-Content -path ~\AppData\Local\Temp\encvaluetmp.txt -Raw) -replace 'LogRhythm|Password|Encryption|Utility|Encrypted|password|\s|:',''
Remove-Item ~\AppData\Local\Temp\encvaluetmp.txt

### Displaying Encrypted Value
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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

encrypt
<#
do
{
### Reading selection
$selection = Read-Host "Proceed with encryption? (y/n)"
switch ($selection)
    {
    'y' 
        {
        encrypt
        }
    'n'
        {
        return
        }
    }
}until ($selection -eq 'n')
#>