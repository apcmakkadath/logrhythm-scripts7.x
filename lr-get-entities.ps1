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


$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOi0xMDAsImp0aSI6IjcwYWZjNzVmLWY2ZTMtNGY3Zi1iYTYzLWJiN2MyZjIwODllNyIsImNpZCI6IjhCMDc4OEFDLUYyQkYtNDhGMS1CQ0RDLTlFMjVEMTIzRDBGMCIsImlzcyI6ImxyLWF1dGgiLCJyaWQiOiJnbG9iYWxBZG1pbiIsInBpZCI6LTEwMCwic3ViIjoiTG9nUmh5dGhtQWRtaW4iLCJleHAiOjE2ODc0MzA0MDEsImRlaWQiOjEsImlhdCI6MTY1NTg5NDQwMX0.Uxr1FmEpzmQn7uHZN1G7y4XTBOeSfeooWToRPXqjGGu3A6Jl_8nEPpQSCAl6gd9_3Qjs45Qt7ixK9-Y1gizzTOKBHqPU2-j8jqXoTyD3qDwzlP-FnQXAnCD_KgBG7W8sPfPSo1Q6n4V-8VjJFUVAcfRL1QassyGvLUXh6dxzFT3G3KJ75qg9aNZ-0Fjwb86FILAm2TYmDMCQlWRXx8qVm6pvIheVSk7I2PeCd1yNg5PyqLYEi9VQq4NvWYsoTT56LstsUCOjsl1Oz1eoKQp8f7KDDpkSjjyF5P-MHsCV_rQpxWqucqzrTcuuOMqOm6dZMKbM86fJ4naVLx-4RjVPmg")

$body = ""

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

$response = Invoke-RestMethod 'https://1.1.1.1:8501/lr-admin-api/entities/' -Method 'GET' -Headers $headers 



$response | ConvertTo-Json