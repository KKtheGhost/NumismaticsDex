#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [switch]$Remove
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$certificatePath = Join-Path $repositoryRoot 'artifacts\NumismaticsDex_Dev.cer'

if (-not (Test-Path $certificatePath -PathType Leaf)) {
    throw 'Public development certificate not found. Run scripts\New-DevCertificate.ps1 first.'
}

$certificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]::new($certificatePath)
foreach ($storeName in @('Root', 'TrustedPeople')) {
    $storePath = "Cert:\LocalMachine\$storeName"
    if ($Remove) {
        Get-ChildItem $storePath |
            Where-Object Thumbprint -eq $certificate.Thumbprint |
            Remove-Item -Force
    }
    else {
        Import-Certificate -FilePath $certificatePath -CertStoreLocation $storePath -ErrorAction Stop | Out-Null
    }
}

if ($Remove) {
    Write-Output 'Removed the NumismaticsDex development certificate from machine trust stores.'
}
else {
    Write-Output 'Trusted the NumismaticsDex development certificate for MSIX deployment on this device.'
}