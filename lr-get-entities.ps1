<### Script written by Aravind for reading LogRhythm entities via API
Applicable to version above 7.4.X to 7.10.x
!!!!! IMPORTANT: Change the IP Address hard coded in the script
Send your feedbacks to apcmakkadath@gmail.com
####>
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

$lrtoken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOi0xMDAsImp0aSI6Ijk3ZGQwNDc0LTcyNjYtNGMxMS1hZmU3LWY1YmQwNWJkZWFmYiIsImNpZCI6IkUwNjQ0RUE4LTI2QUQtNDA4OC05QTMzLTgwNUIyOURFMzgxRSIsImlzcyI6ImxyLWF1dGgiLCJyaWQiOiJnbG9iYWxBZG1pbiIsInBpZCI6LTEwMCwic3ViIjoiTG9nUmh5dGhtQWRtaW4iLCJleHAiOjE3ODQ3OTA3NjIsImRlaWQiOjEsImlhdCI6MTc1MzI1NDc2Mn0.N6MYel1ww-K-MoWYZX9VBEVdND4h3u1Il_UCfQc5GkkB4KSiUdOtB1uScXw65Aq62S98KP2Ach2vSBwyk2OPB4iHKew4FfLJ4-PDso0yO23JN24SW2ai2785l8144wRU5CMpRzwKryKklzVcen-zz0OIXFdXnvyOa3me2kObdqusOA468kCwwwccvYcPXh8zsLo105QotPpMmDB10rRVuqF08jJHuLPM5aGgWiPAJYA16GPCAaNg8_mcPGvkZKdUPR8NQkWayM2_qVN7MhWrC7YScljb06zkLC7uhvtsTeaiBIoLBOw1DBZLvv2xwW4P4-1KBRcy0AQHYzCjUULp7Q"
$pmip = "192.168.1.160"
$serverurl = "$pmip"+":8501"
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $lrtoken")
$body = ""

function getlrtoken{
if($lrtoken.Length -ne 0){
Write-Output "LR Token found"
getpmip
}else{
Write-Output "LR Token NOT found"
}
}

function getpmip{
if($pmip.Length -ne 0){
Write-Output "PM IP Address provided $pmip"
Write-Output "PM Host $pmip`nServer URL is $serverurl"
#$response = Invoke-RestMethod "https://$serverurl/lr-admin-api/entities/" -Method 'GET' -Headers $headers 
$response = Invoke-WebRequest "https://$serverurl/lr-admin-api/entities/" -Method 'GET' -Headers $headers
$response #| ConvertTo-Json
}else{
Write-Output "Couldn't find PM IP Address"
}
}

# Main
getlrtoken
