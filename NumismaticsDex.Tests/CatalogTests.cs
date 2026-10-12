using NumismaticsDex.App;
using NumismaticsDex.Core;

namespace NumismaticsDex.Tests;

public sealed class CatalogTests
{
    [Fact]
    public void CatalogLoadsCollectionsBanknotesAndResearch()
    {
        var collections = BanknoteCatalogStore.LoadCollections();
        var banknotes = BanknoteCatalogStore.Load();

        Assert.Equal(16, collections.Count);
        Assert.Equal(2929, banknotes.Count);
        Assert.All(banknotes.Where(note => note.Research is not null), note =>
        {
            var research = Assert.IsType<BanknoteResearch>(note.Research);
            Assert.False(string.IsNullOrWhiteSpace(research.EnglishDescription));
            Assert.False(string.IsNullOrWhiteSpace(research.JapaneseDescription));
        });
    }

    [Fact]
    public void CatalogFallsBackToDemoDataWhenPackagedJsonIsMissing()
    {
        var catalogPath = Path.Combine(AppContext.BaseDirectory, "Assets", "catalog.json");
        var backupPath = catalogPath + ".test-backup";
        File.Move(catalogPath, backupPath);

        try
        {
            Assert.Equal(DemoCatalog.Banknotes.Count, BanknoteCatalogStore.Load().Count);
            Assert.Equal(DemoCatalog.Collections.Count, BanknoteCatalogStore.LoadCollections().Count);
        }
        finally
        {
            File.Move(backupPath, catalogPath);
        }
    }

    [Fact]
    public void NullAndUnknownRefreshOverridesAreIgnored()
    {
        var overrideDirectory = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "NumismaticsDex",
            "Overrides");
        Directory.CreateDirectory(overrideDirectory);
        var nullPath = Path.Combine(overrideDirectory, $"null-{Guid.NewGuid():N}.json");
        var unknownPath = Path.Combine(overrideDirectory, $"unknown-{Guid.NewGuid():N}.json");

        try
        {
            File.WriteAllText(nullPath, "null");
            File.WriteAllText(unknownPath, """{"Id":"missing-banknote","Title":"x","Issuer":"x","Denomination":"x","IssueDate":"x","Printer":"x","Year":null}""");

            Assert.NotEmpty(BanknoteCatalogStore.Load());
        }
        finally
        {
            File.Delete(nullPath);
            File.Delete(unknownPath);
        }
    }

    [Fact]
    public void RefreshOverridesPersistAndReloadBanknoteMetadata()
    {
        var banknote = BanknoteCatalogStore.Load().First();
        var updated = banknote with
        {
            Title = "Test override title",
            Issuer = "Test override issuer",
            Denomination = "Test override denomination",
            IssueDate = "Test override date",
            Printer = "Test override printer",
            Year = 1901
        };
        var overridePath = GetOverridePath(banknote.Id);
        var previousOverride = File.Exists(overridePath) ? File.ReadAllBytes(overridePath) : null;

        try
        {
            BanknoteCatalogStore.SaveRefreshOverride(updated);

            var reloaded = BanknoteCatalogStore.Load().Single(note => note.Id == banknote.Id);
            Assert.Equal(updated.Title, reloaded.Title);
            Assert.Equal(updated.Issuer, reloaded.Issuer);
            Assert.Equal(updated.Denomination, reloaded.Denomination);
            Assert.Equal(updated.IssueDate, reloaded.IssueDate);
            Assert.Equal(updated.Printer, reloaded.Printer);
            Assert.Equal(updated.Year, reloaded.Year);
        }
        finally
        {
            RestoreOverride(overridePath, previousOverride);
        }
    }

    [Fact]
    public void CatalogRecordsMapAllBanknoteFields()
    {
        var record = new BanknoteCatalogRecord
        {
            CountryCode = "JPN",
            Region = "Asia",
            CollectionId = "japan-nippon-ginko",
            PickNumber = "22",
            PickSubnumber = "a",
            Title = "Bank of Japan",
            Country = "Japan",
            Year = 1942,
            SourceUrl = "https://example.test/source",
            FrontImageUrl = "https://example.test/front.jpg",
            BackImageUrl = "https://example.test/back.jpg",
            Issuer = "Bank of Japan",
            Denomination = "1 Yen",
            IssueDate = "1942",
            Printer = "Bank of Japan",
            VariantDescription = "Specimen"
        };

        var banknote = record.ToBanknote();

        Assert.Equal("JPN:22:a", banknote.Id);
        Assert.Equal("japan-nippon-ginko", banknote.CollectionId);
        Assert.Equal(record.FrontImageUrl, banknote.FrontImageUrl);
        Assert.Equal(record.BackImageUrl, banknote.BackImageUrl);
        Assert.Equal(record.VariantDescription, banknote.VariantDescription);
    }

    [Fact]
    public void ResearchAndCollectionRecordsMapTheirFields()
    {
        var research = new BanknoteResearchRecord
        {
            SimplifiedDescription = "简体",
            TraditionalDescription = "繁體",
            EnglishDescription = "English",
            JapaneseDescription = "日本語",
            Tags = ["rmb"],
            SourceName = "Wikipedia",
            SourceUrl = "https://example.test/research"
        }.ToResearch();
        var collection = new CatalogCollectionRecord
        {
            Id = "sample",
            Title = "Sample",
            Description = "Description",
            SourceUrl = "https://example.test/collection",
            Region = "Asia",
            Country = "Japan"
        }.ToCollection();

        Assert.Equal("日本語", research.JapaneseDescription);
        Assert.Equal(new[] { "rmb" }, research.Tags);
        Assert.Equal("sample", collection.Id);
        Assert.Equal("Asia", collection.Region);
        Assert.Equal("Japan", collection.Country);
    }

    [Fact]
    public void ImagePathResolvesOnlyRequestedPackagedImage()
    {
        var fileName = $"test-{Guid.NewGuid():N}.jpg";
        var imageDirectory = Path.Combine(AppContext.BaseDirectory, "Assets", "Banknotes");
        var imagePath = Path.Combine(imageDirectory, fileName);
        Directory.CreateDirectory(imageDirectory);

        try
        {
            File.WriteAllBytes(imagePath, [1, 2, 3]);
            var banknote = TestBanknoteFactory.Create(
                pickNumber: Guid.NewGuid().ToString("N"),
                frontImageUrl: $"https://example.test/{fileName}");

            Assert.Equal(imagePath, BanknoteCatalogStore.FindImagePath(banknote, front: true));
            Assert.Null(BanknoteCatalogStore.FindImagePath(banknote, front: false));
        }
        finally
        {
            File.Delete(imagePath);
        }
    }

    [Fact]
    public void ImageCachePathIsScopedToBanknoteAndSide()
    {
        var banknote = TestBanknoteFactory.Create(pickNumber: "J/1", frontImageUrl: "https://example.test/note.png");

        var cachePath = BanknoteCatalogStore.GetImageCachePath(banknote, front: true, banknote.FrontImageUrl!);

        Assert.Contains(Path.Combine("BanknoteImages", "CHN_J_1__", "front.png"), cachePath);
        Assert.EndsWith(Path.Combine("BanknoteImages", "CHN_J_1__", "front.jpg"),
            BanknoteCatalogStore.GetImageCachePath(banknote, front: true, "invalid-url"));
    }

    [Fact]
    public void ViewModelFiltersHierarchyAndSearchesVisibleNotes()
    {
        var viewModel = new CatalogViewModel();

        Assert.Equal(2929, viewModel.TotalCount);
        Assert.Equal("P-J1.b", viewModel.InitialSelection.PickLabel);
        Assert.Equal(166, viewModel.VisibleBanknotes.Count);

        viewModel.SelectCountry("Japan");
        Assert.Equal("Japan", viewModel.SelectedCountry);
        Assert.Equal(7, viewModel.CollectionOptions.Count);

        viewModel.SelectCollection("japan-nippon-ginko");
        viewModel.Filter("  P-22  ", "en-US");

        Assert.NotEmpty(viewModel.VisibleBanknotes);
        Assert.All(viewModel.VisibleBanknotes, entry => Assert.Contains("P-22", AppLocalization.SearchText(entry.Banknote, "en-US")));

        viewModel.Filter("no-such-banknote", "en-US");
        Assert.Empty(viewModel.VisibleBanknotes);
    }

    [Fact]
    public void ViewModelIgnoresUnknownHierarchySelectionsAndRestoresSearchResults()
    {
        var viewModel = new CatalogViewModel();
        var initialCollection = viewModel.SelectedCollection.Id;

        viewModel.SelectRegion("Atlantis");
        viewModel.SelectCountry("Atlantis");
        viewModel.SelectCollection("unknown-collection");
        viewModel.Filter("not found", "ja-JP");
        viewModel.Filter(null, "ja-JP");

        Assert.Equal("Asia", viewModel.SelectedRegion);
        Assert.Equal("China", viewModel.SelectedCountry);
        Assert.Equal(initialCollection, viewModel.SelectedCollection.Id);
        Assert.NotEmpty(viewModel.VisibleBanknotes);
    }

    [Fact]
    public void ViewModelChangesRegionAndRebuildsCountryAndCollectionOptions()
    {
        var asia = new CatalogCollection("asia", "Asia notes", "Asia description", "https://example.test/asia")
        {
            Region = "Asia",
            Country = "China"
        };
        var europe = new CatalogCollection("europe", "Europe notes", "Europe description", "https://example.test/europe")
        {
            Region = "Europe",
            Country = "Germany"
        };
        var asiaNote = TestBanknoteFactory.Create(pickNumber: "asia") with
        {
            Region = "Asia",
            CollectionId = asia.Id
        };
        var europeNote = TestBanknoteFactory.Create(pickNumber: "europe") with
        {
            Region = "Europe",
            Country = "Germany",
            CollectionId = europe.Id
        };
        var viewModel = new CatalogViewModel([asia, europe], [asiaNote, europeNote]);

        viewModel.SelectRegion("Europe");
        viewModel.Filter(null, "en-US");

        Assert.Equal("Europe", viewModel.SelectedRegion);
        Assert.Equal("Germany", viewModel.SelectedCountry);
        Assert.Equal(europe.Id, viewModel.SelectedCollection.Id);
        Assert.Single(viewModel.VisibleBanknotes);
        Assert.Equal("Germany", viewModel.VisibleBanknotes[0].Banknote.Country);
        Assert.NotEmpty(viewModel.VisibleBanknotes[0].PickLabel);
        Assert.NotEmpty(viewModel.VisibleBanknotes[0].Issuer);
        Assert.NotEmpty(viewModel.VisibleBanknotes[0].Denomination);
        Assert.NotEmpty(viewModel.VisibleBanknotes[0].VariantCaption);
    }

    [Fact]
    public void ViewModelReplacesKnownBanknoteAndIgnoresUnknownBanknote()
    {
        var viewModel = new CatalogViewModel();
        var banknote = viewModel.VisibleBanknotes.First().Banknote;
        var overridePath = GetOverridePath(banknote.Id);
        var previousOverride = File.Exists(overridePath) ? File.ReadAllBytes(overridePath) : null;
        var updated = banknote with { Issuer = "Updated test issuer" };

        try
        {
            viewModel.Replace(TestBanknoteFactory.Create(pickNumber: "missing"));
            viewModel.Replace(updated);
            viewModel.Filter(null, "en-US");

            Assert.Equal("Updated test issuer", viewModel.VisibleBanknotes.Single(entry => entry.Banknote.Id == banknote.Id).Banknote.Issuer);
        }
        finally
        {
            RestoreOverride(overridePath, previousOverride);
        }
    }

    private static string GetOverridePath(string id)
    {
        var safeId = string.Concat(id.Select(character => char.IsLetterOrDigit(character) ? character : '_'));
        return Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "NumismaticsDex",
            "Overrides",
            safeId + ".json");
    }

    private static void RestoreOverride(string path, byte[]? contents)
    {
        if (contents is null)
        {
            File.Delete(path);
            return;
        }

        File.WriteAllBytes(path, contents);
    }
}