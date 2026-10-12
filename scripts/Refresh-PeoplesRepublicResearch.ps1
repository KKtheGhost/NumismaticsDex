[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$catalogPath = Join-Path $repositoryRoot 'NumismaticsDex.App\Assets\catalog.json'
$collectionId = 'china-peoples-republic'
$catalog = Get-Content $catalogPath -Raw | ConvertFrom-Json
$banknotes = @($catalog.banknotes | Where-Object collectionId -eq $collectionId)
$research = [System.Collections.Generic.List[object]]::new()

$series = @{
    1 = @{
        zh = '第一套人民币由中国人民银行自1948年12月1日起发行，旨在统一各解放区使用的货币。全套有12种面额、62种版别；战时分区设计、制版和就近印制，使票面涵盖劳动生产、交通运输与名胜古迹等题材。'
        tw = '第一套人民幣由中國人民銀行自1948年12月1日起發行，旨在統一各解放區使用的貨幣。全套有12種面額、62種版別；戰時分區設計、製版和就近印製，使票面涵蓋勞動生產、交通運輸與名勝古蹟等題材。'
        en = 'The first series was issued by the Peoples Bank of China from 1 December 1948 to unify currencies used in the liberated areas. It comprised 12 denominations and 62 designs, with varied labor, transport, industrial, and landmark themes reflecting decentralized wartime production.'
        ja = '第一套人民元は、解放区で使用されていた通貨を統一するため、1948年12月1日に中国人民銀行が発行を開始しました。額面は12種類、図案は62種類で、戦時下の分散した生産体制を反映し、労働、交通、工業、名勝など多様な題材が描かれました。'
        tags = @('rmb','series-1','currency-unification','labor-transport')
        source = 'https://zh.wikipedia.org/wiki/第一套人民币'
        sourceName = 'Wikipedia: First series of the renminbi'
    }
    2 = @{
        zh = '第二套人民币自1955年3月1日起发行，票面标注1953年版。新旧币按1元新币折合10,000元旧币换算；全套纸币面额从1分到10元，3元券仅见于本套，背面印有蒙、藏、维吾尔文。'
        tw = '第二套人民幣自1955年3月1日起發行，票面標註1953年版。新舊幣按1元新幣折合10,000元舊幣換算；全套紙幣面額從1分到10元，3元券僅見於本套，背面印有蒙、藏、維吾爾文。'
        en = 'The second series entered circulation on 1 March 1955, though its notes were dated 1953. The reform exchanged 10,000 old yuan for one new yuan. Paper denominations ran from 1 fen to 10 yuan; the series uniquely included a 3-yuan note and printed Mongolian, Tibetan, and Uyghur text on the reverse.'
        ja = '第二套人民元は1955年3月1日に流通を開始し、紙幣の年号は1953年でした。通貨改革では旧1万元を新1元に交換しました。紙幣の額面は1分から10元までで、このシリーズだけの3元券も発行され、裏面にはモンゴル語、チベット語、ウイグル語が併記されました。'
        tags = @('rmb','series-2','currency-reform','multilingual-reverse')
        source = 'https://zh.wikipedia.org/wiki/第二套人民币'
        sourceName = 'Wikipedia: Second series of the renminbi'
    }
    3 = @{
        zh = '第三套人民币自1962年起分批发行，第二、三套曾并行流通约20年，第三套于2000年7月1日停止流通。面额包括1、2、5角及1、2、5、10元，图案集中表现农业生产与工业建设。'
        tw = '第三套人民幣自1962年起分批發行，第二、三套曾並行流通約20年，第三套於2000年7月1日停止流通。面額包括1、2、5角及1、2、5、10元，圖案集中表現農業生產與工業建設。'
        en = 'The third series was introduced from 1962. It circulated alongside the second series for about two decades and was withdrawn on 1 July 2000. Its denominations ranged from 1 jiao to 10 yuan, and its designs emphasized agriculture and industry.'
        ja = '第三套人民元は1962年から順次発行されました。第二套と約20年間併用された後、2000年7月1日に流通を停止しました。額面は1角から10元までで、図案では農業と工業が大きく取り上げられました。'
        tags = @('rmb','series-3','agriculture-industry')
        source = 'https://zh.wikipedia.org/wiki/第三套人民币'
        sourceName = 'Wikipedia: Third series of the renminbi'
    }
    4 = @{
        zh = '第四套人民币于1987至1997年分批发行，票面年号为1980、1990或1996，共有9种纸币面额。多种面额采用少数民族人物像；50元表现工人、农民和知识分子，100元为毛泽东、周恩来、刘少奇、朱德四人像。'
        tw = '第四套人民幣於1987至1997年分批發行，票面年號為1980、1990或1996，共有9種紙幣面額。多種面額採用少數民族人物像；50元表現工人、農民和知識分子，100元為毛澤東、周恩來、劉少奇、朱德四人像。'
        en = 'The fourth series was introduced in stages from 1987 to 1997 and used note dates of 1980, 1990, or 1996 across nine denominations. Many notes depict people from ethnic groups; the 50-yuan note shows a worker, farmer, and intellectual, while the 100-yuan note portrays Mao Zedong, Zhou Enlai, Liu Shaoqi, and Zhu De.'
        ja = '第四套人民元は1987年から1997年にかけて段階的に発行され、9種類の額面に1980年、1990年、1996年の年号が用いられました。少数民族の人物を描いた券が多く、50元券には労働者、農民、知識人、100元券には毛沢東、周恩来、劉少奇、朱徳が描かれています。'
        tags = @('rmb','series-4','ethnic-unity','ethnic-portraits')
        source = 'https://zh.wikipedia.org/wiki/第四套人民币'
        sourceName = 'Wikipedia: Fourth series of the renminbi'
    }
    5 = @{
        zh = '第五套人民币自1999年起分批发行，纸币面额为1、5、10、20、50和100元，其中20元为新增面额。纸币正面统一采用毛泽东像，背面为代表性风景；1999、2005、2015、2019及2020年版逐步调整印制与防伪特征。'
        tw = '第五套人民幣自1999年起分批發行，紙幣面額為1、5、10、20、50和100元，其中20元為新增面額。紙幣正面統一採用毛澤東像，背面為代表性風景；1999、2005、2015、2019及2020年版逐步調整印製與防偽特徵。'
        en = 'The fifth series began phased issuance in 1999, with 1, 5, 10, 20, 50, and 100 yuan banknotes; 20 yuan was a new denomination. Notes use a Mao Zedong portrait on the obverse and landmark scenes on the reverse. Editions dated 1999, 2005, 2015, 2019, and 2020 introduced successive printing and security changes.'
        ja = '第五套人民元は1999年から順次発行され、紙幣の額面は1、5、10、20、50、100元です。20元はこのシリーズで新設された額面でした。表面には毛沢東、裏面には名所の風景が描かれています。1999、2005、2015、2019、2020年版では印刷方式や偽造防止技術が段階的に改良されました。'
        tags = @('rmb','series-5','mao-portrait','security-features')
        source = 'https://zh.wikipedia.org/wiki/第五套人民币'
        sourceName = 'Wikipedia: Fifth series of the renminbi'
    }
}

$commemoratives = @{
    '891' = @{
        zh = '1999年发行的50元人民币纪念钞，纪念中华人民共和国成立50周年。维基百科记载，正面为毛泽东像，背面为动物图案。'
        tw = '1999年發行的50元人民幣紀念鈔，紀念中華人民共和國成立50週年。維基百科記載，正面為毛澤東像，背面為動物圖案。'
        en = 'A 50-yuan commemorative banknote issued in 1999 for the 50th anniversary of the founding of the Peoples Republic of China. Wikipedia describes Mao Zedong on the front and animals on the reverse.'
        ja = '中華人民共和国成立50周年を記念して1999年に発行された50元記念紙幣です。表面には毛沢東、裏面には動物が描かれています。'
        tags = @('rmb','commemorative','anniversary')
    }
    '902' = @{
        zh = '2000年发行的100元橙色聚合物人民币纪念钞，迎接新千年。维基百科记载，正面为龙，背面为中华世纪坛。'
        tw = '2000年發行的100元橙色聚合物人民幣紀念鈔，迎接新千年。維基百科記載，正面為龍，背面為中華世紀壇。'
        en = 'An orange polymer 100-yuan commemorative banknote issued in 2000 for the new millennium, featuring a dragon and the China Millennium Monument.'
        ja = '新千年を記念して2000年に発行された、オレンジ色のポリマー製100元記念紙幣です。龍と中華世紀壇が描かれています。'
        tags = @('rmb','commemorative','millennium','polymer')
    }
    '908' = @{
        zh = '2008年发行的10元北京奥运会纪念钞。维基百科记载，正面为国家体育场“鸟巢”，背面为古典奥运掷铁饼运动员及其他运动员。'
        tw = '2008年發行的10元北京奧運會紀念鈔。維基百科記載，正面為國家體育場「鳥巢」，背面為古典奧運擲鐵餅運動員及其他運動員。'
        en = 'A 10-yuan commemorative banknote issued for the 2008 Beijing Olympics, featuring the National Stadium and Olympic athletes.'
        ja = '2008年北京オリンピックを記念して発行された10元記念紙幣です。国家体育場とオリンピック競技者が描かれています。'
        tags = @('rmb','commemorative','olympics')
    }
    '910' = @{
        zh = '2015年发行的100元航天主题人民币纪念钞。维基百科记载，中国人民银行于2015年11月26日发行此钞，以纪念中国航天科技。'
        tw = '2015年發行的100元航天主題人民幣紀念鈔。維基百科記載，中國人民銀行於2015年11月26日發行此鈔，以紀念中國航天科技。'
        en = 'A blue 100-yuan aerospace commemorative banknote issued by the Peoples Bank of China on 26 November 2015.'
        ja = '中国人民銀行が2015年11月26日に発行した、青色の100元宇宙開発記念紙幣です。'
        tags = @('rmb','commemorative','aerospace')
    }
}

$recent = @{
    W911 = @{
        zh = '2018年发行的50元人民币发行70周年纪念钞。维基百科记载，中国人民银行于2018年12月28日发行1.2亿张。'
        tw = '2018年發行的50元人民幣發行70週年紀念鈔。維基百科記載，中國人民銀行於2018年12月28日發行1.2億張。'
        en = 'A 50-yuan commemorative banknote for the 70th anniversary of renminbi issuance. Wikipedia states that the Peoples Bank of China issued 120 million notes on 28 December 2018.'
        ja = '人民元発行70周年を記念する50元紙幣です。中国人民銀行は2018年12月28日に1億2,000万枚を発行しました。'
        tags = @('rmb','commemorative','anniversary')
        source = 'https://en.wikipedia.org/wiki/Renminbi'
        sourceName = 'Wikipedia: Renminbi'
    }
    W912 = @{
        zh = '第五套人民币2019年版1元纸币。该版于2019年8月30日起发行，调整部分图案并提升防伪性能。'
        tw = '第五套人民幣2019年版1元紙幣。該版於2019年8月30日起發行，調整部分圖案並提升防偽性能。'
        en = 'A 2019-edition 1-yuan note in the fifth series, issued from 30 August 2019 with design and anti-counterfeiting updates.'
        ja = '第五套人民元の2019年版1元紙幣です。2019年8月30日から発行され、図案と偽造防止技術が改良されました。'
        tags = @('rmb','series-5','modified-issue','security-features')
        source = 'https://zh.wikipedia.org/wiki/第五套人民币'
        sourceName = 'Wikipedia: Fifth series of the renminbi'
    }
    W913 = @{
        zh = '第五套人民币2020年版5元纸币。中国人民银行说明，此版采用新的印制技术以提升防伪能力。'
        tw = '第五套人民幣2020年版5元紙幣。中國人民銀行說明，此版採用新的印製技術以提升防偽能力。'
        en = 'A 2020-edition 5-yuan note in the fifth series. The PBOC described its new printing technology as a counterfeit-prevention measure.'
        ja = '第五套人民元の2020年版5元紙幣です。中国人民銀行は、新しい印刷技術を偽造防止策として説明しています。'
        tags = @('rmb','series-5','modified-issue','security-features')
        source = 'https://zh.wikipedia.org/wiki/第五套人民币'
        sourceName = 'Wikipedia: Fifth series of the renminbi'
    }
    W914 = @{
        zh = '第五套人民币2019年版10元纸币。该版于2019年8月30日起发行，调整部分图案并提升防伪性能。'
        tw = '第五套人民幣2019年版10元紙幣。該版於2019年8月30日起發行，調整部分圖案並提升防偽性能。'
        en = 'A 2019-edition 10-yuan note in the fifth series, issued from 30 August 2019 with design and security updates.'
        ja = '第五套人民元の2019年版10元紙幣です。2019年8月30日から発行され、図案と偽造防止機能が更新されました。'
        tags = @('rmb','series-5','modified-issue','security-features')
        source = 'https://zh.wikipedia.org/wiki/第五套人民币'
        sourceName = 'Wikipedia: Fifth series of the renminbi'
    }
    W915 = @{
        zh = '第五套人民币2019年版20元纸币。该版于2019年8月30日起发行，调整部分图案并提升防伪性能；20元为第五套新增面额。'
        tw = '第五套人民幣2019年版20元紙幣。該版於2019年8月30日起發行，調整部分圖案並提升防偽性能；20元為第五套新增面額。'
        en = 'A 2019-edition 20-yuan note in the fifth series, issued from 30 August 2019 with design and security updates. The 20-yuan denomination was new to this series.'
        ja = '第五套人民元の2019年版20元紙幣です。2019年8月30日から発行され、図案と偽造防止機能が更新されました。20元はこのシリーズで新設された額面です。'
        tags = @('rmb','series-5','modified-issue','security-features','new-denomination')
        source = 'https://zh.wikipedia.org/wiki/第五套人民币'
        sourceName = 'Wikipedia: Fifth series of the renminbi'
    }
    W916 = @{
        zh = '第五套人民币2019年版50元纸币。该版于2019年8月30日起发行，调整部分图案并提升防伪性能。'
        tw = '第五套人民幣2019年版50元紙幣。該版於2019年8月30日起發行，調整部分圖案並提升防偽性能。'
        en = 'A 2019-edition 50-yuan note in the fifth series, issued from 30 August 2019 with design and security updates.'
        ja = '第五套人民元の2019年版50元紙幣です。2019年8月30日から発行され、図案と偽造防止機能が更新されました。'
        tags = @('rmb','series-5','modified-issue','security-features')
        source = 'https://zh.wikipedia.org/wiki/第五套人民币'
        sourceName = 'Wikipedia: Fifth series of the renminbi'
    }
    W918 = @{
        zh = '2022年冬季奥运会20元人民币纪念钞之一。中国人民银行于2021年12月发行纸质和聚合物两种版本，以纪念北京冬奥会。'
        tw = '2022年冬季奧運會20元人民幣紀念鈔之一。中國人民銀行於2021年12月發行紙質和聚合物兩種版本，以紀念北京冬奧會。'
        en = 'One of the 20-yuan commemorative notes issued in paper and polymer formats in December 2021 for the 2022 Winter Olympics in Beijing.'
        ja = '2022年北京冬季オリンピックを記念し、2021年12月に紙製とポリマー製で発行された20元記念紙幣の一つです。'
        tags = @('rmb','commemorative','winter-olympics')
        source = 'https://en.wikipedia.org/wiki/Commemorative_banknotes_of_the_renminbi'
        sourceName = 'Wikipedia: Commemorative banknotes of the renminbi'
    }
    W919 = @{
        zh = '2022年冬季奥运会20元人民币纪念钞之一。中国人民银行于2021年12月发行纸质和聚合物两种版本，以纪念北京冬奥会。'
        tw = '2022年冬季奧運會20元人民幣紀念鈔之一。中國人民銀行於2021年12月發行紙質和聚合物兩種版本，以紀念北京冬奧會。'
        en = 'One of the 20-yuan commemorative notes issued in paper and polymer formats in December 2021 for the 2022 Winter Olympics in Beijing.'
        ja = '2022年北京冬季オリンピックを記念し、2021年12月に紙製とポリマー製で発行された20元記念紙幣の一つです。'
        tags = @('rmb','commemorative','winter-olympics')
        source = 'https://en.wikipedia.org/wiki/Commemorative_banknotes_of_the_renminbi'
        sourceName = 'Wikipedia: Commemorative banknotes of the renminbi'
    }
    W920 = @{
        zh = '2024年发行的20元聚合物生肖纪念钞，主题为龙年。维基百科记载，中国人民银行自2024年中国新年起发行生肖主题的20元聚合物纪念钞。'
        tw = '2024年發行的20元聚合物生肖紀念鈔，主題為龍年。維基百科記載，中國人民銀行自2024年中國新年起發行生肖主題的20元聚合物紀念鈔。'
        en = 'A polymer 20-yuan zodiac commemorative note issued in 2024 for the Year of the Dragon, part of the annual series that Wikipedia says began in 2024.'
        ja = '2024年の辰年に発行されたポリマー製20元干支記念紙幣です。2024年に始まった毎年発行のシリーズに属します。'
        tags = @('rmb','commemorative','zodiac','dragon')
        source = 'https://en.wikipedia.org/wiki/Renminbi'
        sourceName = 'Wikipedia: Renminbi'
    }
    W921 = @{
        zh = '2025年发行的20元聚合物生肖纪念钞，主题为蛇年。维基百科将其归入自2024年开始发行的生肖主题20元聚合物纪念钞系列。'
        tw = '2025年發行的20元聚合物生肖紀念鈔，主題為蛇年。維基百科將其歸入自2024年開始發行的生肖主題20元聚合物紀念鈔系列。'
        en = 'A polymer 20-yuan zodiac commemorative note issued in 2025 for the Year of the Snake, part of the annual series that Wikipedia says began in 2024.'
        ja = '2025年の巳年に発行されたポリマー製20元干支記念紙幣です。2024年に始まった毎年発行のシリーズに属します。'
        tags = @('rmb','commemorative','zodiac','snake')
        source = 'https://en.wikipedia.org/wiki/Renminbi'
        sourceName = 'Wikipedia: Renminbi'
    }
    W922 = @{
        zh = '2026年发行的20元聚合物生肖纪念钞，主题为马年。维基百科将其归入自2024年开始发行的生肖主题20元聚合物纪念钞系列。'
        tw = '2026年發行的20元聚合物生肖紀念鈔，主題為馬年。維基百科將其歸入自2024年開始發行的生肖主題20元聚合物紀念鈔系列。'
        en = 'A polymer 20-yuan zodiac commemorative note issued in 2026 for the Year of the Horse, part of the annual series that Wikipedia says began in 2024.'
        ja = '2026年の午年に発行されたポリマー製20元干支記念紙幣です。2024年に始まった毎年発行のシリーズに属します。'
        tags = @('rmb','commemorative','zodiac','horse')
        source = 'https://en.wikipedia.org/wiki/Renminbi'
        sourceName = 'Wikipedia: Renminbi'
    }
}

function Format-Denomination([string]$value, [string]$languageTag) {
    $formatted = $value -replace '(?<=\d)\.(?=\d{3}\b)', ','
    if ($languageTag -eq 'en') { return $formatted }
    if ($languageTag -eq 'ja') {
        $formatted = $formatted -replace '\bDollars?\b', '元' -replace '\bYuan\b', '元' -replace '\bCents?\b', '分' -replace '\bFen\b', '分' -replace '\bChiao\b', '角' -replace '\bJiao\b', '角'
        return $formatted
    }
    $formatted = $formatted -replace '\bDollars?\b', '元' -replace '\bYuan\b', '元' -replace '\bCents?\b', '分' -replace '\bFen\b', '分' -replace '\bChiao\b', '角' -replace '\bJiao\b', '角'
    return $formatted
}

$regularPickCount = 0
foreach ($group in ($banknotes | Group-Object pickNumber)) {
    $pick = $group.Name
    $records = @($group.Group)
    $record = $records[0]
    $years = @($records.year | Where-Object { $_ -and $_ -gt 0 } | Sort-Object -Unique)
    $yearLabel = if ($years.Count -eq 0) { 'unknown' } else { $years -join '/' }
    $yearLabelJa = if ($years.Count -eq 0) { '年代不詳' } else { $years -join '・' }
    $denomEn = Format-Denomination $record.denomination 'en'
    $denomZh = Format-Denomination $record.denomination 'zh'
    $denomTw = Format-Denomination $record.denomination 'tw'
    $denomJa = Format-Denomination $record.denomination 'ja'
    $profile = $null
    $tags = @()
    $sourceName = ''
    $sourceUrl = ''

    if ($commemoratives.ContainsKey($pick)) {
        $profile = $commemoratives[$pick]
        $tags = $profile.Tags
        $sourceName = 'Wikipedia: Renminbi'
        $sourceUrl = 'https://en.wikipedia.org/wiki/Renminbi'
    }
    elseif ($recent.ContainsKey($pick)) {
        $profile = $recent[$pick]
        $tags = $profile.Tags
        $sourceName = $profile.sourceName
        $sourceUrl = $profile.source
    }
    elseif ($pick -match '^FX') {
        $profile = @{
            zh = '中国银行外汇兑换券以人民币为计值单位，供外籍访客等在指定范围使用，面额与人民币等值；纸券包括1979和1988年版，自1980年发行并于1994年停止使用。'
            tw = '中國銀行外匯兌換券以人民幣為計值單位，供外籍訪客等在指定範圍使用，面額與人民幣等值；紙券包括1979和1988年版，自1980年發行並於1994年停止使用。'
            en = 'Bank of China foreign-exchange certificates were renminbi-denominated payment instruments for foreign visitors and designated places, not a separate currency. The 1979 and 1988 issues circulated from 1980 until withdrawal in 1994.'
            ja = '中国銀行外貨兌換券は、外国人旅行者などが指定された場所で使用する人民元建ての決済手段で、独立した通貨ではありません。1979年版と1988年版があり、1980年に流通を開始し、1994年に使用が停止されました。'
        }
        $tags = @('foreign-exchange-certificate','bank-of-china','restricted-use')
        $sourceName = 'Wikipedia: Foreign exchange certificates; Bank of China history'
        $sourceUrl = 'https://zh.wikipedia.org/wiki/中国银行外汇兑换券'
    }
    elseif ($pick -match '^M') {
        $motif = if ($pick -eq 'M41') { @{ zh='正面为运输机图案'; tw='正面為運輸機圖案'; en='The front depicts a transport aircraft.'; ja='表面には輸送機が描かれています。' } } else { @{ zh='正面为火车图案'; tw='正面為火車圖案'; en='The front depicts a train.'; ja='表面には列車が描かれています。' } }
        $profile = @{
            zh = "1965年中国人民解放军军用代金券，面额$denomZh。维基条目说明该券仅供内部使用，禁止市场流通。$($motif.zh)"
            tw = "1965年中國人民解放軍軍用代金券，面額$denomTw。維基條目說明該券僅供內部使用，禁止市場流通。$($motif.tw)"
            en = "A 1965 military payment certificate for the People's Liberation Army, denominated $denomEn. The Wikipedia article says it was for internal use and prohibited from market circulation. $($motif.en)"
            ja = "1965年に中国人民解放軍向けに発行された軍用支払証券で、額面は$denomJaです。内部使用に限られ、市場での流通は禁止されていました。$($motif.ja)"
        }
        $tags = @('military-payment','restricted-use')
        $sourceName = 'Wikipedia: Military payment certificate'
        $sourceUrl = 'https://zh.wikipedia.org/wiki/军用代金券'
    }
    else {
        $number = 0
        if ($pick -match '^([0-9]+)') { $number = [int]$Matches[1] }
        $seriesNumber = if ($number -ge 800 -and $number -le 859) { 1 }
            elseif ($number -ge 860 -and $number -le 872) { 2 }
            elseif ($number -ge 873 -and $number -le 880) { 3 }
            elseif ($number -ge 881 -and $number -le 889) { 4 }
            elseif (($number -ge 895 -and $number -le 901) -or ($number -ge 903 -and $number -le 907) -or $number -eq 909) { 5 }
            else { 0 }
        if ($seriesNumber -eq 0) { throw "No source profile for Pick $pick" }

        $profile = $series[$seriesNumber]
        $tags = @($profile.tags)
        if ($seriesNumber -eq 2 -and $record.denomination -eq '3 Yuan') { $tags += 'unique-three-yuan' }
        if ($seriesNumber -eq 5 -and $record.denomination -eq '20 Yuan') { $tags += 'new-denomination' }
        $pickLabel = 'P-' + $pick
        $profile = @{
            zh = "$pickLabel（$denomZh，目录年份$yearLabel）。$($series[$seriesNumber].zh)"
            tw = "$pickLabel（$denomTw，目錄年份$yearLabel）。$($series[$seriesNumber].tw)"
            en = "$pickLabel ($denomEn; catalog year $yearLabel). $($series[$seriesNumber].en)"
                ja = "$pickLabel（額面$denomJa、記録年$yearLabelJa）。$($series[$seriesNumber].ja)"
        }
        $sourceName = $series[$seriesNumber].sourceName
        $sourceUrl = $series[$seriesNumber].source
        $regularPickCount++
    }

    $research.Add([pscustomobject]@{
        collectionId = $collectionId
        pickNumber = $pick
        simplifiedDescription = $profile.zh
        traditionalDescription = $profile.tw
        englishDescription = $profile.en
        japaneseDescription = $profile.ja
        tags = $tags
        sourceName = $sourceName
        sourceUrl = $sourceUrl
    })
}

$expectedPickCount = @($banknotes | ForEach-Object pickNumber | Sort-Object -Unique).Count
if ($research.Count -ne $expectedPickCount) {
    throw "Research coverage mismatch: $($research.Count) notes for $expectedPickCount Pick entries."
}

$otherResearch = @($catalog.researchNotes | Where-Object collectionId -ne $collectionId)
$catalog.researchNotes = @($otherResearch) + @($research.ToArray())
$json = ConvertTo-Json -InputObject $catalog -Depth 30
[System.IO.File]::WriteAllText($catalogPath, $json, [System.Text.UTF8Encoding]::new($false))
Write-Output "Refreshed $($research.Count) Pick descriptions across $($banknotes.Count) variants ($regularPickCount regular RMB series entries)."