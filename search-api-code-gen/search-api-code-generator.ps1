<### Script written by Aravind 
For gernating powershell code to perform LogRhythm search via API. ### DO NOT ALTER THE CODE. CODE IS DEPENDED ON NUMBER OF LINES @LINE 68
Applicable to version above 7.X
Send your feedbacks to apcmakkadath@gmail.com
####>

### Clean console 
cls

### Collecting requreid paramters
$token = Read-Host "Enter LogRhythm Token Value"
$searchname = Read-Host "Web Search Saved Name[Search must be atleasat executed once ]"
$searchname = $searchname -replace " ", "%"
Write-Output "Enter sa credentials" 
$serverName = $env:computername
$DB = "LogRhythmEMDB" 
pause
$credential = Get-Credential 
$userName = $credential.UserName.Replace("\","")  
$pass = $credential.GetNetworkCredential().password
$query = "select TOP 1 SearchCriteria from LogRhythmEMDB.dbo.WebSearch where SearchCriteria LIKE '%$searchname%' order by DateUpdated desc"
$searchcriteria = invoke-sqlcmd -query $query -database $DB -serverinstance $servername -username $username -password $pass -MaxCharLength 10000
$searchcriteria = $searchcriteria.SearchCriteria

### Display collected details
Write-Host "Token: $token" -ForegroundColor Cyan
Write-Host "Saved Web Search Name: $searchname" -ForegroundColor DarkGreen
Write-Host "serverName: $serverName" -ForegroundColor Cyan
Write-Host "DB: $DB" -ForegroundColor Red
Write-Host "Query: $query" -ForegroundColor DarkYellow
Write-Host "Search criteria: $searchcriteria.searchcriteria" -ForegroundColor DarkCyan
if ($searchcriteria.SearchCriteria.Length -ge 9999){write-host "Search criteria too big. Replace url body in the generated script"}
pause

### Code starts here
function api-search-trigger {
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

### Setting header
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Content-Type", "application/json")
$headers.Add("Authorization", "Bearer mytokenvalue")

### Body content to be replaced by field value in "search criteria" from table LogRhythmEMDB.dbo.websearch. Script will make the necessary changes
$body = @"
mywebsearchcriteria
"@

### Setting response
$response = Invoke-RestMethod 'http://localhost:8505/lr-search-api/actions/search-task' -Method 'POST' -Headers $headers -Body $body
$response | ConvertTo-Json
}
#api-search-trigger

### Genreating your script 
$scriptName = $PSCommandPath
$content = Get-Content -Path $scriptName | Select-Object -Skip 34 -First 30
$searchname1 = $searchname -replace '[^a-zA-Z0-9]+', '-'
$outputfilename = $searchname1 + ".ps1.txt"
$content | Out-File $outputfilename -Force

# Read the file content
$content = Get-Content -Path $outputfilename
# Perform search and replace
$newContent = $content -replace "mytokenvalue", "$token"
$newContent | Set-Content -Path $outputfilename
$newContent = $newContent -replace "mywebsearchcriteria", "$searchcriteria"
$newContent | Set-Content -Path $outputfilename
$newContent = $newContent -replace "#api-search-trigger", "api-search-trigger"
$newContent | Set-Content -Path $outputfilename
Write-Output "Script $outputfilename is generated in your home folder"
