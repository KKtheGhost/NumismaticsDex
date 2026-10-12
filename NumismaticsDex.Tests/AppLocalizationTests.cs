using NumismaticsDex.App;
using NumismaticsDex.Core;

namespace NumismaticsDex.Tests;

public sealed class AppLocalizationTests
{
    [Fact]
    public void GetReturnsLocaleSpecificUiTextAndRejectsUnknownKeys()
    {
        var english = AppLocalization.Get("banknotes", "en-US");
        var japanese = AppLocalization.Get("banknotes", "ja-JP");

        Assert.NotEqual(english, japanese);
        Assert.Throws<KeyNotFoundException>(() => AppLocalization.Get("missing-key", "en-US"));
    }

    [Theory]
    [InlineData("zh-CN", "亚洲", "中国")]
    [InlineData("zh-TW", "亞洲", "中國")]
    [InlineData("ja-JP", "アジア", "中国")]
    [InlineData("en-US", "Asia", "China")]
    public void RegionAndCountryNamesUseLocale(string language, string region, string country)
    {
        Assert.Equal(region, AppLocalization.RegionName("Asia", language));
        Assert.Equal(country, AppLocalization.CountryName("China", language));
    }

    [Theory]
    [InlineData("Manchukuo", "zh-CN", "满洲国")]
    [InlineData("Manchukuo", "zh-TW", "滿洲國")]
    [InlineData("Manchukuo", "ja-JP", "満洲国")]
    [InlineData("Japan", "zh-CN", "日本")]
    [InlineData("Japan", "zh-TW", "日本")]
    [InlineData("Japan", "ja-JP", "日本")]
    public void CountryNamesCoverNonDefaultCatalogCountries(string country, string language, string expected)
    {
        Assert.Equal(expected, AppLocalization.CountryName(country, language));
    }

    [Fact]
    public void CollectionMetadataFallsBackToSourceForUnknownIds()
    {
        var collection = DemoCatalog.Collection;
        var unknown = new CatalogCollection("unknown", "Source title", "Source description", "https://example.test");

        Assert.NotEqual(collection.Title, AppLocalization.CollectionTitle(collection, "ja-JP"));
        Assert.NotEqual(collection.Description, AppLocalization.CollectionDescription(collection, "ja-JP"));
        Assert.Equal(unknown.Title, AppLocalization.CollectionTitle(unknown, "ja-JP"));
        Assert.Equal(unknown.Description, AppLocalization.CollectionDescription(unknown, "ja-JP"));

        foreach (var catalogCollection in BanknoteCatalogStore.LoadCollections())
        {
            foreach (var language in new[] { "en-US", "zh-CN", "zh-TW", "ja-JP" })
            {
                Assert.NotEmpty(AppLocalization.CollectionTitle(catalogCollection, language));
                Assert.NotEmpty(AppLocalization.CollectionDescription(catalogCollection, language));
            }
        }
    }

    [Fact]
    public void NewCollectionTitlesAndDescriptionsUseAllSupportedLocales()
    {
        var expectedTitles = new Dictionary<string, (string Simplified, string Traditional, string English, string Japanese)>
        {
            ["china-foreign-banks"] = ("中国 - 外国银行", "中國 - 外國銀行", "CHINA - FOREIGN BANKS", "中国 - 外国銀行"),
            ["kiau-chau"] = ("中国 - 胶州湾租借地", "中國 - 膠州灣租借地", "KIAU CHAU", "中国 - 膠州湾租借地"),
            ["china-chinese-military"] = ("中国 - 中国军用纸币", "中國 - 中國軍用紙幣", "CHINA - CHINESE MILITARY", "中国 - 中国軍用紙幣"),
            ["china-japanese-soviet-military"] = ("中国 - 日苏军用纸币", "中國 - 日蘇軍用紙幣", "CHINA - JAPANESE & SOVIET MILITARY", "中国 - 日本・ソ連軍用紙幣")
        };

        foreach (var (collectionId, expected) in expectedTitles)
        {
            var collection = new CatalogCollection(collectionId, expected.English, "Source description", "https://example.test/collection");
            Assert.Equal(expected.Simplified, AppLocalization.CollectionTitle(collection, "zh-CN"));
            Assert.Equal(expected.Traditional, AppLocalization.CollectionTitle(collection, "zh-TW"));
            Assert.Equal(expected.English, AppLocalization.CollectionTitle(collection, "en-US"));
            Assert.Equal(expected.Japanese, AppLocalization.CollectionTitle(collection, "ja-JP"));
            Assert.NotEqual(collection.Description, AppLocalization.CollectionDescription(collection, "zh-CN"));
            Assert.NotEqual(collection.Description, AppLocalization.CollectionDescription(collection, "zh-TW"));
            Assert.NotEqual(collection.Description, AppLocalization.CollectionDescription(collection, "ja-JP"));
            Assert.All(new[] { "zh-CN", "zh-TW", "en-US", "ja-JP" }, language =>
                Assert.NotEmpty(AppLocalization.CollectionDescription(collection, language)));
        }
    }

    [Fact]
    public void NewCollectionBanknoteMetadataDoesNotFallBackToEnglish()
    {
        var collectionIds = new[]
        {
            "china-foreign-banks",
            "kiau-chau",
            "china-chinese-military",
            "china-japanese-soviet-military"
        };
        var banknotes = BanknoteCatalogStore.Load()
            .Where(banknote => collectionIds.Contains(banknote.CollectionId))
            .ToArray();
        var languages = new[] { "zh-CN", "zh-TW", "ja-JP" };

        static bool ContainsLatinText(string value) => value.Any(character =>
            character is >= 'A' and <= 'Z' or >= 'a' and <= 'z');

        foreach (var language in languages)
        {
            foreach (var banknote in banknotes.DistinctBy(note => note.Issuer))
            {
                if (ContainsLatinText(banknote.Issuer))
                {
                    Assert.NotEqual(banknote.Issuer, AppLocalization.Issuer(banknote, language));
                }
            }
            foreach (var banknote in banknotes.DistinctBy(note => note.Printer).Where(note => !string.IsNullOrWhiteSpace(note.Printer)))
            {
                Assert.NotEqual(banknote.Printer, AppLocalization.Printer(banknote, language));
            }
            foreach (var banknote in banknotes.DistinctBy(note => note.Denomination))
            {
                if (ContainsLatinText(banknote.Denomination))
                {
                    Assert.NotEqual(banknote.Denomination, AppLocalization.Denomination(banknote, language));
                }
            }
            foreach (var banknote in banknotes.DistinctBy(note => note.IssueDate))
            {
                if (ContainsLatinText(banknote.IssueDate))
                {
                    Assert.NotEqual(banknote.IssueDate, AppLocalization.IssueDate(banknote, language));
                }
            }
            foreach (var banknote in banknotes.DistinctBy(note => (note.VariantDescription, note.PickSubnumber))
                         .Where(note => !string.IsNullOrWhiteSpace(note.VariantDescription)))
            {
                Assert.NotEqual(banknote.VariantDescription, AppLocalization.Variant(banknote, language));
            }
        }
    }

    [Fact]
    public void PrinterAndIssuerTranslateKnownValuesAndPreserveUnknownValues()
    {
        var banknote = TestBanknoteFactory.Create(printer: "Watson Printing Company");
        var unknown = TestBanknoteFactory.Create(printer: "Unknown printer") with { Issuer = "Unmapped Testville Bank" };

        Assert.Equal("ワトソン印刷会社", AppLocalization.Printer(banknote, "ja-JP"));
        Assert.Equal("中国人民銀行", AppLocalization.Issuer(TestBanknoteFactory.Create(), "ja-JP"));
        Assert.Equal("中国人民银行", AppLocalization.Issuer(TestBanknoteFactory.Create(), "zh-CN"));
        Assert.Equal("中國人民銀行", AppLocalization.Issuer(TestBanknoteFactory.Create(), "zh-TW"));
        Assert.Equal("Unknown printer", AppLocalization.Printer(unknown, "ja-JP"));
        Assert.Equal("Unmapped Testville Bank", AppLocalization.Issuer(unknown, "ja-JP"));
        Assert.NotEmpty(AppLocalization.Printer(TestBanknoteFactory.Create(printer: ""), "zh-CN"));

        var army = TestBanknoteFactory.Create() with { Issuer = "People's Liberation Army" };
        Assert.Equal("中国人民解放军", AppLocalization.Issuer(army, "zh-CN"));
        Assert.Equal("中國人民解放軍", AppLocalization.Issuer(army, "zh-TW"));
    }

    [Fact]
    public void ResearchFieldsSelectLocalesAndFallbackWhenJapaneseTextIsMissing()
    {
        var banknote = TestBanknoteFactory.Create(research: TestBanknoteFactory.CreateResearch());
        var withoutJapanese = banknote with
        {
            Research = TestBanknoteFactory.CreateResearch(japaneseDescription: " ")
        };

        Assert.Equal("简体研究说明", AppLocalization.ResearchDescription(banknote, "zh-CN"));
        Assert.Equal("繁體研究說明", AppLocalization.ResearchDescription(banknote, "zh-TW"));
        Assert.Equal("English research description", AppLocalization.ResearchDescription(banknote, "en-US"));
        Assert.Equal("日本語の研究説明", AppLocalization.ResearchDescription(banknote, "ja-JP"));
        Assert.Equal("English research description", AppLocalization.ResearchDescription(withoutJapanese, "ja-JP"));
        Assert.Equal(string.Empty, AppLocalization.ResearchDescription(TestBanknoteFactory.Create(), "ja-JP"));

        var unknownSource = TestBanknoteFactory.Create(research: TestBanknoteFactory.CreateResearch("Unmapped source name"));
        Assert.Equal("Unmapped source name", AppLocalization.ResearchSourceName(unknownSource, "zh-CN"));
    }

    [Fact]
    public void ResearchSourcesAndTagsUseLocalizedLabelsAndKeepUnknownValues()
    {
        var research = TestBanknoteFactory.CreateResearch() with { Tags = ["rmb", "series-1", "custom-tag"] };
        var banknote = TestBanknoteFactory.Create(research: research);

        Assert.Equal(research.SourceName, AppLocalization.ResearchSourceName(banknote, "en-US"));
        Assert.NotEqual(research.SourceName, AppLocalization.ResearchSourceName(banknote, "ja-JP"));
        Assert.Equal("人民币 · 第一套 · custom-tag", AppLocalization.ResearchTags(banknote, "zh-CN"));
        Assert.Contains("人民元", AppLocalization.ResearchTags(banknote, "ja-JP"));
        Assert.Equal(string.Empty, AppLocalization.ResearchSourceName(TestBanknoteFactory.Create(), "ja-JP"));

        var additionalTags = TestBanknoteFactory.Create(research: TestBanknoteFactory.CreateResearch() with
        {
            Tags = ["multiple-denominations", "decimal-reform", "special-stamp"]
        });
        Assert.Contains("多种面额", AppLocalization.ResearchTags(additionalTags, "zh-CN"));
        Assert.Contains("币制折算", AppLocalization.ResearchTags(additionalTags, "zh-CN"));
        Assert.Contains("貼證", AppLocalization.ResearchTags(additionalTags, "zh-TW"));
        Assert.Contains("Multiple denominations", AppLocalization.ResearchTags(additionalTags, "en-US"));
        Assert.Contains("Currency redenomination", AppLocalization.ResearchTags(additionalTags, "en-US"));
        Assert.Contains("Stamp-revalidated note", AppLocalization.ResearchTags(additionalTags, "en-US"));
    }

    [Theory]
    [InlineData("zh-CN", "1,000 Yuan", "1,000 元")]
    [InlineData("zh-TW", "1,000 Yuan", "1,000 元")]
    [InlineData("ja-JP", "1,000 Yuan", "1,000 元")]
    [InlineData("en-US", "1,000 Yuan", "1,000 Yuan")]
    public void DenominationFormattingUsesLocale(string language, string source, string expected)
    {
        var banknote = TestBanknoteFactory.Create(denomination: source);

        Assert.Equal(expected, AppLocalization.Denomination(banknote, language));
    }

    [Fact]
    public void IssueDatesTranslateRepublicAndUnknownDates()
    {
        var republicDate = TestBanknoteFactory.Create(issueDate: "Year 29 of the Republic (1940)");
        var unknownDate = TestBanknoteFactory.Create(issueDate: "ND (ca. 1920)");

        Assert.Contains("民国", AppLocalization.IssueDate(republicDate, "zh-CN"));
        Assert.Contains("中華民国", AppLocalization.IssueDate(republicDate, "ja-JP"));
        Assert.Contains("1940", AppLocalization.IssueDate(republicDate, "ja-JP"));
        Assert.Contains("約1920年", AppLocalization.IssueDate(unknownDate, "ja-JP"));
        Assert.Equal("1940", AppLocalization.IssueDate(TestBanknoteFactory.Create(issueDate: "1940"), "en-US"));
    }

    [Theory]
    [InlineData("zh-CN", "35 个版别")]
    [InlineData("zh-TW", "35 種版別")]
    [InlineData("ja-JP", "35 種類")]
    [InlineData("en-US", "35 variants")]
    public void CountLabelsAndSummariesUseLocale(string language, string expected)
    {
        Assert.Equal(expected, AppLocalization.CountLabel(35, language));
        Assert.Contains("35", AppLocalization.DemoSummary(35, language));
    }

    [Fact]
    public void VariantTranslationPreservesEnglishAndLocalizesCjkText()
    {
        var banknote = TestBanknoteFactory.Create(variantDescription: "With printer's name and serial number.");

        Assert.Equal(banknote.VariantDescription, AppLocalization.Variant(banknote, "en-US"));
        Assert.NotEqual(banknote.VariantDescription, AppLocalization.Variant(banknote, "zh-CN"));
        Assert.NotEqual(banknote.VariantDescription, AppLocalization.Variant(banknote, "ja-JP"));
        Assert.Equal("Variant a", AppLocalization.Variant(TestBanknoteFactory.Create(pickSubnumber: "a"), "en-US"));

        var republicanDates = TestBanknoteFactory.Create(variantDescription: "Year 29 & 30 of the Republic = 1940 & 1941");
        Assert.Contains("二十九、三十年", AppLocalization.Variant(republicanDates, "zh-CN"));
    }

    [Fact]
    public void SearchTextIncludesIdentityResearchAndLocalizedFields()
    {
        var banknote = TestBanknoteFactory.Create(research: TestBanknoteFactory.CreateResearch());

        var text = AppLocalization.SearchText(banknote, "ja-JP");

        Assert.Contains("P-800", text);
        Assert.Contains("People's Bank of China", text);
        Assert.Contains("日本語の研究説明", text);
        Assert.Contains("RMB", text, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void EveryCatalogMetadataValueLocalizesAcrossSupportedLanguages()
    {
        var banknotes = BanknoteCatalogStore.Load();
        var languages = new[] { "en-US", "zh-CN", "zh-TW", "ja-JP" };

        foreach (var language in languages)
        {
            foreach (var banknote in banknotes.DistinctBy(note => note.Issuer))
            {
                Assert.NotNull(AppLocalization.Issuer(banknote, language));
            }
            foreach (var banknote in banknotes.DistinctBy(note => note.Printer))
            {
                Assert.NotNull(AppLocalization.Printer(banknote, language));
            }
            foreach (var banknote in banknotes.DistinctBy(note => note.Denomination))
            {
                Assert.NotNull(AppLocalization.Denomination(banknote, language));
            }
            foreach (var banknote in banknotes.DistinctBy(note => note.IssueDate))
            {
                Assert.NotNull(AppLocalization.IssueDate(banknote, language));
            }
            foreach (var banknote in banknotes.DistinctBy(note => (note.VariantDescription, note.PickSubnumber)))
            {
                Assert.NotNull(AppLocalization.Variant(banknote, language));
            }
            foreach (var banknote in banknotes.Where(note => note.Research is not null)
                         .DistinctBy(note => note.Research!.EnglishDescription))
            {
                Assert.NotNull(AppLocalization.ResearchDescription(banknote, language));
            }
            foreach (var banknote in banknotes.Where(note => note.Research is not null)
                         .DistinctBy(note => note.Research!.SourceName))
            {
                Assert.NotNull(AppLocalization.ResearchSourceName(banknote, language));
            }
            foreach (var banknote in banknotes.Where(note => note.Research is not null)
                         .DistinctBy(note => string.Join('|', note.Research!.Tags)))
            {
                Assert.NotNull(AppLocalization.ResearchTags(banknote, language));
            }
        }
    }

    [Fact]
    public void CombinedRepublicDateVariantFormatsBothEraAndWesternYears()
    {
        var banknote = TestBanknoteFactory.Create(variantDescription: "Year 29 & 30 of the Republic = 1940 & 1941");

        Assert.Contains("1940、1941", AppLocalization.Variant(banknote, "zh-TW"));
    }
}