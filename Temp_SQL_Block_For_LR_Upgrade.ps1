# ================================
# Block TCP/1433 using IP Security Policy
# ================================

# Policy, filter, and rule names
$policyName  = "Block_TCP_1433_Policy"
$filterList  = "Block_TCP_1433_FilterList"
$filterAction = "Block_TCP_1433_Action"

#  Create the filter list (defines what to match)
# Delete if already exists
if (Get-NetIPsecMainModeRule -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName -eq $policyName}) {
    Write-Host "Existing policy found — removing old configuration..."
    netsh ipsec static delete policy name="$policyName" | Out-Null
}

# Create a new IPSec static policy via netsh
Write-Host "Creating IPSec policy..."
netsh ipsec static add policy name="$policyName" description="Blocks any-to-any TCP port 1433" assign=no

Write-Host "Creating filter list..."
netsh ipsec static add filterlist name="$filterList"

Write-Host "Creating filter (Any <-> Any, TCP 1433)..."
netsh ipsec static add filter filterlist="$filterList" srcaddr=any dstaddr=any description="Block TCP 1433" protocol=tcp dstport=1433 mirrored=yes

Write-Host "Creating filter action (Block)..."
netsh ipsec static add filteraction name="$filterAction" action=block

Write-Host "Linking filter and action to a rule..."
netsh ipsec static add rule name="Block_TCP_1433_Rule" policy="$policyName" filterlist="$filterList" filteraction="$filterAction" description="Blocks SQL TCP 1433 traffic"

#  Assign the policy so it becomes active
Write-Host "Assigning IPSec policy..."
netsh ipsec static set policy name="$policyName" assign=yes

Write-Host "`n IPSec policy '$policyName' created and assigned successfully!"
