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
$logfile = "output.log"
date >> $logfile
$lstypeid = "" #  This value must be hard coded for script scheduling purpose. The Logsource Type ID can be retrieved from LogRhythm Console -> Tools -> Knowledge -> Log Source Type Manager #
$list_guid = "" # This value must be hard coded for script scheduling purpose. List's GUID can be retrieved by running SQL query : SELECT * FROM LogRhythmEMDB.dbo.List WHERE  ListID = '<your-list-id>'
$api_token = "" # Paste the LogRhythm API token value in the variable
$pm = "localhost:8501"
Write-Output "Log source type id: $lstypeid" >> $logfile
Write-Output "List Guid: $list_guid" >> $logfile
Write-Output "Api: $pm" >> $logfile

#########################################
########## Get values required ########## 
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Bearer $api_token")

#################################################
########## Add log sources to List ##############
function addtolist{
$ls = Invoke-RestMethod "https://$pm/lr-admin-api/logsources/" -Method 'GET' -Headers $headers 
Write-Output "Attempting to Add Log Sources to List" >> $logfile
$ls | ForEach-Object {
if($_.logsourcetype.id -eq "$lstypeid"){
Write-Output $_.name
Write-Output $_.name >> $logfile

$id = $_.id
$body = @"
{
    `"items`":  [
                  {
                      `"displayValue`":"$id",
                      `"expirationDate`":null,
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
$filePaths = @("C:\Program Files\LogRhythm\LogRhythm Alarming and Response Manager\config\scarm.ini”, “D:\Program Files\LogRhythm\LogRhythm Alarming and Response Manager\config\scarm.ini”, “S:\Program Files\LogRhythm\LogRhythm Alarming and Response Manager\config\scarm.ini", "D:\LogRhythmHA\LogRhythm Alarming and Response Manager\config\scarm.ini")
foreach ($filePath in $filePaths) {
    if (Test-Path -Path $filePath -PathType Leaf) {
        Write-Host "$filePath exists."
    } else {
        Write-Host "$filePath does not exist."
    }
}
if ($filePaths -ne $null)
{
    if ($list_guid -eq "" -or $lstypeid -eq "" -or $api_token -eq ""){
        Write-Output "Check the value for List GUID OR LogSourceTypeID OR API Token" >> $logfile
        } else {
                Write-Output "Pre checks passed" >> $logfile
                addtolist
               }
} 
else 
{
Write-Output "scarm.ini NOT Found. Terminating" >> $logfile
}

