[CmdletBinding()]
param(
    [switch]$RefreshImages,
    [switch]$DryRun,
    [string]$CategoryUrl = 'http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PUP/CIN-PUP.htm',
    [string]$CollectionId = 'china-japanese-puppet-banks',
    [string]$CollectionTitle = 'CHINA - Japanese Puppet Banks',
    [string]$CollectionDescription = 'Paper money issued by banks under Japanese occupation in China.',
    [string]$Region = 'Asia',
    [string]$CountryCode = 'CHN',
    [string]$Country = 'China',
    [string]$PickNumberPattern = ''
)

$sourceRoot = $CategoryUrl.Substring(0, $CategoryUrl.LastIndexOf('/') + 1)
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$assetRoot = Join-Path $repositoryRoot 'NumismaticsDex.App\Assets'
$imageRoot = Join-Path $assetRoot 'Banknotes'
New-Item -Path $imageRoot -ItemType Directory -Force | Out-Null

function Get-SourcePageHtml([string]$url) {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30
    $stream = $response.RawContentStream
    if ($null -eq $stream) {
        return $response.Content
    }

    $stream.Position = 0
    $bytes = [byte[]]::new($stream.Length)
    [void]$stream.Read($bytes, 0, $bytes.Length)
    $contentType = [string]$response.Headers['Content-Type']
    $charsetMatch = [regex]::Match($contentType, '(?i)\bcharset\s*=\s*["'']?(?<charset>[^;"''\s]+)')
    if ($charsetMatch.Success) {
        return [System.Text.Encoding]::GetEncoding($charsetMatch.Groups['charset'].Value).GetString($bytes)
    }

    try {
        return [System.Text.UTF8Encoding]::new($false, $true).GetString($bytes)
    }
    catch [System.Text.DecoderFallbackException] {
        return [System.Text.Encoding]::GetEncoding(1252).GetString($bytes)
    }
}

function ConvertTo-PlainText([string]$html) {
    $text = [regex]::Replace($html, '(?is)<br\s*/?>', ' ')
    $text = [regex]::Replace($text, '(?s)<[^>]+>', ' ')
    $text = [System.Net.WebUtility]::HtmlDecode($text)
    return [regex]::Replace($text, '\s+', ' ').Trim()
}

function ConvertTo-PlainLines([string]$html) {
    $text = [regex]::Replace($html, '(?i)<br\s*/?>', "`n")
    $text = [regex]::Replace($text, '(?i)</(?:td|tr|p|div|li)>', "`n")
    $text = [regex]::Replace($text, '(?s)<[^>]+>', ' ')
    $text = [System.Net.WebUtility]::HtmlDecode($text)
    return @($text -split '[\r\n]+' | ForEach-Object { [regex]::Replace($_, '\s+', ' ').Trim() } | Where-Object { $_ })
}

function Get-DetailField([string]$html, [string]$label) {
    $pattern = '(?is)<td\b[^>]*>\s*<b>\s*<font\b[^>]*>\s*' +
        [regex]::Escape($label) +
        '\s*</font>\s*</b>\s*</td>\s*<td\b[^>]*>(?<value>.*?)</td>'
    $match = [regex]::Match($html, $pattern)
    if (-not $match.Success) {
        return ''
    }

    return ConvertTo-PlainText $match.Groups['value'].Value
}

function Get-VariantDescription([string[]]$lines, [string]$pickNumber, [string]$subnumber) {
    if (-not $subnumber) {
        return ''
    }

    if ($subnumber -match '^\((?<number>[0-9]+)\)$') {
        $variantPattern = '\(\s*' + $Matches['number'] + '\s*\)'
    }
    elseif ($subnumber -match '^(?<letters>[a-z]+)\((?<number>[0-9]+)\)$') {
        $variantPattern = [regex]::Escape($Matches['letters']) + '\s*\(\s*' + $Matches['number'] + '\s*\)'
    }
    elseif ($subnumber -match '^(?<letters>[a-z]+)?\((?<number>[0-9]+(?:-[0-9]+)+)\)$') {
        $letterPattern = if ($Matches['letters']) { [regex]::Escape($Matches['letters']) } else { '' }
        $numberPattern = ([regex]::Escape($Matches['number'])) -replace '\\-', '\s*-\s*'
        $variantPattern = $letterPattern + '\s*\(\s*' + $numberPattern + '\s*\)'
    }
    elseif ($subnumber -match '^\[[a-z]+\]$') {
        $variantPattern = [regex]::Escape($subnumber)
    }
    else {
        $variantPattern = [regex]::Escape($subnumber)
    }

    $targetPattern = '(?i)^\s*' + [regex]::Escape($pickNumber) + '\s*' + $variantPattern + '\s*(?<inlineDescription>.*)$'
        $headingPattern = '(?i)^(?:P-)?(?:[A-Z]+)?[0-9]+[A-Z]?(?:[a-z]+[0-9]+|[a-z]+(?:\s*\(\s*[0-9]+(?:\s*-\s*[0-9]+)*\s*\))?|\[[a-z]+[0-9]*\]|\s*\(\s*[0-9]+(?:\s*-\s*[0-9]+)*\))(?:\s+.*)?$'
    for ($index = 0; $index -lt $lines.Count; $index++) {
        $heading = [regex]::Match($lines[$index], $targetPattern)
        if (-not $heading.Success) {
            continue
        }

        $description = [System.Collections.Generic.List[string]]::new()
        if (-not [string]::IsNullOrWhiteSpace($heading.Groups['inlineDescription'].Value)) {
            $description.Add($heading.Groups['inlineDescription'].Value.Trim())
        }
        for ($next = $index + 1; $next -lt $lines.Count; $next++) {
            if ($lines[$next] -match $headingPattern -or $lines[$next] -match '(?i)^BACK TO\b') {
                break
            }
            $description.Add($lines[$next])
        }

        return ($description -join ' ').Trim()
    }

    return ''
}

function ConvertTo-ImageCode([string]$variant) {
    if ($variant -match '(?i)^([a-z]+)\(1\)$') {
        return ($Matches[1] + '-1').ToLowerInvariant()
    }
    if ($variant -match '(?i)^([a-z]+)\(2\)$') {
        return $Matches[1].ToLowerInvariant()
    }
    if ($variant -match '(?i)^(?<letters>[a-z]+)\((?<first>[0-9]+)-(?<second>[0-9]+)\)$') {
        return ($Matches['letters'] + '-' + $Matches['first'] + $Matches['second']).ToLowerInvariant()
    }
    if ($variant -match '(?i)^\[(?<letters>[a-z]+)\]$') {
        return $Matches['letters'].ToLowerInvariant()
    }
    if ($variant -match '^\((?<number>[0-9]+)\)$') {
        return '-' + $Matches['number']
    }
    return ($variant -replace '\([0-9]+\)', '').ToLowerInvariant()
}

function ConvertTo-ImageAlias([string]$alias) {
    return ($alias -replace '[^A-Za-z0-9]', '').ToLowerInvariant()
}

function Get-ImageCode([string]$imageName, [string]$pageBase) {
    $stem = [System.IO.Path]::GetFileNameWithoutExtension($imageName)
    if (-not $stem.StartsWith($pageBase, [StringComparison]::OrdinalIgnoreCase)) {
        return $null
    }

    $tail = $stem.Substring($pageBase.Length)
    if ($tail -match '^(?<code>.*?)(?<side>[or])$') {
        return $Matches['code'].ToLowerInvariant()
    }

    return $null
}

function Resolve-ImageCode([string]$variant, [string]$pickNumber, [int]$variantIndex, [hashtable]$imageGroups, [hashtable]$imageAliases) {
    $aliasCandidates = [System.Collections.Generic.List[string]]::new()
    if ($variant -match '(?i)^(?<letters>[a-z]+)\((?<first>[0-9]+)-(?<second>[0-9]+)\)$') {
        $letters = $Matches['letters']
        $first = $Matches['first']
        $second = $Matches['second']
        $aliasCandidates.Add("$pickNumber$letters$first$second")
        $aliasCandidates.Add("$pickNumber$letters$second")
        $aliasCandidates.Add("$pickNumber$letters-$first$second")
        $aliasCandidates.Add("$pickNumber$letters-$second")
    }
    elseif ($variant -match '(?i)^\[(?<letters>[a-z]+)\]$') {
        $aliasCandidates.Add("$pickNumber$($Matches['letters'])")
    }
    elseif ($variant -match '(?i)^(?<letter>[a-z]+)\((?<number>[0-9]+)\)$') {
        $letter = $Matches['letter']
        $number = $Matches['number']
        $aliasCandidates.Add("$pickNumber$letter$number")
        $aliasCandidates.Add("$pickNumber$letter-$number")
        $aliasCandidates.Add("$pickNumber$letter")
    }
    elseif ($variant -match '^\((?<number>[0-9]+)\)$') {
        $number = $Matches['number']
        $aliasCandidates.Add("$pickNumber-$number")
        $aliasCandidates.Add("$pickNumber$number")
    }
    else {
        $aliasCandidates.Add("$pickNumber$variant")
        if ($variant -match '^(?i)[a-z]+$') {
            $aliasCandidates.Add("$pickNumber$variant`1")
        }
    }
    $aliasCandidates.Add("$pickNumber-$($variantIndex + 1)")
    $aliasCandidates.Add("$pickNumber$($variantIndex + 1)")

    foreach ($alias in $aliasCandidates) {
        $key = ConvertTo-ImageAlias $alias
        if ($imageAliases.ContainsKey($key)) {
            return $imageAliases[$key]
        }
    }

    foreach ($alias in $aliasCandidates) {
        $aliasKey = ConvertTo-ImageAlias $alias
        foreach ($imageCode in $imageGroups.Keys) {
            if ((ConvertTo-ImageAlias "$pickNumber$imageCode") -eq $aliasKey) {
                return $imageCode
            }
        }
    }

    $imageCode = ConvertTo-ImageCode $variant
    if ($imageGroups.ContainsKey($imageCode)) {
        return $imageCode
    }
    if ($imageGroups.ContainsKey('')) {
        return ''
    }

    if ($variant -match '^\((?<number>[0-9]+)\)$') {
        $number = [int]$Matches['number']
        $candidates = if ($number -eq 1) { @('-1', '') } else { @("-$number", "$number", '') }
        foreach ($candidate in $candidates) {
            if ($imageGroups.ContainsKey($candidate)) {
                return $candidate
            }
        }
    }

    return $imageCode
}

$categoryHtml = Get-SourcePageHtml $CategoryUrl
$sourcePages = @($CategoryUrl)
$detailPagePattern = if ($CategoryUrl -match '(?i)/CIN-REP-CIN\.htm(?:\?.*)?$') {
    'CIN-REP-CIN-[0-9]+\.htm'
}
elseif ($CategoryUrl -match '(?i)/CIN-REP-FGN\.htm(?:\?.*)?$') {
    'CIN-REP-FGN-[0-9]+\.htm'
}

if ($detailPagePattern) {
    $sourceRoot = $CategoryUrl.Substring(0, $CategoryUrl.LastIndexOf('/') + 1)
    $pageMatches = [regex]::Matches($categoryHtml, '(?i)href\s*=\s*["''](?<page>' + $detailPagePattern + ')(?:#[^"'']*)?["'']')
    $pageNames = @($pageMatches | ForEach-Object { $_.Groups['page'].Value } | Sort-Object -Unique)
    if ($pageNames.Count -eq 0) {
        throw "No detail pages found in collection overview: $CategoryUrl"
    }
    $sourcePages = @($pageNames | ForEach-Object { $sourceRoot + $_ })
}

$sourcePageCells = [System.Collections.Generic.List[object]]::new()
foreach ($sourcePageUrl in $sourcePages) {
    $pageHtml = if ($sourcePageUrl -eq $CategoryUrl) { $categoryHtml } else { Get-SourcePageHtml $sourcePageUrl }
    $pageSourceRoot = $sourcePageUrl.Substring(0, $sourcePageUrl.LastIndexOf('/') + 1)
    $pageCells = [regex]::Matches($pageHtml, '(?is)<td[^>]*width="20%"[^>]*>(.*?)</td>')
    foreach ($pageCell in $pageCells) {
        $sourcePageCells.Add([pscustomobject]@{
            Html = $pageCell.Groups[1].Value
            SourceRoot = $pageSourceRoot
        })
    }
}

if ($sourcePageCells.Count -eq 0) {
    throw "No banknote entries found on source page(s): $($sourcePages -join ', ')"
}

$records = [System.Collections.Generic.List[object]]::new()
$imageFiles = @{}
$pageCache = @{}
$errors = [System.Collections.Generic.List[string]]::new()
$lastProgressDetailPageCount = 0

Write-Output "Parsing $($sourcePageCells.Count) banknote cards from $($sourcePages.Count) source page(s)."

foreach ($cellMatch in $sourcePageCells) {
    $cell = $cellMatch.Html
    $sourceRoot = $cellMatch.SourceRoot
    $pickMatch = [regex]::Match($cell, '(?is)P-?(?<pick>(?:(?:[A-Z]+)?[0-9]+[A-Z]?|S\s*-?\s*[0-9](?:\s*[0-9])*[A-Z]?|NL|A))(?:\s+NL(?<specimen>s)?)?\s*</a>')
    $unlinkedSeriesPick = $false
    if (-not $pickMatch.Success) {
        $plainCell = ConvertTo-PlainText $cell
        $plainPickMatch = [regex]::Match($plainCell, '(?i)\bPS\s*-\s*(?<pick>[0-9](?:\s*[0-9])*[A-Z]?)')
        if (-not $plainPickMatch.Success) {
            continue
        }

        $sourcePickNumber = 'S-' + ($plainPickMatch.Groups['pick'].Value -replace '\s+', '')
        $unlinkedSeriesPick = $true
        $variantTail = ''
    }
    else {
        $sourcePickNumber = $pickMatch.Groups['pick'].Value -replace '\s+', ''
        $variantTail = $cell.Substring($pickMatch.Index + $pickMatch.Length)
    }

    $pickNumber = $sourcePickNumber
    if ($sourcePickNumber -match '^S-(?<number>[0-9]+[A-Z]?)$') {
        $pickNumber = 'S' + $Matches['number']
    }
    if ($PickNumberPattern -and $pickNumber -notmatch $PickNumberPattern) {
        continue
    }

    $variantText = ConvertTo-PlainText $variantTail
    if ($unlinkedSeriesPick) {
        $variants = @('')
    }
    elseif ($sourcePickNumber -in @('NL', 'A')) {
        $variants = if ($pickMatch.Groups['specimen'].Success) { @('s') } else { @('') }
    }
    else {
            $variants = @([regex]::Matches($variantText, '(?i)(?:\b[a-z]+[0-9]+|\b[a-z]+\s*(?:\([0-9]+(?:-[0-9]+)*\))?|\[[a-z]+[0-9]*\]|\([0-9]+(?:-[0-9]+)*\))') | ForEach-Object { $_.Value -replace '\s+', '' } | Select-Object -Unique)
        if ($variants.Count -eq 0) {
            $variants = @('')
        }
    }

    $valueMatch = [regex]::Match($cell, '(?is)<font[^>]*size="4"[^>]*>(?<value>.*?)</font>')
    $categoryValue = if ($valueMatch.Success) { ConvertTo-PlainText $valueMatch.Groups['value'].Value } else { '' }
    $pageMatch = [regex]::Match($cell, '(?is)href="(?<page>[A-Z]{3}[A-Z0-9-]+\.htm)"[^>]*>\s*P-')
    if (-not $pageMatch.Success) {
        $pageMatch = [regex]::Match($cell, '(?is)href="(?<page>[A-Z]{3}[A-Z0-9-]+\.htm)"')
    }
    if (-not $pageMatch.Success) {
        $errors.Add("$pickNumber has no detail page link")
        continue
    }

    $pageFile = $pageMatch.Groups['page'].Value
    $detailUrl = $sourceRoot + $pageFile
    if (-not $pageCache.ContainsKey($detailUrl)) {
        if (($pageCache.Count % 10) -eq 0) {
            Write-Output "Requesting detail page $($pageCache.Count + 1): $detailUrl"
        }
        try {
            $pageCache[$detailUrl] = Get-SourcePageHtml $detailUrl
        }
        catch {
            $errors.Add("Could not load $detailUrl : $($_.Exception.Message)")
            continue
        }
    }

    if ($pageCache.Count -ge $lastProgressDetailPageCount + 50) {
        $lastProgressDetailPageCount = [Math]::Floor($pageCache.Count / 50) * 50
        Write-Output "Loaded $lastProgressDetailPageCount distinct detail pages; expanded $($records.Count) variants so far."
    }

    $detailHtml = $pageCache[$detailUrl]
    if ($sourcePickNumber -in @('NL', 'A')) {
        $pickNumber = 'NL-' + [System.IO.Path]::GetFileNameWithoutExtension($pageFile)
    }

    $recordSourceUrl = $detailUrl
    $isMislinkedFengtienEntry = $sourcePickNumber -eq 'NL' -and $pageFile -eq 'CINA0016A2.htm'
    $value = Get-DetailField $detailHtml 'Value'
    $issuer = Get-DetailField $detailHtml 'Issued by'
    $issueDate = Get-DetailField $detailHtml 'Date'
    $printer = Get-DetailField $detailHtml 'Printer'
    if ($sourcePickNumber -in @('NL', 'A') -and $categoryValue) { $value = $categoryValue }
    elseif (-not $value) { $value = $categoryValue }
    if ($isMislinkedFengtienEntry) {
        $issuer = 'General Bank of Communications, Fengtien Branch'
        $issueDate = '1909'
        $printer = ''
        $recordSourceUrl = $CategoryUrl
    }
    if (-not $issuer) { $issuer = 'Unknown issuer' }
    if (-not $issueDate) { $issueDate = 'Unknown' }
    if (-not $printer) { $printer = '' }
    if ($CollectionId -eq 'china-peoples-republic' -and
        ($pickNumber -match '^[0-9]' -or $pickNumber -match '^W') -and
        $issuer -match "(?i)(People.?s Bank of China|Zhongguo Renmin Yinhang)") {
        $printer = "People's Bank of China"
    }
    $years = [regex]::Matches($issueDate, '\b[0-9]{4}\b')
    $year = if ($years.Count -gt 0) { [int]$years[$years.Count - 1].Value } else { $null }

    $pageBase = [System.IO.Path]::GetFileNameWithoutExtension($pageFile)
    $imageGroups = @{}
    $imageAliases = @{}
    $imageNamePattern = '(?i)\b[A-Z]{3}[A-Z0-9-]+[A-Z0-9()-]*[OR]\.JPE?G\b'
    foreach ($imageMatch in [regex]::Matches($detailHtml, $imageNamePattern)) {
        $imageName = [System.IO.Path]::GetFileName($imageMatch.Value)
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($imageName)
        $code = Get-ImageCode $imageName $pageBase
        if ($null -eq $code -and $pageBase -match '^(?<prefix>.+-)[0-9]+$' -and $stem.StartsWith($Matches['prefix'], [StringComparison]::OrdinalIgnoreCase)) {
            $tail = $stem.Substring($Matches['prefix'].Length)
            if ($tail -match '^(?<number>[0-9]+)(?<side>[or])$') {
                $code = '-' + $Matches['number']
            }
        }
        if ($null -eq $code) {
            continue
        }

        $side = $stem.Substring($stem.Length - 1).ToLowerInvariant()
        if (-not $imageGroups.ContainsKey($code)) {
            $imageGroups[$code] = @{}
        }
        $imageGroups[$code][$side] = $imageName
        $imageFiles[$imageName] = $true
    }

    $imageAliasPattern = '(?is)<a\b[^>]*name\s*=\s*["''](?<anchor>[^"'']+)["''][^>]*>\s*<img\b[^>]*src\s*=\s*["''](?<image>[A-Z]{3}[A-Z0-9()\-]+[OR]\.JPE?G)["'']'
    foreach ($aliasMatch in [regex]::Matches($detailHtml, $imageAliasPattern)) {
        $imageCode = Get-ImageCode $aliasMatch.Groups['image'].Value $pageBase
        if ($null -ne $imageCode) {
            $imageAliases[(ConvertTo-ImageAlias $aliasMatch.Groups['anchor'].Value)] = $imageCode
        }
    }

    $detailLines = ConvertTo-PlainLines $detailHtml
    $normalizedDetailLines = @($detailLines | ForEach-Object { $_ -replace '\s+', '' })
    $expandedVariants = [System.Collections.Generic.List[string]]::new()
    foreach ($variant in $variants) {
        if ($variant -match '^(?<letters>[a-z]{2,})$') {
            $letters = $Matches['letters']
            $combinedHeading = ($pickNumber + $letters).ToLowerInvariant()
            if ($normalizedDetailLines -notcontains $combinedHeading) {
                $splitVariants = [System.Collections.Generic.List[string]]::new()
                foreach ($letter in $letters.ToCharArray()) {
                    $candidate = [string]$letter
                    if ($normalizedDetailLines -contains (($pickNumber + $candidate).ToLowerInvariant())) {
                        $splitVariants.Add($candidate)
                    }
                }

                if ($splitVariants.Count -gt 0) {
                    $expandedVariants.AddRange($splitVariants)
                    continue
                }
            }
        }

        $expandedVariants.Add($variant)
    }
    $variants = @($expandedVariants.ToArray())
    $variants = @($expandedVariants.ToArray() | Select-Object -Unique)

    for ($variantIndex = 0; $variantIndex -lt $variants.Count; $variantIndex++) {
        $variant = $variants[$variantIndex]
        $imageCode = Resolve-ImageCode $variant $pickNumber $variantIndex $imageGroups $imageAliases
        if (-not $variant) {
            if ($imageGroups.ContainsKey('a')) {
                $imageCode = 'a'
            }
            elseif ($imageGroups.Count -eq 1) {
                $imageCode = @($imageGroups.Keys)[0]
            }
        }
        elseif ($variantIndex -eq 0 -and $variant -eq 'a' -and $imageGroups.ContainsKey('') -and -not $imageGroups.ContainsKey('a')) {
            $imageCode = ''
        }

        $frontName = $null
        $backName = $null
        if ($imageGroups.ContainsKey($imageCode)) {
            $group = $imageGroups[$imageCode]
            if ($group.ContainsKey('o')) { $frontName = $group['o'] }
            if ($group.ContainsKey('r')) { $backName = $group['r'] }
        }
        if ($isMislinkedFengtienEntry) {
            $frontName = $null
            $backName = $null
        }

        $frontUrl = if ($frontName) { $sourceRoot + $frontName } else { $null }
        $backUrl = if ($backName) { $sourceRoot + $backName } else { $null }
        $description = Get-VariantDescription $detailLines $pickNumber $variant
        if ($sourcePickNumber -eq 'A' -and $variant -eq 's') {
            $description = Get-DetailField $detailHtml 'Remark'
            if (-not $description) { $description = 'Specimen' }
        }
        $records.Add([ordered]@{
            countryCode = $CountryCode
            region = $Region
            collectionId = $CollectionId
            pickNumber = $pickNumber
            pickSubnumber = if ($variant) { $variant } else { $null }
            title = $issuer
            country = $Country
            year = $year
            sourceUrl = $recordSourceUrl
            frontImageUrl = $frontUrl
            backImageUrl = $backUrl
            issuer = $issuer
            denomination = $value
            issueDate = $issueDate
            printer = $printer
            variantDescription = $description
        })
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Warning $_ }
    throw "Import stopped because $($errors.Count) catalog page(s) could not be read or linked."
}

$importedPickCount = @($records | ForEach-Object { $_['pickNumber'] } | Sort-Object -Unique).Count
if ($records.Count -lt $importedPickCount) {
    throw "Import produced fewer variants than Pick entries ($($records.Count) records for $importedPickCount Pick entries)."
}

$catalogPath = Join-Path $assetRoot 'catalog.json'
$previousCatalog = $null
$previousBanknotes = @()
if (Test-Path $catalogPath) {
    $previousCatalog = Get-Content $catalogPath -Raw | ConvertFrom-Json
    if ($previousCatalog.banknotes) {
        $previousBanknotes = @($previousCatalog.banknotes)
    }
}

$preservedBanknotes = @($previousBanknotes | Where-Object { $_.collectionId -ne $CollectionId })
$combinedRecords = @($preservedBanknotes) + @($records)
$identityGroups = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[object]]]::new([System.StringComparer]::Ordinal)
foreach ($record in $combinedRecords) {
    $identity = '{0}:{1}:{2}' -f $record.countryCode, $record.pickNumber, $record.pickSubnumber
    if (-not $identityGroups.ContainsKey($identity)) {
        $identityGroups[$identity] = [System.Collections.Generic.List[object]]::new()
    }
    $identityGroups[$identity].Add($record)
}
$identityCollisions = @($identityGroups.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 })
if ($identityCollisions.Count -gt 0) {
    $collisionDetails = @($identityCollisions | ForEach-Object {
        $recordsForIdentity = @($_.Value | ForEach-Object {
            "$($_.collectionId) / $($_.issuer) / sub='$($_.pickSubnumber)' / value='$($_.denomination)' / date='$($_.issueDate)' / source='$($_.sourceUrl)' / front='$($_.frontImageUrl)' / variant='$($_.variantDescription)'"
        })
        "  $($_.Key): $($recordsForIdentity -join ' <> ')"
    })
    throw "Import would create $($identityCollisions.Count) duplicate country/Pick/subnumber identity(ies):`n$($collisionDetails -join [Environment]::NewLine)"
}

if ($DryRun) {
    $withImages = @($records | Where-Object { $_.frontImageUrl -or $_.backImageUrl }).Count
    $withBothImages = @($records | Where-Object { $_.frontImageUrl -and $_.backImageUrl }).Count
    Write-Output "Dry run: $($sourcePages.Count) source pages parsed into '$CollectionTitle'."
    Write-Output "Would import $($records.Count) variants from $importedPickCount Pick entries."
    Write-Output "Potential source images: $($imageFiles.Count); records with at least one side: $withImages; both sides: $withBothImages."
    Write-Output 'Identity collisions: 0. Catalog and image files were not changed.'
    return
}

$collectionRecords = [System.Collections.Generic.List[object]]::new()
if ($previousCatalog.collections) {
    foreach ($collection in $previousCatalog.collections) {
        if ($collection.id -ne $CollectionId) {
            $collectionRecords.Add($collection)
        }
    }
}
else {
    $previousCollectionIds = @($previousBanknotes | ForEach-Object { $_.collectionId } | Where-Object { $_ } | Sort-Object -Unique)
    foreach ($previousId in $previousCollectionIds) {
        if ($previousId -eq 'china-japanese-puppet-banks') {
            $collectionRecords.Add([ordered]@{
                id = $previousId
                title = 'CHINA - Japanese Puppet Banks'
                description = 'Paper money issued by banks under Japanese occupation in China.'
                sourceUrl = if ($previousCatalog.sourceUrl) { $previousCatalog.sourceUrl } else { 'http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PUP/CIN-PUP.htm' }
                region = 'Asia'
                country = 'China'
            })
        }
    }
}

$collectionRecords.Add([ordered]@{
    id = $CollectionId
    title = $CollectionTitle
    description = $CollectionDescription
    sourceUrl = $CategoryUrl
    region = $Region
    country = $Country
})

$sourceUrl = if ($previousCatalog.sourceUrl) { $previousCatalog.sourceUrl } else { $CategoryUrl }
$pickEntryCount = @($combinedRecords | ForEach-Object { "$($_.collectionId):$($_.pickNumber)" } | Sort-Object -Unique).Count
$catalog = [ordered]@{
    schemaVersion = 1
    sourceUrl = $sourceUrl
    importedAt = [DateTimeOffset]::UtcNow.ToString('O')
    pickEntryCount = $pickEntryCount
    collections = @($collectionRecords.ToArray())
    researchNotes = @($previousCatalog.researchNotes)
    banknotes = $combinedRecords
}
$json = ConvertTo-Json -InputObject $catalog -Depth 8
[System.IO.File]::WriteAllText($catalogPath, $json, [System.Text.UTF8Encoding]::new($false))

$imageList = @($imageFiles.Keys | Sort-Object)
$batchSize = 16
for ($start = 0; $start -lt $imageList.Count; $start += $batchSize) {
    $curlArguments = [System.Collections.Generic.List[string]]::new()
    foreach ($argument in @('--parallel', '--parallel-immediate', '--parallel-max', '8', '--fail', '--silent', '--show-error', '--connect-timeout', '10', '--max-time', '60')) {
        $curlArguments.Add($argument)
    }

    $pending = [System.Collections.Generic.List[object]]::new()
    $end = [Math]::Min($start + $batchSize, $imageList.Count)
    for ($index = $start; $index -lt $end; $index++) {
        $imageName = $imageList[$index]
        $path = Join-Path $imageRoot $imageName
        if (-not $RefreshImages -and (Test-Path $path)) {
            continue
        }

        $curlArguments.Add('--url')
        $curlArguments.Add($sourceRoot + $imageName)
        $curlArguments.Add('--output')
        $curlArguments.Add($path)
        $pending.Add([pscustomobject]@{ Name = $imageName; Path = $path })
    }

    if ($pending.Count -gt 0) {
        & curl.exe @($curlArguments.ToArray())
        if ($LASTEXITCODE -ne 0) {
            foreach ($item in $pending) {
                if (-not (Test-Path $item.Path) -or (Get-Item $item.Path).Length -eq 0) {
                    Remove-Item $item.Path -Force -ErrorAction SilentlyContinue
                    Write-Warning "Image download failed: $($item.Name)"
                }
            }
        }
    }

    Write-Output "Downloaded/checked $end of $($imageList.Count) source images..."
}

$withImages = @($records | Where-Object { $_.frontImageUrl -or $_.backImageUrl }).Count
$withBothImages = @($records | Where-Object { $_.frontImageUrl -and $_.backImageUrl }).Count
$localImages = @(Get-ChildItem $imageRoot -Filter '*.jpg' -File -ErrorAction SilentlyContinue).Count
Write-Output "Imported $($records.Count) variants from $importedPickCount Pick entries into '$CollectionTitle'."
Write-Output "Combined catalog: $($combinedRecords.Count) variants from $pickEntryCount Pick entries across $($collectionRecords.Count) collections."
Write-Output "New records with source images: $withImages; with both sides: $withBothImages."
Write-Output "Records with source images: $withImages; local original JPG files: $localImages."
Write-Output "Catalog: $(Join-Path $assetRoot 'catalog.json')"