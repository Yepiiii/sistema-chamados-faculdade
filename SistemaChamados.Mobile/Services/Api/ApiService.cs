using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using SistemaChamados.Mobile.Helpers;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;

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
                HandleError(resp, content);
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
                if (result == null)
                {
                    throw new ApiException(HttpStatusCode.InternalServerError, "A resposta da API veio vazia.", content);
                }

                return result;
            }
            catch (JsonException jex)
            {
                Debug.WriteLine($"[ApiService] JSON deserialization error: {jex.Message}");
                Debug.WriteLine($"[ApiService] JSON Exception StackTrace: {jex.StackTrace}");
                Console.WriteLine($"[ApiService] JSON deserialization error: {jex.Message}");
                throw new ApiException(HttpStatusCode.InternalServerError, $"Erro ao interpretar resposta da API: {jex.Message}", content, jex);
            }
        }
        catch (ApiException)
        {
            throw;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[ApiService] GET Exception: {ex.GetType().Name} - {ex.Message}");
            Debug.WriteLine($"[ApiService] StackTrace: {ex.StackTrace}");
            Console.WriteLine($"[ApiService] GET Exception: {ex.GetType().Name} - {ex.Message}");
            throw new ApiException(HttpStatusCode.InternalServerError, ex.Message, null, ex);
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
                HandleError(resp, errorContent);
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
        catch (ApiException)
        {
            throw;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[ApiService] EXCEÇÃO: {ex.GetType().Name} - {ex.Message}");
            Debug.WriteLine($"[ApiService] StackTrace: {ex.StackTrace}");
            throw new ApiException(HttpStatusCode.InternalServerError, ex.Message, null, ex);
        }
    }

    public async Task<TResponse?> PutAsync<TRequest, TResponse>(string uri, TRequest data)
    {
        try
        {
            var payload = JsonConvert.SerializeObject(data);
            var resp = await _client.PutAsync(uri, new StringContent(payload, System.Text.Encoding.UTF8, "application/json"));

            var responseContent = await resp.Content.ReadAsStringAsync();
            Debug.WriteLine($"[ApiService] PUT {uri} - Status {(int)resp.StatusCode} {resp.StatusCode}");

            if (!resp.IsSuccessStatusCode)
            {
                Debug.WriteLine($"[ApiService] PUT error payload: {responseContent}");
                HandleError(resp, responseContent);
            }

            var settings = new JsonSerializerSettings
            {
                ReferenceLoopHandling = ReferenceLoopHandling.Ignore,
                MetadataPropertyHandling = MetadataPropertyHandling.Ignore
            };

            return JsonConvert.DeserializeObject<TResponse>(responseContent, settings);
        }
        catch (ApiException)
        {
            throw;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[ApiService] PUT Exception: {ex.GetType().Name} - {ex.Message}");
            Debug.WriteLine($"[ApiService] StackTrace: {ex.StackTrace}");
            throw new ApiException(HttpStatusCode.InternalServerError, ex.Message, null, ex);
        }
    }

    public async Task<bool> DeleteAsync(string uri)
    {
        try
        {
            var resp = await _client.DeleteAsync(uri);
            var responseContent = await resp.Content.ReadAsStringAsync();
            Debug.WriteLine($"[ApiService] DELETE {uri} - Status {(int)resp.StatusCode} {resp.StatusCode}");

            if (!resp.IsSuccessStatusCode)
            {
                Debug.WriteLine($"[ApiService] DELETE error payload: {responseContent}");
                HandleError(resp, responseContent);
            }

            return true;
        }
        catch (ApiException)
        {
            throw;
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"[ApiService] DELETE Exception: {ex.GetType().Name} - {ex.Message}");
            Debug.WriteLine($"[ApiService] StackTrace: {ex.StackTrace}");
            throw new ApiException(HttpStatusCode.InternalServerError, ex.Message, null, ex);
        }
    }

    private static void HandleError(HttpResponseMessage response, string? responseContent = null)
    {
        var statusCode = response.StatusCode;
        var message = ResolveErrorMessage(response, responseContent);

        Debug.WriteLine($"[ApiService] HandleError: {(int)statusCode} {statusCode} - {message}");
        Console.WriteLine($"[ApiService] HandleError: {(int)statusCode} {statusCode} - {message}");

        throw new ApiException(statusCode, message, responseContent);
    }

    private static string ResolveErrorMessage(HttpResponseMessage response, string? responseContent)
    {
        var extractedMessage = ExtractErrorMessage(responseContent);

        if (!string.IsNullOrWhiteSpace(extractedMessage))
        {
            return extractedMessage.Trim();
        }

        if (response.StatusCode == HttpStatusCode.Unauthorized)
        {
            return "Sessão expirada. Faça login novamente.";
        }

        if (!string.IsNullOrWhiteSpace(response.ReasonPhrase))
        {
            return response.ReasonPhrase!;
        }

        return $"Erro HTTP {(int)response.StatusCode}";
    }

    private static string? ExtractErrorMessage(string? responseContent)
    {
        if (string.IsNullOrWhiteSpace(responseContent))
        {
            return null;
        }

        try
        {
            var token = JToken.Parse(responseContent);

            if (token.Type == JTokenType.Object)
            {
                var obj = (JObject)token;

                string? message = obj["message"]?.ToString()
                    ?? obj["title"]?.ToString()
                    ?? obj["error"]?.ToString()
                    ?? obj["detail"]?.ToString();

                if (!string.IsNullOrWhiteSpace(message))
                {
                    return message;
                }

                if (obj["errors"] is JObject errorsObj)
                {
                    var firstMessage = errorsObj.Properties()
                        .SelectMany(p => p.Value)
                        .Select(v => v?.ToString())
                        .FirstOrDefault(s => !string.IsNullOrWhiteSpace(s));

                    if (!string.IsNullOrWhiteSpace(firstMessage))
                    {
                        return firstMessage;
                    }
                }
            }
            else if (token.Type == JTokenType.Array)
            {
                var first = token.First?.ToString();
                if (!string.IsNullOrWhiteSpace(first))
                {
                    return first;
                }
            }
        }
        catch (JsonException)
        {
            // Conteúdo não é JSON – usa texto bruto
        }

        return responseContent;
    }
}