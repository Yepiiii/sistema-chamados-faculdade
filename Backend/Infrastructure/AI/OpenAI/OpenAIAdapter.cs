using SistemaChamados.Application.DTOs;
using SistemaChamados.Core.Interfaces.AI;
using SistemaChamados.Core.Repositories;
using System.Text;
using System.Text.Json;

namespace SistemaChamados.Infrastructure.AI.OpenAI
{
    /// <summary>
    /// Adapter para OpenAI que implementa a interface genérica IAIAnalysisService.
    /// Configurado como Typed Client do IHttpClientFactory para reutilização de conexões.
    /// </summary>
    public class OpenAIAdapter : IAIAnalysisService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly IUserRepository _userRepository;
        private readonly AIPromptBuilder _promptBuilder;
        private readonly ILogger<OpenAIAdapter> _logger;

        /// <summary>
        /// Construtor que recebe HttpClient via IHttpClientFactory (injeção automática).
        /// </summary>
        public OpenAIAdapter(
            HttpClient httpClient, 
            IConfiguration configuration, 
            IUserRepository userRepository,
            AIPromptBuilder promptBuilder,
            ILogger<OpenAIAdapter> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _userRepository = userRepository;
            _promptBuilder = promptBuilder;
            _logger = logger;
            
            // Configuração base do HttpClient para OpenAI
            _httpClient.BaseAddress = new Uri("https://api.openai.com/v1/");
            _httpClient.Timeout = TimeSpan.FromSeconds(30);
        }

        public async Task<AnaliseChamadoResponseDto?> AnalisarChamadoAsync(string descricaoProblema)
        {
            var apiKey = _configuration["OpenAI:ApiKey"];
            if (string.IsNullOrEmpty(apiKey))
            {
                _logger.LogError("Chave da API da OpenAI não configurada.");
                return null;
            }

            try
            {
                var prompt = await _promptBuilder.CriarPromptAnaliseAsync(descricaoProblema);

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
                var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");

                // Configurar Bearer Token por requisição
                _httpClient.DefaultRequestHeaders.Authorization = 
                    new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", apiKey);

                var response = await _httpClient.PostAsync("chat/completions", content);

                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    _logger.LogError($"Erro na API da OpenAI: {response.StatusCode} - {errorContent}");
                    return null;
                }

                var responseContent = await response.Content.ReadAsStringAsync();
                var openAIResponse = JsonSerializer.Deserialize<OpenAIResponse>(responseContent);

                var resultText = openAIResponse?.choices?.FirstOrDefault()?.message?.content;

                if (string.IsNullOrWhiteSpace(resultText))
                {
                    return null;
                }

                var analise = JsonSerializer.Deserialize<AnaliseChamadoResponseDto>(resultText);
                
                if (analise != null)
                {
                    // Buscar técnico especialista usando Repository
                    var tecnicoEspecialista = await _userRepository.GetTecnicoEspecialistaAsync(analise.CategoriaId);
                    
                    // Se não encontrar especialista, busca qualquer técnico como fallback
                    if (tecnicoEspecialista == null)
                    {
                        _logger.LogWarning("Nenhum técnico especialista encontrado para CategoriaId {CategoriaId}. Procurando técnico geral.", analise.CategoriaId);
                        tecnicoEspecialista = await _userRepository.GetTecnicoAtivoAsync();
                    }

                    if (tecnicoEspecialista != null)
                    {
                        analise.TecnicoId = tecnicoEspecialista.Id;
                        analise.TecnicoNome = tecnicoEspecialista.NomeCompleto;
                        _logger.LogInformation("Chamado atribuído ao técnico ID {TecnicoId}", tecnicoEspecialista.Id);
                    }
                    else
                    {
                        _logger.LogWarning("Nenhum técnico encontrado no sistema para atribuição.");
                    }
                }
                
                return analise;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro inesperado ao se comunicar com a OpenAI.");
                return null;
            }
        }

        #region OpenAI DTOs
        private class OpenAIRequest
        {
            public string model { get; set; } = string.Empty;
            public List<OpenAIMessage> messages { get; set; } = new();
            public double temperature { get; set; }
        }

        private class OpenAIMessage
        {
            public string role { get; set; } = string.Empty;
            public string content { get; set; } = string.Empty;
        }

        private class OpenAIResponse
        {
            public List<OpenAIChoice>? choices { get; set; }
        }

        private class OpenAIChoice
        {
            public OpenAIMessage? message { get; set; }
        }
        #endregion
    }
}
