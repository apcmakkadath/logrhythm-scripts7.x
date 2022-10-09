<### Script written by Aravind to Write to file read a list entries from LogRhythm List Manager and writes the values to a text file locally. 
Applicable to version above 7.4.X to 7.10.x
Send your feedbacks to apcmakkadath@gmail.com

Write to file read a list entries from LogRhythm List Manager and writes the values to a text file locally.
### !!!! Pre requisistes :
1. Get a token from LogRhythm -> Deployment Manager -> Third party applications -> Generate token
2. Get the ListID of the List from LogRhythm List Manager. List Manager -> ListID (#list_id)
3. Get the List guid from SQL Server Management Studio. SELECT *   FROM [LogRhythmEMDB].[dbo].[List] where ListID = list_id
4. Copy the List GUID (#list_guid)
####>


### Get the list item details

### Required parameters

$pm_ip = "localhost:8501"
$list_guid = ""
$bearer_token = ""
$output_location = "d:\ip_blocklist_lr.txt"

### Setting TLS 1.2

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

### Reading the list 

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer $bearer_token")
$body = ""
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
Write-Host $bearer_token

$response = Invoke-RestMethod "https://$pm_ip/lr-admin-api/lists/$list_guid/" -Method 'GET' -Headers $headers 
 
### Write to file 

$response.items | Foreach-object {$_.value} | Out-File -FilePath $output_location
