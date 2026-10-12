# NumismaticsDex

[![CI](https://github.com/KKtheGhost/NumismaticsDex/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/KKtheGhost/NumismaticsDex/actions/workflows/ci.yml)
[![Release](https://github.com/KKtheGhost/NumismaticsDex/actions/workflows/release.yml/badge.svg)](https://github.com/KKtheGhost/NumismaticsDex/actions/workflows/release.yml)

<!-- coverage:start -->

**Core/non-UI logic line coverage:** 100.00% (3016/3016 lines), updated from commit 7922f61.
<!-- coverage:end -->

NumismaticsDex is a Windows-native numismatic catalog demo. The catalog includes `CHINA - Japanese Puppet Banks` (105 Pick entries, 166 variants), `CHINA - People's Republic` (130 Pick entries, 181 variants), `MANCHUKUO` (21 Pick entries, 31 variants), `CHINA - Empire` (90 Pick entries, 173 variants), `CHINA - REPUBLIC - CHINESE BANKS` (710 Pick entries, 1,531 variants), and seven `JAPAN` collections (134 Pick entries, 217 variants), for 1,190 Pick entries and 2,299 country/Pick/subnumber records total.

## Requirements

- Windows 10 version 1809 or later
- .NET 8 SDK
- Internet access to restore the Windows App SDK packages and load images for the selected banknote; source metadata refresh remains explicit
- For MSIX creation and local installation: Windows SDK packaging tools and a trusted signing certificate

The app uses WinUI 3 with Windows App SDK 2.5.1. The Windows SDK targeting reference is pinned in the app project so the required reference pack can be restored through NuGet.

## Build and run

```powershell
dotnet restore .\NumismaticsDex.sln
dotnet build .\NumismaticsDex.sln -c Debug
```

Run the packaged app from Visual Studio 2022 (17.11 or later) with the Windows App SDK and MSIX tooling installed. The startup window opens at a desktop-friendly size; the initial selection is P-J 1b.

The subtitle credits Kivinsae Fang in Simplified Chinese, Traditional Chinese, and English. The header language selector supports English, Simplified Chinese, Traditional Chinese, and Japanese. Japanese is used for translated interface and catalog values; source text is retained where a reliable translation is unavailable. The sun/moon icon toggles both the page palette and native WinUI control theme. Catalog metadata loads at launch; only the selected banknote's front and back images are fetched as needed and cached on disk. The image directory is not included in Git or the default release package.

The paper-money browser uses a cascading path: `Asia` → country → collection. China contains the Japanese Puppet Banks, People's Republic, Manchukuo, Empire, and Republic Chinese Banks collections. Japan contains Nippon Ginko, regional and exchange banks, the Great Imperial Japanese National Bank, foreign banks, Japanese government notes, military currency, and Allied military currency.

## Tests and coverage

Run the unit suite locally:

```powershell
dotnet test .\NumismaticsDex.Tests\NumismaticsDex.Tests.csproj -c Release
```

GitHub Actions builds the WinUI app, runs tests, and collects line coverage for Core and non-UI catalog, localization, and image/source logic. The WinUI view is build-checked but excluded from unit line coverage. The CI badge above reflects the latest workflow result; after pushes to `main`, CI updates the coverage percentage and source commit shown here.

## Releases

Pushing a `v0.0.1` tag or manually running the Release workflow with that tag publishes a signed GitHub prerelease with the MSIX, its Windows App Runtime dependencies, and the signing certificate. The package uses a temporary self-signed demo certificate; trust it only if you accept that certificate, and do not treat it as a production publisher identity.

## Create an MSIX

Create and trust a current-user development signing certificate once:

```powershell
\.\scripts\New-DevCertificate.ps1
```

The first script keeps the private key in `CurrentUser\My` and trusts it for the current user. AppX deployment also requires the self-signed root to be trusted on the device. Run the following once from an elevated PowerShell window; it imports only this app's public certificate into the machine `Root` and `TrustedPeople` stores:

```powershell
\.\scripts\Trust-DevCertificate-Machine.ps1
```

This does not disable signature checks. The install script checks for machine trust and explains this prerequisite if it is missing. To remove the machine trust later, run `\.\scripts\Trust-DevCertificate-Machine.ps1 -Remove` from an elevated PowerShell window.

Build, install/update, and launch the signed package:

```powershell
\.\scripts\Package.ps1
\.\scripts\Install-Dev.ps1
\.\scripts\Run-Installed.ps1
```

To create a private/offline package with locally available banknote images, opt in explicitly:

```powershell
\.\scripts\Package.ps1 -IncludeLocalBanknoteAssets
```

Do not redistribute those source images unless their owner has granted permission.

For a clean iteration cycle:

```powershell
\.\scripts\Uninstall-Dev.ps1
\.\scripts\Package.ps1
\.\scripts\Install-Dev.ps1
```

The installer verifies the package signature, includes the Windows App Runtime dependency, and replaces any current-user installation before deploying the new build. This is necessary because MSIX rejects changed contents under the same package version; the demo does not yet persist user data. The uninstaller removes the app for the current user and leaves the development certificate trusted for the next iteration. `\.\scripts\Uninstall-Dev.ps1 -RemoveDevelopmentCertificate` clears current-user trust; machine trust is removed separately with the elevated command above. Windows Settings > Apps can also uninstall the app.

`-Unsigned` remains available for packaging diagnostics only; Windows will not install an unsigned MSIX:

```powershell
\.\scripts\Package.ps1 -Unsigned
```

This WinUI app is intended to run with package identity. Use `Run-Installed.ps1` for fast relaunches between builds; a standalone unpackaged EXE is not provided.

## Catalog and image assets

The importer defaults to the Japanese Puppet Banks category and reads its Pick entries, variants, details, and source images:

```powershell
.\scripts\Import-BanknoteCollection.ps1
```

Import the People's Republic category into the same catalog with its own cascade option:

```powershell
.\scripts\Import-BanknoteCollection.ps1 `
	-CategoryUrl 'http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CIN-PR.htm' `
	-CollectionId 'china-peoples-republic' `
	-CollectionTitle "CHINA - People's Republic" `
	-CollectionDescription "Renminbi banknotes, foreign exchange certificates, and military payment certificates issued in the People's Republic of China."
```

Import Manchukuo under China while retaining its distinct country code:

```powershell
.\scripts\Import-BanknoteCollection.ps1 `
	-CategoryUrl 'http://www.banknote.ws/COLLECTION/countries/ASI/MNK/MNK.htm' `
	-CollectionId 'manchukuo' `
	-CollectionTitle 'MANCHUKUO' `
	-CollectionDescription 'Paper money issued in Manchukuo by its central bank.' `
	-CountryCode 'MNK' `
	-Country 'China'
```

Import the Ming/Qing and imperial-era banknotes:

```powershell
.\scripts\Import-BanknoteCollection.ps1 `
	-CategoryUrl 'http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-EMP/CIN-EMP.htm' `
	-CollectionId 'china-empire' `
	-CollectionTitle 'CHINA - Empire' `
	-CollectionDescription 'Ming and Qing dynasty banknotes and later imperial Chinese issues.' `
	-CountryCode 'CHN' `
	-Country 'China'
```

Import the Republic-era Chinese Banks overview and all five linked detail pages as one collection:

```powershell
.\scripts\Import-BanknoteCollection.ps1 `
	-CategoryUrl 'http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-REP-CIN/CIN-REP-CIN.htm' `
	-CollectionId 'china-republic-chinese-banks' `
	-CollectionTitle 'CHINA - REPUBLIC - CHINESE BANKS' `
	-CollectionDescription 'Republic-era Chinese banknotes, including central, provincial, and commercial bank issues.' `
	-CountryCode 'CHN' `
	-Country 'China'
```

Import the Bank of Japan collection:

```powershell
.\scripts\Import-BanknoteCollection.ps1 `
	-CategoryUrl 'http://www.banknote.ws/COLLECTION/countries/ASI/JAP/JAP-NPG.htm' `
	-CollectionId 'japan-nippon-ginko' `
	-CollectionTitle 'JAPAN - NIPPON GINKO' `
	-CollectionDescription 'Paper money issued by the Bank of Japan.' `
	-CountryCode 'JPN' `
	-Country 'Japan'
```

Import the other Japan themes from `JAP-GIJNB.htm`, `JAP-GVT.htm`, `JAP-MIL.htm`, and `JAP-ALLY.htm` with their own collection IDs. `JAP-LOC.htm` contains both regional/exchange and foreign-bank notes; split them with `-PickNumberPattern '^S(?:16[1-9]|17[0-9]|18[0-6])$'` and `-PickNumberPattern '^S224$'`, respectively.

Regenerate research notes for the China Empire, Japanese Puppet Banks, and Manchukuo collections:

```powershell
.\scripts\Refresh-ChinaOtherResearch.ps1
```

Regenerate the multilingual, Wikipedia-cited Japan research notes after changing the imported records:

```powershell
.\scripts\Refresh-JapanResearch.ps1
.\scripts\Refresh-JapanOtherResearch.ps1
```

The importer supports three-letter country prefixes in source detail and image filenames. It replaces records only for the selected collection and preserves other catalog collections. It generates `NumismaticsDex.App\Assets\catalog.json` and the external `NumismaticsDex.App\Assets\Banknotes` directory. The combined catalog contains 2,299 variants. The importer can create 3,175 original full-size JPG files, copied without resizing or recompressing. These third-party images are ignored by Git and excluded from default builds because image redistribution rights have not been established.

At runtime, the app resolves only the selected banknote's front/back image paths. If neither a local cache nor an explicitly included offline asset exists, it streams that image directly to the per-user cache; it never loads all image bytes into memory. The two visible image slots decode at a bounded width and release the previous selection when the user changes notes. Every record with a source detail page also has a **Refresh from source** action, which explicitly fetches metadata and image URLs for that record. Records without cataloged image URLs can still refresh their metadata. To force a full-source image refresh during import:

```powershell
.\scripts\Import-BanknoteCollection.ps1 -RefreshImages
```

The paper-money identity is country code + Pick number + subnumber, for example `CHN:J1:a`, `CHN:AA3:-`, and `MNK:J120:-`. Source `P-NL` entries use detail-page-specific internal Pick numbers such as `NL-CINA0016A2` to keep repeated unlisted labels unique. The UI can search by Pick label, denomination, issuer, and the active-language variant text.

The People's Republic collection has Wikipedia-prioritized, multilingual research notes for all 130 Pick entries and 181 variants. This covers 104 regular RMB-series entries (153 variants), four numbered commemorative issues (five variants), 11 W-prefixed recent issues, nine Bank of China foreign-exchange certificates, and two military payment certificate entries. P-891, P-902, P-908, and P-910 are described separately as commemorative issues; W911, W918-W922 are commemorative, while W912-W916 are modified fifth-series issues. W is only a Pick-number prefix, not a commemorative marker. Foreign-exchange and military certificates retain their own issuer tags rather than RMB-series tags. PBOC-issued RMB and W notes list the People's Bank of China as printer; individual first-series printing works are added only when a reliable public source is available.

The China Empire, Japanese Puppet Banks, and Manchukuo collections now have 211 additional multilingual research notes across 216 Pick groups. All 90 Empire and 21 Manchukuo groups are covered; 100 of 105 Japanese Puppet Banks groups are covered. The five Chi Tung Bank Picks remain without analysis because available public sources do not provide sufficiently specific issue history. Together with the People's Republic collection, 341 of China's 346 Pick groups have research notes.

Japan has multilingual, Wikipedia-cited research notes for all 134 Pick entries across its seven collections. The descriptions distinguish Meiji government notes, chartered national-bank notes, private exchange issues, Bank of Japan series, Japanese military currency, and Allied A/B yen. For S-224 and M-19/M-20, Wikipedia has no item-specific account; the notes say so and limit those details to the catalog record.

## Data source and attribution
- Collection: [CHINA - REPUBLIC - CHINESE BANKS - OVERVIEW](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-REP-CIN/CIN-REP-CIN.htm)
- Republic Chinese Banks detail pages: [01](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-REP-CIN/CIN-REP-CIN-01.htm), [02](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-REP-CIN/CIN-REP-CIN-02.htm), [03](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-REP-CIN/CIN-REP-CIN-03.htm), [04](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-REP-CIN/CIN-REP-CIN-04.htm), and [05](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-REP-CIN/CIN-REP-CIN-05.htm)

- Collection: [CHINA - Japanese Puppet Banks](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PUP/CIN-PUP.htm)
- P-J 1 details and variant descriptions: [CINJ0001](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PUP/CINJ0001.htm)
- Collection: [CHINA - People's Republic](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CIN-PR.htm)
- P-800 details: [CIN0800](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CIN0800.htm)
- Collection: [MANCHUKUO](http://www.banknote.ws/COLLECTION/countries/ASI/MNK/MNK.htm)
- P-J 120 details: [CINJ0120](http://www.banknote.ws/COLLECTION/countries/ASI/MNK/CINJ0120.htm)
- Collection: [CHINA - Empire](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-EMP/CIN-EMP.htm)
- Ming Dynasty P-AA3 details: [CINAA0003](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-EMP/CINAA0003.htm)
- Ming paper currency: [Great Ming Treasure Note](https://en.wikipedia.org/wiki/Great_Ming_Treasure_Note)
- Qing and early modern Chinese notes: [Paper money of the Qing dynasty](https://en.wikipedia.org/wiki/Paper_money_of_the_Qing_dynasty), [Da-Qing Bank](https://en.wikipedia.org/wiki/Da-Qing_Bank), [Imperial Bank of China](https://en.wikipedia.org/wiki/Imperial_Bank_of_China), and [Bank of Communications](https://en.wikipedia.org/wiki/Bank_of_Communications)
- Japanese-occupied Chinese currency: [History of Chinese currency](https://en.wikipedia.org/wiki/History_of_Chinese_currency), [Central Reserve Bank of China](https://en.wikipedia.org/wiki/Central_Reserve_Bank_of_China), [Huaxing Commercial Bank](https://en.wikipedia.org/wiki/Huaxing_Commercial_Bank), and [Mengjiang yuan](https://en.wikipedia.org/wiki/Mengjiang_yuan)
- Manchukuo issues: [Manchukuo yuan](https://en.wikipedia.org/wiki/Manchukuo_yuan)
- Collection: [JAPAN - NIPPON GINKO](http://www.banknote.ws/COLLECTION/countries/ASI/JAP/JAP-NPG.htm)
- P-22 Daikoku issue details: [JAP0022](http://www.banknote.ws/COLLECTION/countries/ASI/JAP/JAP0022.htm)
- Japan regional/exchange and foreign-bank issues: [JAP-LOC](http://www.banknote.ws/COLLECTION/countries/ASI/JAP/JAP-LOC.htm)
- Great Imperial Japanese National Bank: [JAP-GIJNB](http://www.banknote.ws/COLLECTION/countries/ASI/JAP/JAP-GIJNB.htm)
- Japanese government notes: [JAP-GVT](http://www.banknote.ws/COLLECTION/countries/ASI/JAP/JAP-GVT.htm)
- Japanese military currency: [JAP-MIL](http://www.banknote.ws/COLLECTION/countries/ASI/JAP/JAP-MIL.htm)
- Allied Military Currency: [JAP-ALLY](http://www.banknote.ws/COLLECTION/countries/ASI/JAP/JAP-ALLY.htm)
- Bank of Japan note history: [Japanese Wikipedia](https://ja.wikipedia.org/wiki/日本銀行券) and [Banknotes of the Japanese yen](https://en.wikipedia.org/wiki/Banknotes_of_the_Japanese_yen)
- Other Japan themes: [Japanese currency](https://en.wikipedia.org/wiki/Japanese_currency), [Meiji Tsūhō](https://en.wikipedia.org/wiki/Meiji_Tsuho), [Dajōkansatsu](https://en.wikipedia.org/wiki/Daj%C5%8Dkansatsu), [National Banks in Meiji Japan](https://en.wikipedia.org/wiki/National_Banks_in_Meiji_Japan), [small-denomination government notes](https://ja.wikipedia.org/wiki/小額政府紙幣), [Japanese military currency, 1894–1918](https://en.wikipedia.org/wiki/Japanese_military_currency_(1894%E2%80%931918)), [Japanese military currency, 1937–1945](https://en.wikipedia.org/wiki/Japanese_military_currency_(1937%E2%80%931945)), [A yen](https://en.wikipedia.org/wiki/A_yen), [B yen](https://en.wikipedia.org/wiki/B_yen), and [Allied Military Currency](https://en.wikipedia.org/wiki/Allied_Military_Currency)
- Denomination-specific Wikipedia references are retained per Japan Pick note, including [1 yen](https://en.wikipedia.org/wiki/1_yen_note), [5 yen](https://en.wikipedia.org/wiki/5_yen_note), [10 yen](https://en.wikipedia.org/wiki/10_yen_note), [200 yen](https://en.wikipedia.org/wiki/200_yen_note), [2,000 yen](https://en.wikipedia.org/wiki/2000_yen_note), [1,000 yen](https://en.wikipedia.org/wiki/1000_yen_note), [5,000 yen](https://en.wikipedia.org/wiki/5000_yen_note), and [10,000 yen](https://en.wikipedia.org/wiki/10,000_yen_note)
- RMB series pages: [First](https://zh.wikipedia.org/wiki/第一套人民币), [Second](https://zh.wikipedia.org/wiki/第二套人民币), [Third](https://zh.wikipedia.org/wiki/第三套人民币), [Fourth](https://zh.wikipedia.org/wiki/第四套人民币), and [Fifth](https://zh.wikipedia.org/wiki/第五套人民币) series
- Commemorative issues: [Renminbi](https://en.wikipedia.org/wiki/Renminbi) and [Commemorative banknotes of the renminbi](https://en.wikipedia.org/wiki/Commemorative_banknotes_of_the_renminbi)
- Foreign-exchange certificates: [Chinese Wikipedia](https://zh.wikipedia.org/wiki/中国银行外汇兑换券) and [Bank of China history](https://www.bankofchina.com/en/aboutboc/ab7/200809/t20080926_1601850.html)
- Military payment certificates: [Chinese Wikipedia](https://zh.wikipedia.org/wiki/军用代金券)
- China News Service RMB overview, citing PBOC public information: [China News Service](https://www.chinanews.com.cn/cj/2015/08-10/7457570.shtml)
- P-910 aerospace commemorative banknote: [CIN0910](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CIN0910.htm)
- W911 70th-anniversary issue: [CINW2018-050](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CINW2018-050.htm)
- W918/W919 Winter Olympics issues: [CINW2022-020-1](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CINW2022-020-1.htm) and [CINW2022-020-2](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CINW2022-020-2.htm)
- W920-W922 Zodiac issues: [CINW0920](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CINW0920.htm), [CINW0921](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CINW0921.htm), and [CINW0922](http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CINW0922.htm)

The banknote records and images belong to banknote.ws. Source attribution and original detail links are retained per record. Confirm the site's terms and image permissions before redistributing the external asset directory.

## Architecture

- `NumismaticsDex.Core`: portable catalog types and data contracts. `CatalogItem` is category-neutral; `Banknote` adds country/Pick/subnumber identity. Coin and medal models can be added without changing the UI's shared identity contract.
- `NumismaticsDex.App`: WinUI 3 desktop interface, search, selection, localized banknote details, and light/dark themes.
- `scripts`: full-category import, development certificate setup, MSIX packaging, install/update, uninstall, launch, and manifest icon generation.

The Core library targets .NET 8 and is separate from WinUI so future iOS and Linux clients can reuse catalog data types with platform-appropriate frontends.