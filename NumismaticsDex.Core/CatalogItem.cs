namespace NumismaticsDex.Core;

public enum CollectibleKind
{
    Banknote,
    Coin,
    Medal
}

public abstract record CatalogItem(
    string Id,
    CollectibleKind Kind,
    string Title,
    string Country,
    int? Year,
    string SourceUrl,
    string? FrontImageUrl,
    string? BackImageUrl);

public sealed record CatalogCollection(
    string Id,
    string Title,
    string Description,
    string SourceUrl)
{
    public string Region { get; init; } = string.Empty;
    public string Country { get; init; } = string.Empty;
}
