[cmdletBinding()]
param(
[Parameter(Mandatory=$true)][String]$IDPairFile,
[Parameter(Mandatory=$true)][String]$TokenFile
)
Clear-Host
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
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

# Sample Json
function ShowJsonformat{
write-host " --- Example Json ID Pair format ---
[
  {
    "LogSourceTypeID": 500168,
    "ListID": 2001
  },
  {
    "LogSourceTypeID": 500169,
    "ListID": 2002
  },
  {
    "LogSourceTypeID": 500170,
    "ListID": 2003
  }
]
--- Example Json Token File format ---
{
	"Token": "eyJhbGci.....",
	"SaPwd": "logrhythm!1"
}
"
}

function ReadIDPair{

$JsonIDPair = Get-Content $IDPairFile 
$IDPair = $JsonIDPair | ConvertFrom-Json 
Write-Host "$($IDPair.Count) Pairs found "
foreach ($Pair in $IDPair){
if($($Pair.ListID) -is [int]){Write-Host "$($Pair.ListID) is valid"}else{Write-Host "Invalid ListID: $($Pair.ListID)"; ShowJsonformat; exit}
if($($Pair.LogSourceTypeID) -is [int]){Write-Host "$($Pair.LogSourceTypeID) is valid"}else{Write-Host "Invalid LogSourceTypeID: $($Pair.LogSourceTypeID)"; ShowJsonformat; exit}
}

if((Get-Content -Path $TokenFile).Length -gt 0){
Write-Host "Valid Token File Found."
$Pass = (Get-Content -Path $TokenFile) | ConvertFrom-Json
$Token = $Pass.Token
$Sapwd = $Pass.SaPwd
if($Token.length -gt 0 -and $Sapwd.length -gt 0){
Write-Host "Retrieved LogRhythm Token and credentials"
}else{
Write-Host "invalid Token File Contents"
ShowJsonformat
}
}else{
Write-Host "Invalid Token File."
exit
}

GetLogSourceTypeID
}

function GetLogSourceTypeID{
try{
$LSTHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$LSTHeaders.Add("accept", "application/json")
$LSTHeaders.Add("Authorization", "Bearer $Token")
foreach ($Pair in $IDPair){
$LSTUrl1 = "https://localhost:8501/lr-admin-api/logsources/"
$LSTUrl2 = "?offset=0&count=1000&messageSourceTypeId=$($Pair.LogSourceTypeID)&recordStatus=all"
$LSTUrl = $LSTUrl1 + $LSTUrl2
$LSTID = Invoke-RestMethod -Uri $LSTUrl -Headers $LSTHeaders -Method Get 
Write-Host "--- LogSources for LogSourceType ID: $($Pair.LogSourceTypeID). List ID: $($Pair.ListID)--- " -ForegroundColor DarkGreen
foreach ($LS in $LSTID){


$ListHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$ListHeaders.Add("accept", "application/json")
$ListHeaders.Add("loadListItems", "true")
$ListHeaders.Add("content-type", "application/json")
$ListHeaders.Add("Authorization", "Bearer $Token")
$ListGUID = Invoke-Sqlcmd -Query "Select ListID, GUID from LogRhythmEMDB.dbo.List where ListID = $($Pair.ListID)"
$Guid = $ListGUID.GUID
$id = $($LS.id)
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
Write-Host "$id : $($LS.Name) to List with GUID $Guid" -ForegroundColor Cyan
$ListAPICall = Invoke-RestMethod -Uri "https://localhost:8501/lr-admin-api/lists/$Guid/items" -Method POST -Headers $ListHeaders -Body $body

}

}
}catch{
Write-Host "Could not read Log Sources!"
}
}

# Main
ReadIDPair -IDPairFile $IDPairFile -TokenFile $TokenFile
