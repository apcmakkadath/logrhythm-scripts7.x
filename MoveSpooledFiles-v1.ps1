<#
.Description
LogRhythm - Move files from one directory to another when the target directory is empty. Used to move spooled event or log files.
Micah Shelton 11-18-2016
This version uploaded to Confluence by Keelan Lang on 12-23-2021
Credits to original author(s)
#>
#######################################

## To get input parameters
function input_value{
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Input'
$form.Size = New-Object System.Drawing.Size(400,400)
$form.StartPosition = 'CenterScreen'
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,240)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,240)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)
$label = New-Object System.Windows.Forms.Label

$label.Location = New-Object System.Drawing.Point(10,40)
$label.Size = New-Object System.Drawing.Size(280,50)
$label.Text = $global:desc
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,150)
$textBox.Size = New-Object System.Drawing.Size(260,20)

$form.Controls.Add($textBox)
$form.Topmost = $true
$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()
if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $input = $textBox.Text
    $input
}
}

# To get input folders
Function Get-Folder($initialDirectory="C:\Program Files\")
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $global:desc 
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

# Directory path for the source
$global:desc = "Select Source Folder"
$Source = Get-Folder

# Directory path for the destination
$global:desc = "Select Destination Folder"
$destination = Get-Folder

# Number of files to move from source to dest at a time.
$global:desc = "Number of files to move from source to dest at a time"
$FileLimit = input_value

$global:desc = "Number of seconds to sleep before looking to see if the dest directory is empty"
$SleepTime = input_value 
#######################################
#
# Do not change anything below this line
#
#######################################
$originationInfo = [System.IO.Directory]::GetFiles("$source")
Write-Host (Get-Date), "Files in HOLD:", $originationInfo.count -foregroundcolor "red" #Returns the count of all of the files in the directory

while ('$originationInfo.count -gt 0')
{

$destinationInfo = [System.IO.Directory]::GetFiles("$destination")
Write-Host (Get-Date), "Files in process:" $destinationInfo.count -foregroundcolor "yellow" #Returns the count of all of the files in the directory
If ($destinationInfo.count -lt 2) 
  {    
    $SrcCount = [System.IO.Directory]::GetFiles("$source")
    if ($SrcCount.count -lt 1)
       {
              Write-Host "***File Move Complete***" -foregroundcolor "white"
              exit
       }
       
       Write-Host (Get-Date), "Moving" $FileLimit "for processing." -foregroundcolor "green"
        
       #Destination for files 
       $PickupDirectory = Get-ChildItem -Path $Source | sort-object -Property LastWriteTime       
                    
        $Counter = 0 
        foreach ($file in $PickupDirectory) {     
        if ($Counter -ne $FileLimit)     
        {                
            Write-Host $file.FullName -foregroundcolor "green" #Output file fullname to screen                   
            Move-Item $file.FullName -destination $Destination         
            $Counter++         
            }   
        } 
       $originationInfo = [System.IO.Directory]::GetFiles("$source")
       Write-Host (Get-Date), "Files in HOLD:", $originationInfo.count -foregroundcolor "red"
  }
     Start-Sleep -s $SleepTime 
}
Exit 
