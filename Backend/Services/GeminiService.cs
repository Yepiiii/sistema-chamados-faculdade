using Microsoft.EntityFrameworkCore;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Data;
using System.Text;
using System.Text.Json;

namespace SistemaChamados.Services
{
    public class GeminiService : IOpenAIService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ApplicationDbContext _context;
        private readonly ILogger<GeminiService> _logger;

        public GeminiService(HttpClient httpClient, IConfiguration configuration, ApplicationDbContext context, ILogger<GeminiService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _context = context;
            _logger = logger;
        }

        public async Task<AnaliseChamadoResponseDto?> AnalisarChamadoAsync(string descricaoProblema)
        {
            // Tentar pegar de variável de ambiente primeiro, depois de configuration
            var apiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY") 
                         ?? _configuration["GEMINI_API_KEY"];
            
            if (string.IsNullOrEmpty(apiKey))
            {
                _logger.LogError("Chave da API do Gemini não configurada. Verifique o arquivo .env");
                return null;
            }
            
            _logger.LogInformation($"Usando chave do Gemini: {apiKey.Substring(0, 10)}...");

            try
            {
                var prompt = await CriarPromptAnalise(descricaoProblema);

                // Formato da requisição para o Gemini
                var requestBody = new
                {
                    contents = new[]
                    {
                        new
                        {
                            parts = new[]
                            {
                                new { text = prompt }
                            }
                        }
                    },
                    generationConfig = new
                    {
                        temperature = 0.2,
                        topK = 1,
                        topP = 1,
                        maxOutputTokens = 2048
                    }
                };

                var jsonContent = JsonSerializer.Serialize(requestBody);
                var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

                // URL da API do Gemini - usando modelo 2.5-flash (mais recente e estável)
                var url = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={apiKey}";

                var response = await _httpClient.PostAsync(url, content);

                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    _logger.LogError($"Erro na API do Gemini: {response.StatusCode} - {errorContent}");
                    return null;
                }

                var responseContent = await response.Content.ReadAsStringAsync();
                _logger.LogInformation($"Resposta completa do Gemini: {responseContent}");

                // Parse da resposta do Gemini
                var geminiResponse = JsonSerializer.Deserialize<JsonElement>(responseContent);
                
                var resultText = geminiResponse
                    .GetProperty("candidates")[0]
                    .GetProperty("content")
                    .GetProperty("parts")[0]
                    .GetProperty("text")
                    .GetString();

                if (string.IsNullOrWhiteSpace(resultText))
                {
                    _logger.LogWarning("Resposta vazia do Gemini");
                    return null;
                }

                // Limpar markdown se houver
                resultText = resultText.Trim();
                if (resultText.StartsWith("```json"))
                {
                    resultText = resultText.Replace("```json", "").Replace("```", "").Trim();
                }

                _logger.LogInformation($"Texto extraído para parsing: {resultText}");

                var analise = JsonSerializer.Deserialize<AnaliseChamadoResponseDto>(resultText, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });
                
                if (analise != null)
                {
                    // Buscar técnico especialista
                    var tecnicoEspecialista = await _context.Usuarios
                        .FirstOrDefaultAsync(u => u.TipoUsuario == 3 && u.CategoriaEspecialidadeId == analise.CategoriaId && u.Ativo);
                    
                    if (tecnicoEspecialista != null)
                    {
                        analise.TecnicoId = tecnicoEspecialista.Id;
                        analise.TecnicoNome = tecnicoEspecialista.NomeCompleto;
                    }
                }
                
                return analise;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Erro inesperado ao se comunicar com o Gemini. Mensagem: {ex.Message}");
                _logger.LogError($"StackTrace: {ex.StackTrace}");
                return null;
            }
        }

        private async Task<string> CriarPromptAnalise(string descricaoProblema)
        {
            var categorias = await _context.Categorias.Where(c => c.Ativo).ToListAsync();
            var prioridades = await _context.Prioridades.Where(p => p.Ativo).ToListAsync();

            var categoriasTexto = string.Join("\n", categorias.Select(c => $"- ID: {c.Id}, Nome: {c.Nome}"));
            var prioridadesTexto = string.Join("\n", prioridades.Select(p => $"- ID: {p.Id}, Nome: {p.Nome}"));

            return $@"Analise o problema de TI a seguir e classifique-o.

Descrição do Problema: ""{descricaoProblema}""

Categorias Disponíveis:
{categoriasTexto}

Prioridades Disponíveis:
{prioridadesTexto}

Responda APENAS com um JSON válido no seguinte formato, sem texto adicional, sem markdown:
{{
  ""CategoriaId"": <ID da categoria>,
  ""CategoriaNome"": ""<Nome da categoria>"",
  ""PrioridadeId"": <ID da prioridade>,
  ""PrioridadeNome"": ""<Nome da prioridade>"",
  ""TituloSugerido"": ""<Um título curto e claro para o chamado>"",
  ""Justificativa"": ""<Uma breve justificativa para a sua escolha>""
}}";
        }
    }
}
