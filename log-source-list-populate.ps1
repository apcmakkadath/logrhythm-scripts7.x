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
########## Linebreak function ########### 
function linebreak
{
    Write-Output "---------------------------------------------------------------------"
}

#########################################
########## Get values required ########## 
$pm = "localhost:8501"
$list_guid = "" #This value must be hard coded for script scheduling purpose. List's GUID can be retrieved by running SQL query : SELECT * FROM LogRhythmEMDB.dbo.List WHERE  ListID = '<your-list-id>'
$api_token = "" # Paste the LogRhythm API token value in the variable
$lstypeid = "" # This value must be hard coded for script scheduling purpose. The Logsource Type ID can be retrieved from LogRhythm Console -> Tools -> Knowledge -> Log Source Type Manager #
#$logfile = "D:\LogRhythm\Scripts\output.log"  ### To be added in next version of script
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Bearer $api_token")

#################################################
########## Add log sources to List ##############
function addtolist{
$ls = Invoke-RestMethod "https://$pm/lr-admin-api/logsources/" -Method 'GET' -Headers $headers #-Body $body
Write-Output "Added Log Source IDs"
linebreak
$ls | ForEach-Object {
if($_.logsourcetype.id -eq "$lstypeid"){
Write-Output $_.id
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
Invoke-RestMethod "https://$pm/lr-admin-api/lists/$list_guid/items" -Method 'POST' -Headers $headers -Body $body
linebreak
}
}
}

###############################################
########## Check pre-requisistes ##############
if (Test-Path "C:\Program Files\LogRhythm\LogRhythm Alarming and Response Manager\config\scarm.ini")
{
    if ($list_guid -eq "" -or $lstypeid -eq "" -or $api_token -eq ""){
        Write-Output "Check the value for List GUID OR LogSourceTypeID OR API Token"
        } else {
                Write-Output "Pre checks passed"
                addtolist
               }
} 
else 
{
Write-Output "Run this script from Platform Manager"
}

