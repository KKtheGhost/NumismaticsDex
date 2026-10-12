using System.Text.Json;
using NumismaticsDex.Core;

namespace NumismaticsDex.App;

public sealed record BanknoteRefreshOverride(
    string Id,
    string Title,
    string Issuer,
    string Denomination,
    string IssueDate,
    string Printer,
    int? Year);

public sealed class BanknoteCatalogRecord
{
    public string CountryCode { get; init; } = string.Empty;
    public string Region { get; init; } = "Asia";
    public string CollectionId { get; init; } = "china-japanese-puppet-banks";
    public string PickNumber { get; init; } = string.Empty;
    public string? PickSubnumber { get; init; }
    public string Title { get; init; } = string.Empty;
    public string Country { get; init; } = string.Empty;
    public int? Year { get; init; }
    public string SourceUrl { get; init; } = string.Empty;
    public string? FrontImageUrl { get; init; }
    public string? BackImageUrl { get; init; }
    public string Issuer { get; init; } = string.Empty;
    public string Denomination { get; init; } = string.Empty;
    public string IssueDate { get; init; } = string.Empty;
    public string Printer { get; init; } = string.Empty;
    public string VariantDescription { get; init; } = string.Empty;

    public Banknote ToBanknote() => new(
        CountryCode,
        PickNumber,
        PickSubnumber,
        Title,
        Country,
        Year,
        SourceUrl,
        FrontImageUrl,
        BackImageUrl,
        Issuer,
        Denomination,
        IssueDate,
        Printer,
        VariantDescription)
    {
        Region = Region,
        CollectionId = CollectionId
    };
}

public sealed class CatalogCollectionRecord
{
    public string Id { get; init; } = string.Empty;
    public string Title { get; init; } = string.Empty;
    public string Description { get; init; } = string.Empty;
    public string SourceUrl { get; init; } = string.Empty;
    public string Region { get; init; } = string.Empty;
    public string Country { get; init; } = string.Empty;

    public CatalogCollection ToCollection() => new(Id, Title, Description, SourceUrl)
    {
        Region = Region,
        Country = Country
    };
}

public sealed class BanknoteResearchRecord
{
    public string CollectionId { get; init; } = string.Empty;
    public string PickNumber { get; init; } = string.Empty;
    public string SimplifiedDescription { get; init; } = string.Empty;
    public string TraditionalDescription { get; init; } = string.Empty;
    public string EnglishDescription { get; init; } = string.Empty;
    public string JapaneseDescription { get; init; } = string.Empty;
    public string[] Tags { get; init; } = [];
    public string SourceName { get; init; } = string.Empty;
    public string SourceUrl { get; init; } = string.Empty;

    public BanknoteResearch ToResearch() => new(
        SimplifiedDescription,
        TraditionalDescription,
        EnglishDescription,
        JapaneseDescription,
        Tags,
        SourceName,
        SourceUrl);
}

public static class BanknoteCatalogStore
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true
    };

    private static string LocalRoot => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "NumismaticsDex");

    public static IReadOnlyList<Banknote> Load()
    {
        var catalogPath = Path.Combine(AppContext.BaseDirectory, "Assets", "catalog.json");
        List<Banknote>? banknotes = null;

        if (File.Exists(catalogPath))
        {
            using var catalog = JsonDocument.Parse(File.ReadAllText(catalogPath));
            var researchByPick = new Dictionary<string, BanknoteResearch>(StringComparer.Ordinal);
            if (catalog.RootElement.TryGetProperty("researchNotes", out var researchArray))
            {
                var researchRecords = researchArray.Deserialize<List<BanknoteResearchRecord>>(JsonOptions);
                if (researchRecords is not null)
                {
                    foreach (var record in researchRecords)
                    {
                        researchByPick[$"{record.CollectionId}:{record.PickNumber}"] = record.ToResearch();
                    }
                }
            }

            if (catalog.RootElement.TryGetProperty("banknotes", out var banknoteArray))
            {
                var records = banknoteArray.Deserialize<List<BanknoteCatalogRecord>>(JsonOptions);
                banknotes = records?.Select(record =>
                {
                    var banknote = record.ToBanknote();
                    return researchByPick.TryGetValue($"{banknote.CollectionId}:{banknote.PickNumber}", out var research)
                        ? banknote with { Research = research }
                        : banknote;
                }).ToList();
            }
        }

        banknotes ??= DemoCatalog.Banknotes.ToList();
        ApplyRefreshOverrides(banknotes);
        return banknotes;
    }

    public static IReadOnlyList<CatalogCollection> LoadCollections()
    {
        var catalogPath = Path.Combine(AppContext.BaseDirectory, "Assets", "catalog.json");
        if (File.Exists(catalogPath))
        {
            using var catalog = JsonDocument.Parse(File.ReadAllText(catalogPath));
            if (catalog.RootElement.TryGetProperty("collections", out var collectionArray))
            {
                var records = collectionArray.Deserialize<List<CatalogCollectionRecord>>(JsonOptions);
                if (records is { Count: > 0 })
                {
                    return records.Select(record => record.ToCollection()).ToList();
                }
            }
        }

        return DemoCatalog.Collections;
    }

    public static string? FindImagePath(Banknote banknote, bool front)
    {
        var source = front ? banknote.FrontImageUrl : banknote.BackImageUrl;
        if (!Uri.TryCreate(source, UriKind.Absolute, out var sourceUri))
        {
            return null;
        }

        var side = front ? "front" : "back";
        var extension = Path.GetExtension(sourceUri.LocalPath);
        var cached = Path.Combine(LocalRoot, "BanknoteImages", SafeId(banknote.Id), side + extension);
        if (File.Exists(cached))
        {
            return cached;
        }

        var packaged = Path.Combine(AppContext.BaseDirectory, "Assets", "Banknotes", Path.GetFileName(sourceUri.LocalPath));
        return File.Exists(packaged) ? packaged : null;
    }

    public static string GetImageCachePath(Banknote banknote, bool front, string sourceUrl)
    {
        var extension = Uri.TryCreate(sourceUrl, UriKind.Absolute, out var sourceUri)
            ? Path.GetExtension(sourceUri.LocalPath)
            : ".jpg";
        var side = front ? "front" : "back";
        return Path.Combine(LocalRoot, "BanknoteImages", SafeId(banknote.Id), side + extension);
    }

    public static void SaveRefreshOverride(Banknote banknote)
    {
        var directory = Path.Combine(LocalRoot, "Overrides");
        Directory.CreateDirectory(directory);
        var snapshot = new BanknoteRefreshOverride(
            banknote.Id,
            banknote.Title,
            banknote.Issuer,
            banknote.Denomination,
            banknote.IssueDate,
            banknote.Printer,
            banknote.Year);
        var json = JsonSerializer.Serialize(snapshot, JsonOptions);
        File.WriteAllText(Path.Combine(directory, SafeId(banknote.Id) + ".json"), json);
    }

    private static void ApplyRefreshOverrides(List<Banknote> banknotes)
    {
        var directory = Path.Combine(LocalRoot, "Overrides");
        if (!Directory.Exists(directory))
        {
            return;
        }

        foreach (var file in Directory.EnumerateFiles(directory, "*.json"))
        {
            var snapshot = JsonSerializer.Deserialize<BanknoteRefreshOverride>(File.ReadAllText(file), JsonOptions);
            if (snapshot is null)
            {
                continue;
            }

            var index = banknotes.FindIndex(banknote => banknote.Id == snapshot.Id);
            if (index >= 0)
            {
                banknotes[index] = banknotes[index] with
                {
                    Title = snapshot.Title,
                    Issuer = snapshot.Issuer,
                    Denomination = snapshot.Denomination,
                    IssueDate = snapshot.IssueDate,
                    Printer = snapshot.Printer,
                    Year = snapshot.Year
                };
            }
        }
    }

    private static string SafeId(string id) =>
        string.Concat(id.Select(character => char.IsLetterOrDigit(character) ? character : '_'));
}