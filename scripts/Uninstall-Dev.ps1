[CmdletBinding()]
param(
    [switch]$RemoveDevelopmentCertificate
)

$ErrorActionPreference = 'Stop'
$installedPackages = @(Get-AppxPackage -Name 'NumismaticsDex' -ErrorAction SilentlyContinue)

if ($installedPackages.Count -eq 0) {
    Write-Output 'NumismaticsDex is not installed for the current Windows user.'
}
else {
    foreach ($package in $installedPackages) {
        Get-Process -Name 'NumismaticsDex.App' -ErrorAction SilentlyContinue |
            Stop-Process -Force -ErrorAction SilentlyContinue
        Remove-AppxPackage -Package $package.PackageFullName -Confirm:$false -ErrorAction Stop
        Write-Output "Removed $($package.Name) $($package.Version)."
    }
}

if (Get-AppxPackage -Name 'NumismaticsDex' -ErrorAction SilentlyContinue) {
    throw 'NumismaticsDex is still registered after uninstall.'
}

if ($RemoveDevelopmentCertificate) {
    $certificates = @(Get-ChildItem 'Cert:\CurrentUser\My' | Where-Object Subject -eq 'CN=NumismaticsDex')
    foreach ($storeName in @('My', 'TrustedPeople', 'Root')) {
        $storePath = "Cert:\CurrentUser\$storeName"
        foreach ($certificate in Get-ChildItem $storePath | Where-Object Subject -eq 'CN=NumismaticsDex') {
            Remove-Item "$storePath\$($certificate.Thumbprint)" -Force
        }
    }

    $publicCertificate = Join-Path (Split-Path $PSScriptRoot -Parent) 'artifacts\NumismaticsDex_Dev.cer'
    if (Test-Path $publicCertificate) {
        Remove-Item $publicCertificate -Force
    }

    Write-Output 'Removed the NumismaticsDex development certificate from this Windows user.'
}