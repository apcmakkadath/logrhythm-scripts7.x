<### Script written by Aravind for reading LogRhythm entities via API
Applicable to version above 7.4.X to 7.10.x
!!!!! IMPORTANT: Change the IP Address hard coded in the script
Send your feedbacks to apcmakkadath@gmail.com
####>

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

$lrtoken = ""
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $lrtoken")
$body = ""

if($lrtoken.Length -ne 0){
Write-Host "LR Token found"
Write-Output $lrtoken
$response = Invoke-RestMethod 'https://localhost:8501/lr-admin-api/entities/' -Method 'GET' -Headers $headers 
$response | ConvertTo-Json
}else{
Write-Host "LR Token NOT found"
}
