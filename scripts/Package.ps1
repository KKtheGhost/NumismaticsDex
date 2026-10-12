[CmdletBinding()]
param(
    [string]$CertificateThumbprint,
    [switch]$Unsigned,
    [switch]$IncludeLocalBanknoteAssets
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$projectPath = Join-Path $repositoryRoot 'NumismaticsDex.App\NumismaticsDex.App.csproj'

& (Join-Path $PSScriptRoot 'New-PackageAssets.ps1')

$arguments = @(
    'publish', $projectPath,
    '--configuration', 'Release',
    '--runtime', 'win-x64',
    '-p:GenerateAppxPackageOnBuild=true'
)

if ($Unsigned -and $CertificateThumbprint) {
    throw 'CertificateThumbprint cannot be combined with Unsigned.'
}

if ($Unsigned) {
    $arguments += '-p:AppxPackageSigningEnabled=false'
}
else {
    if ($CertificateThumbprint) {
        $certificate = Get-Item "Cert:\CurrentUser\My\$CertificateThumbprint" -ErrorAction SilentlyContinue
    }
    else {
        $certificate = Get-ChildItem 'Cert:\CurrentUser\My' |
            Where-Object { $_.Subject -eq 'CN=NumismaticsDex' -and $_.HasPrivateKey -and $_.NotAfter -gt (Get-Date) } |
            Sort-Object NotAfter -Descending |
            Select-Object -First 1
    }

    if (-not $certificate -or -not $certificate.HasPrivateKey) {
        throw 'No valid signing certificate was found. Run scripts\New-DevCertificate.ps1 first.'
    }

    $arguments += @(
        '-p:AppxPackageSigningEnabled=true',
        "-p:PackageCertificateThumbprint=$($certificate.Thumbprint)"
    )
}

if ($IncludeLocalBanknoteAssets) {
    $arguments += '-p:IncludeLocalBanknoteAssets=true'
}

Push-Location $repositoryRoot
try {
    & dotnet @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "MSIX packaging failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}