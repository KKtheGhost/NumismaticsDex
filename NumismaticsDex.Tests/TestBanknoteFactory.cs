using NumismaticsDex.Core;

namespace NumismaticsDex.Tests;

internal static class TestBanknoteFactory
{
    public static Banknote Create(
        string pickNumber = "800",
        string? pickSubnumber = null,
        string denomination = "1 Yuan",
        string issueDate = "1948",
        string printer = "People's Bank of China",
        string variantDescription = "",
        BanknoteResearch? research = null,
        string? frontImageUrl = null,
        string? backImageUrl = null) => new(
            "CHN",
            pickNumber,
            pickSubnumber,
            "People's Bank of China",
            "China",
            1948,
            "https://example.test/note",
            frontImageUrl,
            backImageUrl,
            "People's Bank of China",
            denomination,
            issueDate,
            printer,
            variantDescription)
        {
            CollectionId = "china-peoples-republic",
            Research = research
        };

    public static BanknoteResearch CreateResearch(
        string sourceName = "Wikipedia: First series of the renminbi",
        string japaneseDescription = "日本語の研究説明") => new(
            "简体研究说明",
            "繁體研究說明",
            "English research description",
            japaneseDescription,
            ["rmb", "series-1"],
            sourceName,
            "https://example.test/research");
}