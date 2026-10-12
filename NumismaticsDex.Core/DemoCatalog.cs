namespace NumismaticsDex.Core;

public static class DemoCatalog
{
    private const string CategoryUrl =
        "http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PUP/CIN-PUP.htm";
    private const string PeoplesRepublicCategoryUrl =
        "http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PR/CIN-PR.htm";
    private const string ManchukuoCategoryUrl =
        "http://www.banknote.ws/COLLECTION/countries/ASI/MNK/MNK.htm";
    private const string EmpireCategoryUrl =
        "http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-EMP/CIN-EMP.htm";
    private const string NoteUrl =
        "http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PUP/CINJ0001.htm";

    public static CatalogCollection Collection { get; } = new(
        "china-japanese-puppet-banks",
        "CHINA - Japanese Puppet Banks",
        "Paper money issued by banks under Japanese occupation in China.",
        CategoryUrl)
    {
        Region = "Asia",
        Country = "China"
    };

    public static CatalogCollection PeoplesRepublicCollection { get; } = new(
        "china-peoples-republic",
        "CHINA - People's Republic",
        "Renminbi banknotes, foreign exchange certificates, and military payment certificates issued in the People's Republic of China.",
        PeoplesRepublicCategoryUrl)
    {
        Region = "Asia",
        Country = "China"
    };

    public static CatalogCollection ManchukuoCollection { get; } = new(
        "manchukuo",
        "MANCHUKUO",
        "Paper money issued in Manchukuo by its central bank.",
        ManchukuoCategoryUrl)
    {
        Region = "Asia",
        Country = "China"
    };

    public static CatalogCollection EmpireCollection { get; } = new(
        "china-empire",
        "CHINA - Empire",
        "Ming and Qing dynasty banknotes and later imperial Chinese issues.",
        EmpireCategoryUrl)
    {
        Region = "Asia",
        Country = "China"
    };

    public static IReadOnlyList<CatalogCollection> Collections => [Collection, PeoplesRepublicCollection, ManchukuoCollection, EmpireCollection];

    public static IReadOnlyList<Banknote> Banknotes { get; } =
    [
        new Banknote(
            "CHN", "J1", "a", "Central Reserve Bank of China", "China", 1940,
            NoteUrl,
            "http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PUP/CINJ0001ao.jpg",
            "http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PUP/CINJ0001ar.jpg",
            "Central Reserve Bank of China", "1 Cent",
            "Year 29 of the Republic (1940)", "Watson Printing Company",
            "With printer's name and serial number."),
        new Banknote(
            "CHN", "J1", "b", "Central Reserve Bank of China", "China", 1940,
            NoteUrl,
            "http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PUP/CINJ0001bo.jpg",
            "http://www.banknote.ws/COLLECTION/countries/ASI/CIN/CIN-PUP/CINJ0001br.jpg",
            "Central Reserve Bank of China", "1 Cent",
            "Year 29 of the Republic (1940)", "Watson Printing Company",
            "Without Printer's name Block # only.")
    ];
}