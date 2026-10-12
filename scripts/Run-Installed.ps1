$ErrorActionPreference = 'Stop'
$package = Get-AppxPackage -Name 'NumismaticsDex' -ErrorAction SilentlyContinue

if (-not $package) {
    throw 'NumismaticsDex is not installed. Run scripts\Install-Dev.ps1 first.'
}

Start-Process -FilePath 'explorer.exe' -ArgumentList "shell:AppsFolder\$($package.PackageFamilyName)!App"