[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$catalogPath = Join-Path $repositoryRoot 'NumismaticsDex.App\Assets\catalog.json'
$catalog = Get-Content $catalogPath -Raw | ConvertFrom-Json
$collectionIds = @('china-empire','china-japanese-puppet-banks','manchukuo')
$banknotes = @($catalog.banknotes | Where-Object collectionId -in $collectionIds)
$profiles = @{
    ming = @{
        issuerZh = '明代宝钞发行体系'
        issuerJa = '明代宝鈔の発行制度'
        zh = '大明宝钞由明廷自1375年起发行，以贯、文等计值，最初可按名义面额折合铜钱。它不以金属储备作足值担保，长期超发与政府拒收、少换旧钞削弱了公众信任并造成贬值。'
        tw = '大明寶鈔由明廷自1375年起發行，以貫、文等計值，最初可按名義面額折合銅錢。它不以金屬儲備作足值擔保，長期超發與政府拒收、少換舊鈔削弱了公眾信任並造成貶值。'
        en = 'The Ming court began issuing Great Ming Treasure Notes in 1375, denominated in guan and wen and initially valued by reference to copper cash. They were not backed by hard-currency reserves; over-issuance and limited government acceptance eroded confidence and value.'
        ja = '明朝は1375年に大明宝鈔の発行を開始し、貫と文を単位としました。当初は銅銭を基準に名目価値が定められましたが、正貨準備による裏付けはありませんでした。過剰発行や政府による受け取りの限定が、信用と価値の低下を招きました。'
        sourceName = 'Wikipedia: Great Ming Treasure Note'
        sourceUrl = 'https://en.wikipedia.org/wiki/Great_Ming_Treasure_Note'
    }
    qingCash = @{
        issuerZh = '清政府制钱钞体系'
        issuerJa = '清政府の制銭紙幣'
        zh = '咸丰年间，太平天国战争等财政压力及铜料短缺促使清廷重新发行纸币。大清宝钞按文计值，面额从数百文扩展到高额；纸钞与制钱、银两并行，实际兑换和市场价值受地区汇率及通胀影响。'
        tw = '咸豐年間，太平天國戰爭等財政壓力及銅料短缺促使清廷重新發行紙幣。大清寶鈔按文計值，面額從數百文擴展到高額；紙鈔與制錢、銀兩並行，實際兌換和市場價值受地區匯率及通膨影響。'
        en = 'Fiscal pressure during the Xianfeng era, including the Taiping Rebellion, and shortages of copper led the Qing court to resume paper issuance. Great Qing Treasure Notes were denominated in wen, with denominations rising from hundreds to very large sums; their market value and exchange varied by region amid inflation.'
        ja = '太平天国の乱など咸豊年間の財政難と銅不足を背景に、清朝は紙幣発行を再開しました。大清宝鈔は文を単位とし、額面は数百文から巨額へと拡大しました。インフレのなかで、市場価値や交換条件は地域ごとに異なりました。'
        sourceName = 'Wikipedia: Paper money of the Qing dynasty'
        sourceUrl = 'https://en.wikipedia.org/wiki/Paper_money_of_the_Qing_dynasty'
    }
    qingTael = @{
        issuerZh = '清政府户部官票'
        issuerJa = '清政府の戸部官票'
        zh = '户部官票是咸丰年间以银两计值的清政府纸币，常见面额包括1、3、5、10和50两，与按文计值的制钱钞并行。它们的兑换和流通受指定机构、地区折价及财政信用影响，不能把票面银两等同于各地实际兑付价值。'
        tw = '戶部官票是咸豐年間以銀兩計值的清政府紙幣，常見面額包括1、3、5、10和50兩，與按文計值的制錢鈔並行。它們的兌換和流通受指定機構、地區折價及財政信用影響，不能把票面銀兩等同於各地實際兌付價值。'
        en = 'Hubu guanpiao were Qing government notes denominated in silver taels during the Xianfeng era, with denominations including 1, 3, 5, 10, and 50 taels. They circulated alongside cash-denominated notes, while exchange depended on designated institutions, local discounts, and fiscal confidence.'
        ja = '戸部官票は咸豊年間に発行された清朝政府紙幣で、銀両を単位とし、1、3、5、10、50両などの額面がありました。文建て紙幣と併用され、交換は指定機関、地域ごとの割引、政府財政への信頼に左右されました。'
        sourceName = 'Wikipedia: Paper money of the Qing dynasty'
        sourceUrl = 'https://en.wikipedia.org/wiki/Paper_money_of_the_Qing_dynasty'
    }
    daqing = @{
        issuerZh = '大清银行'
        issuerJa = '大清銀行'
        zh = '大清银行于1905年设立，兼具中央银行与商业银行职能，是清廷统一币制、发行政府纸币的改革尝试。其纸币采用银两和银元两套计值体系，分行券反映晚清各地并行的货币与区域金融网络；具体版别以目录记录为准。'
        tw = '大清銀行於1905年設立，兼具中央銀行與商業銀行職能，是清廷統一幣制、發行政府紙幣的改革嘗試。其紙幣採用銀兩和銀元兩套計值體系，分行券反映晚清各地並行的貨幣與區域金融網絡；具體版別以目錄記錄為準。'
        en = 'Founded in 1905, the Da-Qing Bank combined central- and commercial-bank functions and represented a late-Qing attempt to unify currency and issue government notes. It issued both tael- and yuan-denominated series; branch issues reflect the period''s regional financial network and varied local currencies.'
        ja = '大清銀行は1905年に設立され、中央銀行と商業銀行の機能を兼ねました。通貨統一と政府紙幣発行を目指した清末の試みで、銀両建てと元建ての両方を発行しました。各支店券は、地域ごとに異なる通貨と金融網を反映しています。'
        sourceName = 'Wikipedia: Da-Qing Bank'
        sourceUrl = 'https://en.wikipedia.org/wiki/Da-Qing_Bank'
    }
    imperialBank = @{
        issuerZh = '中国通商银行（Imperial Bank of China）'
        issuerJa = '中国通商銀行'
        zh = '中国通商银行于1897年在上海开业，是中国较早采用现代公司组织和西式银行制度的本土银行。1898年起发行银两或银元计值的纸券，并在广州、北京、上海等地设分支；分行和币制差异是晚清纸币多元格局的一部分。'
        tw = '中國通商銀行於1897年在上海開業，是中國較早採用現代公司組織和西式銀行制度的本土銀行。1898年起發行銀兩或銀元計值的紙券，並在廣州、北京、上海等地設分支；分行和幣制差異是晚清紙幣多元格局的一部分。'
        en = 'The Imperial Bank of China opened in Shanghai in 1897 as an early Chinese-owned bank organized on modern, Western-style lines. From 1898 it issued notes denominated in taels or yuan and operated branches including Canton, Peking, and Shanghai, within the late-Qing landscape of multiple regional currencies.'
        ja = '中国通商銀行は1897年に上海で開業した、中国資本による初期の近代的な西洋式銀行です。1898年から銀両建てまたは元建ての紙幣を発行し、広州、北京、上海などに支店を置きました。複数の地域通貨が併存した清末の金融環境を背景としています。'
        sourceName = 'Wikipedia: Imperial Bank of China'
        sourceUrl = 'https://en.wikipedia.org/wiki/Imperial_Bank_of_China'
    }
    communications = @{
        issuerZh = '交通银行'
        issuerJa = '交通銀行'
        zh = '交通银行于1908年设立，早期与收回京汉铁路经营权的融资有关，也是发行近代中国纸币的本土银行之一。晚清各类银行券常以银元或地方通行货币计值；此系列的年份、分行、面额和具体版别依目录记录。'
        tw = '交通銀行於1908年設立，早期與收回京漢鐵路經營權的融資有關，也是發行近代中國紙幣的本土銀行之一。晚清各類銀行券常以銀元或地方通行貨幣計值；此系列的年份、分行、面額和具體版別依目錄記錄。'
        en = 'Founded in 1908, the Bank of Communications was initially connected with financing the recovery of the Beijing-Hankou Railway and became one of the domestic Chinese banks that issued modern banknotes. Late-Qing notes used yuan and other locally circulating units; the catalog records the issue date, branch, and denomination for this Pick.'
        ja = '交通銀行は1908年に設立され、当初は京漢鉄道の経営権回収に関わる資金調達と結び付いていました。近代紙幣を発行した中国の銀行の一つです。清末の紙幣には元のほか地域通貨も用いられ、この分類番号の発行年、支店、額面はカタログ記録に基づきます。'
        sourceName = 'Wikipedia: Bank of Communications'
        sourceUrl = 'https://en.wikipedia.org/wiki/Bank_of_Communications'
    }
    railway = @{
        issuerZh = '中国铁路发行机构'
        issuerJa = '中国の鉄道会社'
        zh = '清末铁路公司也曾发行纸券筹集和管理铁路相关资金。维基资料将1895年北洋铁路公司的银元券列为中国早期现代横式纸币之一；其后铁路分支发行券与银元计价并存于区域货币体系中。此Pick的分行、年份与面额以目录记录为准。'
        tw = '清末鐵路公司也曾發行紙券籌集和管理鐵路相關資金。維基資料將1895年北洋鐵路公司的銀元券列為中國早期現代橫式紙幣之一；其後鐵路分支發行券與銀元計價並存於區域貨幣體系中。此Pick的分行、年份與面額以目錄記錄為準。'
        en = 'Late-Qing railway companies also issued paper currency connected with railway finance. Wikipedia identifies the 1895 Beiyang railway-company dollar note as one of China''s early modern horizontal-format banknotes; later railway branch issues formed part of a regionally varied currency system.'
        ja = '清末には鉄道会社も鉄道事業の資金に関連する紙幣を発行しました。1895年の北洋鉄道会社ドル券は、中国初期の近代的な横型紙幣の一つとされています。その後の鉄道支店券も、地域ごとに異なる通貨制度の一部を成しました。'
        sourceName = 'Wikipedia: Paper money of the Qing dynasty'
        sourceUrl = 'https://en.wikipedia.org/wiki/Paper_money_of_the_Qing_dynasty'
    }
    regionalBank = @{
        issuerZh = '晚清地方商业银行'
        issuerJa = '清末の地方銀行'
        zh = '晚清现代银行、地方官办金融机构与传统钱庄并存，各地纸币使用银两、银元或制钱等不同单位，跨区域兑换并无单一标准。公开资料将此发行机构列入晚清中国银行体系，但没有说明该Pick的具体发行政策；本条仅结合可核对的目录信息提供时代背景。'
        tw = '晚清現代銀行、地方官辦金融機構與傳統錢莊並存，各地紙幣使用銀兩、銀元或制錢等不同單位，跨區域兌換並無單一標準。公開資料將此發行機構列入晚清中國銀行體系，但沒有說明該Pick的具體發行政策；本條僅結合可核對的目錄資訊提供時代背景。'
        en = 'Modern banks, provincial financial institutions, and traditional money shops coexisted in late-Qing China. Notes used different local units such as taels, dollars, or cash, with no single standard for exchange across regions. Public references place this issuer in the period''s banking system but do not document this Pick''s individual issue policy, so the note-specific details here are limited to the catalog record.'
        ja = '清末には近代銀行、地方金融機関、伝統的な銭荘が併存しました。紙幣には銀両、銀元、制銭など地域ごとに異なる単位が用いられ、地域間で統一された交換基準はありませんでした。公開資料はこの発行機関を当時の銀行制度に位置付けますが、個別の収録番号に関する発行方針は詳述していないため、ここでは確認できるカタログ情報に限定しています。'
        sourceName = 'Wikipedia: Paper money of the Qing dynasty'
        sourceUrl = 'https://en.wikipedia.org/wiki/Paper_money_of_the_Qing_dynasty'
    }
    centralReserve = @{
        issuerZh = '中央储备银行'
        issuerJa = '中央儲備銀行'
        zh = '中央储备银行是汪精卫政权在南京、上海设立的发钞银行，1940年成立、1941年开始营业，试图把占领区货币纳入日元区。战局变化后，市场信心减弱并出现严重贬值与通胀；不同年份的大面额发行体现了这一背景。'
        tw = '中央儲備銀行是汪精衛政權在南京、上海設立的發鈔銀行，1940年成立、1941年開始營業，試圖把佔領區貨幣納入日圓區。戰局變化後，市場信心減弱並出現嚴重貶值與通膨；不同年份的大面額發行體現了這一背景。'
        en = 'The Central Reserve Bank was the Wang Jingwei regime''s note-issuing bank, based in Nanjing and Shanghai. Formed in 1940 and operating from 1941, it sought to draw occupied areas into the yen zone. Confidence later weakened as the war turned, and the currency suffered severe depreciation and inflation.'
        ja = '中央儲備銀行は汪兆銘政権の発券銀行で、南京と上海を拠点としていました。1940年に設立され、1941年に営業を開始し、占領地域を円圏に組み込むことを目指しました。戦況の変化とともに信用は弱まり、通貨は大幅な下落とインフレに見舞われました。'
        sourceName = 'Wikipedia: Central Reserve Bank of China'
        sourceUrl = 'https://en.wikipedia.org/wiki/Central_Reserve_Bank_of_China'
    }
    federalReserve = @{
        issuerZh = '中国联合准备银行'
        issuerJa = '中国連合準備銀行'
        zh = '中国联合准备银行由日占华北的临时政府设立，1938年开始发行钞票，初期与国民政府法币等值；1939年日方禁止法币流通后，兑换关系被强制调整。1945年接收时的兑换率仍为5元联合准备银行券兑1元法币，显示其币值由占领当局政策左右。'
        tw = '中國聯合準備銀行由日佔華北的臨時政府設立，1938年開始發行鈔票，初期與國民政府法幣等值；1939年日方禁止法幣流通後，兌換關係被強制調整。1945年接收時的兌換率仍為5元聯合準備銀行券兌1元法幣，顯示其幣值由佔領當局政策左右。'
        en = 'The Federal Reserve Bank of China was established by the Japanese-backed Provisional Government in North China. Its notes began in 1938 at parity with Nationalist fabi; after fabi was banned in 1939, the occupation authorities imposed exchange terms. In 1945, five FRB yuan exchanged for one fabi.'
        ja = '中国連合準備銀行は、日本の支援を受けた華北臨時政府によって設立されました。1938年に発行を始めた紙幣は当初、国民政府の法幣と等価でしたが、1939年に法幣が禁止されると、占領当局が交換条件を定めました。1945年には連銀券5元が法幣1元に交換されました。'
        sourceName = 'Wikipedia: History of Chinese currency'
        sourceUrl = 'https://en.wikipedia.org/wiki/History_of_Chinese_currency'
    }
    huaxing = @{
        issuerZh = '华兴商业银行'
        issuerJa = '華興商業銀行'
        zh = '华兴商业银行于1938年在上海开业，是日方支持的中华民国维新政府辖区内的发钞银行，发行的货币在其控制地区流通。1939年华兴元与英镑挂钩；1941年中央储备银行成立后，华兴货币按规定比例兑换并退出发行。'
        tw = '華興商業銀行於1938年在上海開業，是日方支持的中華民國維新政府轄區內的發鈔銀行，發行的貨幣在其控制地區流通。1939年華興元與英鎊掛鉤；1941年中央儲備銀行成立後，華興貨幣按規定比例兌換並退出發行。'
        en = 'Huaxing Commercial Bank began operating in Shanghai in 1938 as the note-issuing bank of the Japanese-backed Reformed Government. Its currency was compelled to circulate in that government''s territory, was pegged to sterling in 1939, and was exchanged for Central Reserve Bank currency after that bank took over the monetary role in 1941.'
        ja = '華興商業銀行は1938年に上海で営業を開始し、日本の支援を受けた維新政府の発券銀行となりました。同政府の管轄地域で通貨の流通が強制され、1939年には英ポンドと連動しました。1941年に中央儲備銀行が通貨業務を引き継ぐと、華興元は同銀行券と交換されました。'
        sourceName = 'Wikipedia: Huaxing Commercial Bank'
        sourceUrl = 'https://en.wikipedia.org/wiki/Huaxing_Commercial_Bank'
    }
    mengjiang = @{
        issuerZh = '蒙疆银行'
        issuerJa = '蒙疆銀行'
        zh = '蒙疆银行发行的蒙疆元自1937年起在日本扶植的蒙疆政权辖区流通。早期察南银行先使用东北地方银行旧券加印，随后由蒙疆银行发行自己的纸币；币制包含分、角和元等单位，发行及使用延续至1945年。'
        tw = '蒙疆銀行發行的蒙疆元自1937年起在日本扶植的蒙疆政權轄區流通。早期察南銀行先使用東北地方銀行舊券加印，隨後由蒙疆銀行發行自己的紙幣；幣制包含分、角和元等單位，發行及使用延續至1945年。'
        en = 'The Mengjiang yuan circulated from 1937 in territories governed by the Japanese-backed Mengjiang administrations. The South Chahar Bank first overprinted older northeastern Chinese notes; the Bank of Mengjiang then issued its own currency in fen, jiao, and yuan denominations through 1945.'
        ja = '蒙疆元は1937年から日本の支援を受けた蒙疆政権の統治地域で流通しました。察南銀行が東北地方の旧紙幣に加刷して発行した後、蒙疆銀行が分、角、元建ての独自通貨を発行し、1945年まで続きました。'
        sourceName = 'Wikipedia: Mengjiang yuan'
        sourceUrl = 'https://en.wikipedia.org/wiki/Mengjiang_yuan'
    }
    chanan = @{
        issuerZh = '察南银行'
        issuerJa = '察南銀行'
        zh = '察南银行于1937年在張家口一帶成立，曾将东北地方银行1929年版旧券加印后发行；不久其发钞职能被蒙疆银行取代。此类地方券反映日占区内多个政权和银行各自发行货币、流通体系并未统一的状况。'
        tw = '察南銀行於1937年在張家口一帶成立，曾將東北地方銀行1929年版舊券加印後發行；不久其發鈔職能被蒙疆銀行取代。此類地方券反映日佔區內多個政權和銀行各自發行貨幣、流通體系並未統一的狀況。'
        en = 'The South Chahar Bank was established around Kalgan in 1937 and initially issued overprinted notes based on 1929 northeastern Chinese banknotes. The Bank of Mengjiang soon replaced it as issuer, illustrating the fragmented note systems in Japanese-occupied areas.'
        ja = '察南銀行は1937年に張家口周辺で設立され、当初は1929年発行の中国東北地方の紙幣に加刷して発行しました。その後まもなく蒙疆銀行が発券機能を引き継ぎました。日本占領地域で発券制度が分立していた状況を示す例です。'
        sourceName = 'Wikipedia: Mengjiang yuan'
        sourceUrl = 'https://en.wikipedia.org/wiki/Mengjiang_yuan'
    }
    manchukuo = @{
        issuerZh = '满洲中央银行'
        issuerJa = '満洲中央銀行'
        zh = '满洲中央银行于1932年成立并接收东北地区原有数家发钞银行的资产与货币发行职能，发行满洲国圆。新币最初以白银为本位，1935年脱离银本位并转与日元挂钩；战争后期出现较高面额，货币于1945年随政权终结而退出。'
        tw = '滿洲中央銀行於1932年成立並接收東北地區原有數家發鈔銀行的資產與貨幣發行職能，發行滿洲國圓。新幣最初以白銀為本位，1935年脫離銀本位並轉與日圓掛鉤；戰爭後期出現較高面額，貨幣於1945年隨政權終結而退出。'
        en = 'Established in 1932, the Central Bank of Manchou took over assets and note issuance from several existing northeastern banks and issued the Manchukuo yuan. The currency began on a silver basis, left the silver standard in 1935, and was pegged to the yen; higher denominations appeared late in the war before the currency ended in 1945.'
        ja = '満洲中央銀行は1932年に設立され、東北地方の既存銀行数行から資産と発券業務を引き継ぎ、満洲国圓を発行しました。当初は銀本位でしたが、1935年に離脱して円に連動しました。戦争末期には高額紙幣が発行され、1945年に通貨制度は終わりました。'
        sourceName = 'Wikipedia: Manchukuo yuan'
        sourceUrl = 'https://en.wikipedia.org/wiki/Manchukuo_yuan'
    }
}

 $managedSourceNames = @($profiles.Values | ForEach-Object { $_.sourceName } | Sort-Object -Unique)

function Get-ResearchProfile([string]$collectionId, [string]$issuer, [string]$pickNumber) {
    switch ($collectionId) {
        'china-empire' {
            if ($issuer -eq 'Treasury, Ming Dynasty') { return $profiles.ming }
            if ($issuer -match '^(Treasury of the Great Ch\x27ing|Treasury, Ch\x27ing Dynasty)$') { return $profiles.qingCash }
            if ($issuer -match '^Ministry of Interior and Finance, Ch\x27ing Dynasty$') {
                if ($pickNumber -match '^A[5-8]$') { return $profiles.qingCash }
                return $profiles.qingTael
            }
            if ($issuer -match '^Ta.?Ching Government Bank') { return $profiles.daqing }
            if ($issuer -match '^Imperial Bank of China') { return $profiles.imperialBank }
            if ($issuer -match '^General Bank of Communications') { return $profiles.communications }
            if ($issuer -match '^Imperial Chinese Railways') { return $profiles.railway }
            if ($issuer -in @('Ningpo Commercial Bank','Sin Chun Bank of China')) { return $profiles.regionalBank }
        }
        'china-japanese-puppet-banks' {
            if ($issuer -eq 'Central Reserve Bank of China') { return $profiles.centralReserve }
            if ($issuer -eq 'Federal Reserve Bank of China') { return $profiles.federalReserve }
            if ($issuer -eq 'Hua Hsing Commercial Bank') { return $profiles.huaxing }
            if ($issuer -match '^Mengchiang Bank') { return $profiles.mengjiang }
            if ($issuer -eq 'Chanan Bank') { return $profiles.chanan }
            if ($issuer -match '^Chi Tung Bank') { return $null }
        }
        'manchukuo' { return $profiles.manchukuo }
    }
    return $null
}

function ConvertTo-ChineseDenomination([string]$value) {
    $formatted = $value -replace '(?i)\s*\((?:Cash|Liang)\)', ''
    $formatted = $formatted -replace '(?<=\d)\.(?=\d{3}\b)', ','
    $formatted = $formatted -replace '(?i)\bDollars?\b', '元' -replace '(?i)\bYuan\b', '元'
    $formatted = $formatted -replace '(?i)\bCents?\b', '分' -replace '(?i)\bFen\b', '分'
    $formatted = $formatted -replace '(?i)\bChiao\b', '角' -replace '(?i)\bMace\b', '钱'
    $formatted = $formatted -replace '(?i)\bTaels?\b', '两' -replace '(?i)\bWen\b', '文'
    $formatted = $formatted -replace '(?i)\bCash\b', '文' -replace '\s+', ' '
    return $formatted.Trim()
}

$targetResearch = @($catalog.researchNotes | Where-Object collectionId -in $collectionIds)
function ConvertTo-JapaneseDenomination([string]$value) {
    $formatted = $value -replace '(?<=\d)\.(?=\d{3}\b)', ','
    $formatted = $formatted -replace '(?i)\s*\((?:Cash|Liang)\)', ''
    $formatted = $formatted -replace '(?i)\bDollars?\b', '元' -replace '(?i)\bYuan\b', '元' -replace '(?i)\bYen\b', '円'
    $formatted = $formatted -replace '(?i)\bCents?\b', '分' -replace '(?i)\bFen\b', '分' -replace '(?i)\b(?:Chiao|Jiao)\b', '角'
    $formatted = $formatted -replace '(?i)\b(?:Cash|Wen)\b', '文' -replace '(?i)\bKuan\b', '貫' -replace '(?i)\bMace\b', '銭'
    $formatted = $formatted -replace '(?i)\bTaels?\b', '両' -replace '(?i)\bRupees?\b', 'ルピー'
    return ($formatted -replace '(?<=\d)\s+(?=(?:元|分|角|円|文|貫|銭|両|ルピー))', '').Trim()
}

$preservedResearch = @($targetResearch | Where-Object {
    ($_.simplifiedDescription -or $_.traditionalDescription -or $_.englishDescription) -and
    $_.sourceName -notin $managedSourceNames
})
$preservedKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($note in $preservedResearch) {
    [void]$preservedKeys.Add(('{0}:{1}' -f $note.collectionId,$note.pickNumber))
}

$research = [System.Collections.Generic.List[object]]::new()
$unprofiled = [System.Collections.Generic.List[string]]::new()
foreach ($group in ($banknotes | Group-Object { '{0}:{1}' -f $_.collectionId,$_.pickNumber })) {
    $record = $group.Group[0]
    $key = '{0}:{1}' -f $record.collectionId,$record.pickNumber
    if ($preservedKeys.Contains($key)) { continue }

    $profile = Get-ResearchProfile $record.collectionId $record.issuer $record.pickNumber
    if ($null -eq $profile) {
        $unprofiled.Add($key)
        continue
    }

    $years = @($group.Group.year | Where-Object { $_ -and $_ -gt 0 } | Sort-Object -Unique)
    $yearZh = if ($years.Count) { $years -join '、' } else { '年代未详' }
    $yearEn = if ($years.Count) { $years -join '/' } else { 'date unknown' }
        $yearJa = if ($years.Count) { $years -join '・' } else { '年代不詳' }
    $denominationZh = ConvertTo-ChineseDenomination $record.denomination
    if (!$denominationZh) { $denominationZh = '面额见目录' }
    $denominationJa = ConvertTo-JapaneseDenomination $record.denomination
    if (!$denominationJa) { $denominationJa = '額面不詳' }
    $pickLabel = 'P-' + $record.pickNumber

    $research.Add([pscustomobject]@{
        collectionId = $record.collectionId
        pickNumber = $record.pickNumber
        simplifiedDescription = "$pickLabel（目录年份$yearZh，面额$denominationZh；发行机构：$($profile.issuerZh)）。$($profile.zh)"
        traditionalDescription = "$pickLabel（目錄年份$yearZh，面額$denominationZh；發行機構：$($profile.issuerZh)）。$($profile.tw)"
        englishDescription = "$pickLabel (catalog date $yearEn; denomination $($record.denomination); issuer: $($record.issuer)). $($profile.en)"
            japaneseDescription = "$pickLabel（記録年$yearJa、額面$denominationJa、発行機関：$($profile.issuerJa)）。$($profile.ja)"
        tags = @()
        sourceName = $profile.sourceName
        sourceUrl = $profile.sourceUrl
    })
}

$unexpectedUnprofiled = @($unprofiled | Where-Object { $_ -notmatch '^china-japanese-puppet-banks:.*$' })
if ($unexpectedUnprofiled.Count) {
    throw "No public-source profile for: $($unexpectedUnprofiled -join ', ')"
}

$expectedMissingCount = @($banknotes | Group-Object { '{0}:{1}' -f $_.collectionId,$_.pickNumber } | Where-Object {
    $key = '{0}:{1}' -f $_.Group[0].collectionId,$_.Group[0].pickNumber
    -not $preservedKeys.Contains($key)
}).Count
if ($research.Count + $unprofiled.Count -ne $expectedMissingCount) {
    throw "Coverage mismatch: generated $($research.Count), left $($unprofiled.Count) unprofiled, expected $expectedMissingCount missing Pick groups."
}

$otherResearch = @($catalog.researchNotes | Where-Object collectionId -notin $collectionIds)
$catalog.researchNotes = @($otherResearch) + @($preservedResearch) + @($research.ToArray())
$json = ConvertTo-Json -InputObject $catalog -Depth 30
[System.IO.File]::WriteAllText($catalogPath, $json, [System.Text.UTF8Encoding]::new($false))

Write-Output "Refreshed $($research.Count) Wikipedia-based descriptions across $($collectionIds.Count) China collections."
Write-Output "Left $($unprofiled.Count) Pick groups without analysis because no sufficiently specific public source was found."
$unprofiled | ForEach-Object { Write-Output "  $_" }