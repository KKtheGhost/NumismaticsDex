[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$catalogPath = Join-Path $repositoryRoot 'NumismaticsDex.App\Assets\catalog.json'
$collectionIds = @(
    'japan-regional-exchange-banks',
    'japan-foreign-banks',
    'japan-great-imperial-national-bank',
    'japan-government-banknotes',
    'japan-military-currency',
    'japan-allied-military-currency'
)
$catalog = Get-Content $catalogPath -Raw | ConvertFrom-Json
$banknotes = @($catalog.banknotes | Where-Object { $_.collectionId -in $collectionIds })
if ($banknotes.Count -eq 0) {
    throw 'No non-Nippon Ginko Japan collections found. Import the collections first.'
}

$profiles = @{
    earlyLocal = @{
        zh = '明治维新前后，日本同时流通政府、地方和民间发行的纸券，面额可能使用两、朱、分、文或钱等旧单位。1871年建立日元制度后，旧券逐步兑换或退出；此条目的发行人和具体面额依据目录记录。'
        tw = '明治維新前後，日本同時流通政府、地方和民間發行的紙券，面額可能使用兩、朱、分、文或錢等舊單位。1871年建立日圓制度後，舊券逐步兌換或退出；此條目的發行人和具體面額依據目錄記錄。'
        en = 'Around the Meiji transition, government, domain, and private issuers circulated paper notes in older units such as ryō, shu, bu, mon, and sen. After the yen system was adopted in 1871, older notes were gradually exchanged or withdrawn; the issuer and denomination shown here follow the catalog record.'
        ja = '明治維新前後、政府、藩、民間の発行者が両、朱、分、文、銭など旧単位の紙券を流通させました。1871年に円制度が導入されると、旧券は次第に交換または回収されました。発行者と額面はカタログ記録に基づきます。'
        tags = @('regional-banknote','government-note')
        sourceName = 'Wikipedia: Japanese currency'
        sourceUrl = 'https://en.wikipedia.org/wiki/Japanese_currency'
    }
    dajokansatsu = @{
        zh = '太政官札是明治政府1868至1869年发行的早期纸券，以旧金单位计值且不可兑换；维基条目指出其发行与新政府筹措战争经费有关，后来曾以明治通宝兑换。'
        tw = '太政官札是明治政府1868至1869年發行的早期紙券，以舊金單位計值且不可兌換；維基條目指出其發行與新政府籌措戰爭經費有關，後來曾以明治通寶兌換。'
        en = 'Dajōkansatsu were early Meiji government paper issues from 1868–1869, denominated in old gold units and not convertible. Wikipedia describes them as a fiscal measure for the new government during wartime; they were later exchanged for Meiji Tsūhō notes.'
        ja = '太政官札は1868〜1869年に明治政府が発行した初期紙幣で、旧金単位建て、兌換不可でした。戦時下の新政府による財政措置とされ、後に明治通宝と交換されました。'
        tags = @('government-note','dajo-kansatsu')
        sourceName = 'Wikipedia: Dajōkansatsu'
        sourceUrl = 'https://en.wikipedia.org/wiki/Daj%C5%8Dkansatsu'
    }
    civilDepartment = @{
        zh = '这组1869年民部省纸券属于日元制度确立前的早期政府发行。维基日本货币史记录当时多种政府与民间纸券并行；具体面额和发行机构依目录原始记录。'
        tw = '這組1869年民部省紙券屬於日圓制度確立前的早期政府發行。維基日本貨幣史記錄當時多種政府與民間紙券並行；具體面額和發行機構依目錄原始記錄。'
        en = 'These 1869 Civil Department notes belong to early government issues before the yen system was established. Wikipedia describes multiple government and private paper currencies circulating in this period; the specific denomination and issuer follow the catalog record.'
        ja = '1869年の民部省紙券は、円制度の確立前に発行された初期の政府紙幣です。当時は政府や民間の複数の紙幣が併用されていました。個別の額面と発行機関はカタログ記録に基づきます。'
        tags = @('government-note','regional-banknote')
        sourceName = 'Wikipedia: Japanese currency'
        sourceUrl = 'https://en.wikipedia.org/wiki/Japanese_currency'
    }
    developmentOffice = @{
        zh = '此1872年开拓使纸券面额为20钱，发行时日本已开始推行日元及十进位货币制度。日本货币维基条目提供制度背景，但没有记述这张具体券的发行细节。'
        tw = '此1872年開拓使紙券面額為20錢，發行時日本已開始推行日圓及十進位貨幣制度。日本貨幣維基條目提供制度背景，但沒有記述這張具體券的發行細節。'
        en = 'This 1872 Development Office note is denominated at 20 sen, after Japan began adopting the yen and decimal currency system. Wikipedia provides the monetary-transition context but does not detail this particular note.'
        ja = 'この開拓使紙券は1872年発行の20銭券で、日本が円と十進法の通貨制度を導入し始めた時期のものです。参照資料は通貨制度の移行を説明していますが、この個別紙幣の詳細は扱っていません。'
        tags = @('government-note')
        sourceName = 'Wikipedia: Japanese currency (general context; individual issue not covered)'
        sourceUrl = 'https://en.wikipedia.org/wiki/Japanese_currency'
    }
    exchangeCompany = @{
        zh = '东京兑换会社纸券是明治初期兑换会社发行的民间纸币。维基国立银行史记载，兑换会社是当时商业银行制度形成前后、获准发行纸券的早期机构之一。'
        tw = '東京兌換会社紙券是明治初期兌換会社發行的民間紙幣。維基國立銀行史記載，兌換会社是當時商業銀行制度形成前後、獲准發行紙券的早期機構之一。'
        en = 'Tokyo Kawase Kaisha notes were privately issued in early Meiji Japan. The Wikipedia history of national banks describes kawase-kaisha as early commercial institutions authorized to issue notes before the centralized Bank of Japan system.'
        ja = '東京為替会社の紙券は明治初期に民間発行されました。国立銀行の歴史資料では、為替会社は日本銀行による中央銀行制度が整う前に紙券発行を認められた初期の商業機関として説明されています。'
        tags = @('regional-banknote','exchange-bank')
        sourceName = 'Wikipedia: National Banks in Meiji Japan'
        sourceUrl = 'https://en.wikipedia.org/wiki/National_Banks_in_Meiji_Japan'
    }
    kyotoLocal = @{
        zh = '京都发行的500文纸券采用日元制度确立前的文为面额单位。维基日本货币史说明当时地方纸券与金、银、铜币并行；该条目的具体发行信息依目录记录。'
        tw = '京都發行的500文紙券採用日圓制度確立前的文為面額單位。維基日本貨幣史說明當時地方紙券與金、銀、銅幣並行；該條目的具體發行資訊依目錄記錄。'
        en = 'This Kyoto note is denominated in 500 mon, an older unit predating the yen system. Wikipedia describes local paper currencies circulating alongside gold, silver, and copper money; the issue-specific details follow the catalog record.'
        ja = 'この京都紙券は、円制度以前の単位である500文建てです。当時は地方紙幣が金銀銅貨と併用されていました。個別の発行情報はカタログ記録に基づきます。'
        tags = @('regional-banknote')
        sourceName = 'Wikipedia: Japanese currency'
        sourceUrl = 'https://en.wikipedia.org/wiki/Japanese_currency'
    }
    foreignBank = @{
        zh = '目录将此券记录为印度西部中央银行1866年横滨发行的25美元纸币。Wikipedia日本货币史仅提供19世纪货币制度背景，并未记载该银行或此券的专门信息；具体发行事实以原始目录记录为准。'
        tw = '目錄將此券記錄為印度西部中央銀行1866年橫濱發行的25美元紙幣。Wikipedia日本貨幣史僅提供19世紀貨幣制度背景，並未記載該銀行或此券的專門資訊；具體發行事實以原始目錄記錄為準。'
        en = 'The catalog identifies this as a 25-dollar note issued at Yokohama in 1866 by the Central Bank of Western India. The Wikipedia Japanese-currency overview supplies only broad context and does not cover this bank or note; the issue-specific details remain attributed to the source catalog.'
        ja = 'カタログでは、インド西部中央銀行が1866年に横浜で発行した25ドル紙幣とされています。日本の通貨史に関する参照資料は概説にとどまり、この銀行や紙幣を扱っていません。個別の発行情報は原カタログに基づきます。'
        tags = @('foreign-banknote')
        sourceName = 'Wikipedia: Japanese currency (general context; individual issue not covered)'
        sourceUrl = 'https://en.wikipedia.org/wiki/Japanese_currency'
    }
    nationalBank = @{
        zh = '大日本帝国国立银行依国立银行条例发行银行券。维基记载，1872年条例建立特许银行发券制度，1876年修法后可用国债支持发行，银行券兑换条件随之变化；本券发行于1877至1878年。'
        tw = '大日本帝國國立銀行依國立銀行條例發行銀行券。維基記載，1872年條例建立特許銀行發券制度，1876年修法後可用國債支持發行，銀行券兌換條件隨之變化；本券發行於1877至1878年。'
        en = 'The Great Imperial Japanese National Bank issued notes under the National Bank Acts. Wikipedia records that the 1872 act created chartered note-issuing banks and the 1876 amendment allowed bond-backed issuance with changed convertibility; these Pick notes date to 1877–1878.'
        ja = '大日本帝国国立銀行は国立銀行条例に基づいて紙幣を発行しました。1872年の条例は特許を受けた発券銀行を設け、1876年の改正では国債を裏付けとする発行を認め、兌換条件も変わりました。この分類番号の紙幣は1877〜1878年の発行です。'
        tags = @('national-bank-note','government-note')
        sourceName = 'Wikipedia: National Banks in Meiji Japan'
        sourceUrl = 'https://en.wikipedia.org/wiki/National_Banks_in_Meiji_Japan'
    }
    meijiTsuho = @{
        zh = '明治通宝是明治政府1872年起发行的首批西式印刷纸币，以日元与钱为面额。维基记载，早期在德国印制、后转为日本国内生产；繁复图案旨在应对当时普遍的伪造问题。'
        tw = '明治通寶是明治政府1872年起發行的首批西式印刷紙幣，以日圓與錢為面額。維基記載，早期在德國印製、後轉為日本國內生產；繁複圖案旨在因應當時普遍的偽造問題。'
        en = 'Meiji Tsūhō were among the first Western-style printed notes issued by the Meiji government from 1872, denominated in yen and sen. Wikipedia notes that early printing was done in Germany before production moved to Japan, and that the elaborate designs responded to widespread counterfeiting.'
        ja = '明治通宝は1872年から明治政府が発行した初期の西洋式印刷紙幣で、円と銭を単位としました。初期分はドイツで印刷され、後に国内生産へ移行しました。精巧な図案は当時広がっていた偽造への対策でもありました。'
        tags = @('government-note','meiji-tsuho')
        sourceName = 'Wikipedia: Meiji Tsūhō'
        sourceUrl = 'https://en.wikipedia.org/wiki/Meiji_Tsuho'
    }
    modifiedGovernment = @{
        zh = '1881至1883年的改造纸币承接明治通宝，维基面额条目记载神功皇后图案是日本纸币最早的人物肖像之一，并采用水印等防伪设计。'
        tw = '1881至1883年的改造紙幣承接明治通寶，維基面額條目記載神功皇后圖案是日本紙幣最早的人物肖像之一，並採用水印等防偽設計。'
        en = 'The 1881–1883 remodeled government notes followed Meiji Tsūhō. Wikipedia denomination articles identify the Empress Jingū design among the earliest Japanese banknote portraits and describe watermarks as an anti-counterfeiting feature.'
        ja = '1881〜1883年の改造紙幣は明治通宝に続く政府紙幣です。神功皇后の図案は日本の紙幣における初期の人物肖像の一つで、透かしも偽造防止機能として用いられました。'
        tags = @('government-note','modified-issue','anti-counterfeiting')
        sourceName = 'Wikipedia: Meiji Tsūhō and Japanese yen banknotes'
        sourceUrl = 'https://en.wikipedia.org/wiki/Meiji_Tsuho'
    }
    smallGovernment = @{
        zh = '第一次世界大战期间，硬币材料短缺促使政府发行10、20及50钱小额纸币，作为辅币替代。日本语维基小额政府纸币条目记载了其发行年份、面额与大藏省印章。'
        tw = '第一次世界大戰期間，硬幣材料短缺促使政府發行10、20及50錢小額紙幣，作為輔幣替代。日語維基小額政府紙幣條目記載了其發行年份、面額與大藏省印章。'
        en = 'During World War I, shortages of coinage materials led the government to issue 10-, 20-, and 50-sen small-denomination notes as subsidiary currency. The Japanese Wikipedia article documents their dates, denominations, and Finance Minister seal.'
        ja = '第一次世界大戦中、貨幣材料が不足したため、政府は補助通貨として10、20、50銭の小額紙幣を発行しました。日本語版ウィキペディアには発行年、額面、大蔵大臣印が記録されています。'
        tags = @('government-note')
        sourceName = 'Wikipedia: 小額政府紙幣 (Small-denomination government notes)'
        sourceUrl = 'https://ja.wikipedia.org/wiki/小額政府紙幣'
    }
    wartimeGovernment = @{
        zh = '战争时期金属材料短缺使政府发行50钱纸币替代硬币。该面额先后出现富士樱、靖国神社和板垣退助等版式；后期券在盟军占领下改动题号或底纹。'
        tw = '戰爭時期金屬材料短缺使政府發行50錢紙幣替代硬幣。該面額先後出現富士櫻、靖國神社和板垣退助等版式；後期券在盟軍佔領下改動題號或底紋。'
        en = 'Wartime metal shortages led the government to issue 50-sen notes as substitutes for coins. The denomination appeared in Fuji-and-cherry, Yasukuni Shrine, and Itagaki Taisuke designs; later printing changed the title or background under occupation.'
        ja = '戦時中の金属不足を受け、政府は硬貨に代わる50銭紙幣を発行しました。富士山と桜、靖国神社、板垣退助などの図案があり、占領下の後期印刷では表題や背景が変更されました。'
        tags = @('government-note','wartime-note')
        sourceName = 'Wikipedia: 小額政府紙幣 (Small-denomination government notes)'
        sourceUrl = 'https://ja.wikipedia.org/wiki/小額政府紙幣'
    }
    russoJapaneseWar = @{
        zh = '日俄战争期间发行的军用纸券，用于军队在相关地区购买物资。Wikipedia记载该组包括10钱至10日元面额，可按规定兑换银币；其图案沿用当时日本民用纸券的风格。'
        tw = '日俄戰爭期間發行的軍用紙券，用於軍隊在相關地區購買物資。Wikipedia記載該組包括10錢至10日圓面額，可按規定兌換銀幣；其圖案沿用當時日本民用紙券的風格。'
        en = 'Military notes issued during the Russo-Japanese War for troop purchases in the campaign region. Wikipedia describes denominations from 10 sen to ¥10, redeemable for silver, with designs resembling contemporary civilian notes.'
        ja = '日露戦争中、作戦地域で軍の調達に用いるため発行された軍用紙幣です。額面は10銭から10円までで、銀貨と交換可能でした。図案は当時の一般紙幣に似せて作られています。'
        tags = @('military-currency')
        sourceName = 'Wikipedia: Japanese military currency (1894–1918)'
        sourceUrl = 'https://en.wikipedia.org/wiki/Japanese_military_currency_(1894%E2%80%931918)'
    }
    qingdaoWar = @{
        zh = '1914年青岛战役期间发行的军用纸券，面额为10、20、50钱及1日元以上。Wikipedia记载这些券按银兑换，战事结束后多数被兑换，发行与流通时间较短。'
        tw = '1914年青島戰役期間發行的軍用紙券，面額為10、20、50錢及1日圓以上。Wikipedia記載這些券按銀兌換，戰事結束後多數被兌換，發行與流通時間較短。'
        en = 'Military notes issued for the 1914 Siege of Qingdao, in denominations from 10, 20, and 50 sen through yen values. Wikipedia states they were redeemable in silver and that most were redeemed after the short campaign.'
        ja = '1914年の青島の戦いに際して発行された軍用紙幣です。10、20、50銭から円単位までの額面があり、銀貨と交換できました。短期間の作戦終了後、その大半は回収・交換されました。'
        tags = @('military-currency')
        sourceName = 'Wikipedia: Japanese military currency (1894–1918)'
        sourceUrl = 'https://en.wikipedia.org/wiki/Japanese_military_currency_(1894%E2%80%931918)'
    }
    siberianIntervention = @{
        zh = '1918年西伯利亚出兵期间发行的军用纸券，维基记载其由朝鲜银行办理军费支付，并有黄金储备支持；部分纸券在撤军后仍继续流通。'
        tw = '1918年西伯利亞出兵期間發行的軍用紙券，維基記載其由朝鮮銀行辦理軍費支付，並有黃金儲備支持；部分紙券在撤軍後仍繼續流通。'
        en = 'Military notes issued for the 1918 Siberian intervention. Wikipedia describes payments through the Bank of Chōsen and gold backing; some notes continued to circulate after the intervention.'
        ja = '1918年のシベリア出兵に際して発行された軍用紙幣です。朝鮮銀行を通じた支払いと金による裏付けが記録されており、出兵終了後も一部の紙幣は流通を続けました。'
        tags = @('military-currency')
        sourceName = 'Wikipedia: Japanese military currency (1894–1918)'
        sourceUrl = 'https://en.wikipedia.org/wiki/Japanese_military_currency_(1894%E2%80%931918)'
    }
    kopeckCaveat = @{
        zh = '目录记录此券为日本帝国政府发行的戈比面额军用券，发行年代约为1940年代。可查的Wikipedia日本军票概述主要讨论日元军票，未提供这两种戈比券的专门史料；此处不推断其具体战区或用途。'
        tw = '目錄記錄此券為日本帝國政府發行的戈比面額軍用券，發行年代約為1940年代。可查的Wikipedia日本軍票概述主要討論日圓軍票，未提供這兩種戈比券的專門史料；此處不推斷其具體戰區或用途。'
        en = 'The catalog identifies this as a kopeck-denominated military note issued by the Imperial Japanese Government in the 1940s. Available Wikipedia overviews focus on yen-denominated military currency and do not document these two kopeck issues, so no specific theater or use is inferred here.'
        ja = 'カタログでは、1940年代に大日本帝国政府が発行したコペイカ建て軍用紙幣とされています。公開されている概説は円建て軍票を中心としており、この2種類のコペイカ券を記録していません。そのため、具体的な戦域や用途は推定していません。'
        tags = @('military-currency')
        sourceName = 'Wikipedia: Japanese military currency (general context; kopeck issues not covered)'
        sourceUrl = 'https://en.wikipedia.org/wiki/Japanese_military_currency_(1937%E2%80%931945)'
    }
    alliedA = @{
        zh = 'A型盟军日元军票于1945年印制，原为盟军计划进入日本时使用。Wikipedia记载其在日本本土并未投入流通；A yen在其他占领区的用途与B yen不同。'
        tw = 'A型盟軍日圓軍票於1945年印製，原為盟軍計畫進入日本時使用。Wikipedia記載其在日本本土並未投入流通；A yen在其他佔領區的用途與B yen不同。'
        en = 'A-yen Allied military scrip was printed in 1945 for the planned occupation of Japan. Wikipedia says it was not circulated in mainland Japan; A-yen use in other occupied areas differed from B-yen use.'
        ja = 'A円軍票は日本占領計画に備えて1945年に印刷された連合軍軍票です。日本本土では流通せず、他の占領地域におけるA円の使用状況もB円とは異なりました。'
        tags = @('allied-currency','occupation-currency','a-yen','not-used-in-japan')
        sourceName = 'Wikipedia: A yen and Allied Military Currency'
        sourceUrl = 'https://en.wikipedia.org/wiki/A_yen'
    }
    alliedB = @{
        zh = 'B型军票属于琉球群岛占领时期货币，1946至1958年主要供当地平民流通；它不是日本本土通用的日本银行券。'
        tw = 'B型軍票屬於琉球群島佔領時期貨幣，1946至1958年主要供當地平民流通；它不是日本本土通用的日本銀行券。'
        en = 'B-yen was occupation scrip used for civilian circulation in the Ryukyu Islands from 1946 to 1958, not a Bank of Japan note circulating on mainland Japan.'
        ja = 'B円軍票は1946年から1958年まで琉球諸島で民間流通に用いられた占領地通貨です。日本本土で流通した日本銀行券ではありません。'
        tags = @('allied-currency','occupation-currency','b-yen')
        sourceName = 'Wikipedia: B yen and Allied Military Currency'
        sourceUrl = 'https://en.wikipedia.org/wiki/B_yen'
    }
}

$research = [System.Collections.Generic.List[object]]::new()
foreach ($group in ($banknotes | Group-Object { '{0}:{1}' -f $_.collectionId,$_.pickNumber })) {
    $record = $group.Group[0]
    $collectionId = $record.collectionId
    $pick = $record.pickNumber
    $number = if ($pick -match '^(?:M)?(?<number>[0-9]+)') { [int]$Matches.number } else { 0 }
    $profile = $null

    switch ($collectionId) {
        'japan-regional-exchange-banks' {
            if ($pick -in @('S162','S164','S165')) { $profile = $profiles.dajokansatsu }
            elseif ($pick -in @('S167','S168','S169')) { $profile = $profiles.civilDepartment }
            elseif ($pick -eq 'S180') { $profile = $profiles.exchangeCompany }
            elseif ($pick -eq 'S186') { $profile = $profiles.kyotoLocal }
            elseif ($pick -eq 'S175') { $profile = $profiles.developmentOffice }
            else { $profile = $profiles.earlyLocal }
        }
        'japan-foreign-banks' { $profile = $profiles.foreignBank }
        'japan-great-imperial-national-bank' { $profile = $profiles.nationalBank }
        'japan-government-banknotes' {
            if ($number -le 14) { $profile = $profiles.meijiTsuho }
            elseif ($number -ge 15 -and $number -le 19) { $profile = $profiles.modifiedGovernment }
            elseif ($number -ge 46 -and $number -le 48) { $profile = $profiles.smallGovernment }
            elseif ($number -ge 58 -and $number -le 61) { $profile = $profiles.wartimeGovernment }
        }
        'japan-military-currency' {
            if ($number -ge 1 -and $number -le 6) { $profile = $profiles.russoJapaneseWar }
            elseif ($number -ge 7 -and $number -le 10) { $profile = $profiles.qingdaoWar }
            elseif ($number -ge 13 -and $number -le 18) { $profile = $profiles.siberianIntervention }
            elseif ($pick -in @('M19','M20')) { $profile = $profiles.kopeckCaveat }
        }
        'japan-allied-military-currency' {
            if ($pick -in @('63','65','67','69','71','73','75')) { $profile = $profiles.alliedA }
            else { $profile = $profiles.alliedB }
        }
    }

    if ($null -eq $profile) {
        throw "No Wikipedia research profile for $collectionId Pick $pick."
    }

    $pickLabel = if ($pick -match '^S') { "P-$pick" } else { "P-$pick" }
    $tags = @($profile.tags)
    $research.Add([pscustomobject]@{
        collectionId = $collectionId
        pickNumber = $pick
        simplifiedDescription = "$pickLabel。$($profile.zh)"
        traditionalDescription = "$pickLabel。$($profile.tw)"
        englishDescription = "$pickLabel. $($profile.en)"
        japaneseDescription = "$pickLabel。$($profile.ja)"
        tags = @($tags | Sort-Object -Unique)
        sourceName = $profile.sourceName
        sourceUrl = $profile.sourceUrl
    })
}

$expectedPickKeys = @($banknotes | ForEach-Object { '{0}:{1}' -f $_.collectionId,$_.pickNumber } | Sort-Object -Unique)
if ($research.Count -ne $expectedPickKeys.Count) {
    throw "Research coverage mismatch: $($research.Count) notes for $($expectedPickKeys.Count) Japan Pick entries."
}

$otherResearch = @($catalog.researchNotes | Where-Object { $_.collectionId -notin $collectionIds })
$catalog.researchNotes = @($otherResearch) + @($research.ToArray())
$json = ConvertTo-Json -InputObject $catalog -Depth 30
[System.IO.File]::WriteAllText($catalogPath, $json, [System.Text.UTF8Encoding]::new($false))
Write-Output "Refreshed $($research.Count) Wikipedia-based research notes across $($collectionIds.Count) Japan themes."