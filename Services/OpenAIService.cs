using System.Linq;
using System.Net;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Data;
using System.Text;
using System.Text.Json;

namespace SistemaChamados.Services
{
    public class OpenAIService : IOpenAIService
    {
        private static readonly string[] DefaultGeminiModels = new[]
        {
            "gemini-1.5-flash-latest",
            "gemini-1.5-flash",
            "gemini-2.5-flash",
            "gemini-2.0-flash-lite"
        };

        private static bool _geminiModelListLogged;

        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _context;
        private readonly ILogger<OpenAIService> _logger;

        public OpenAIService(HttpClient httpClient, IConfiguration configuration, ApplicationDbContext context, ILogger<OpenAIService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _context = context;
            _logger = logger;
        }

        public async Task<AnaliseChamadoResponseDto?> AnalisarChamadoAsync(string descricaoProblema)
        {
            try
            {
                var prompt = await CriarPromptAnalise(descricaoProblema);

                AnaliseChamadoResponseDto? analise = null;

                var geminiKey = _configuration["Gemini:ApiKey"];
                if (!string.IsNullOrWhiteSpace(geminiKey))
                {
                    analise = await ObterAnaliseViaGemini(geminiKey, prompt);
                }

                if (analise == null)
                {
                    var openAiKey = _configuration["OpenAI:ApiKey"];
                    if (!string.IsNullOrWhiteSpace(openAiKey))
                    {
                        analise = await ObterAnaliseViaOpenAI(openAiKey, prompt);
                    }
                }

                if (analise == null)
                {
                    _logger.LogError("Não foi possível obter análise da IA (Gemini/OpenAI).");
                    return null;
                }

                var tecnicoEspecialista = await _context.Usuarios
                    .FirstOrDefaultAsync(u =>
                        u.TipoUsuario == 2 &&
                        u.EspecialidadeCategoriaId == analise.CategoriaId &&
                        u.Ativo);

                if (tecnicoEspecialista == null)
                {
                    _logger.LogWarning("Nenhum técnico especialista (Tipo 2) encontrado para CategoriaId {CategoriaId}. Procurando técnico geral (Tipo 2).", analise.CategoriaId);
                    tecnicoEspecialista = await _context.Usuarios
                        .FirstOrDefaultAsync(u => u.TipoUsuario == 2 && u.Ativo);
                }

                if (tecnicoEspecialista != null)
                {
                    analise.TecnicoId = tecnicoEspecialista.Id;
                    analise.TecnicoNome = tecnicoEspecialista.NomeCompleto;
                    _logger.LogInformation("Chamado atribuído ao técnico ID {TecnicoId}", tecnicoEspecialista.Id);
                }
                else
                {
                    _logger.LogWarning("Nenhum técnico (TipoUsuario == 2) encontrado no sistema para atribuição.");
                }

                return analise;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro inesperado ao processar a análise de IA.");
                return null;
            }
        }

        private async Task<string> CriarPromptAnalise(string descricaoProblema)
        {
            var categorias = await _context.Categorias.Where(c => c.Ativo).ToListAsync();
            var prioridades = await _context.Prioridades.Where(p => p.Ativo).ToListAsync();

            var categoriasTexto = string.Join("\n", categorias.Select(c => $"- ID: {c.Id}, Nome: {c.Nome}"));
            var prioridadesTexto = string.Join("\n", prioridades.Select(p => $"- ID: {p.Id}, Nome: {p.Nome}"));

            return MontarPrompt(descricaoProblema, categoriasTexto, prioridadesTexto);
        }

        private async Task<AnaliseChamadoResponseDto?> ObterAnaliseViaGemini(string apiKey, string prompt)
        {
            var modelosConfigurados = new List<string>();
            var modeloPrincipal = _configuration["Gemini:Model"];

            if (!string.IsNullOrWhiteSpace(modeloPrincipal))
            {
                modelosConfigurados.Add(modeloPrincipal.Trim());
            }

            var modelosFallback = _configuration.GetSection("Gemini:FallbackModels").Get<string[]?>();
            if (modelosFallback != null && modelosFallback.Length > 0)
            {
                modelosConfigurados.AddRange(modelosFallback.Where(m => !string.IsNullOrWhiteSpace(m)).Select(m => m.Trim()));
            }

            if (modelosConfigurados.Count == 0)
            {
                modelosConfigurados.AddRange(DefaultGeminiModels);
            }

            foreach (var modelo in modelosConfigurados.Distinct(StringComparer.OrdinalIgnoreCase))
            {
                var resultado = await ChamarGeminiAsync(apiKey, prompt, modelo);

                if (resultado.Analise != null)
                {
                    if (!string.Equals(modelo, modeloPrincipal, StringComparison.OrdinalIgnoreCase) && !string.IsNullOrWhiteSpace(modeloPrincipal))
                    {
                        _logger.LogWarning("Usando modelo Gemini alternativo '{ModeloAlternativo}' após falha com '{ModeloConfigurado}'.", modelo, modeloPrincipal);
                    }

                    return resultado.Analise;
                }

                if (resultado.StatusCode == HttpStatusCode.NotFound)
                {
                    await LogModelosGeminiDisponiveis(apiKey);
                }
            }

            return null;
        }

        private async Task<AnaliseChamadoResponseDto?> ObterAnaliseViaOpenAI(string apiKey, string prompt)
        {
            var requestBody = new OpenAIRequest
            {
                model = "gpt-3.5-turbo",
                messages = new List<OpenAIMessage>
                {
                    new OpenAIMessage { role = "system", content = "Você é um especialista em triagem de chamados de TI. Responda apenas com o formato JSON solicitado." },
                    new OpenAIMessage { role = "user", content = prompt }
                },
                temperature = 0.2
            };

            var jsonContent = JsonSerializer.Serialize(requestBody);
            using var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

            _httpClient.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", apiKey);

            var response = await _httpClient.PostAsync("https://api.openai.com/v1/chat/completions", content);

            var responseContent = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogError("Erro na API da OpenAI: {StatusCode} - {Body}", response.StatusCode, Truncar(responseContent));
                _httpClient.DefaultRequestHeaders.Authorization = null;
                return null;
            }

            try
            {
                var openAIResponse = JsonSerializer.Deserialize<OpenAIResponse>(responseContent);
                var rawText = openAIResponse?.choices?.FirstOrDefault()?.message?.content;
                return ExtrairAnalise(rawText);
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Falha ao interpretar resposta da OpenAI: {Resposta}", responseContent);
                return null;
            }
            finally
            {
                _httpClient.DefaultRequestHeaders.Authorization = null;
            }
        }

        private async Task<(AnaliseChamadoResponseDto? Analise, HttpStatusCode? StatusCode)> ChamarGeminiAsync(string apiKey, string prompt, string modelo)
        {
            var requestUri = $"https://generativelanguage.googleapis.com/v1beta/models/{modelo}:generateContent?key={apiKey}";

            _httpClient.DefaultRequestHeaders.Authorization = null;

            var payload = new
            {
                contents = new[]
                {
                    new
                    {
                        role = "user",
                        parts = new[]
                        {
                            new { text = prompt }
                        }
                    }
                },
                generationConfig = new
                {
                    temperature = 0.2,
                    topP = 0.8
                }
            };

            var json = JsonSerializer.Serialize(payload);
            using var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await _httpClient.PostAsync(requestUri, content);
            var status = response.StatusCode;
            var responseContent = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                _logger.LogError("Erro na API da Gemini (modelo {Modelo}): {StatusCode} - {Body}", modelo, status, Truncar(responseContent));
                return (null, status);
            }

            try
            {
                using var document = JsonDocument.Parse(responseContent);

                if (document.RootElement.TryGetProperty("candidates", out var candidatesElement) &&
                    candidatesElement.ValueKind == JsonValueKind.Array)
                {
                    foreach (var candidate in candidatesElement.EnumerateArray())
                    {
                        if (candidate.TryGetProperty("content", out var contentElement) &&
                            contentElement.TryGetProperty("parts", out var partsElement) &&
                            partsElement.ValueKind == JsonValueKind.Array)
                        {
                            foreach (var part in partsElement.EnumerateArray())
                            {
                                if (part.TryGetProperty("text", out var textElement))
                                {
                                    var rawText = textElement.GetString();
                                    var analise = ExtrairAnalise(rawText);
                                    if (analise != null)
                                    {
                                        return (analise, status);
                                    }
                                }
                            }
                        }
                    }
                }

                _logger.LogError("Resposta da Gemini (modelo {Modelo}) sem conteúdo JSON válido: {Resposta}", modelo, Truncar(responseContent));
                return (null, status);
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Falha ao interpretar resposta da Gemini (modelo {Modelo}): {Resposta}", modelo, Truncar(responseContent));
                return (null, status);
            }
        }

        private async Task LogModelosGeminiDisponiveis(string apiKey)
        {
            if (_geminiModelListLogged)
            {
                return;
            }

            try
            {
                var requestUri = $"https://generativelanguage.googleapis.com/v1beta/models?key={apiKey}";
                var response = await _httpClient.GetAsync(requestUri);
                var body = await response.Content.ReadAsStringAsync();

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning("Falha ao listar modelos da Gemini: {StatusCode} - {Body}", response.StatusCode, Truncar(body));
                    return;
                }

                using var document = JsonDocument.Parse(body);
                if (document.RootElement.TryGetProperty("models", out var modelsElement) && modelsElement.ValueKind == JsonValueKind.Array)
                {
                    var modelos = modelsElement
                        .EnumerateArray()
                        .Select(modelo => modelo.TryGetProperty("name", out var nameElement) ? nameElement.GetString() : null)
                        .Where(name => !string.IsNullOrWhiteSpace(name))
                        .ToArray();

                    if (modelos.Length > 0)
                    {
                        _logger.LogInformation("Modelos Gemini disponíveis: {Modelos}", string.Join(", ", modelos));
                        _geminiModelListLogged = true;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Erro ao tentar listar modelos disponíveis da Gemini.");
            }
        }

        private static string Truncar(string texto, int maxLength = 1000)
        {
            if (string.IsNullOrEmpty(texto))
            {
                return texto;
            }

            return texto.Length <= maxLength ? texto : texto.Substring(0, maxLength) + "...";
        }

        private AnaliseChamadoResponseDto? ExtrairAnalise(string? resultText)
        {
            if (string.IsNullOrWhiteSpace(resultText))
            {
                _logger.LogWarning("Resposta da IA vazia ou nula.");
                return null;
            }

            var cleanedJson = ExtrairBlocoJson(resultText);

            if (string.IsNullOrWhiteSpace(cleanedJson))
            {
                _logger.LogError("Não foi possível localizar um bloco JSON válido na resposta da IA: {Resposta}", resultText);
                return null;
            }

            try
            {
                return JsonSerializer.Deserialize<AnaliseChamadoResponseDto>(cleanedJson, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true,
                    AllowTrailingCommas = true
                });
            }
            catch (JsonException ex)
            {
                _logger.LogError(ex, "Falha ao desserializar resposta da IA: {Resposta}", cleanedJson);
                return null;
            }
        }

        private static string? ExtrairBlocoJson(string texto)
        {
            if (string.IsNullOrWhiteSpace(texto))
            {
                return null;
            }

            var cleaned = texto.Trim();

            if (cleaned.StartsWith("```", StringComparison.Ordinal))
            {
                var linhas = cleaned
                    .Split('\n')
                    .Where(l => !l.TrimStart().StartsWith("```", StringComparison.Ordinal))
                    .ToArray();
                cleaned = string.Join('\n', linhas);
            }

            var inicio = cleaned.IndexOf('{');
            var fim = cleaned.LastIndexOf('}');

            if (inicio < 0 || fim < 0 || fim < inicio)
            {
                return null;
            }

            return cleaned.Substring(inicio, fim - inicio + 1);
        }

        private static string MontarPrompt(string descricaoProblema, string categoriasTexto, string prioridadesTexto)
        {
            return $@"Analise o problema de TI a seguir e classifique-o.

Descrição do Problema: ""{descricaoProblema}""

Categorias Disponíveis:
{categoriasTexto}

Prioridades Disponíveis:
{prioridadesTexto}

Responda APENAS com um JSON no seguinte formato, sem texto adicional:
{{
  ""CategoriaId"": <ID da categoria>,
  ""CategoriaNome"": ""<Nome da categoria>"",
  ""PrioridadeId"": <ID da prioridade>,
  ""PrioridadeNome"": ""<Nome da prioridade>"",
  ""TituloSugerido"": ""<Um título curto e claro para o chamado>"",
  ""Justificativa"": ""<Uma breve justificativa para a sua escolha>"",
  ""ConfiancaCategoria"": <número entre 0 e 1 indicando a confiança na categoria sugerida>,
  ""ConfiancaPrioridade"": <número entre 0 e 1 indicando a confiança na prioridade sugerida>
}}";
        }
    }
}