using System;
using System.Net.Http;
using System.Threading.Tasks;
using System.IO;
using System.Text.Json;
using Newtonsoft.Json;

class ApiSmokeTest
{
    public static async Task<int> Main()
    {
        try
        {
            // Try to read appsettings.json from the parent folder (SistemaChamados.Mobile/appsettings.json)
            var settingsPath = Path.Combine("..", "appsettings.json");
            string baseUrl = null;
            if (File.Exists(settingsPath))
            {
                try
                {
                    var txt = await File.ReadAllTextAsync(settingsPath);
                    using var doc = JsonDocument.Parse(txt);
                    if (doc.RootElement.TryGetProperty("BaseUrl", out var b))
                        baseUrl = b.GetString();
                    else if (doc.RootElement.TryGetProperty("BaseUrlWindows", out var bw))
                        baseUrl = bw.GetString();
                }
                catch { /* ignore parsing errors */ }
            }

            if (string.IsNullOrEmpty(baseUrl))
            {
                baseUrl = "http://localhost:5246/api/"; // fallback
            }

            var client = new HttpClient { BaseAddress = new Uri(baseUrl), Timeout = TimeSpan.FromSeconds(10) };
            Console.WriteLine($"Using BaseUrl: {client.BaseAddress}");

            await TestEndpoint(client, "categorias");
            await TestEndpoint(client, "prioridades");

            return 0;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Exception: {ex.GetType().Name} - {ex.Message}");
            return 2;
        }
    }

    static async Task TestEndpoint(HttpClient client, string path)
    {
        Console.WriteLine($"GET {path}");
        try
        {
            var resp = await client.GetAsync(path);
            Console.WriteLine($"Status: {(int)resp.StatusCode} {resp.StatusCode}");
            var content = await resp.Content.ReadAsStringAsync();
            Console.WriteLine($"Content (preview 1000): { (content.Length>1000 ? content.Substring(0,1000)+"..." : content) }");

            try
            {
                var obj = JsonConvert.DeserializeObject(content);
                Console.WriteLine($"JSON parse ok: { (obj!=null) }");
            }
            catch (Exception jex)
            {
                Console.WriteLine($"JSON parse error: {jex.Message}");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Request error: {ex.GetType().Name} - {ex.Message}");
        }
    }
}
