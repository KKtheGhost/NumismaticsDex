using System.Net;
using NumismaticsDex.App;

namespace NumismaticsDex.Tests;

public sealed class SourceRefreshTests
{
    [Fact]
    public async Task RefreshAsyncParsesFieldsAndStreamsBothImagesToCache()
    {
        var noteId = Guid.NewGuid().ToString("N");
        var frontUrl = $"https://images.example.test/{noteId}-front.jpg";
        var backUrl = $"https://images.example.test/{noteId}-back.jpg";
        var banknote = TestBanknoteFactory.Create(
            pickNumber: noteId,
            frontImageUrl: frontUrl,
            backImageUrl: backUrl) with
        {
            SourceUrl = "https://example.test/detail"
        };
        const string html = """
            <table>
              <tr><td><b><font>Issued by</font></b></td><td>New &amp; Improved Bank</td></tr>
              <tr><td><b><font>Value</font></b></td><td>5 Dollars</td></tr>
              <tr><td><b><font>Date</font></b></td><td>Year 29 of the Republic (1940), revised 1941</td></tr>
              <tr><td><b><font>Printer</font></b></td><td>Test Printing Works</td></tr>
            </table>
            """;
        var requests = new List<string>();
        var frontBytes = new byte[] { 1, 2, 3 };
        var backBytes = new byte[] { 4, 5, 6 };
        using var client = new HttpClient(new StubHttpMessageHandler(request =>
        {
            requests.Add(request.RequestUri!.AbsoluteUri);
            if (request.RequestUri.AbsoluteUri == banknote.SourceUrl)
            {
                return StubHttpMessageHandler.Ok(new StringContent(html));
            }

            return StubHttpMessageHandler.Ok(new ByteArrayContent(
                request.RequestUri.AbsoluteUri == frontUrl ? frontBytes : backBytes));
        }));
        var frontCache = BanknoteCatalogStore.GetImageCachePath(banknote, front: true, frontUrl);
        var backCache = BanknoteCatalogStore.GetImageCachePath(banknote, front: false, backUrl);

        try
        {
            var updated = await new BanknoteSourceService(client).RefreshAsync(banknote);

            Assert.Equal("New & Improved Bank", updated.Title);
            Assert.Equal("New & Improved Bank", updated.Issuer);
            Assert.Equal("5 Dollars", updated.Denomination);
            Assert.Equal(1941, updated.Year);
            Assert.Equal("Test Printing Works", updated.Printer);
            Assert.Equal(3, requests.Count);
            Assert.Equal(frontBytes, await File.ReadAllBytesAsync(frontCache));
            Assert.Equal(backBytes, await File.ReadAllBytesAsync(backCache));
        }
        finally
        {
            DeleteCache(frontCache);
        }
    }

    [Fact]
    public async Task RefreshAsyncPreservesExistingFieldsWhenSourceFieldsAreMissing()
    {
        var banknote = TestBanknoteFactory.Create() with { SourceUrl = "https://example.test/detail" };
        using var client = new HttpClient(new StubHttpMessageHandler(_ => StubHttpMessageHandler.Ok(new StringContent("<html></html>"))));

        var updated = await new BanknoteSourceService(client).RefreshAsync(banknote);

        Assert.Equal(banknote.Title, updated.Title);
        Assert.Equal(banknote.Issuer, updated.Issuer);
        Assert.Equal(banknote.Denomination, updated.Denomination);
        Assert.Equal(banknote.IssueDate, updated.IssueDate);
        Assert.Equal(banknote.Year, updated.Year);
    }

    [Fact]
    public async Task RefreshAsyncRejectsMissingSourceAndPropagatesHttpFailures()
    {
        var banknote = TestBanknoteFactory.Create();
        using var client = new HttpClient(new StubHttpMessageHandler(_ => new HttpResponseMessage(HttpStatusCode.ServiceUnavailable)));
        var service = new BanknoteSourceService(client);

        Assert.False(BanknoteSourceService.CanRefresh(banknote with { SourceUrl = "" }));
        await Assert.ThrowsAsync<InvalidOperationException>(() => service.RefreshAsync(banknote with { SourceUrl = "" }));
        await Assert.ThrowsAsync<HttpRequestException>(() => service.RefreshAsync(banknote with { SourceUrl = "https://example.test/detail" }));
        Assert.True(BanknoteSourceService.CanRefresh(banknote));
    }

    [Fact]
    public async Task RefreshAsyncRejectsEmptyImageResponses()
    {
        var noteId = Guid.NewGuid().ToString("N");
        var imageUrl = $"https://images.example.test/{noteId}.jpg";
        var banknote = TestBanknoteFactory.Create(pickNumber: noteId, frontImageUrl: imageUrl) with
        {
            SourceUrl = "https://example.test/detail"
        };
        using var client = new HttpClient(new StubHttpMessageHandler(request => request.RequestUri!.AbsoluteUri == banknote.SourceUrl
            ? StubHttpMessageHandler.Ok(new StringContent("<html></html>"))
            : StubHttpMessageHandler.Ok(new ByteArrayContent([]))));
        var cachePath = BanknoteCatalogStore.GetImageCachePath(banknote, front: true, imageUrl);

        try
        {
            await Assert.ThrowsAsync<InvalidDataException>(() => new BanknoteSourceService(client).RefreshAsync(banknote));
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