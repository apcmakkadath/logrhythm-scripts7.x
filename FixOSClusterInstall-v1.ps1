


# ============================================
# LogRhythm DX - Consul Configuration Utility
# ============================================

$Consul = "http://localhost:8500"
$SqlServer = "localhost"

$dxle = "false"

$dxcacert = @"
-----BEGIN CERTIFICATE-----
MIIDxTCCAq2gAwIBAgIUNwmFl57pW31bs98DOMVbru0cEF0wDQYJKoZIhvcNAQEL
BQAwcjELMAkGA1UEBhMCVVMxETAPBgNVBAgMCENvbG9yYWRvMRAwDgYDVQQHDAdC
b3VsZGVyMRIwEAYDVQQKDAlMb2dSaHl0aG0xETAPBgNVBAsMCGdJUU1WTFBEMRcw
FQYDVQQDDA5EWC1DQS1nSVFNVkxQRDAeFw0yNjExMTUwOTIxMjBaFw0zNjExMTIw
OTIxMjBaMHIxCzAJBgNVBAYTAlVTMREwDwYDVQQIDAhDb2xvcmFkbzEQMA4GA1UE
BwwHQm91bGRlcjESMBAGA1UECgwJTG9nUmh5dGhtMREwDwYDVQQLDAhnSVFNVkxQ
RDEXMBUGA1UEAwwORFgtQ0EtZ0lRTVZMUEQwggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQCuGK61veONwEwrfOlyx8wzuNmEVwMWTBUtM+45TLc5PUYVfs1n
6HvIY/G8NbbahmlNTWxduzDq/Ih5ZSxN60+WNNJqZdCUjl/SkgkfJt1AFcsAYs5F
MF/euzILe9zFpdIBCeEcFhw1PO54RhH35HG1fHswmVUJ1GWyD5b0s8hoXk2F/S9b
iDPXSWoWtG3C4fKckySASb+3PpBL/xti3UxWSjGEBFdQ4gqiyngrF6YF3RsRhuzK
psR/DOeILaqva1P4mltWTdbdOXuN0cZxKmJvd+RF2c+hqBmnZ7VhR/i5RctkgGdY
hlZxPyJVNyuR4hb3GNO/IYvVE59VwnzmxU4JAgMBAAGjUzBRMB0GA1UdDgQWBBRO
gyMWmVBhk16yKGYYmBE4r1USwDAfBgNVHSMEGDAWgBROgyMWmVBhk16yKGYYmBE4
r1USwDAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCoOeeOuc4Y
D2VydCR/piQHvsEavh6jccaLZyJeNLLvSw9eBpzpb6/1hBVXZyOeN/pDF88U+sH3
SbBEj0dnwlqrXpmd3vIoqsUR8bRwITSnUoMgkeVZoBuqrOflH6uIO6/UJVwbl3cJ
5HPum5lNNTM0wFeeE6q0Z7rwfgfCsFIr72KaKnVJzlzQ9HnHsOipsEfcF67G8DWv
za6d7iOSkjzu+TREaYGLkq1z93ONd4y1tcsWUnl2ucrY5jjKkU+OqN5MKH4wrwGp
mz9R9WNn+ok9w7BFPVXk7eTbrmWt70DiFdxOuatVhzm8m/D7DCyqZyJgzsAGMdZ7
2fTuFgL/KcnI
-----END CERTIFICATE-----

"@

$dxcacertpath = "/usr/local/logrhythm/env/opensearch-ca.pem"

$dxoscakey = @"
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCuGK61veONwEwr
fOlyx8wzuNmEVwMWTBUtM+45TLc5PUYVfs1n6HvIY/G8NbbahmlNTWxduzDq/Ih5
ZSxN60+WNNJqZdCUjl/SkgkfJt1AFcsAYs5FMF/euzILe9zFpdIBCeEcFhw1PO54
RhH35HG1fHswmVUJ1GWyD5b0s8hoXk2F/S9biDPXSWoWtG3C4fKckySASb+3PpBL
/xti3UxWSjGEBFdQ4gqiyngrF6YF3RsRhuzKpsR/DOeILaqva1P4mltWTdbdOXuN
0cZxKmJvd+RF2c+hqBmnZ7VhR/i5RctkgGdYhlZxPyJVNyuR4hb3GNO/IYvVE59V
wnzmxU4JAgMBAAECggEAH9gk8NpUaqO/av70pomUOOu5YcMWrffpsbR7gSCerQof
rSPeB4EXTy6001PR6API9BpS1Yw9ZOYfQnE2muQNUTDFQi/waJPoRBhxMbEGrEew
M5hfGXnBN3jvLPmRhtePY6A+fEgxDa3hAr/yXnD7OZKU5+1MCDnBBkJivsy5vhkg
Gve4JBwX5lJQh9l8BWzeJn3qyJO9ldMni9buhEXLjGS8/CJooN30UPwI8aWyatWk
soPrI1yoeTlJShLhrtmVbLMAiS1muQqqUavesAy8X9crQy9Y/Etg6zgJvU/cStWA
voOhYWc3bdD7gEHlsfyBlHs9F7iaVYUyAvYmguJJTwKBgQDp4h2ELxCv7N7yqmXt
pnOROjPYdVP4DnHpByZvpD/PViwEkVb9lOlcfbyzxO2pEuyNdrm3j8mUU/XTcenP
cUrWxmRta68UsGqqHmXzrkj+oMCCeIjTg/gZl2vGdjtpidNFvY7GZMeaaLh663Or
RtTGsVF0v6JmwGNuqrrYbIFOwwKBgQC+jzy+nyFxAdPkNy8va8JDdRmDBdsHUaci
Z8Nh5z+JydYoD2yNVYmgmI8AgtorlAYDyzOYDrywQDy/2lZw4w+fefpHOMA5jc6r
7XqoYgCifAbP2bX+OiWO4u95InmvIQ7dVnfRmXOb8iL1lz4YBuxkfGONtBt3bOAf
PRPDKjJ7QwKBgQCGMdIjvOmDN5L4g2K2h/H5Wv7SbQd/5bHgNdUM654dNeFNwaK7
Hw0Cn7Z9IzoF77DAvmVy+FJ+A+qhptOzzdpV/0EyMz4izdJ1x7lRpyeEyfGLKuO/
ERJyhJo3JjGSrZ0Gf+wC02Jfq0RmauBUXvDJDIajSS1CbZLftaA9e4x6BwKBgBpS
tQRr/PWcWAXVbaoyS4KAAYcs3uWy7NB+3ul+RTOmcvPTtZ4Ma9eIW3CporOUXgRW
JIljt8LtDLc/1OMBKp5P/jeqajtJEHyFcIUkDIxlb5d0roQwyhFj3cqw7Xg4q9H9
aM3GUcb/+r5MJyKwiiUTXbksYQLtQkRubnVuNcz7AoGAKNMsNBDw2UGhl2tMAU78
WbgXw5H8XqKAzxymjh7RRQG3fXcfzcwW4LFLJbbevrymuFaNseaJ2Jrh7B2wy57Z
GzvtBNtK4Z1zybJHco1G1L63t51cBwc8HKrwKx3VNyxnRkavFD/knEEXYc60pSOF
AuJ+Cd19SrDZcew36ULflsM=
-----END PRIVATE KEY-----

"@

$dxosp = "PNuR7wnVbAKv1CfRLxkVE5Zq9iJr53QM"
$dxosscheme = "https"
$dxosu = "LogRhythmOpenSearch"

function Select-DXCluster {

    param (
        [Parameter(Mandatory)]
        [array]$Clusters
    )

    $Selected = 0

    while ($true) {

        Clear-Host

        Write-Host "`n  LogRhythm DX Cluster Selection" -ForegroundColor Cyan
        Write-Host "  Use UP/DOWN arrows and ENTER to select.`n"

        for ($i = 0; $i -lt $Clusters.Count; $i++) {

            $Cluster = $Clusters[$i]

            if ($i -eq $Selected) {
                Write-Host "  > $($Cluster.ClusterName) [$($Cluster.ClusterIdentifier)]" `
                    -ForegroundColor Black -BackgroundColor Cyan
            }
            else {
                Write-Host "    $($Cluster.ClusterName) [$($Cluster.ClusterIdentifier)]"
            }
        }

        $Key = [Console]::ReadKey($true)

        switch ($Key.Key) {

            "UpArrow" {
                if ($Selected -gt 0) {
                    $Selected--
                }
                else {
                    $Selected = $Clusters.Count - 1
                }
            }

            "DownArrow" {
                if ($Selected -lt ($Clusters.Count - 1)) {
                    $Selected++
                }
                else {
                    $Selected = 0
                }
            }

            "Enter" {
                return $Clusters[$Selected]
            }

            "Escape" {
                return $null
            }
        }
    }
}

function Start-DXConfigurator {

    # ----------------------------------------
    # 1. SQL authentication - only once
    # ----------------------------------------

    $SAPassword = Read-Host "Enter SQL SA Password" -AsSecureString
    $BSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SAPassword)

    try {
        $PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)

        Write-Host "`nConnecting to LogRhythmEMDB..." -ForegroundColor Cyan

        $DXClusters = @(Invoke-Sqlcmd `
            -Query "SELECT ClusterName, ClusterIdentifier FROM LogRhythmEMDB.dbo.NGPCluster" `
            -ServerInstance $SqlServer `
            -Database LogRhythmEMDB `
            -Username sa `
            -Password $PlainPassword `
            -SuppressProviderContextWarning `
            -ErrorAction Stop)
    }
    catch {
        Write-Host "`nSQL connection failed: $_" -ForegroundColor Red
        return
    }
    finally {
        if ($BSTR -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        }

        $PlainPassword = $null
    }

    if ($DXClusters.Count -eq 0) {
        Write-Host "No DX clusters found!" -ForegroundColor Red
        return
    }

    # ----------------------------------------
    # 2. Repeat cluster configuration
    # ----------------------------------------

    do {

        # Select cluster
        $SelectedCluster = Select-DXCluster -Clusters $DXClusters

        if ($null -eq $SelectedCluster) {
            Write-Host "`nSelection cancelled." -ForegroundColor Yellow
            break
        }

        $DXID = $SelectedCluster.ClusterIdentifier

        # Confirm selection
        Write-Host "`nSelected DX Cluster:" -ForegroundColor Cyan
        Write-Host "Name : $($SelectedCluster.ClusterName)"
        Write-Host "ID   : $DXID"

        $Confirm = Read-Host "`nApply configuration to this cluster? (Y/N)"

        if ($Confirm -match '^(Y|YES)$') {

            # --------------------------------
            # Consul KV configuration
            # --------------------------------

            $Config = [ordered]@{
                "DX_LOCKING_ENABLED"    = $dxle
                "DX_OS_CA_CERT"         = $dxcacert
                "DX_OS_CA_CERT_PATH"    = $dxcacertpath
                "DX_OS_CA_KEY"          = $dxoscakey
                "DX_OS_KIBANA_PASSWORD" = $dxosp
                "DX_OS_PASSWORD"        = $dxosp
                "DX_OS_SCHEME"          = $dxosscheme
                "DX_OS_USERNAME"        = $dxosu
            }

            $Success = 0
            $Failed = 0

            Write-Host "`nApplying Consul configuration..." -ForegroundColor Cyan

            foreach ($Entry in $Config.GetEnumerator()) {

                $Key = "services/lr-dx-config/$DXID/configs/$($Entry.Key)"

                try {

                    $EncodedKey = ($Key -split '/' | ForEach-Object {
                        [uri]::EscapeDataString($_)
                    }) -join '/'

                    $Result = Invoke-RestMethod `
                        -Method PUT `
                        -Uri "$Consul/v1/kv/$EncodedKey" `
                        -Body ([string]$Entry.Value) `
                        -ContentType "text/plain; charset=utf-8" `
                        -ErrorAction Stop

                    if ($Result -eq $true) {
                        Write-Host "[SUCCESS] $($Entry.Key)" -ForegroundColor Green
                        $Success++
                    }
                    else {
                        Write-Host "[FAILED] $($Entry.Key)" -ForegroundColor Red
                        $Failed++
                    }
                }
                catch {
                    Write-Host "[FAILED] $($Entry.Key) - $_" -ForegroundColor Red
                    $Failed++
                }
            }

            # --------------------------------
            # Summary
            # --------------------------------

            Write-Host "`n================================" -ForegroundColor Cyan
            Write-Host "DX Configuration Summary"
            Write-Host "================================"
            Write-Host "Cluster : $($SelectedCluster.ClusterName)"
            Write-Host "DX ID   : $DXID"
            Write-Host "Success : $Success" -ForegroundColor Green
            Write-Host "Failed  : $Failed" -ForegroundColor Red
            Write-Host "================================`n"

        }
        else {
            Write-Host "`nSkipped $($SelectedCluster.ClusterName)." -ForegroundColor Yellow
        }

        # Repeat?
        $Again = Read-Host "`nConfigure another DX cluster? (Y/N)"

    } while ($Again -match '^(Y|YES)$')

    Write-Host "`nDX configuration session completed." -ForegroundColor Cyan
}

# Execute
Start-DXConfigurator



