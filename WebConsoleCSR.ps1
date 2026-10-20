<#
This is a simple script attempt to achieve creation of CSR file
Aravind Chaliyadath
apcmakkadath@gmail.com
#>

Clear-Host
function getossl{

Get-CimInstance Win32_Service -Filter "Name='LogRhythmAPIGateway'" |    ForEach-Object {
        if ($_.PathName -match '^"?(.+?)\\dependencies\\') { $apigp = $Matches[1]; Write-Host "Retrieved API gateway service path: $apigp" -f Green }
    }
$ossl = "$apigp" + "\dependencies\openssl\openssl.exe"
if(Test-Path -Path $ossl -PathType Leaf){
    Write-Host "Retrieved openssl executable path: $ossl" -f Green
    createsslcfg
    }else{
    Write-Host "Couldn't find Openssl executable" -f Red
    Write-Host "Try executing the script from Platform Manager" -f Yellow
    }

}

function createsslcfg{

$Global:certpath = Read-Host "Full directory path to create certs "
if(Test-Path -Path $certpath -PathType Container){
    Write-Host "Directory $certpath verified" -f Green
    }else{
    Write-Host "Directory not verified`nTry again!" -f Red
    exit
    }

$dns1 = Read-Host "DNS 1"
$dns2 = Read-Host "DNS 2"
$dns3 = Read-Host "DNS 3"
$ip1 = Read-Host "IP 1"
$ip2 = Read-Host "IP 2"
$ip3 = Read-Host "IP 3"
Write-Host "[2 Letters Maximum for Country]" -f Yellow
$c = read-host "Country [2 Letters Maximum]" 
$st = read-host "State"
$l = read-host "Location"
$o = read-host "Organization"
$cn = read-host "Common Name"


$sslcfg = @"
[req]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = v3_req

[dn]
C  = $c
ST = $st
L  = $l
O  = $o
CN = $cn

[v3_req]
basicConstraints = CA:FALSE
keyUsage         = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName   = @alt_names

[alt_names]
DNS.1    = $dns1
DNS.2    = $dns2
DNS.3    = $dns3
IP.1    = $ip1
IP.2    = $ip2
IP.3    = $ip3
"@

Write-Output $sslcfg | Out-File "$certpath\openssl.cfg" -Force utf8
$sslcfgp = "$certpath" + "\openssl.cfg" 
if($sslcfgp.Length -gt 0){
    Write-Host "Openssl.cfg file created" -f Green
    createcsr
    }else{
    Write-Host "Openssl.cfg creation failed" -f Red
    exit
    }

}

function createcsr{

$out = & $ossl req -new -newkey rsa:2048 -nodes -sha256 -out "$certpath\CSR.csr" -keyout "$certpath\privateKey.key" -config "$certpath\openssl.cfg" 2>&1

$pem = & $ossl rsa -in $certpath\privateKey.key -out $certpath\LogRhythmSSL.pem 2>&1

}

#Main
getossl
