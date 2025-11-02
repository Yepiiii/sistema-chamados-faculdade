using System.Net.Http.Headers;

namespace SistemaChamados.Mobile.Services.Api;

public interface IApiService
{
    void AddAuthorizationHeader(string token);
    void ClearAuthorizationHeader();
    Task<T?> GetAsync<T>(string uri);
    Task<TResponse?> PostAsync<TRequest, TResponse>(string uri, TRequest data);
    Task<TResponse?> PutAsync<TRequest, TResponse>(string uri, TRequest data);
    Task<bool> DeleteAsync(string uri);
}
