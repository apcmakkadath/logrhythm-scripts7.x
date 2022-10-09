<### Script written by Aravind for error checks in LogRhythm XM log files 
Applicable to version above 7.4.X to 7.10.x
This script checks for keywork "***ERROR***" and "[ERROR]" in a specific list of log files
The list of log files are hard coded in the script
Send your feedbacks to apcmakkadath@gmail.com
####>

### Color functions
function green
{
    process { write-host $_ -ForegroundColor Green }
}

function red
{
    process { write-host $_ -ForegroundColor Red }
}

### Main menu 
function Find-Errors
{
    param (
        [string]$Title = 'Log Files'
    )
    Clear-Host
    write-output "================ $Title ================" | green
    
    write-output "1: Press '1' for Checking Mediator logs." 
    write-output "2: Press '2' for Checking Data Indexer logs." 
    write-output "3: Press '3' for Checking AI Engine and ARM logs." 
    write-output "4: Press '4' for Checking Auth Services and Common logs." 
    write-output "5: Press '5' for Checking Job Manager logs." 
    write-output "6: Press '6' for Checking Web Service logs."
    write-output "Q: Press 'Q' to quit." | red
}

### Log file path initialization
$scmedsvr = @("C:\Program Files\LogRhythm\LogRhythm Mediator Server\logs\scmedsvr.log","C:\Program Files\LogRhythm\LogRhythm Mediator Server\logs\scmpe.log","C:\Program Files\LogRhythm\LogRhythm Mediator Server\logs\scmpedns.log")
$data_indexer = @("C:\Program Files\LogRhythm\Data Indexer\logs\bulldozer.log","C:\Program Files\LogRhythm\Data Indexer\logs\columbo.log","C:\Program Files\LogRhythm\Data Indexer\logs\carpenter.log","C:\Program Files\LogRhythm\Data Indexer\logs\gomaintain.log","C:\Program Files\LogRhythm\Data Indexer\logs\transporter.log","C:\Program Files\LogRhythm\Data Indexer\elasticsearch\logs\logrhythm_index_search_slowlog.log","C:\Program Files\LogRhythm\Data Indexer\elasticsearch\logs\logrhythm_index_indexing_slowlog.log")
$aiengine = @("C:\Program Files\LogRhythm\LogRhythm AI Engine\logs\LRAIEEngine.log","C:\Program Files\LogRhythm\LogRhythm AI Engine\logs\LRAIEComMgr.log","C:\Program Files\LogRhythm\LogRhythm AI Engine Cache Drilldown\logs\LogRhythm AI Engine Cache Drilldown.log","C:\Program Files\LogRhythm\LogRhythm Alarming and Response Manager\logs\scarm.log")
$auth_common = @("C:\Program Files\LogRhythm\LogRhythm Authentication Services\logs\LogRhythm Authentication API.log","C:\Program Files\LogRhythm\LogRhythm Authentication Services\logs\LogRhythm SQL Service.log","C:\Program Files\LogRhythm\LogRhythm Authentication Services\logs\LogRhythm Windows Authentication Service.log","C:\Program Files\LogRhythm\LogRhythm Common\logs\LogRhythm API Gateway.log","C:\Program Files\LogRhythm\LogRhythm Common\logs\LogRhythm Service Registry.log","C:\Program Files\LogRhythm\LogRhythm Common\logs\LogRhythm Metrics Collection.log")
$jobmgr = @("C:\Program Files\LogRhythm\LogRhythm Job Manager\logs\lrjobmgr.log")
$webconsole = @("C:\Program Files\LogRhythm\LogRhythm Web Services\logs\LogRhythm Web Console API.log","C:\Program Files\LogRhythm\LogRhythm Web Services\logs\LogRhythm Web Indexer.log","C:\Program Files\LogRhythm\LogRhythm Web Services\logs\LogRhythm Web Console UI.log","C:\Program Files\LogRhythm\LogRhythm Web Services\logs\LogRhythm Web Services Host API.log","C:\Program Files\LogRhythm\LogRhythm Web Services\logs\LogRhythm Search API.log")

### Error finding and printing function
function error_find
{
for ($i=0; $i -lt $file_selection.Length; $i++)
        {
        $finds = Select-String -Path $file_selection[$i] -Pattern '\*\*\*ERROR'
        $finds1 = Select-String -Path $file_selection[$i] -Pattern '\[ERROR'
        if ($finds.length -gt 0) {$finds[-1]}
        if ($finds1.length -gt 0) {$finds1[-1]}
        }
}


### Menu loop
do
{
### Show menu
Find-Errors –Title 'Log Files'
### Selection process
$selection = Read-Host "Please make a selection" 

switch ($selection)
    {
    '1' 
        {
        ### Finding errors in Mediator log files ###
        $file_selection = $scmedsvr
        write-output "Checking Mediator Server log files" | green
        error_find
        pause
        }
    '2'
        {
        ### Finding errors in Data Indexer log files ###
        $file_selection = $data_indexer
        write-output "Checking Data Indexer log files" | green
        error_find
        pause
        }

    '3'
        {
        ### Finding errors in AI Engine and ARM log files ###
        $file_selection = $aiengine
        write-output "Checking AI Engine and ARM log files" | green 
        error_find
        pause
        }

    '4'
        {
        ### Finding errors in Auth Services & Common log files ###
        $file_selection = $auth_common
        write-output "Checking Auth Services and Common Services log files" | green
        error_find
        pause
        }

    '5'
        {
        ### Finding errors in Job Manager log files ###
        $file_selection = $jobmgr
        write-output "Checking Job Manager log files" | green
        error_find
        pause
        }
    '6'
        {
        ### Finding errors in Web Services log files ###
        $file_selection = $webconsole
        write-output "Checking Web Services log files" | green
        error_find
        pause
        }
    'q'
        {
        return

        }

    }
}until ($selection -eq 'q')