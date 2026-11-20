<#
.SYNOPSIS
    To Move Inactive Archives to elsewhere

.EXAMPLE
    .\osstats.ps1 -dxip 10.0.0.15
    .\osstats.ps1 -dxip 10.0.0.15 -Days 14
#>

<#
A LogRhythm archive FILE has the following naming scheme:
<NormalMsgDate>_<LogSourceId>_<HostID>_<MediatorID>_<CreationTicks>.<EXT>

A LogRhythm archive DIRECTORY has the following naming scheme:
<NormalMsgDate>_<LogSourceId>_<CreationTicks>.<EXT>

#>

[cmdletbinding()]
param(
    [Parameter(Mandatory=$True)][string]$SrcDir,
    [Parameter(Mandatory=$True)][string]$DestDir
    )
Clear-Host

Function Path-Check{
param(
[Parameter(Mandatory=$True)][string]$Dir,
[Parameter(Mandatory=$True)][string]$DirFlag
)

try{
if(Test-Path -Path $Dir -PathType Container){
    Write-Host "Directory $Dir : Found" -f Green
    return $dir
    }else{
    Write-Host "Directory $Dir : NOT Found" -f Red
    Write-Host "Try without quotes" -f Gray
    $Dir = Read-Host "Enter $DirFlag"
    Path-Check -Dir $Dir -DirFlag $DirFlag
    }
}catch{
Write-Host "Illegal $DirFlag path" -f DarkGray
$Dir = Read-Host "Enter $DirFlag"
Path-Check -Dir $Dir -DirFlag $DirFlag
}

}

Function ShowBanner{

$Banner = @"

####################################################################################################
# Script does not validate the archive file extensions nor destination directory size              #    
# Make sure the source archive directory contains ONLY inactive archives with file extension .lca  #
# Make sure destination directory has enough space                                                 #
####################################################################################################

"@

Write-Host $Banner -f Cyan

}

Function GetDates{

Write-Host "Archives date older than?" -f Yellow 
Write-Host "Enter in format yyyyMM, yyyyMMdd ONLY" -f DarkGray


#region Validation
$validInput = $false
$number = 0

while (-not $validInput) {
    $DateToMove = Read-Host
    
    # TryParse checks if the string can be converted to an [int]
    if ([int]::TryParse($DateToMove, [ref]$number)) {
        $validInput = $true
    } else {
        Write-Host "Invalid input. That is not a valid entry. Please try again.`nEnter in format yyyyMM, yyyyMMdd ONLY" -f Yellow
    }
}

Write-Host "Proceeding with $number" -ForegroundColor Green
$DateToMove = $number 
#endregion

Write-Host "Finding archives starting with $DateToMove" -f DarkGray
$DirToMove = Get-ChildItem -Directory -Path $SrcDir -Depth 2 -Filter $DateToMove*
$DirCount = $DirToMove.Name.count

$ShowOptions = @"

Press M to Move, D to Delete, Q to Quit/Exit
"[M]Move [D]Delete [Q]Quit "

"@
Write-Host $ShowOptions -ForegroundColor Cyan
$Action = Read-Host 

switch ($Action) {
    "M"   { MoveArchives }
    "D"   { DeleteArchives }
    "Q" { Write-Host "Terminating" ; Exit }
    default  { Write-Host "Invalid Input" }
}


}

Function MoveArchives{

Write-Host "$DirCount archives found"
$Proceed = Read-Host "Proceed with moving archives(y/n)"
if($Proceed -eq "y"){
    Write-Host "Attempting to move archives" -f DarkGray
    foreach ($ArchiveDir in $DirToMove){
        
        Write-Host "Moving $($ArchiveDir.Name) to $DestDir" -f DarkGray
        robocopy "$($ArchiveDir.FullName)" "$DestDir\$($ArchiveDir.Name)" /E /MOVE /R:0 /W:0 
        Start-Sleep -Milliseconds 100
        
        }
    Write-Host "Verifying Move Activity" -f DarkYellow
    $DirsMoved = Get-ChildItem -Directory -Path $DestDir -Depth 2 -Filter $DateToMove*
    $DirsMovedCount = $DirsMoved.Count 
    Write-Host "$DirsMovedCount files verified in $DestDir" -f Cyan
    $Repeat = Read-Host "Move again(y/n)"
    if($Repeat -eq "y"){
        GetDates
        }else{
        Pause
        }
    }else{
    Write-Host "Interrupted by user" -f Yellow
    Exit
    }

}

Function DeleteArchives{

Write-Host "$DirCount archives found"
$Proceed = Read-Host "Proceed with deleting archives(y/n)"
if($Proceed -eq "y"){
    Write-Host "Attempting to delete archives" -f Red
    foreach ($ArchiveDir in $DirToMove){
        
        Write-Host "Deleting $($ArchiveDir.Name) " -f DarkGray
        Remove-Item -Path $ArchiveDir.FullName -Recurse -Force -ErrorAction Continue
        Start-Sleep -Milliseconds 100
        
        }
    Write-Host "Verifying Delete Activity" -f DarkYellow
    $DirsDeleted = Get-ChildItem -Directory -Path $SrcDir -Depth 2 -Filter $DateToMove*
    $DirsDeletedCount = $DirsDeleted.Count 
    
    Write-Host "In $SrcDir`n$DirCount directories present earlier; $DirsDeletedCount directories present now" -f Cyan
        
    $Repeat = Read-Host "Delete again(y/n)"
    if($Repeat -eq "y"){
        GetDates
        }else{
        Pause
        }
    }else{
    Write-Host "Interrupted by user" -f Yellow
    Exit
    }

}

#region Main
$Global:SrcDir  = Path-Check -Dir $SrcDir -DirFlag "Source"
$Global:DestDir = Path-Check -Dir $DestDir -DirFlag "Destination"

Write-Host "`nValid directories obtained"
Write-Host "Src directory : $SrcDir" -f DarkGreen
Write-Host "Dest directory : $DestDir" -f DarkGreen

ShowBanner

GetDates

#endregion Remove-Item -Path $ArchiveDir.FullName -Recurse -Force -ErrorAction Continue