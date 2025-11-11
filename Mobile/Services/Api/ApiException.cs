using System;
using System.Net;

namespace SistemaChamados.Mobile.Services.Api;

public class ApiException : Exception
{
    public HttpStatusCode StatusCode { get; }
    public string? ResponseContent { get; }

    public ApiException(HttpStatusCode statusCode, string message, string? responseContent = null, Exception? innerException = null)
        : base(string.IsNullOrWhiteSpace(message) ? $"Erro HTTP {(int)statusCode}" : message, innerException)
    {
        StatusCode = statusCode;
        ResponseContent = responseContent;
    }
}
