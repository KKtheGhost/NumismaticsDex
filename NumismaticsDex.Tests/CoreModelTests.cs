using NumismaticsDex.Core;

namespace NumismaticsDex.Tests;

public sealed class CoreModelTests
{
    [Theory]
    [InlineData(null, "P-800")]
    [InlineData("a", "P-800.a")]
    [InlineData("(I)", "P-800(I)")]
    public void PickLabelFormatsOptionalSubnumbers(string? subnumber, string expected)
    {
        var banknote = TestBanknoteFactory.Create(pickSubnumber: subnumber);

        Assert.Equal(expected, banknote.PickLabel);
    }

    [Theory]
    [InlineData(null, "Standard issue")]
    [InlineData("a", "Variant a")]
    public void VariantCaptionUsesDescriptionOrFallback(string? subnumber, string expected)
    {
        var banknote = TestBanknoteFactory.Create(pickSubnumber: subnumber);

        Assert.Equal(expected, banknote.VariantCaption);
    }

    [Fact]
    public void VariantCaptionPrefersCatalogDescription()
    {
        var banknote = TestBanknoteFactory.Create(pickSubnumber: "a", variantDescription: "With watermark.");

        Assert.Equal("With watermark.", banknote.VariantCaption);
    }

    [Fact]
    public void DemoCatalogHasDistinctCollectionsAndBanknoteIdentities()
    {
        Assert.Equal(4, DemoCatalog.Collections.Count);
        Assert.Equal(DemoCatalog.Banknotes.Count, DemoCatalog.Banknotes.Select(note => note.Id).Distinct().Count());
        Assert.All(DemoCatalog.Banknotes, note => Assert.Equal(CollectibleKind.Banknote, note.Kind));
    }
}