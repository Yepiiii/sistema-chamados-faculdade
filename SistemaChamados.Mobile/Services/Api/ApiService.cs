using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Net.Http.Headers;
using SistemaChamados.Mobile.Helpers;
using System.Diagnostics;

namespace SistemaChamados.Mobile.Services.Api;

public class ApiService : IApiService
{
    private readonly HttpClient _client;

    public ApiService(HttpClient client)
    {
        _client = client;
        _client.BaseAddress = new Uri(Constants.BaseUrl);
        _client.Timeout = TimeSpan.FromSeconds(60); // Aumentado para 60 segundos
        _client.DefaultRequestHeaders.AcceptCharset.Clear();
        _client.DefaultRequestHeaders.AcceptCharset.Add(new System.Net.Http.Headers.StringWithQualityHeaderValue("utf-8"));
        Debug.WriteLine($"[ApiService] Inicializado com BaseUrl: {Constants.BaseUrl}");
        Debug.WriteLine($"[ApiService] Timeout configurado: 60 segundos");
    }

    public void AddAuthorizationHeader(string token)
    {
        if (string.IsNullOrEmpty(token)) return;
        if (_client.DefaultRequestHeaders.Contains("Authorization"))
            _client.DefaultRequestHeaders.Remove("Authorization");
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
    }

    public void ClearAuthorizationHeader()
    {
        if (_client.DefaultRequestHeaders.Contains("Authorization"))
        {
            _client.DefaultRequestHeaders.Remove("Authorization");
        }
    }

    public async Task<T?> GetAsync<T>(string uri)
    {
        Debug.WriteLine($"[ApiService] GET {uri}");
        Console.WriteLine($"[ApiService] GET {uri}");
        try
        {
            var resp = await _client.GetAsync(uri);
            Console.WriteLine($"[ApiService] Status {(int)resp.StatusCode} {resp.StatusCode}");

            var bytes = await resp.Content.ReadAsByteArrayAsync();
            var content = System.Text.Encoding.UTF8.GetString(bytes);
            // Log the raw content for easier diagnosis (trim if too large)
            if (!string.IsNullOrEmpty(content))
            {
                var preview = content.Length > 1000 ? content.Substring(0, 1000) + "..." : content;
                Debug.WriteLine($"[ApiService] Response content (preview): {preview}");
                Console.WriteLine($"[ApiService] Response content (preview): {preview}");
            }

            if (!resp.IsSuccessStatusCode)
            {
                HandleError(resp.StatusCode);
                return default;
            }

            var settings = new JsonSerializerSettings { ReferenceLoopHandling = ReferenceLoopHandling.Ignore, MetadataPropertyHandling = MetadataPropertyHandling.Ignore };
            try
            {
                // Some API responses may be wrapped with $id/$values (preserve references)
                // e.g. { "$id": "1", "$values": [ { ... }, ... ] }
                // If so, unwrap to the inner array before deserializing to the expected type.
                if (!string.IsNullOrWhiteSpace(content) && content.Contains("\"$values\""))
                {
                    try
                    {
                        var jo = JObject.Parse(content);
                        var values = jo["$values"];
                        if (values != null)
                        {
                            var unwrapped = values.ToString();
                            Debug.WriteLine("[ApiService] Unwrapped $values from response before deserialization.");
                            Console.WriteLine("[ApiService] Unwrapped $values from response before deserialization.");
                            content = unwrapped;
                        }
                    }
                    catch (Exception exUnwrap)
                    {
                        Debug.WriteLine($"[ApiService] Failed to unwrap $values: {exUnwrap.Message}");
                        Console.WriteLine($"[ApiService] Failed to unwrap $values: {exUnwrap.Message}");
                    }
                }

                var result = JsonConvert.DeserializeObject<T>(content, settings);
                return result;
            }
            catch (JsonException jex)
            {
                Debug.WriteLine($"[ApiService] JSON deserialization error: {jex.Message}");
                Debug.WriteLine($"[ApiService] JSON Exception StackTrace: {jex.StackTrace}");
                Console.WriteLine($"[ApiService] JSON deserialization error: {jex.Message}");
                return default;
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[ApiService] GET Exception: {ex.GetType().Name} - {ex.Message}");
            Debug.WriteLine($"[ApiService] StackTrace: {ex.StackTrace}");
            Console.WriteLine($"[ApiService] GET Exception: {ex.GetType().Name} - {ex.Message}");
            return default;
        }
    }

    public async Task<TResponse?> PostAsync<TRequest, TResponse>(string uri, TRequest data)
    {
        try
        {
            Debug.WriteLine($"[ApiService] POST {uri}");
            var payload = JsonConvert.SerializeObject(data);
            Debug.WriteLine($"[ApiService] Payload: {payload}");
            
            var resp = await _client.PostAsync(uri, new StringContent(payload, System.Text.Encoding.UTF8, "application/json"));
            
            Debug.WriteLine($"[ApiService] Status: {resp.StatusCode}");
            
            if (!resp.IsSuccessStatusCode)
            {
                var errorBytes = await resp.Content.ReadAsByteArrayAsync();
                var errorContent = System.Text.Encoding.UTF8.GetString(errorBytes);
                Debug.WriteLine($"[ApiService] Erro HTTP {(int)resp.StatusCode}: {errorContent}");
                
                // Extrai mensagem de erro do JSON se possível
                string errorMessage = errorContent;
                try
                {
                    var errorJson = JObject.Parse(errorContent);
                    if (errorJson["message"] != null)
                        errorMessage = errorJson["message"]?.ToString() ?? errorContent;
                    else if (errorJson["title"] != null)
                        errorMessage = errorJson["title"]?.ToString() ?? errorContent;
                }
                catch { /* Se não for JSON, usa o conteúdo bruto */ }
                
                // Lança exceção com a mensagem de erro da API
                throw new HttpRequestException($"{resp.StatusCode}: {errorMessage}");
            }
            
            var jsonBytes = await resp.Content.ReadAsByteArrayAsync();
            var json = System.Text.Encoding.UTF8.GetString(jsonBytes);
            Debug.WriteLine($"[ApiService] JSON recebido (primeiros 200 chars): {json.Substring(0, Math.Min(200, json.Length))}");
            
            var settings = new JsonSerializerSettings 
            { 
                ReferenceLoopHandling = ReferenceLoopHandling.Ignore, 
                MetadataPropertyHandling = MetadataPropertyHandling.Ignore 
            };
            
            var result = JsonConvert.DeserializeObject<TResponse>(json, settings);
            Debug.WriteLine($"[ApiService] Desserialização concluída: {result != null}");
            
            return result;
        }
        catch (HttpRequestException)
        {
            // Re-lança HttpRequestException para preservar a mensagem de erro da API
            throw;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[ApiService] EXCEÇÃO: {ex.GetType().Name} - {ex.Message}");
            Debug.WriteLine($"[ApiService] StackTrace: {ex.StackTrace}");
            throw;
        }
    }

    public async Task<TResponse?> PutAsync<TRequest, TResponse>(string uri, TRequest data)
    {
        var payload = JsonConvert.SerializeObject(data);
        var resp = await _client.PutAsync(uri, new StringContent(payload, System.Text.Encoding.UTF8, "application/json"));
        if (!resp.IsSuccessStatusCode)
        {
            HandleError(resp.StatusCode);
            return default;
        }
        var jsonBytes = await resp.Content.ReadAsByteArrayAsync();
        var json = System.Text.Encoding.UTF8.GetString(jsonBytes);
        var settings = new JsonSerializerSettings { ReferenceLoopHandling = ReferenceLoopHandling.Ignore, MetadataPropertyHandling = MetadataPropertyHandling.Ignore };
        return JsonConvert.DeserializeObject<TResponse>(json, settings);
    }

    public async Task<bool> DeleteAsync(string uri)
    {
        var resp = await _client.DeleteAsync(uri);
        if (!resp.IsSuccessStatusCode)
        {
            HandleError(resp.StatusCode);
            return false;
        }
        return true;
    }

    private void HandleError(System.Net.HttpStatusCode statusCode)
    {
        Debug.WriteLine($"[ApiService] HandleError: {statusCode}");
        Console.WriteLine($"[ApiService] HandleError: {statusCode}");
        switch (statusCode)
        {
            case System.Net.HttpStatusCode.Unauthorized:
                break;
            case System.Net.HttpStatusCode.NotFound:
                break;
            case System.Net.HttpStatusCode.InternalServerError:
                break;
        }
    }
}