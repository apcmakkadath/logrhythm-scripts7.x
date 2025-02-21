<### Script written by Aravind for adding log sources to a list of selected sourcetype
Applicable to version above 7.X
Tested successfully on version 7.14.X
Send your feedbacks to apcmakkadath@gmail.com
####>

#########################################
########## Setting TLS ################## 
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

#########################################
########## Constants ########### 
$Global:logfile = "output.log"
Write-Output "====================================" >> $Global:logfile
date >> $Global:logfile
$Global:lstypeid = "" #  This value must be hard coded for script scheduling purpose. The Logsource Type ID can be retrieved from LogRhythm Console -> Tools -> Knowledge -> Log Source Type Manager #
$Global:list_guid = "" # This value must be hard coded for script scheduling purpose. List's GUID can be retrieved by running SQL query : SELECT * FROM LogRhythmEMDB.dbo.List WHERE  ListID = '<your-list-id>'
$Global:api_token = "" # Paste the LogRhythm API token value in the variable
$Global:pm = "localhost:8501"

#########################################
### getting keys and credentials from encrypted file
function getsapwd{
try {
$configdirpath = "C:\Program Files\LogRhythm\LogRhythm Alarming and Response Manager\config\LSLP"
$sapwd_encrypted = Get-Content "$configdirpath\sapwd.encrypted"
$sapwd_secure = ConvertTo-SecureString $sapwd_encrypted
$Global:sapwd = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sapwd_secure))
$sapwdflg=1
addtolist
}catch{
Write-Output "Unable to get sa pwd. Try executing ls-list-populate-config.ps1"
}
}

Write-Output "Log source type id: $Global:lstypeid" >> $logfile
Write-Output "List Guid: $Global:list_guid" >> $Global:logfile
Write-Output "Api: $Global:pm" >> $Global:logfile

#########################################
########## Update list ########## 
function addtolist{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Bearer $api_token")

#################################################
########## Add log sources to List ##############
Write-Output "Attempting to Add Log Sources to List" >> $logfile
$db = "LogRhythmEMDB"
$instance = $env:COMPUTERNAME
$user = "sa"

$msgsourceid = invoke-sqlcmd -query "select * from LogRhythmEMDB.dbo.MsgSource where MsgSourceTypeID = '$lstypeid'" -database $db -serverinstance $instance -username $user -password $sapwd 

$msgsourceid | ForEach-Object {
if($_.MsgSourceTypeId -eq "$lstypeid"){
Write-Output $_.name
Write-Output $_.name >> $logfile

$id = $_.MsgSourceId

$body = @"
{
    `"items`":  [
                  {
                      `"displayValue`":"$id",
                      `"isExpired`":false,
                      `"isListItem`":false,
                      `"isPattern`":false,
                      `"listItemDataType`":`"Int32`",
                      `"listItemType`":`"MsgSource`",
                      `"value`":`"$id`"
                  }
              ]
}
"@
$result = Invoke-RestMethod "https://$pm/lr-admin-api/lists/$list_guid/items" -Method 'POST' -Headers $headers -Body $body

}
}

}

###############################################
########## Check pre-requisistes ##############
# finding scarm.ini
function prechecks{
$filePaths = @("C:\Program Files\LogRhythm\LogRhythm Alarming and Response Manager\config\scarm.ini”, “D:\LogRhythmHA\LogRhythm Alarming and Response Manager\config\scarm.ini”, “S:\LogRhythmHA\LogRhythm Alarming and Response Manager\config\scarm.ini")
foreach ($filePath in $filePaths) {
    if (Test-Path -Path $filePath -PathType Leaf) {
        Write-Host "scarm.ini found"
        write-output "$filePath"
        $scarmflag=1
    }
}


# checking logsourcetypeid, api-token, listid
if ($Global:lstypeid -ne '' -and $api_token -ne '' -and $list_guid -ne ''){
Write-Output "Values found for LogSourceTypeID, API Token and List GUID"
$valueflag=1
}else{
Write-Output "Value in correct for lstypeid OR api_token OR list_guid"
write-output "LogSourceTypeID: $lstypeid"
write-output "API Token: $api_token"
write-output "List Guid: $list_guid"
}
if ($scarmflag -eq 1 -and $valueflag -eq 1){
Write-Output "Pre checks passed"
getsapwd
}else{
Write-Output "Pre check failed"
}
}
prechecks
