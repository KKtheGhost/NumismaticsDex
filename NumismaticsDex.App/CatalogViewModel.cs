using System.Collections.ObjectModel;
using NumismaticsDex.Core;

namespace NumismaticsDex.App;

public sealed record BanknoteListEntry(
    Banknote Banknote,
    string PickLabel,
    string Issuer,
    string Denomination,
    string VariantCaption);

public sealed class CatalogViewModel
{
    private readonly List<Banknote> _allBanknotes;
    private readonly List<CatalogCollection> _allCollections;
    private string _selectedCollectionId = string.Empty;

    public int TotalCount => _allBanknotes.Count;
    public ObservableCollection<string> RegionOptions { get; } = new();
    public ObservableCollection<string> CountryOptions { get; } = new();
    public ObservableCollection<CatalogCollection> CollectionOptions { get; } = new();
    public string SelectedRegion { get; private set; } = string.Empty;
    public string SelectedCountry { get; private set; } = string.Empty;
    public CatalogCollection SelectedCollection =>
        _allCollections.First(collection => collection.Id == _selectedCollectionId);

    public ObservableCollection<BanknoteListEntry> VisibleBanknotes { get; } = new();

    public CatalogViewModel()
        : this(BanknoteCatalogStore.LoadCollections(), BanknoteCatalogStore.Load())
    {
    }

    internal CatalogViewModel(IEnumerable<CatalogCollection> collections, IEnumerable<Banknote> banknotes)
    {
        _allCollections = collections.ToList();
        var countryByCollection = _allCollections.ToDictionary(collection => collection.Id, collection => collection.Country);
        _allBanknotes = banknotes
            .Select(banknote => countryByCollection.TryGetValue(banknote.CollectionId, out var country)
                ? banknote with { Country = country }
                : banknote)
            .ToList();

        foreach (var region in _allCollections.Select(collection => collection.Region).Distinct())
        {
            RegionOptions.Add(region);
        }
        SelectedRegion = RegionOptions.FirstOrDefault() ?? string.Empty;
        RebuildCountryOptions();
        Filter(null, "zh-CN");
    }

    public Banknote InitialSelection =>
        _allBanknotes.FirstOrDefault(banknote => banknote.PickNumber == "J1" && banknote.PickSubnumber == "b")
        ?? _allBanknotes.First();

    public void Replace(Banknote updated)
    {
        var index = _allBanknotes.FindIndex(banknote => banknote.Id == updated.Id);
        if (index < 0)
        {
            return;
        }

        _allBanknotes[index] = updated;
        BanknoteCatalogStore.SaveRefreshOverride(updated);
    }

    public void SelectRegion(string region)
    {
        if (!RegionOptions.Contains(region) || SelectedRegion == region)
        {
            return;
        }

        SelectedRegion = region;
        RebuildCountryOptions();
    }

    public void SelectCountry(string country)
    {
        if (!CountryOptions.Contains(country) || SelectedCountry == country)
        {
            return;
        }

        SelectedCountry = country;
        RebuildCollectionOptions();
    }

    public void SelectCollection(string collectionId)
    {
        if (CollectionOptions.Any(collection => collection.Id == collectionId))
        {
            _selectedCollectionId = collectionId;
        }
    }

    public void Filter(string? query, string languageTag)
    {
        var search = query?.Trim();
        var matches = _allBanknotes.Where(banknote =>
            banknote.Region == SelectedRegion &&
            banknote.Country == SelectedCountry &&
            banknote.CollectionId == _selectedCollectionId);

        if (!string.IsNullOrEmpty(search))
        {
            matches = matches.Where(banknote =>
                AppLocalization.SearchText(banknote, languageTag)
                    .Contains(search, StringComparison.OrdinalIgnoreCase));
        }

        VisibleBanknotes.Clear();
        foreach (var banknote in matches)
        {
            VisibleBanknotes.Add(new BanknoteListEntry(
                banknote,
                banknote.PickLabel,
                AppLocalization.Issuer(banknote, languageTag),
                AppLocalization.Denomination(banknote, languageTag),
                AppLocalization.Variant(banknote, languageTag)));
        }
    }

    private void RebuildCountryOptions()
    {
        CountryOptions.Clear();
        foreach (var country in _allCollections
                     .Where(collection => collection.Region == SelectedRegion)
                     .Select(collection => collection.Country)
                     .Distinct())
        {
            CountryOptions.Add(country);
        }

        SelectedCountry = CountryOptions.FirstOrDefault() ?? string.Empty;
        RebuildCollectionOptions();
    }

    private void RebuildCollectionOptions()
    {
        CollectionOptions.Clear();
        foreach (var collection in _allCollections.Where(collection =>
                     collection.Region == SelectedRegion && collection.Country == SelectedCountry))
        {
            CollectionOptions.Add(collection);
        }

        if (!CollectionOptions.Any(collection => collection.Id == _selectedCollectionId))
        {
            _selectedCollectionId = CollectionOptions.FirstOrDefault()?.Id ?? string.Empty;
        }
    }
}