<#
.SYNOPSIS
    OpenSearch health report for a LogRhythm DX node.

.EXAMPLE
    .\osstats.ps1 -dxip 10.0.0.15
    .\osstats.ps1 -dxip 10.0.0.15 -Days 14
#>
param(
    [string]$dxip,
    [string]$osp,
    [int]$Days = 7
)

$ErrorActionPreference = 'Stop'
$script:Width  = 72
$script:Issues = New-Object System.Collections.ArrayList   # critical
$script:Warns  = New-Object System.Collections.ArrayList   # warning

# ----------------------------------------------------------------------------
# Thresholds (percent)
# ----------------------------------------------------------------------------
$T = @{
    Heap = @{ Warn = 75; Crit = 85 }
    Disk = @{ Warn = 75; Crit = 85 }   # 85 = default OpenSearch low watermark
    Cpu  = @{ Warn = 70; Crit = 90 }
}

# ----------------------------------------------------------------------------
# Output helpers (ASCII only so it renders the same in PS 5.1 / ISE / PS 7)
# ----------------------------------------------------------------------------
function Write-Rule([string]$Char = '-', [string]$Color = 'DarkGray') {
    Write-Host ($Char * $script:Width) -ForegroundColor $Color
}

function Write-Section([string]$Title) {
    Write-Host ''
    Write-Host "[ $Title ]" -ForegroundColor Cyan
    Write-Rule
}

function Write-Item([string]$Label, $Value, [string]$Color = 'White') {
    Write-Host ('  {0,-28}' -f $Label) -NoNewline -ForegroundColor Gray
    Write-Host $Value -ForegroundColor $Color
}

function Get-LevelColor([double]$Value, [double]$Warn, [double]$Crit) {
    if ($Value -ge $Crit) { 'Red' } elseif ($Value -ge $Warn) { 'Yellow' } else { 'Green' }
}

function Get-HealthColor([string]$Status) {
    switch ($Status) { 'green' { 'Green' } 'yellow' { 'Yellow' } 'red' { 'Red' } default { 'Gray' } }
}

function Write-Bar([double]$Pct, [string]$Color, [int]$Size = 10) {
    $f = [math]::Max(0, [math]::Min($Size, [int][math]::Round($Pct / 100 * $Size)))
    Write-Host ('[' + ('#' * $f) + ('-' * ($Size - $f)) + ']') -NoNewline -ForegroundColor $Color
}

function Write-Metric($Raw, [double]$Warn, [double]$Crit) {
    if ($null -eq $Raw -or "$Raw" -eq '') {
        Write-Host ('{0,-19}' -f '  n/a') -NoNewline -ForegroundColor DarkGray
        return
    }
    $v = [double]$Raw
    $c = Get-LevelColor $v $Warn $Crit
    Write-Bar $v $c 10
    Write-Host (' {0,3}%  ' -f [int]$v) -NoNewline -ForegroundColor $c
}

function Format-Size([double]$Bytes) {
    if     ($Bytes -ge 1TB) { '{0:N2} TB' -f ($Bytes / 1TB) }
    elseif ($Bytes -ge 1GB) { '{0:N2} GB' -f ($Bytes / 1GB) }
    elseif ($Bytes -ge 1MB) { '{0:N1} MB' -f ($Bytes / 1MB) }
    else                    { '{0:N0} KB' -f ($Bytes / 1KB) }
}

# ----------------------------------------------------------------------------
# Connectivity helpers
# ----------------------------------------------------------------------------
function Initialize-Tls {
    
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        if (-not ('TrustAllCertsPolicy' -as [type])) {
            Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate,
                                      WebRequest request, int certificateProblem) { return true; }
}
"@
        }
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    }
}

function Get-OsPasswordFromConsul {
    
    try {
        $keys = Invoke-RestMethod -Uri 'http://127.0.0.1:8500/v1/kv/?keys' -TimeoutSec 5
        $k = $keys | Where-Object { $_ -match 'DX_OS_PASSWORD' } | Select-Object -First 1
        if ($k) {
            $v = Invoke-RestMethod -Uri "http://127.0.0.1:8500/v1/kv/${k}?raw" -TimeoutSec 5
            if ($v) { return [string]$v }
        }
    } catch { }
    return $null
}

function Invoke-OS([string]$Path) {
    $p = @{
        Uri        = "https://$($script:dxip):9200$Path"
        Headers    = $script:Headers
        Method     = 'Get'
        TimeoutSec = 30
    }
    if ($PSVersionTable.PSVersion.Major -ge 6) { $p.SkipCertificateCheck = $true }
    Invoke-RestMethod @p
}

# ----------------------------------------------------------------------------
# Banner + environment checks
# ----------------------------------------------------------------------------
Clear-Host
Write-Rule '=' 'Cyan'
Write-Host '  LogRhythm OpenSearch Health Report' -ForegroundColor White
Write-Host ('  Generated: {0}   Host: {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $env:COMPUTERNAME) -ForegroundColor Gray
Write-Rule '=' 'Cyan'

Initialize-Tls

Write-Section 'Environment'
$lrj = Get-Service -Name lrjobmgr   -ErrorAction SilentlyContinue
$sql = Get-Service -Name mssqlserver -ErrorAction SilentlyContinue
$onPM = ($lrj.Status -eq 'Running' -and $sql.Status -eq 'Running')
if ($onPM) { Write-Item 'Platform Manager' 'Detected (services running)' 'Green' }
else       { Write-Item 'Platform Manager' 'Not detected - password may need to be supplied' 'Yellow' }

if (-not $dxip) { $dxip = Read-Host '  DX IP Address' }
$script:dxip = $dxip
Write-Item 'DX IP' $dxip 'Cyan'

if (-not $osp -and $onPM) { $osp = Get-OsPasswordFromConsul }
if ($osp) {
    Write-Item 'OpenSearch password' 'Retrieved' 'Green'
} else {
    Write-Item 'OpenSearch password' 'Not retrieved - prompting' 'Yellow'
    $sec  = Read-Host '  OpenSearch password' -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
    try { $osp = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(('{0}:{1}' -f 'LogRhythmOpenSearch', $osp)))
$script:Headers = @{ Authorization = "Basic $auth"; 'Content-Type' = 'application/json' }

try {
    $root = Invoke-OS ''
    Write-Item 'Reachability' ('OK  (OpenSearch {0})' -f $root.version.number) 'Green'
} catch {
    Write-Item 'Reachability' 'FAILED' 'Red'
    Write-Host ('  {0}' -f $_.Exception.Message) -ForegroundColor DarkRed
    return
}

# ----------------------------------------------------------------------------
# Collect data
# ----------------------------------------------------------------------------
try {
    $health = Invoke-OS '/_cluster/health'
    $nodes  = Invoke-OS '/_cat/nodes?format=json&h=name,node.role,master,heap.percent,cpu,load_1m'
    $alloc  = Invoke-OS '/_cat/allocation?format=json&bytes=b&h=node,disk.used,disk.avail,disk.total,disk.percent,shards'
    $idx    = Invoke-OS '/_cat/indices?format=json&bytes=b&h=index,health,status,store.size,docs.count,pri,rep'
} catch {
    Write-Host ("`n  Data collection failed: {0}" -f $_.Exception.Message) -ForegroundColor Red
    return
}

# ----------------------------------------------------------------------------
# Cluster
# ----------------------------------------------------------------------------
Write-Section 'Cluster'
$hc = Get-HealthColor $health.status
Write-Item 'Cluster name' $health.cluster_name
Write-Item 'Status' $health.status.ToUpper() $hc
Write-Item 'Nodes (data)' ('{0} ({1})' -f $health.number_of_nodes, $health.number_of_data_nodes)
Write-Item 'Active primary shards' $health.active_primary_shards
Write-Item 'Active shards' $health.active_shards
Write-Item 'Unassigned shards' $health.unassigned_shards $(if ($health.unassigned_shards -gt 0) { 'Red' } else { 'Green' })
Write-Item 'Initializing / Relocating' ('{0} / {1}' -f $health.initializing_shards, $health.relocating_shards) $(if ($health.initializing_shards + $health.relocating_shards -gt 0) { 'Yellow' } else { 'Green' })
Write-Item 'Pending tasks' $health.number_of_pending_tasks $(if ($health.number_of_pending_tasks -gt 0) { 'Yellow' } else { 'Green' })

$pctShards = [double]$health.active_shards_percent_as_number
$pc = if ($pctShards -ge 100) { 'Green' } elseif ($pctShards -ge 90) { 'Yellow' } else { 'Red' }
Write-Host ('  {0,-28}' -f 'Shard availability') -NoNewline -ForegroundColor Gray
Write-Bar $pctShards $pc 20
Write-Host (' {0:N1}%' -f $pctShards) -ForegroundColor $pc

if ($health.status -eq 'red')    { [void]$script:Issues.Add('Cluster status is RED') }
if ($health.status -eq 'yellow') { [void]$script:Warns.Add('Cluster status is YELLOW') }
if ($health.unassigned_shards -gt 0) { [void]$script:Warns.Add("$($health.unassigned_shards) unassigned shard(s)") }

# ----------------------------------------------------------------------------
# Nodes
# ----------------------------------------------------------------------------
Write-Section 'Nodes'
Write-Host ('  {0,-16}{1,-7}{2,-19}{3,-19}{4,-7}{5}' -f 'NODE', 'ROLE', 'HEAP', 'DISK', 'CPU', 'LOAD1') -ForegroundColor DarkGray
foreach ($n in $nodes) {
    $a = $alloc | Where-Object { $_.node -eq $n.name } | Select-Object -First 1
    $star = if ($n.master -eq '*') { '*' } else { ' ' }
    Write-Host ('{0} {1,-16}{2,-7}' -f $star, $n.name, $n.'node.role') -NoNewline -ForegroundColor White
    Write-Metric $n.'heap.percent' $T.Heap.Warn $T.Heap.Crit
    Write-Metric $a.'disk.percent' $T.Disk.Warn $T.Disk.Crit
    $cpuC = if ($n.cpu) { Get-LevelColor ([double]$n.cpu) $T.Cpu.Warn $T.Cpu.Crit } else { 'DarkGray' }
    Write-Host ('{0,4}%  ' -f $n.cpu) -NoNewline -ForegroundColor $cpuC
    Write-Host $n.load_1m -ForegroundColor Gray

    if ($n.'heap.percent' -and [double]$n.'heap.percent' -ge $T.Heap.Crit) { [void]$script:Issues.Add("Heap $($n.'heap.percent')% on $($n.name)") }
    elseif ($n.'heap.percent' -and [double]$n.'heap.percent' -ge $T.Heap.Warn) { [void]$script:Warns.Add("Heap $($n.'heap.percent')% on $($n.name)") }
    if ($a.'disk.percent' -and [double]$a.'disk.percent' -ge $T.Disk.Crit) { [void]$script:Issues.Add("Disk $($a.'disk.percent')% on $($n.name)") }
    elseif ($a.'disk.percent' -and [double]$a.'disk.percent' -ge $T.Disk.Warn) { [void]$script:Warns.Add("Disk $($a.'disk.percent')% on $($n.name)") }
}
Write-Host '  (* = elected master)' -ForegroundColor DarkGray

# ----------------------------------------------------------------------------
# Indices
# ----------------------------------------------------------------------------
Write-Section 'Indices'
$totalIdx = @($idx).Count
$logIdx   = @($idx | Where-Object { $_.index -like 'logs-*' })
$nRed     = @($idx | Where-Object { $_.health -eq 'red' }).Count
$nYellow  = @($idx | Where-Object { $_.health -eq 'yellow' }).Count
$nGreen   = @($idx | Where-Object { $_.health -eq 'green' }).Count
$nClosed  = @($idx | Where-Object { $_.status -eq 'close' }).Count

Write-Item 'Total indices' $totalIdx
Write-Item 'Log indices (logs-*)' $logIdx.Count
Write-Item 'Critical (red)'  $nRed    $(if ($nRed    -gt 0) { 'Red' }    else { 'Green' })
Write-Item 'Warning (yellow)' $nYellow $(if ($nYellow -gt 0) { 'Yellow' } else { 'Green' })
Write-Item 'OK (green)' $nGreen 'Green'
if ($nClosed -gt 0) { Write-Item 'Closed' $nClosed 'Yellow' }

if ($nRed -gt 0)    { [void]$script:Issues.Add("$nRed red index/indices") }
if ($nYellow -gt 0) { [void]$script:Warns.Add("$nYellow yellow index/indices") }

$bad = @($idx | Where-Object { $_.health -in 'red', 'yellow' } | Sort-Object health | Select-Object -First 10)
if ($bad.Count -gt 0) {
    Write-Host ''
    Write-Host '  Unhealthy indices (first 10):' -ForegroundColor Gray
    foreach ($b in $bad) {
        Write-Host ('    {0,-8}' -f $b.health.ToUpper()) -NoNewline -ForegroundColor (Get-HealthColor $b.health)
        Write-Host $b.index -ForegroundColor White
    }
}

# ----------------------------------------------------------------------------
# Storage
# ----------------------------------------------------------------------------
Write-Section "Log index storage (last $Days days)"
if ($logIdx.Count -eq 0) {
    Write-Host '  No logs-* indices found.' -ForegroundColor Yellow
} else {
    $dated = foreach ($i in $logIdx) {
        if ($i.index -match '(\d{4})[-.](\d{2})[-.](\d{2})') {
            [pscustomobject]@{
                Date = [datetime]::new([int]$Matches[1], [int]$Matches[2], [int]$Matches[3])
                Size = [long]$i.'store.size'
                Docs = [long]$i.'docs.count'
            }
        }
    }
    $daily = @($dated | Group-Object { $_.Date.ToString('yyyy-MM-dd') } | ForEach-Object {
        [pscustomobject]@{
            Date = [datetime]$_.Name
            Size = ($_.Group | Measure-Object Size -Sum).Sum
            Docs = ($_.Group | Measure-Object Docs -Sum).Sum
        }
    } | Sort-Object Date)

    $totalBytes = ($logIdx | ForEach-Object { [long]$_.'store.size' } | Measure-Object -Sum).Sum
    Write-Item 'Total log storage' (Format-Size $totalBytes) 'Cyan'

    if ($daily.Count -gt 0) {
        $oldest = $daily[0].Date
        $newest = $daily[-1].Date
        $span   = ($newest - $oldest).Days + 1
        $avgAll = $totalBytes / $daily.Count
        $recent = @($daily | Select-Object -Last $Days)
        $avgRec = ($recent | Measure-Object Size -Average).Average
        $maxDay = $daily | Sort-Object Size -Descending | Select-Object -First 1

        Write-Item 'Oldest / newest index' ('{0:yyyy-MM-dd} / {1:yyyy-MM-dd}' -f $oldest, $newest)
        Write-Item 'Retention span' ('{0} days ({1} with data)' -f $span, $daily.Count) $(if ($span -ne $daily.Count) { 'Yellow' } else { 'White' })
        Write-Item 'Avg size per day (all)' (Format-Size $avgAll)
        Write-Item "Avg size per day ($Days d)" (Format-Size $avgRec) 'Cyan'
        Write-Item 'Largest day' ('{0}  {1:yyyy-MM-dd}' -f (Format-Size $maxDay.Size), $maxDay.Date)

        if ($span -ne $daily.Count) { [void]$script:Warns.Add("Gaps in daily indices ($($daily.Count) of $span days present)") }
        if ($newest -lt (Get-Date).Date.AddDays(-1)) { [void]$script:Issues.Add("Newest log index is $($newest.ToString('yyyy-MM-dd')) - ingestion may have stopped") }

        # Disk runway estimate (to the 85% low watermark)
        $totDisk  = ($alloc | Where-Object { $_.'disk.total' } | ForEach-Object { [double]$_.'disk.total' } | Measure-Object -Sum).Sum
        $usedDisk = ($alloc | Where-Object { $_.'disk.used'  } | ForEach-Object { [double]$_.'disk.used'  } | Measure-Object -Sum).Sum
        if ($totDisk -gt 0 -and $avgRec -gt 0) {
            $headroom = $totDisk * 0.85 - $usedDisk
            $runway   = [math]::Floor($headroom / $avgRec)
            $rc = if ($runway -lt 7) { 'Red' } elseif ($runway -lt 30) { 'Yellow' } else { 'Green' }
            Write-Item 'Disk runway (est.)' ('~{0} days to 85% (no retention clean-up assumed)' -f [math]::Max(0, $runway)) $rc
            if ($runway -lt 7)  { [void]$script:Issues.Add("Disk runway ~$runway days") }
            elseif ($runway -lt 30) { [void]$script:Warns.Add("Disk runway ~$runway days") }
        }

        Write-Host ''
        Write-Host ('  {0,-12}{1,-24}{2,-12}{3}' -f 'DATE', 'SIZE', '', 'DOCS') -ForegroundColor DarkGray
        $scale = ($recent | Measure-Object Size -Maximum).Maximum
        foreach ($d in $recent) {
            $pct = if ($scale -gt 0) { $d.Size / $scale * 100 } else { 0 }
            $c   = if ($avgRec -gt 0 -and $d.Size -gt $avgRec * 1.5) { 'Yellow' } else { 'Cyan' }
            Write-Host ('  {0:yyyy-MM-dd}  ' -f $d.Date) -NoNewline -ForegroundColor White
            Write-Bar $pct $c 16
            Write-Host (' {0,10}   {1,15:N0}' -f (Format-Size $d.Size), $d.Docs) -ForegroundColor $c
        }
        Write-Host '  (yellow bar = day is >1.5x the recent average)' -ForegroundColor DarkGray
    }
}


# Print Summary
Write-Host ''
Write-Rule '=' 'Cyan'
if ($script:Issues.Count -gt 0) {
    Write-Host '  OVERALL: CRITICAL' -ForegroundColor Red
} elseif ($script:Warns.Count -gt 0) {
    Write-Host '  OVERALL: WARNING' -ForegroundColor Yellow
} else {
    Write-Host '  OVERALL: HEALTHY' -ForegroundColor Green
}
foreach ($m in $script:Issues) { Write-Host "   [CRIT] $m" -ForegroundColor Red }
foreach ($m in $script:Warns)  { Write-Host "   [WARN] $m" -ForegroundColor Yellow }
Write-Rule '=' 'Cyan'
