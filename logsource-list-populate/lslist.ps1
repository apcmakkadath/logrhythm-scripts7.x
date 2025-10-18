<### Script written by Aravind for adding log sources to a list of selected sourcetype
Applicable to version above 7.X
Tested successfully on version 7.19.X
Send your feedbacks to apcmakkadath@gmail.com

Sample list.csv 
ListID,LogSourceTypeID
2001,1000669
2002,1000548

####>

# set tls
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
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls10 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

# constants
$Global:api_token = "" # Paste the LogRhythm API token value in the variable
$Global:pm = "localhost:8501"
$Global:sapwd = "logrhythm!1"
$list_path = "C:\LogRhythm\LogSourcesList\list.csv" # path to csv list file
$db = "LogRhythmEMDB"
$instance = $env:COMPUTERNAME
$user = "sa"

function checksapwd{
try {
 
    Invoke-Sqlcmd -ServerInstance $instance -Username $user -Password $sapwd -Query "SELECT GETDATE()" -ErrorAction Stop
    Write-Output "SQL Login Successful`nProceeding..."
    addtolist
}
catch {
    Write-Output "SQL Login Failed: $($_.Exception.Message)"
}
}

########## Update list ########## 
function addtolist{
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Bearer $api_token")

########## Add log sources to List ##############
Write-Host "Attempting to Add Log Sources to List"
$list = Import-Csv -Path $list_path

foreach($row in $list){
$listid = $row.ListID
$lstypeid = $row.LogSourceTypeID
Write-Host "Fetching GUID for ListID $listid"
$listguid = invoke-sqlcmd -query "select * from LogRhythmEMDB.dbo.List where ListID = '$listid'" -database $db -serverinstance $instance -username $user -password $sapwd
$list_guid = $listguid.guid.Guid
$msgsourceid = invoke-sqlcmd -query "select * from LogRhythmEMDB.dbo.MsgSource where MsgSourceTypeID = '$lstypeid'" -database $db -serverinstance $instance -username $user -password $sapwd
Write-Host "Fetching Log sources for LogSourceTypeID $lstypeid"
$msgsourceid | ForEach-Object {
if($_.MsgSourceTypeId -eq "$lstypeid"){

Write-Host $_.name

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
}

########## Check requirements ##############
function ispm{
$isjmp=Get-Service -name lrjobmgr
if($isjmp -ne $null)
    {
    Write-Host "Running from Platform Manager.`nProceeding..."
    isvaluesok
    }
else
    {
    Write-Host "Job Manager service not found. You should run the script from Platform Manager"
    }
}

function checklist{
if (-Not (Test-Path $list_path))
    {
    Write-Host "Couldn't find a csv at $list_path OR list_path variable NULL.`nQuitting."
    }else
    {
    Write-Host "Found list.csv. Proceeding to add to list..."
    addtolist
    }
}

function isvaluesok{
if($Global:api_token -eq '' -or $Global:sapwd -eq '' -or $list_path -eq '')
    {
    Write-Host "Values missing`nCheck LR API token/sa credentials/List path`nUnable to proceed`nQuitting..."
    }
    else
    {
    Write-Host "Required values found.`nProceeding..."
    checklist
    }
}
# Main
ispm
