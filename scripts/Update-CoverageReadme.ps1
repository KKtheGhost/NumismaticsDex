[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$CoverageFile,
    [string]$Commit = 'local'
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$coveragePath = if ([System.IO.Path]::IsPathRooted($CoverageFile)) {
    $CoverageFile
}
else {
    Join-Path $repositoryRoot $CoverageFile
}

if (-not (Test-Path $coveragePath)) {
    throw "Coverage report not found: $coveragePath"
}

[xml]$coverage = [System.IO.File]::ReadAllText($coveragePath)
$coveredLines = [int]$coverage.coverage.GetAttribute('lines-covered')
$validLines = [int]$coverage.coverage.GetAttribute('lines-valid')
if ($validLines -eq 0) {
    throw 'Coverage report contains no source lines.'
}

$lineRate = [double]::Parse(
    $coverage.coverage.GetAttribute('line-rate'),
    [System.Globalization.CultureInfo]::InvariantCulture)
$percentage = ($lineRate * 100).ToString('0.00', [System.Globalization.CultureInfo]::InvariantCulture)
$shortCommit = $Commit.Substring(0, [Math]::Min(7, $Commit.Length))
$badgeColor = if ($lineRate -ge 0.9) {
    'brightgreen'
}
elseif ($lineRate -ge 0.75) {
    'yellow'
}
else {
    'red'
}
$badgeUrl = "https://img.shields.io/badge/Core%20%2F%20non--UI%20logic%20coverage-$($percentage)%25-$badgeColor"
$coverageText = "[![Core/non-UI logic coverage: $percentage%]($badgeUrl)](https://github.com/KKtheGhost/NumismaticsDex/actions/workflows/ci.yml)"
$coverageSummary = "Core/non-UI logic line coverage: $percentage% ($coveredLines/$validLines lines), updated from commit $shortCommit."

$readmePath = Join-Path $repositoryRoot 'README.md'
$readme = [System.IO.File]::ReadAllText($readmePath)
$startMarker = '<!-- coverage:start -->'
$endMarker = '<!-- coverage:end -->'
$contentStart = $readme.IndexOf($startMarker, [System.StringComparison]::Ordinal)
$contentEnd = $readme.IndexOf($endMarker, [System.StringComparison]::Ordinal)
if ($contentStart -lt 0 -or $contentEnd -lt $contentStart) {
    throw 'README coverage markers are missing or out of order.'
}

$contentStart += $startMarker.Length
$replacement = "`n`n$coverageText`n"
$updatedReadme = $readme.Substring(0, $contentStart) + $replacement + $readme.Substring($contentEnd)
[System.IO.File]::WriteAllText($readmePath, $updatedReadme, [System.Text.UTF8Encoding]::new($false))

Write-Output $coverageText
if ($env:GITHUB_STEP_SUMMARY) {
    Add-Content -Path $env:GITHUB_STEP_SUMMARY -Value $coverageSummary
}