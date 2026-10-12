using System.Net.Http;
using NumismaticsDex.Core;

namespace NumismaticsDex.App;

public sealed class BanknoteImageService
{
    private static readonly HttpClient Client = new(new HttpClientHandler
    {
        AllowAutoRedirect = true
    })
    {
        Timeout = TimeSpan.FromSeconds(30)
    };

    private readonly HttpClient _client;

    public BanknoteImageService(HttpClient? client = null)
    {
        _client = client ?? Client;
    }

    public async Task<string?> LoadAsync(Banknote banknote, bool front, CancellationToken cancellationToken = default)
    {
        var cachedPath = BanknoteCatalogStore.FindImagePath(banknote, front);
        if (cachedPath is not null)
        {
            return cachedPath;
        }

        var imageUrl = front ? banknote.FrontImageUrl : banknote.BackImageUrl;
        if (!Uri.TryCreate(imageUrl, UriKind.Absolute, out var imageUri) ||
            imageUri.Scheme is not ("http" or "https"))
        {
            return null;
        }

        using var response = await _client.GetAsync(imageUri, HttpCompletionOption.ResponseHeadersRead, cancellationToken);
        response.EnsureSuccessStatusCode();

        var cachePath = BanknoteCatalogStore.GetImageCachePath(banknote, front, imageUrl!);
        Directory.CreateDirectory(Path.GetDirectoryName(cachePath)!);
        var temporaryPath = cachePath + ".tmp";

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
                throw new InvalidDataException("The image source returned an empty response.");
            }
        }
        catch
        {
            File.Delete(temporaryPath);
            throw;
        }

        File.Move(temporaryPath, cachePath, true);
        return cachePath;
    }
}