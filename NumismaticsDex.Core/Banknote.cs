namespace NumismaticsDex.Core;

public sealed record Banknote : CatalogItem
{
    public Banknote(
        string countryCode,
        string pickNumber,
        string? pickSubnumber,
        string title,
        string country,
        int? year,
        string sourceUrl,
        string? frontImageUrl,
        string? backImageUrl,
        string issuer,
        string denomination,
        string issueDate,
        string printer,
        string variantDescription)
        : base(
            $"{countryCode}:{pickNumber}:{pickSubnumber ?? "-"}",
            CollectibleKind.Banknote,
            title,
            country,
            year,
            sourceUrl,
            frontImageUrl,
            backImageUrl)
    {
        CountryCode = countryCode;
        PickNumber = pickNumber;
        PickSubnumber = pickSubnumber;
        Issuer = issuer;
        Denomination = denomination;
        IssueDate = issueDate;
        Printer = printer;
        VariantDescription = variantDescription;
    }

    public string CountryCode { get; init; }
    public string Region { get; init; } = "Asia";
    public string CollectionId { get; init; } = "china-japanese-puppet-banks";
    public string PickNumber { get; init; }
        public string? PickSubnumber { get; init; }
    public string Issuer { get; init; }
    public string Denomination { get; init; }
    public string IssueDate { get; init; }
    public string Printer { get; init; }
    public string VariantDescription { get; init; }
    public BanknoteResearch? Research { get; init; }

    public string PickLabel => PickSubnumber is null
        ? $"P-{PickNumber}"
        : PickSubnumber.StartsWith('(')
            ? $"P-{PickNumber}{PickSubnumber}"
            : $"P-{PickNumber}.{PickSubnumber}";

    public string VariantCaption => string.IsNullOrWhiteSpace(VariantDescription)
        ? PickSubnumber is null ? "Standard issue" : $"Variant {PickSubnumber}"
        : VariantDescription;
}

public sealed record BanknoteResearch(
    string SimplifiedDescription,
    string TraditionalDescription,
    string EnglishDescription,
    string JapaneseDescription,
    IReadOnlyList<string> Tags,
    string SourceName,
    string SourceUrl);