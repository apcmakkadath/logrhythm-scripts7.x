<### Script written by Aravind for fixing web console error:  Error: ajax error 404
Tested on 7.9.X versions
Send your feedbacks to apcmakkadath@gmail.com
####>
Clear-Host
function green
{
    process { Write-Host $_ -ForegroundColor Green }
}

function red
{
    process { Write-Host $_ -ForegroundColor Red }
}

Write-Output "Fixing web console ajax error" | red 
Restart-Service -DisplayName "LogRhythm Admin API"
Start-Sleep 2
Restart-Service -DisplayName "LogRhythm API Gateway"
Start-Sleep 2
Restart-Service -DisplayName "LogRhythm Authentication API"
Start-Sleep 2
Restart-Service -DisplayName "LogRhythm Case API"
Start-Sleep 2
Restart-Service -DisplayName "LogRhythm Service Registry"
Start-Sleep 2
Restart-Service -DisplayName "LogRhythm SQL Service"
Start-Sleep 2
Restart-Service -DisplayName "LogRhythm Web Console API"
Start-Sleep 2
Restart-Service -DisplayName "LogRhythm Web Console UI"
Start-Sleep 2
Restart-Service -DisplayName "LogRhythm Web Indexer"
Start-Sleep 2
Restart-Service -DisplayName "LogRhythm Web Services Host API"
Start-Sleep 2
Restart-Service -DisplayName "LogRhythm Windows Authentication Service"
Start-Sleep 2
Write-Output "Please wait for the web console services to start before you check" | green
pause
