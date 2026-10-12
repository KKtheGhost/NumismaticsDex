[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path $PSScriptRoot -Parent
$catalogPath = Join-Path $repositoryRoot 'NumismaticsDex.App\Assets\catalog.json'
$collectionId = 'japan-nippon-ginko'
$catalog = Get-Content $catalogPath -Raw | ConvertFrom-Json
$banknotes = @($catalog.banknotes | Where-Object { $_.collectionId -eq $collectionId })
if ($banknotes.Count -eq 0) {
    throw "No banknotes found for collection '$collectionId'. Import the collection first."
}

$profiles = @{
    silverFirst = @{
        zh = '日本银行最初一批纸币依据1884年《兌換银行券条例》发行，处于银本位时期，票面承诺按面额兑换银币。首批面额自1885年起陆续发行；早期券的纸张与防伪设计问题促成后续改版。'
        tw = '日本銀行最初一批紙幣依據1884年《兌換銀行券條例》發行，處於銀本位時期，票面承諾按面額兌換銀幣。首批面額自1885年起陸續發行；早期券的紙張與防偽設計問題促成後續改版。'
        en = 'Among the Bank of Japan''s first note issues, these were convertible into silver under the silver standard. The first denominations appeared from 1885; problems with early paper and anti-counterfeiting design led to later revisions.'
        ja = '日本銀行の初期紙幣の一部は銀本位制の下で銀貨と交換可能でした。最初の額面は1885年から発行されました。初期紙幣の用紙や偽造防止設計に問題があり、後の改版につながりました。'
        tags = @('silver-standard','silver-convertible')
    }
    silverRedesign = @{
        zh = '改造型日本银行银兑券承接早期发行，调整了人物肖像与券面设计，并采用水印等防伪手段。对应面额的维基条目将改版与旧券易损、变色及伪造问题联系起来。'
        tw = '改造型日本銀行銀兌券承接早期發行，調整了人物肖像與券面設計，並採用水印等防偽手段。對應面額的維基條目將改版與舊券易損、變色及偽造問題聯繫起來。'
        en = 'This redesigned Bank of Japan silver-convertible issue followed the early notes, revising portraits and layouts and using watermarks among its security measures. The denomination articles connect the redesigns with durability, discoloration, and counterfeiting problems in earlier notes.'
        ja = 'この改造銀兌換券は初期紙幣を引き継ぎ、肖像と券面構成を改め、透かしなどの偽造防止策を採用しました。各額面の解説では、旧券の耐久性、変色、偽造問題が改版の背景として挙げられています。'
        tags = @('silver-convertible','modified-issue','anti-counterfeiting')
    }
    taishoSilver = @{
        zh = '1916年大正时期的一日元银券。维基面额条目将其列为采用阿拉伯数字流水号的变体，并置于第一次世界大战期间纸币需求上升、辅币短缺的背景中。'
        tw = '1916年大正時期的一日圓銀券。維基面額條目將其列為採用阿拉伯數字流水號的變體，並置於第一次世界大戰期間紙幣需求上升、輔幣短缺的背景中。'
        en = 'A 1916 Taishō-era one-yen silver note. The denomination article identifies an Arabic-serial-number variety and places the issue amid rising banknote demand and subsidiary-coin shortages during World War I.'
        ja = '1916年の大正期に発行された1円銀兌換券です。額面別資料はアラビア数字の通し番号を持つ版を記録しており、第一次世界大戦中の紙幣需要増と補助貨幣不足の時期に位置付けています。'
        tags = @('silver-convertible','taisho-era')
    }
    earlyGold = @{
        zh = '日本1897年转向金本位后，银行券的兑付基础由银转为金。这些发行于明治末期至大正初期的券种记录了日本银行金兑换券体系及不同面额的更替。'
        tw = '日本1897年轉向金本位後，銀行券的兌付基礎由銀轉為金。這些發行於明治末期至大正初期的券種記錄了日本銀行金兌換券體系及不同面額的更替。'
        en = 'After Japan adopted the gold standard in 1897, the basis for redeeming notes shifted from silver to gold. These late-Meiji and early-Taishō issues document the Bank of Japan gold-convertible system across changing denominations.'
        ja = '日本が1897年に金本位制へ移行した後、紙幣の兌換基準は銀から金に変わりました。明治末期から大正初期のこれらの券種は、日本銀行の金兌換券制度と額面の変遷を記録しています。'
        tags = @('gold-standard','gold-convertible')
    }
    watermarkGold = @{
        zh = '1910年发行的五金元券属于金兑换券。五日元券的维基条目记载，此次改版采用专门的水印区域及更复杂的底纹，以回应摄影复制带来的伪造风险。'
        tw = '1910年發行的五金圓券屬於金兌換券。五日圓券的維基條目記載，此次改版採用專門的水印區域及更複雜的底紋，以回應攝影複製帶來的偽造風險。'
        en = 'The 1910 five-gold-yen note was a gold-convertible issue. The five-yen article describes a designated watermark area and more complex patterns introduced as photographic reproduction increased counterfeiting risks.'
        ja = '1910年発行の5円金兌換券です。額面別資料によれば、写真複製による偽造リスクの高まりに対応するため、専用の透かし部分と複雑な地紋が採用されました。'
        tags = @('gold-standard','gold-convertible','anti-counterfeiting')
    }
    taishoGold = @{
        zh = '大正时期发行的金兑换券延续了金本位下的银行券制度。第一次世界大战带来纸币需求变化，而日本于1917年停止金输出，实际兑金条件随之受限。'
        tw = '大正時期發行的金兌換券延續了金本位下的銀行券制度。第一次世界大戰帶來紙幣需求變化，而日本於1917年停止金輸出，實際兌金條件隨之受限。'
        en = 'These Taishō-era gold-convertible notes continued the banknote system under the gold standard. World War I changed demand for paper currency, while Japan suspended gold exports in 1917, limiting practical redemption.'
        ja = '大正期の金兌換券は金本位制下の紙幣制度を引き継ぎました。第一次世界大戦で紙幣需要が変化し、日本は1917年に金輸出を停止したため、実際の金兌換は制限されました。'
        tags = @('gold-standard','gold-convertible','taisho-era')
    }
    emergency200First = @{
        zh = '1927年昭和金融恐慌期间发行的二百日元应急券。日本银行需要迅速准备可供银行间兑换的纸币，首期赶印券省略背面印刷，因而有“裏白”之称。'
        tw = '1927年昭和金融恐慌期間發行的二百日圓應急券。日本銀行需要迅速準備可供銀行間兌換的紙幣，首期趕印券省略背面印刷，因而有「裏白」之稱。'
        en = 'An emergency ¥200 note issued during the 1927 Shōwa financial crisis. The Bank of Japan needed notes quickly for interbank exchange; the first hurried issue omitted reverse printing and became known as the blank-back note.'
        ja = '1927年の昭和金融恐慌時に発行された200円の緊急券です。日本銀行は銀行間交換用紙幣を急いで準備し、最初の急造券は裏面印刷を省略したため「裏白」と呼ばれました。'
        tags = @('emergency-issue','showa-era')
    }
    emergency200Later = @{
        zh = '同属1927年昭和金融恐慌应急发行的二百日元券。后续设计在背面加入红色图案；其中部分券曾留存在日本银行库房，至1945年才开始实际流通，兑金文句当时已过时。'
        tw = '同屬1927年昭和金融恐慌應急發行的二百日圓券。後續設計在背面加入紅色圖案；其中部分券曾留存在日本銀行庫房，至1945年才開始實際流通，兌金文句當時已過時。'
        en = 'A later ¥200 design from the 1927 emergency issue added a red reverse pattern. Some notes remained in Bank of Japan vaults until 1945, by which time their gold-convertibility wording was obsolete.'
        ja = '1927年の緊急発行に属する後続の200円券では、裏面に赤色の図柄が加わりました。一部は日本銀行の保管庫に残され、1945年になってから流通を始めた時点では、金兌換の文言はすでに実効性を失っていました。'
        tags = @('emergency-issue','showa-era')
    }
    prewarRenewal = @{
        zh = '1930至1931年的改版券处于日本短暂恢复金本位及其后转向管理通货制度的时期。背面的英文面额是该批目录所标识的版式特征；1931年金兑换停止后，兑金承诺不再具有实际效力。'
        tw = '1930至1931年的改版券處於日本短暫恢復金本位及其後轉向管理通貨制度的時期。背面的英文面額是該批目錄所標識的版式特徵；1931年金兌換停止後，兌金承諾不再具有實際效力。'
        en = 'These 1930–1931 redesigns appeared during Japan''s brief return to the gold standard and its subsequent move toward managed currency. English denominations on the reverse identify this cataloged layout; gold redemption was suspended in 1931.'
        ja = '1930〜1931年の改版券は、日本が短期間金本位制に復帰した後、管理通貨制度へ移る時期に登場しました。裏面の英語額面はこのカタログ記載版の特徴です。1931年の金兌換停止後、兌換の約束は実質的な効力を失いました。'
        tags = @('gold-standard','gold-convertible','managed-currency')
    }
    wartimeTransition = @{
        zh = '1942年《日本银行法》正式停止金兑换，日本银行转向发行不兑换纸币。此组涵盖战争时期的高面额改版及1945年前后的发行，反映战时金融制度和制钞需求变化。'
        tw = '1942年《日本銀行法》正式停止金兌換，日本銀行轉向發行不兌換紙幣。此組涵蓋戰爭時期的高面額改版及1945年前後的發行，反映戰時金融制度和製鈔需求變化。'
        en = 'The 1942 Bank of Japan Act formally ended gold convertibility and the bank issued inconvertible notes. This group covers wartime high-denomination redesigns and issues around 1945, reflecting changes in monetary policy and production needs.'
        ja = '1942年の日本銀行法により金兌換が正式に終了し、日本銀行は不換紙幣を発行するようになりました。このグループには戦時中の高額券の改版と1945年前後の発行券が含まれ、金融制度と紙幣製造需要の変化を反映しています。'
        tags = @('managed-currency','wartime-note')
    }
    firstIssue = @{
        zh = '日本银行1942年改组后发行的第一号券，属于不兑换纸币。维基面额条目记载，战时物资与人手紧张促使印制流程和图案简化，部分后期变体省略流水号。'
        tw = '日本銀行1942年改組後發行的第一號券，屬於不兌換紙幣。維基面額條目記載，戰時物資與人手緊張促使印製流程和圖案簡化，部分後期變體省略流水號。'
        en = 'Part of the First Issue series introduced after the Bank of Japan was reorganized in 1942, these were inconvertible notes. Denomination articles describe wartime material and labor shortages that simplified production; some later varieties omitted serial numbers.'
        ja = '1942年の日本銀行再編後に導入された第一号券シリーズの一部で、不換紙幣です。額面別資料によれば、戦時の資材・人手不足で製造工程や図柄が簡略化され、後期の一部の版では通し番号が省略されました。'
        tags = @('first-issue-series','managed-currency','wartime-note')
    }
    warEndIssues = @{
        zh = '1945年前后的战争末期发行券，属于日本银行不兑换纸币体系。高面额券与简化版式对应战时及战后初期的支付压力；不同Pick项并非同一版式。'
        tw = '1945年前後的戰爭末期發行券，屬於日本銀行不兌換紙幣體系。高面額券與簡化版式對應戰時及戰後初期的支付壓力；不同Pick項並非同一版式。'
        en = 'Issued near the end of World War II, these notes belong to the Bank of Japan inconvertible-currency period. High denominations and simplified layouts reflect wartime and immediate postwar payment pressures; the individual Pick entries are distinct designs.'
        ja = '第二次世界大戦末期に発行された、日本銀行の不換紙幣です。高額面や簡略化された券面は、戦時および終戦直後の支払需要を反映しています。各収録番号はそれぞれ異なる図案です。'
        tags = @('managed-currency','wartime-note')
    }
    stampRevalidation = @{
        zh = '1946年新圆切替期间，为弥补新券供应不足，部分旧券贴附证纸后暂作新币使用。此类记录应理解为旧券经贴证重新认可的过渡形态，而非普通新设计纸币。'
        tw = '1946年新圓切換期間，為彌補新券供應不足，部分舊券貼附證紙後暫作新幣使用。此類記錄應理解為舊券經貼證重新認可的過渡形態，而非普通新設計紙幣。'
        en = 'During the 1946 new-yen conversion, old notes bearing validation stamps temporarily supplemented the shortage of new notes. These are revalidated transitional notes, not ordinary newly designed banknotes.'
        ja = '1946年の新円切替時、新券不足を補うため、旧紙幣に証紙を貼って一時的に使用しました。これらは新規デザインの通常紙幣ではなく、証紙によって再認証された移行期の紙幣です。'
        tags = @('postwar-reform','special-stamp')
    }
    seriesA = @{
        zh = '战后新圆切替推动A号券发行，用新币纸券替换旧币并应对恶性通胀。日本银行券维基条目指出，战后物资条件限制了纸张与印制质量，部分早期券防伪能力较弱。'
        tw = '戰後新圓切換推動A號券發行，用新幣紙券替換舊幣並應對惡性通膨。日本銀行券維基條目指出，戰後物資條件限制了紙張與印製品質，部分早期券防偽能力較弱。'
        en = 'Series A notes supplied the new-yen currency during the postwar conversion and high inflation. The Japanese Wikipedia article notes that postwar material constraints affected paper and print quality, leaving some early notes with weaker security.'
        ja = '戦後の新円切替と高インフレに対応するため、A号券が新円紙幣を供給しました。戦後の資材不足が用紙と印刷品質に影響し、初期券の一部では偽造防止力が弱かったとされています。'
        tags = @('series-a','postwar-reform')
    }
    seriesB = @{
        zh = 'B号券自1950年起分面额发行，承接战后新币制度并扩展较高面额。具体券面以人物肖像和历史建筑为主，发行年份与图案依面额而异。'
        tw = 'B號券自1950年起分面額發行，承接戰後新幣制度並擴展較高面額。具體券面以人物肖像和歷史建築為主，發行年份與圖案依面額而異。'
        en = 'Series B notes were introduced by denomination from 1950, extending the postwar currency system to higher values. Portraits and historic architecture feature on the notes; issue dates and designs vary by denomination.'
        ja = 'B号券は1950年から額面ごとに発行され、戦後の通貨制度を高額面へ拡張しました。肖像や歴史的建造物が図案に採用され、発行年と図柄は額面によって異なります。'
        tags = @('series-b','postwar-reform')
    }
    seriesC = @{
        zh = 'C号券自1957年起陆续发行，扩充五千、一万及后续五百、一千日元面额。此时期以肖像、银行建筑和名胜图案为主，并逐步更新水印等防伪设计。'
        tw = 'C號券自1957年起陸續發行，擴充五千、一萬及後續五百、一千日圓面額。此時期以肖像、銀行建築和名勝圖案為主，並逐步更新水印等防偽設計。'
        en = 'Series C began in 1957 and introduced ¥5,000 and ¥10,000 notes, followed by ¥500 and ¥1,000 issues. Portraits, bank architecture, and landmarks feature in the designs, alongside updated watermark security.'
        ja = 'C号券は1957年に発行を開始し、5,000円券と10,000円券、その後500円券と1,000円券を追加しました。肖像、銀行建築、名所を描き、透かしによる偽造防止策も更新されました。'
        tags = @('series-c','anti-counterfeiting')
    }
    seriesD = @{
        zh = 'D号券自1984年改版发行，以近代日本人物肖像为主。水印、微缩文字及触觉识别标记等防伪和无障碍设计随面额逐步采用。'
        tw = 'D號券自1984年改版發行，以近代日本人物肖像為主。水印、微縮文字及觸覺識別標記等防偽和無障礙設計隨面額逐步採用。'
        en = 'Series D began its redesign in 1984, featuring portraits of modern Japanese figures. Watermarks, microprinting, and tactile denomination marks were introduced across the series.'
        ja = 'D号券は1984年に改版が始まり、近代日本の人物を肖像に採用しました。シリーズ全体に透かし、マイクロ文字、触って分かる額面識別マークが導入されました。'
        tags = @('series-d','anti-counterfeiting')
    }
    seriesDMini = @{
        zh = 'D号券的1993年小改版延续原有肖像与主题，同时调整流水号颜色并强化防伪细节。目录所列后续日期对应改版/印次差异，不代表新的系列编号。'
        tw = 'D號券的1993年小改版延續原有肖像與主題，同時調整流水號顏色並強化防偽細節。目錄所列後續日期對應改版／印次差異，不代表新的系列編號。'
        en = 'The 1993 mini-revision of Series D retained its portraits and themes while changing serial-number colors and security details. Later catalog dates represent revised printings, not a new series letter.'
        ja = '1993年のD号券小改版は肖像と主題を維持しつつ、通し番号の色と偽造防止上の細部を変更しました。後年のカタログ年は新しいシリーズ記号ではなく、改版印刷を示します。'
        tags = @('series-d','modified-issue','anti-counterfeiting')
    }
    twoThousand = @{
        zh = '二千日元D号券于2000年7月19日发行，图案包括冲绳守礼门、源氏物语绘卷及紫式部。它与千禧年和冲绳G8峰会有关，但维基明确说明该券并非纪念钞，而是按一般流通券发行。'
        tw = '二千日圓D號券於2000年7月19日發行，圖案包括沖繩守禮門、源氏物語繪卷及紫式部。它與千禧年和沖繩G8峰會有關，但維基明確說明該券並非紀念鈔，而是按一般流通券發行。'
        en = 'The ¥2,000 Series D note was issued on 19 July 2000. Its design combines the Shureimon gate in Okinawa with The Tale of Genji and Murasaki Shikibu. It marked the millennium and Okinawa G8 summit, but Wikipedia explicitly classifies it as a regular circulating note, not a commemorative banknote.'
        ja = '2,000円D号券は2000年7月19日に発行されました。沖縄の守礼門と『源氏物語』、紫式部を組み合わせた図案です。ミレニアムと沖縄G8サミットに合わせて発行されましたが、ウィキペディアは記念紙幣ではなく通常流通紙幣に分類しています。'
        tags = @('series-d','two-thousand-yen','general-circulation','g8-summit')
    }
    seriesE = @{
        zh = 'E号券于2004年开始发行，千元、五千元和一万元券采用不同人物及文化图案，并加入欧元环等防伪设计。其系列身份与之后的2024年F号券不同。'
        tw = 'E號券於2004年開始發行，千圓、五千圓和一萬圓券採用不同人物及文化圖案，並加入歐元環等防偽設計。其系列身份與之後的2024年F號券不同。'
        en = 'Series E began in 2004 with distinct portraits and cultural motifs across the ¥1,000, ¥5,000, and ¥10,000 notes. The series incorporated anti-counterfeiting features including the EURion constellation and is distinct from 2024 Series F.'
        ja = 'E号券は2004年に発行され、1,000円、5,000円、10,000円券に異なる肖像と文化的図案を採用しました。ユーロ記号模様などの偽造防止機能を取り入れ、2024年発行のF号券とは別のシリーズです。'
        tags = @('series-e','anti-counterfeiting')
    }
    seriesF = @{
        zh = 'F号券于2024年7月3日发行，采用新的历史人物与文化图案，并引入高精细水印和三维全息等防伪技术。此版首次在票面以英文标示“BANK OF JAPAN”。'
        tw = 'F號券於2024年7月3日發行，採用新的歷史人物與文化圖案，並引入高精細水印和三維全息等防偽技術。此版首次在票面以英文標示「BANK OF JAPAN」。'
        en = 'Series F entered circulation on 3 July 2024 with new historical portraits and cultural motifs, high-definition watermarks, and 3D holograms. It was the first Japanese series to print “BANK OF JAPAN” in English on the notes.'
        ja = 'F号券は2024年7月3日に流通を開始し、新しい歴史上の人物と文化的図案、高精細透かし、立体ホログラムを採用しました。紙幣に英語で「BANK OF JAPAN」と印刷した初の日本紙幣シリーズです。'
        tags = @('series-f','anti-counterfeiting')
    }
}

$designs = @{
    '22' = @{ zh='一日元券正面以大黑天为主题。'; tw='一日圓券正面以大黑天為主題。'; en='The one-yen note features Daikokuten on the obverse.' }
    '23' = @{ zh='五日元券将大黑天置于背面圆形图案中。'; tw='五日圓券將大黑天置於背面圓形圖案中。'; en='The five-yen note places Daikokuten in a circular reverse design.' }
    '24' = @{ zh='十日元券正面采用大黑天图像。'; tw='十日圓券正面採用大黑天圖像。'; en='The ten-yen note features Daikokuten on the obverse.' }
    '25' = @{ zh='百日元券属于早期大黑天主题发行。'; tw='百日圓券屬於早期大黑天主題發行。'; en='The ¥100 note belongs to the early Daikokuten-themed issue.' }
    '26' = @{ zh='一日元改造券以武内宿祢为肖像，并以一日元银币图案呼应兑银属性。'; tw='一日圓改造券以武內宿禰為肖像，並以一日圓銀幣圖案呼應兌銀屬性。'; en='The redesigned one-yen note portrays Takenouchi no Sukune and shows a silver one-yen coin, reflecting its silver-convertible status.' }
    '27' = @{ zh='五日元改造券以菅原道真为肖像，背面保留银兑文字。'; tw='五日圓改造券以菅原道真為肖像，背面保留銀兌文字。'; en='The redesigned five-yen note portrays Sugawara no Michizane and retains silver-redemption wording on the reverse.' }
    '28' = @{ zh='十日元改造券以和气清麻吕为肖像，图案含野猪主题。'; tw='十日圓改造券以和氣清麻呂為肖像，圖案含野豬主題。'; en='The redesigned ten-yen note portrays Wake no Kiyomaro and includes a wild-boar motif.' }
    '29' = @{ zh='百日元改造券以藤原镰足为肖像，是大黑天券之后的改版。'; tw='百日圓改造券以藤原鎌足為肖像，是大黑天券之後的改版。'; en='The redesigned ¥100 note portrays Fujiwara no Kamatari, replacing the earlier Daikokuten design.' }
    '34' = @{ zh='五日元券采用水印专用留白区，背面以菅原道真相关图案强化辨识。'; tw='五日圓券採用水印專用留白區，背面以菅原道真相關圖案強化辨識。'; en='The five-yen issue used a dedicated watermark area and a reverse design associated with Sugawara no Michizane.' }
    '37B' = @{ zh='首期券为仓促印制的单面设计，背面留白。'; tw='首期券為倉促印製的單面設計，背面留白。'; en='The first issue was hurriedly printed on one side, leaving the reverse blank.' }
    '38' = @{ zh='后续变体在背面增加红色纹样；部分券留存库房至战后才投入流通。'; tw='後續變體在背面增加紅色紋樣；部分券留存庫房至戰後才投入流通。'; en='A later variety added a red reverse pattern; some notes remained in storage until after the war.' }
    '39' = @{ zh='五日元券以菅原道真和北野天满宫为主题。'; tw='五日圓券以菅原道真和北野天滿宮為主題。'; en='The five-yen note features Sugawara no Michizane and Kitano Tenmangū.' }
    '40' = @{ zh='十日元券以和气清麻吕及野猪图案为主题。'; tw='十日圓券以和氣清麻呂及野豬圖案為主題。'; en='The ten-yen note features Wake no Kiyomaro and a wild-boar motif.' }
    '42' = @{ zh='百日元券以圣德太子为肖像，背面为法隆寺。'; tw='百日圓券以聖德太子為肖像，背面為法隆寺。'; en='The ¥100 note features Prince Shōtoku and Hōryū-ji on the reverse.' }
    '45' = @{ zh='一千日元券采用日本武尊肖像及建部大社图案。'; tw='一千日圓券採用日本武尊肖像及建部大社圖案。'; en='The ¥1,000 note features Yamato Takeru and Takebe Taisha.' }
    '49' = @{ zh='第一号券一日元版以武内宿祢为正面主题，背面为宇倍神社。'; tw='第一號券一日圓版以武內宿禰為正面主題，背面為宇倍神社。'; en='The First Issue ¥1 note features Takenouchi no Sukune and Ube Shrine.' }
    '50' = @{ zh='第一号券五日元版以菅原道真和北野天满宫为主题。'; tw='第一號券五日圓版以菅原道真和北野天滿宮為主題。'; en='The First Issue ¥5 note features Sugawara no Michizane and Kitano Tenmangū.' }
    '51' = @{ zh='此十日元券承接战时改版，保留和气清麻吕及护王神社题材。'; tw='此十日圓券承接戰時改版，保留和氣清麻呂及護王神社題材。'; en='This wartime ten-yen issue continues the Wake no Kiyomaro and Gōō Shrine design theme.' }
    '57' = @{ zh='百日元券采用圣德太子及法隆寺图案；目录变体说明还提示不同印次。'; tw='百日圓券採用聖德太子及法隆寺圖案；目錄變體說明還提示不同印次。'; en='The ¥100 note uses the Prince Shōtoku and Hōryū-ji design; the catalog also distinguishes print varieties.' }
    '78A' = @{ zh='百日元券以圣德太子为肖像，背面为法隆寺图案。'; tw='百日圓券以聖德太子為肖像，背面為法隆寺圖案。'; en='The ¥100 note features Prince Shōtoku and Hōryū-ji on the reverse.' }
    '85' = @{ zh='A号一日元券以二宫尊德为肖像，采用彩色底纹；战后初期券面安全性较弱。'; tw='A號一日圓券以二宮尊德為肖像，採用彩色底紋；戰後初期券面安全性較弱。'; en='The Series A ¥1 note portrays Ninomiya Sontoku over a colored pattern; early postwar production had weaker security.' }
    '86' = @{ zh='A号五日元券以彩色纹样为主要设计特征。'; tw='A號五日圓券以彩色紋樣為主要設計特徵。'; en='The Series A ¥5 note is distinguished by its colored pattern design.' }
    '89' = @{ zh='A号百日元券以板垣退助为肖像，是新圆切替时期的百元纸券。'; tw='A號百日圓券以板垣退助為肖像，是新圓切換時期的百圓紙券。'; en='The Series A ¥100 note portrays Itagaki Taisuke and belongs to the postwar new-yen conversion.' }
    '90' = @{ zh='B号百日元券以板垣退助为肖像。'; tw='B號百日圓券以板垣退助為肖像。'; en='The Series B ¥100 note features Itagaki Taisuke.' }
    '91' = @{ zh='B号五百日元券以岩仓具视为肖像，背面为富士山景观。'; tw='B號五百日圓券以岩倉具視為肖像，背面為富士山景觀。'; en='The Series B ¥500 note features Iwakura Tomomi and a Mount Fuji view.' }
    '92' = @{ zh='B号一千日元券以圣德太子为肖像，背面为法隆寺梦殿。'; tw='B號一千日圓券以聖德太子為肖像，背面為法隆寺夢殿。'; en='The Series B ¥1,000 note features Prince Shōtoku and the Hall of Dreams at Hōryū-ji.' }
    '93' = @{ zh='C号五千日元券以圣德太子和日本银行本店为主题。'; tw='C號五千日圓券以聖德太子和日本銀行本店為主題。'; en='The Series C ¥5,000 note features Prince Shōtoku and the Bank of Japan headquarters.' }
    '94' = @{ zh='C号一万日元券以圣德太子和京都平等院凤凰堂图案为主题。'; tw='C號一萬日圓券以聖德太子和京都平等院鳳凰堂圖案為主題。'; en='The Series C ¥10,000 note features Prince Shōtoku and the Phoenix Hall at Byōdō-in.' }
    '95' = @{ zh='C号五百日元券延续岩仓具视肖像及富士山背面图案，并更新水印。'; tw='C號五百日圓券延續岩倉具視肖像及富士山背面圖案，並更新水印。'; en='The Series C ¥500 note retains Iwakura Tomomi and Mount Fuji imagery, with an updated watermark.' }
    '96' = @{ zh='C号一千日元券以伊藤博文为肖像，背面为日本银行本店。'; tw='C號一千日圓券以伊藤博文為肖像，背面為日本銀行本店。'; en='The Series C ¥1,000 note features Itō Hirobumi and the Bank of Japan headquarters.' }
    '97' = @{ zh='D号一千日元券以夏目漱石为肖像，背面为丹顶鹤。'; tw='D號一千日圓券以夏目漱石為肖像，背面為丹頂鶴。'; en='The Series D ¥1,000 note features Natsume Sōseki and red-crowned cranes.' }
    '98' = @{ zh='D号五千日元券以新渡户稻造为肖像，背面为富士山与本栖湖景观。'; tw='D號五千日圓券以新渡戶稻造為肖像，背面為富士山與本栖湖景觀。'; en='The Series D ¥5,000 note features Nitobe Inazō and Mount Fuji over Lake Motosu.' }
    '99' = @{ zh='D号一万日元券以福泽谕吉为肖像，背面为雉鸡。'; tw='D號一萬日圓券以福澤諭吉為肖像，背面為雉雞。'; en='The Series D ¥10,000 note features Fukuzawa Yukichi and green pheasants.' }
    '100' = @{ zh='D号一千日元改版延续夏目漱石和丹顶鹤图案，流水号颜色变化对应不同印次。'; tw='D號一千日圓改版延續夏目漱石和丹頂鶴圖案，流水號顏色變化對應不同印次。'; en='This revised Series D ¥1,000 retains Natsume Sōseki and red-crowned cranes; serial-number color distinguishes print revisions.' }
    '101' = @{ zh='D号五千日元改版保留新渡户稻造及富士山、本栖湖图案，并改进识别与防伪细节。'; tw='D號五千日圓改版保留新渡戶稻造及富士山、本栖湖圖案，並改進識別與防偽細節。'; en='The revised Series D ¥5,000 retains Nitobe Inazō and Mount Fuji/Lake Motosu imagery, with updated identification and security details.' }
    '102' = @{ zh='D号一万日元改版延续福泽谕吉和雉鸡图案，并调整流水号颜色及防伪细节。'; tw='D號一萬日圓改版延續福澤諭吉和雉雞圖案，並調整流水號顏色及防偽細節。'; en='The revised Series D ¥10,000 retains Fukuzawa Yukichi and green pheasants, with serial-color and security updates.' }
    '104' = @{ zh='E号一千日元券以野口英世为肖像，背面采用富士山与樱花图案。'; tw='E號一千日圓券以野口英世為肖像，背面採用富士山與櫻花圖案。'; en='The Series E ¥1,000 features Hideyo Noguchi and Mount Fuji with cherry blossoms.' }
    '105' = @{ zh='E号五千日元券以樋口一叶为肖像，背面图案取材于尾形光琳《燕子花图》。'; tw='E號五千日圓券以樋口一葉為肖像，背面圖案取材於尾形光琳《燕子花圖》。'; en='The Series E ¥5,000 features Ichiyō Higuchi and irises based on the Irises screen by Ogata Kōrin.' }
    '106' = @{ zh='E号一万日元券延续福泽谕吉肖像，背面回归平等院凤凰堂凤凰像。'; tw='E號一萬日圓券延續福澤諭吉肖像，背面回歸平等院鳳凰堂鳳凰像。'; en='The Series E ¥10,000 retains Fukuzawa Yukichi and returns the Byōdō-in Phoenix Hall design to the reverse.' }
    'W107' = @{ zh='F号一千日元券以北里柴三郎和葛饰北斋《神奈川冲浪里》为主题。'; tw='F號一千日圓券以北里柴三郎和葛飾北齋《神奈川沖浪裏》為主題。'; en='The Series F ¥1,000 features Kitasato Shibasaburō and the Hokusai print The Great Wave off Kanagawa.' }
    'W108' = @{ zh='F号五千日元券以津田梅子和藤花为主题。'; tw='F號五千日圓券以津田梅子和藤花為主題。'; en='The Series F ¥5,000 features Tsuda Umeko and wisteria flowers.' }
    'W109' = @{ zh='F号一万日元券以涩泽荣一和东京站丸之内站舍为主题。'; tw='F號一萬日圓券以澀澤榮一和東京站丸之內站舍為主題。'; en='The Series F ¥10,000 features Shibusawa Eiichi and the Marunouchi building at Tokyo Station.' }
}

    $designsJa = @{
        '22' = '1円券の表面には大黒天が描かれています。'
        '23' = '5円券の裏面には、円形の図案の中に大黒天が描かれています。'
        '24' = '10円券の表面には大黒天が描かれています。'
        '25' = '100円券は初期の大黒天図案のシリーズです。'
        '26' = '改造1円券は武内宿禰の肖像を採用し、銀兌換券であることを示すように1円銀貨も描いています。'
        '27' = '改造5円券は菅原道真を描き、裏面には銀兌換の文言が残されています。'
        '28' = '改造10円券は和気清麻呂を肖像に採用し、猪の図案を取り入れています。'
        '29' = '改造100円券は大黒天の旧図案に代わり、藤原鎌足を肖像に採用しています。'
        '34' = '5円券には透かし用の専用余白があり、裏面は菅原道真に関連する図案で識別性を高めています。'
        '37B' = '第一回発行券は急造された片面印刷で、裏面は白紙でした。'
        '38' = '後続の版では裏面に赤い模様が加わり、一部は戦後まで保管された後に流通しました。'
        '39' = '5円券は菅原道真と北野天満宮を描いています。'
        '40' = '10円券は和気清麻呂と猪の図案を採用しています。'
        '42' = '100円券は聖徳太子を肖像に採用し、裏面には法隆寺を描いています。'
        '45' = '1,000円券は日本武尊の肖像と建部大社の図案を採用しています。'
        '49' = '第一号券1円版は表面に武内宿禰、裏面に宇倍神社を描いています。'
        '50' = '第一号券5円版は菅原道真と北野天満宮を描いています。'
        '51' = 'この戦時中の10円券は和気清麻呂と護王神社の図案を引き継いでいます。'
        '57' = '100円券は聖徳太子と法隆寺を描いており、カタログの版別説明では印刷違いも区別しています。'
        '78A' = '100円券は聖徳太子を肖像に採用し、裏面に法隆寺を描いています。'
        '85' = 'A号1円券は二宮尊徳を肖像に採用し、色刷りの地紋を使用しました。戦後初期の製造では偽造防止力が弱かったとされています。'
        '86' = 'A号5円券の主な特徴は色刷りの模様です。'
        '89' = 'A号100円券は板垣退助を肖像に採用し、戦後の新円切替期に発行されました。'
        '90' = 'B号100円券は板垣退助を肖像に採用しています。'
        '91' = 'B号500円券は岩倉具視を肖像に採用し、裏面に富士山を描いています。'
        '92' = 'B号1,000円券は聖徳太子を肖像に採用し、裏面に法隆寺夢殿を描いています。'
        '93' = 'C号5,000円券は聖徳太子と日本銀行本店を描いています。'
        '94' = 'C号10,000円券は聖徳太子と京都・平等院鳳凰堂を描いています。'
        '95' = 'C号500円券は岩倉具視と富士山の図案を引き継ぎ、透かしを更新しました。'
        '96' = 'C号1,000円券は伊藤博文を肖像に採用し、裏面に日本銀行本店を描いています。'
        '97' = 'D号1,000円券は夏目漱石を肖像に採用し、裏面にタンチョウを描いています。'
        '98' = 'D号5,000円券は新渡戸稲造を肖像に採用し、富士山と本栖湖を描いています。'
        '99' = 'D号10,000円券は福沢諭吉を肖像に採用し、裏面にキジを描いています。'
        '100' = 'D号1,000円券の改版は夏目漱石とタンチョウの図案を維持し、通し番号の色が印刷時期を区別します。'
        '101' = '改版D号5,000円券は新渡戸稲造、富士山、本栖湖の図案を維持し、識別・偽造防止の細部を更新しました。'
        '102' = '改版D号10,000円券は福沢諭吉とキジの図案を維持し、通し番号の色と偽造防止上の細部を変更しました。'
        '104' = 'E号1,000円券は野口英世を肖像に採用し、裏面に富士山と桜を描いています。'
        '105' = 'E号5,000円券は樋口一葉を肖像に採用し、裏面は尾形光琳の『燕子花図屏風』をもとにしています。'
        '106' = 'E号10,000円券は福沢諭吉の肖像を引き継ぎ、裏面に平等院鳳凰堂の鳳凰像を再び採用しました。'
        'W107' = 'F号1,000円券は北里柴三郎と葛飾北斎の『神奈川沖浪裏』を描いています。'
        'W108' = 'F号5,000円券は津田梅子と藤の花を描いています。'
        'W109' = 'F号10,000円券は渋沢栄一と東京駅丸の内駅舎を描いています。'
    }

    function Format-Denomination([string]$value, [string]$languageTag) {
    $formatted = $value -replace '(?<=\d)\.(?=\d{3}\b)', ','
    if ($languageTag -eq 'en-US') { return $formatted }
    if ($languageTag -eq 'ja-JP') {
        $formatted = $formatted -replace ' Silver Yen', '円銀兌換券' -replace ' Gold Yen', '円金兌換券' -replace ' Yen', '円' -replace ' Sen', '銭'
        return $formatted
    }
    $formatted = $formatted -replace ' Silver Yen', $(if ($languageTag -eq 'zh-TW') { ' 銀圓' } else { ' 银元' })
    $formatted = $formatted -replace ' Gold Yen', $(if ($languageTag -eq 'zh-TW') { ' 金圓' } else { ' 金元' })
    $formatted = $formatted -replace ' Yen', $(if ($languageTag -eq 'zh-TW') { ' 日圓' } else { ' 日元' })
    $formatted = $formatted -replace ' Sen', $(if ($languageTag -eq 'zh-TW') { ' 錢' } else { ' 钱' })
    return $formatted -replace '(?<=\d)\s+(?=(银元|金元|日元|銀圓|金圓|日圓|錢|钱))', ''
}

function Get-WikipediaSource([string]$denomination) {
    if ($denomination -notmatch '^(?<amount>[0-9.,]+)\s+(?<unit>Silver Yen|Gold Yen|Yen|Sen)$') {
        return [pscustomobject]@{ Name = 'Wikipedia: Bank of Japan notes'; Url = 'https://ja.wikipedia.org/wiki/日本銀行券' }
    }

    $amount = [int]($Matches.amount -replace '[^0-9]', '')
    $unit = $Matches.unit
    if ($unit -eq 'Yen' -and ($amount -eq 20 -or $amount -eq 100)) {
        return [pscustomobject]@{ Name = 'Wikipedia: 日本銀行券'; Url = 'https://ja.wikipedia.org/wiki/日本銀行券' }
    }

    $wikiAmount = if ($amount -eq 10000) { '10,000' } else { [string]$amount }
    $wikiUnit = if ($unit -eq 'Sen') { 'sen' } else { 'yen' }
    $page = "${wikiAmount}_${wikiUnit}_note"
    $title = if ($wikiAmount -eq '10,000') { '10,000' } else { $wikiAmount }
    return [pscustomobject]@{ Name = "Wikipedia: $title $wikiUnit note"; Url = "https://en.wikipedia.org/wiki/$page" }
}

$research = [System.Collections.Generic.List[object]]::new()
foreach ($group in ($banknotes | Group-Object pickNumber)) {
    $pick = $group.Name
    $record = $group.Group[0]
    $profile = $null

    if ($pick -eq '103') { $profile = $profiles.twoThousand }
    elseif ($pick -eq '37B') { $profile = $profiles.emergency200First }
    elseif ($pick -eq '38') { $profile = $profiles.emergency200Later }
    elseif ($pick -match '^W10[7-9]$') { $profile = $profiles.seriesF }
    else {
        $number = if ($pick -match '^(?<number>\d+)') { [int]$Matches.number } else { 0 }
        if ($number -ge 22 -and $number -le 25) { $profile = $profiles.silverFirst }
        elseif ($number -ge 26 -and $number -le 29) { $profile = $profiles.silverRedesign }
        elseif ($number -eq 30) { $profile = $profiles.taishoSilver }
        elseif ($number -ge 31 -and $number -le 33) { $profile = $profiles.earlyGold }
        elseif ($number -eq 34) { $profile = $profiles.watermarkGold }
        elseif ($number -ge 35 -and $number -le 37) { $profile = $profiles.taishoGold }
        elseif ($number -ge 39 -and $number -le 42) { $profile = $profiles.prewarRenewal }
        elseif ($number -ge 43 -and $number -le 45) { $profile = $profiles.wartimeTransition }
        elseif ($number -ge 49 -and $number -le 57) { $profile = $profiles.firstIssue }
        elseif ($number -eq 77 -or $number -eq 78) { $profile = $profiles.warEndIssues }
        elseif ($number -ge 79 -and $number -le 80) { $profile = $profiles.stampRevalidation }
        elseif ($number -ge 83 -and $number -le 89) { $profile = $profiles.seriesA }
        elseif ($number -ge 90 -and $number -le 92) { $profile = $profiles.seriesB }
        elseif ($number -ge 93 -and $number -le 96) { $profile = $profiles.seriesC }
        elseif ($number -ge 97 -and $number -le 99) { $profile = $profiles.seriesD }
        elseif ($number -ge 100 -and $number -le 102) { $profile = $profiles.seriesDMini }
        elseif ($number -ge 104 -and $number -le 106) { $profile = $profiles.seriesE }
    }

    if ($null -eq $profile) {
        throw "No Wikipedia research profile for Japan Pick $pick."
    }

    $denominationZh = Format-Denomination $record.denomination 'zh-CN'
    $denominationTw = Format-Denomination $record.denomination 'zh-TW'
    $denominationEn = Format-Denomination $record.denomination 'en-US'
    $denominationJa = Format-Denomination $record.denomination 'ja-JP'
    $pickLabel = "P-$pick"
    $design = $designs[$pick]
    $designZh = if ($design) { " $($design.zh)" } else { '' }
    $designTw = if ($design) { " $($design.tw)" } else { '' }
    $designEn = if ($design) { " $($design.en)" } else { '' }
    $designJa = if ($designsJa.ContainsKey($pick)) { " $($designsJa[$pick])" } else { '' }
    $source = Get-WikipediaSource $record.denomination
    $tags = @('japanese-yen','bank-of-japan') + @($profile.tags)

    $research.Add([pscustomobject]@{
        collectionId = $collectionId
        pickNumber = $pick
        simplifiedDescription = "$pickLabel（面值$denominationZh）。$($profile.zh)$designZh"
        traditionalDescription = "$pickLabel（面額$denominationTw）。$($profile.tw)$designTw"
        englishDescription = "$pickLabel ($denominationEn). $($profile.en)$designEn"
        japaneseDescription = "$pickLabel（$denominationJa）。$($profile.ja)$designJa"
        tags = @($tags | Sort-Object -Unique)
        sourceName = $source.Name
        sourceUrl = $source.Url
    })
}

$expectedPicks = @($banknotes | ForEach-Object { $_.pickNumber } | Sort-Object -Unique)
if ($research.Count -ne $expectedPicks.Count) {
    throw "Research coverage mismatch: $($research.Count) notes for $($expectedPicks.Count) Pick entries."
}

$otherResearch = @($catalog.researchNotes | Where-Object { $_.collectionId -ne $collectionId })
$catalog.researchNotes = @($otherResearch) + @($research.ToArray())
$json = ConvertTo-Json -InputObject $catalog -Depth 30
[System.IO.File]::WriteAllText($catalogPath, $json, [System.Text.UTF8Encoding]::new($false))
Write-Output "Refreshed $($research.Count) Wikipedia-based research notes for '$collectionId'."