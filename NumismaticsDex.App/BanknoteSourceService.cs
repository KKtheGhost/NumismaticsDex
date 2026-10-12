using System.Net;
using System.Net.Http;
using System.Text.RegularExpressions;
using NumismaticsDex.Core;

namespace NumismaticsDex.App;

public sealed class BanknoteSourceService
{
    private static readonly HttpClient Client = new(new HttpClientHandler
    {
        AllowAutoRedirect = true
    })
    {
        Timeout = TimeSpan.FromSeconds(40)
    };

    private readonly HttpClient _client;

    public BanknoteSourceService(HttpClient? client = null)
    {
        _client = client ?? Client;
    }

    public static bool CanRefresh(Banknote banknote) =>
        Uri.TryCreate(banknote.SourceUrl, UriKind.Absolute, out _);

    public async Task<Banknote> RefreshAsync(Banknote banknote, CancellationToken cancellationToken = default)
    {
        if (!CanRefresh(banknote))
        {
            throw new InvalidOperationException("This note has no source page.");
        }

        using var pageResponse = await _client.GetAsync(banknote.SourceUrl, cancellationToken);
        pageResponse.EnsureSuccessStatusCode();
        var html = await pageResponse.Content.ReadAsStringAsync(cancellationToken);

        var issuer = ReadField(html, "Issued by");
        var denomination = ReadField(html, "Value");
        var issueDate = ReadField(html, "Date");
        var printer = ReadField(html, "Printer");
        var year = ReadYear(issueDate) ?? banknote.Year;
        var updated = banknote with
        {
            Title = string.IsNullOrWhiteSpace(issuer) ? banknote.Title : issuer,
            Issuer = string.IsNullOrWhiteSpace(issuer) ? banknote.Issuer : issuer,
            Denomination = string.IsNullOrWhiteSpace(denomination) ? banknote.Denomination : denomination,
            IssueDate = string.IsNullOrWhiteSpace(issueDate) ? banknote.IssueDate : issueDate,
            Printer = string.IsNullOrWhiteSpace(printer) ? banknote.Printer : printer,
            Year = year
        };

        if (!string.IsNullOrWhiteSpace(banknote.FrontImageUrl))
        {
            await DownloadImageAsync(banknote, true, banknote.FrontImageUrl, cancellationToken);
        }
        if (!string.IsNullOrWhiteSpace(banknote.BackImageUrl))
        {
            await DownloadImageAsync(banknote, false, banknote.BackImageUrl, cancellationToken);
        }

        return updated;
    }

    private async Task DownloadImageAsync(
        Banknote banknote,
        bool front,
        string imageUrl,
        CancellationToken cancellationToken)
    {
        using var response = await _client.GetAsync(imageUrl, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        response.EnsureSuccessStatusCode();
        var path = BanknoteCatalogStore.GetImageCachePath(banknote, front, imageUrl);
        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        var temporaryPath = path + ".tmp";

        try
        {
            await using var source = await response.Content.ReadAsStreamAsync(cancellationToken);
            await using var destination = new FileStream(
                temporaryPath,
                FileMode.Create,
                FileAccess.Write,
                FileShare.None,
                81920,
                FileOptions.Asynchronous | FileOptions.SequentialScan);
            await source.CopyToAsync(destination, cancellationToken);
            if (destination.Length == 0)
            {
                throw new InvalidDataException("The source returned an empty image.");
            }
        }
        catch
        {
            File.Delete(temporaryPath);
            throw;
        }

        File.Move(temporaryPath, path, true);
    }

    private static string ReadField(string html, string label)
    {
        var pattern = "(?is)<td\\b[^>]*>\\s*<b>\\s*<font\\b[^>]*>\\s*" +
            Regex.Escape(label) +
            "\\s*</font>\\s*</b>\\s*</td>\\s*<td\\b[^>]*>(?<value>.*?)</td>";
        var match = Regex.Match(html, pattern);
        if (!match.Success)
        {
            return string.Empty;
        }

        var plainText = Regex.Replace(match.Groups["value"].Value, "(?is)<br\\s*/?>", " ");
        plainText = Regex.Replace(plainText, "(?s)<[^>]+>", " ");
        return Regex.Replace(WebUtility.HtmlDecode(plainText), "\\s+", " ").Trim();
    }

    private static int? ReadYear(string issueDate)
    {
        var years = Regex.Matches(issueDate, "\\b(?:18|19|20)[0-9]{2}\\b");
        return years.Count == 0 ? null : int.Parse(years[years.Count - 1].Value);
    }
}