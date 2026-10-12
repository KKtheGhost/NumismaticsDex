$ErrorActionPreference = 'Stop'

$subject = 'CN=NumismaticsDex'
$certificate = Get-ChildItem 'Cert:\CurrentUser\My' |
    Where-Object { $_.Subject -eq $subject -and $_.HasPrivateKey -and $_.NotAfter -gt (Get-Date) } |
    Sort-Object NotAfter -Descending |
    Select-Object -First 1

if (-not $certificate) {
    $certificate = New-SelfSignedCertificate `
        -Type CodeSigningCert `
        -Subject $subject `
        -CertStoreLocation 'Cert:\CurrentUser\My' `
        -HashAlgorithm SHA256 `
        -NotAfter (Get-Date).AddYears(2)
}

$repositoryRoot = Split-Path $PSScriptRoot -Parent
$artifactDirectory = Join-Path $repositoryRoot 'artifacts'
New-Item -Path $artifactDirectory -ItemType Directory -Force | Out-Null
Export-Certificate -Cert $certificate -FilePath (Join-Path $artifactDirectory 'NumismaticsDex_Dev.cer') -Force | Out-Null

foreach ($storeName in @('TrustedPeople', 'Root')) {
    Import-Certificate `
        -FilePath (Join-Path $artifactDirectory 'NumismaticsDex_Dev.cer') `
        -CertStoreLocation "Cert:\CurrentUser\$storeName" `
        -ErrorAction Stop | Out-Null
}

Write-Output "Development certificate is ready for this Windows user: $($certificate.Thumbprint)"