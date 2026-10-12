using System.Net;

namespace NumismaticsDex.Tests;

internal sealed class StubHttpMessageHandler(Func<HttpRequestMessage, HttpResponseMessage> respond) : HttpMessageHandler
{
    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        return Task.FromResult(respond(request));
    }

    public static HttpResponseMessage Ok(HttpContent content) => new(HttpStatusCode.OK)
    {
        Content = content
    };
}