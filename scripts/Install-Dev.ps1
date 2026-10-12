param(
    [string]$PackagePath
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent

if (-not $PackagePath) {
    $package = Get-ChildItem (Join-Path $repositoryRoot 'NumismaticsDex.App\AppPackages') `
        -Filter 'NumismaticsDex.App_*.msix' -Recurse -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}
else {
    $resolvedPath = if ([System.IO.Path]::IsPathRooted($PackagePath)) {
        $PackagePath
    }
    else {
        Join-Path $repositoryRoot $PackagePath
    }
    $package = Get-Item $resolvedPath -ErrorAction SilentlyContinue
}

if (-not $package) {
    throw 'No app MSIX was found. Run scripts\Package.ps1 first.'
}

$signature = Get-AuthenticodeSignature -FilePath $package.FullName
if ($signature.Status -ne 'Valid') {
    throw "The app package is not signed by a trusted certificate (status: $($signature.Status)). Run scripts\New-DevCertificate.ps1, then scripts\Package.ps1."
}

$thumbprint = $signature.SignerCertificate.Thumbprint
$machineRoot = Get-ChildItem 'Cert:\LocalMachine\Root' -ErrorAction SilentlyContinue |
    Where-Object Thumbprint -eq $thumbprint |
    Select-Object -First 1
if (-not $machineRoot) {
    throw 'Windows AppX deployment requires this self-signed root to be trusted on the device. Run scripts\Trust-DevCertificate-Machine.ps1 once from an elevated PowerShell window.'
}

$dependencyDirectory = Join-Path (Split-Path $package.FullName -Parent) 'Dependencies\x64'
$dependencies = @(Get-ChildItem $dependencyDirectory -Filter '*.msix' -ErrorAction SilentlyContinue)
$installArguments = @{
    Path = $package.FullName
    ForceUpdateFromAnyVersion = $true
    ForceApplicationShutdown = $true
    ErrorAction = 'Stop'
}

if ($dependencies.Count -gt 0) {
    $installArguments.DependencyPath = [string[]]$dependencies.FullName
}

foreach ($installedPackage in @(Get-AppxPackage -Name 'NumismaticsDex' -ErrorAction SilentlyContinue)) {
    Get-Process -Name 'NumismaticsDex.App' -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue
    Remove-AppxPackage `
        -Package $installedPackage.PackageFullName `
        -Confirm:$false `
        -ErrorAction Stop
}

Add-AppxPackage @installArguments
$installedPackage = Get-AppxPackage -Name 'NumismaticsDex' -ErrorAction SilentlyContinue
if (-not $installedPackage) {
    throw 'Package deployment completed, but NumismaticsDex was not registered for the current user.'
}

Write-Output "Installed $($installedPackage.Name) $($installedPackage.Version) for the current Windows user."