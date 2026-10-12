using System.Net;
using NumismaticsDex.App;

namespace NumismaticsDex.Tests;

public sealed class ImageLoadingTests
{
    [Fact]
    public async Task DefaultHttpClientsInitializeWithoutNetworkForUnsupportedOperations()
    {
        var banknote = TestBanknoteFactory.Create(frontImageUrl: "file:///unsupported-image.jpg");

        Assert.Null(await new BanknoteImageService().LoadAsync(banknote, front: true));
        await Assert.ThrowsAsync<InvalidOperationException>(() =>
            new BanknoteSourceService().RefreshAsync(banknote with { SourceUrl = "" }));
    }

    [Fact]
    public async Task LoadAsyncDownloadsOnlyTheRequestedSideAndReusesDiskCache()
    {
        var noteId = Guid.NewGuid().ToString("N");
        var frontUrl = $"https://images.example.test/{noteId}-front.jpg";
        var banknote = TestBanknoteFactory.Create(
            pickNumber: noteId,
            frontImageUrl: frontUrl,
            backImageUrl: $"https://images.example.test/{noteId}-back.jpg");
        var requestCount = 0;
        var bytes = Enumerable.Range(0, 32_768).Select(value => (byte)value).ToArray();
        using var client = new HttpClient(new StubHttpMessageHandler(_ =>
        {
            Interlocked.Increment(ref requestCount);
            return StubHttpMessageHandler.Ok(new ByteArrayContent(bytes));
        }));
        var service = new BanknoteImageService(client);
        var cachePath = BanknoteCatalogStore.GetImageCachePath(banknote, front: true, frontUrl);
        var backCachePath = BanknoteCatalogStore.GetImageCachePath(banknote, front: false, banknote.BackImageUrl!);

        try
        {
            var firstPath = await service.LoadAsync(banknote, front: true);
            Assert.Equal(1, requestCount);
            Assert.False(File.Exists(backCachePath));

            var cachedPath = await service.LoadAsync(banknote, front: true);
            var backPath = await service.LoadAsync(banknote, front: false);

            Assert.Equal(cachePath, firstPath);
            Assert.Equal(firstPath, cachedPath);
            Assert.Equal(backCachePath, backPath);
            Assert.Equal(2, requestCount);
            Assert.Equal(bytes, await File.ReadAllBytesAsync(cachePath));
        }
        finally
        {
            DeleteCache(cachePath);
        }
    }

    [Fact]
    public async Task LoadAsyncPrefersPackagedOrCachedImageWithoutNetwork()
    {
        var noteId = Guid.NewGuid().ToString("N");
        var url = $"https://images.example.test/{noteId}.jpg";
        var banknote = TestBanknoteFactory.Create(pickNumber: noteId, frontImageUrl: url);
        var cachePath = BanknoteCatalogStore.GetImageCachePath(banknote, front: true, url);
        var requestCount = 0;
        using var client = new HttpClient(new StubHttpMessageHandler(_ =>
        {
            Interlocked.Increment(ref requestCount);
            return StubHttpMessageHandler.Ok(new ByteArrayContent([1]));
        }));

        Directory.CreateDirectory(Path.GetDirectoryName(cachePath)!);
        try
        {
            await File.WriteAllBytesAsync(cachePath, [9, 8, 7]);

            var result = await new BanknoteImageService(client).LoadAsync(banknote, front: true);

            Assert.Equal(cachePath, result);
            Assert.Equal(0, requestCount);
        }
        finally
        {
            DeleteCache(cachePath);
        }
    }

    [Fact]
    public async Task LoadAsyncSkipsMissingAndUnsupportedImageUrls()
    {
        var noteId = Guid.NewGuid().ToString("N");
        var banknote = TestBanknoteFactory.Create(
            pickNumber: noteId,
            frontImageUrl: "file:///not-a-network-image.jpg");
        var requestCount = 0;
        using var client = new HttpClient(new StubHttpMessageHandler(_ =>
        {
            Interlocked.Increment(ref requestCount);
            return StubHttpMessageHandler.Ok(new ByteArrayContent([1]));
        }));
        var service = new BanknoteImageService(client);

        Assert.Null(await service.LoadAsync(banknote, front: true));
        Assert.Null(await service.LoadAsync(banknote, front: false));
        Assert.Equal(0, requestCount);
    }

    [Fact]
    public async Task LoadAsyncRejectsHttpErrorsAndEmptyImagesWithoutLeavingCacheFiles()
    {
        var noteId = Guid.NewGuid().ToString("N");
        var url = $"https://images.example.test/{noteId}.jpg";
        var banknote = TestBanknoteFactory.Create(pickNumber: noteId, frontImageUrl: url);
        var cachePath = BanknoteCatalogStore.GetImageCachePath(banknote, front: true, url);

        using (var errorClient = new HttpClient(new StubHttpMessageHandler(_ => new HttpResponseMessage(HttpStatusCode.NotFound))))
        {
            await Assert.ThrowsAsync<HttpRequestException>(() => new BanknoteImageService(errorClient).LoadAsync(banknote, front: true));
        }

        using (var emptyClient = new HttpClient(new StubHttpMessageHandler(_ => StubHttpMessageHandler.Ok(new ByteArrayContent([])))))
        {
            await Assert.ThrowsAsync<InvalidDataException>(() => new BanknoteImageService(emptyClient).LoadAsync(banknote, front: true));
        }

        try
        {
            Assert.False(File.Exists(cachePath));
            Assert.False(File.Exists(cachePath + ".tmp"));
        }
        finally
        {
            DeleteCache(cachePath);
        }
    }

    private static void DeleteCache(string cachePath)
    {
        var directory = Path.GetDirectoryName(cachePath);
        if (directory is not null && Directory.Exists(directory))
        {
            Directory.Delete(directory, recursive: true);
        }
    }
}