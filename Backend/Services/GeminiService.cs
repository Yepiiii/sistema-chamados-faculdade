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
        
        // Constantes para melhor controle
        private const string GEMINI_BASE_URL = "https://generativelanguage.googleapis.com/v1beta";
        private const string GEMINI_MODEL = "gemini-2.0-flash-exp"; // Modelo mais estável
        private const int MAX_OUTPUT_TOKENS = 1024; // Reduzido para evitar MAX_TOKENS
        private const double TEMPERATURE = 0.1; // Mais determinístico
        
        public GeminiService(HttpClient httpClient, IConfiguration configuration, ApplicationDbContext context, ILogger<GeminiService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _context = context;
            _logger = logger;
            
            // Configurar timeout do HttpClient
            _httpClient.Timeout = TimeSpan.FromSeconds(30);
        }

        public async Task<AnaliseChamadoResponseDto?> AnalisarChamadoAsync(string descricaoProblema)
        {
            _logger.LogInformation("═══════════════════════════════════════════════════════");
            _logger.LogInformation("🔍 [DIAGNÓSTICO GEMINI] Iniciando análise de chamado");
            _logger.LogInformation("═══════════════════════════════════════════════════════");
            
            // ============ ETAPA 1: VERIFICAR CHAVE API ============
            var apiKey = ObterChaveAPI();
            if (string.IsNullOrEmpty(apiKey))
            {
                _logger.LogError("❌ [ERRO] Chave API não encontrada!");
                _logger.LogError("   Verifique:");
                _logger.LogError("   - Arquivo .env existe na pasta Backend?");
                _logger.LogError("   - Variável GEMINI_API_KEY está definida?");
                _logger.LogError("   - Formato: GEMINI_API_KEY=\"AIza...\"");
                return null;
            }
            
            _logger.LogInformation($"✅ [OK] Chave API carregada: {apiKey.Substring(0, 10)}***");
            _logger.LogInformation($"   Tamanho da chave: {apiKey.Length} caracteres");
            _logger.LogInformation($"   Formato válido: {(apiKey.StartsWith("AIza") ? "SIM" : "NÃO")}");

            try
            {
                // ============ ETAPA 2: CRIAR PROMPT ============
                _logger.LogInformation("📝 [ETAPA 2] Criando prompt para análise...");
                var prompt = await CriarPromptAnalise(descricaoProblema);
                _logger.LogInformation($"   Prompt criado com {prompt.Length} caracteres");
                _logger.LogDebug($"   Prompt: {prompt.Substring(0, Math.Min(200, prompt.Length))}...");

                // ============ ETAPA 3: MONTAR REQUISIÇÃO ============
                _logger.LogInformation("🔧 [ETAPA 3] Montando requisição para Gemini...");
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
                        temperature = TEMPERATURE,
                        topK = 1,
                        topP = 1,
                        maxOutputTokens = MAX_OUTPUT_TOKENS,
                        stopSequences = new string[] { } // Sem sequências de parada
                    },
                    safetySettings = new[]
                    {
                        new { category = "HARM_CATEGORY_HARASSMENT", threshold = "BLOCK_NONE" },
                        new { category = "HARM_CATEGORY_HATE_SPEECH", threshold = "BLOCK_NONE" },
                        new { category = "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold = "BLOCK_NONE" },
                        new { category = "HARM_CATEGORY_DANGEROUS_CONTENT", threshold = "BLOCK_NONE" }
                    }
                };

                var jsonContent = JsonSerializer.Serialize(requestBody, new JsonSerializerOptions 
                { 
                    WriteIndented = false 
                });
                _logger.LogDebug($"   JSON Request: {jsonContent.Substring(0, Math.Min(300, jsonContent.Length))}...");

                var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");
                var url = $"{GEMINI_BASE_URL}/models/{GEMINI_MODEL}:generateContent?key={apiKey}";
                
                _logger.LogInformation($"   URL: {GEMINI_BASE_URL}/models/{GEMINI_MODEL}:generateContent");
                _logger.LogInformation($"   Modelo: {GEMINI_MODEL}");
                _logger.LogInformation($"   Temperature: {TEMPERATURE}");
                _logger.LogInformation($"   Max Tokens: {MAX_OUTPUT_TOKENS}");

                // ============ ETAPA 4: ENVIAR REQUISIÇÃO ============
                _logger.LogInformation("📡 [ETAPA 4] Enviando requisição HTTP...");
                var stopwatch = System.Diagnostics.Stopwatch.StartNew();
                var response = await _httpClient.PostAsync(url, content);
                stopwatch.Stop();
                
                _logger.LogInformation($"   Status HTTP: {(int)response.StatusCode} {response.StatusCode}");
                _logger.LogInformation($"   Tempo de resposta: {stopwatch.ElapsedMilliseconds}ms");
                _logger.LogInformation($"   Content-Type: {response.Content.Headers.ContentType}");

                // ============ ETAPA 5: TRATAR ERROS HTTP ============
                if (!response.IsSuccessStatusCode)
                {
                    var errorContent = await response.Content.ReadAsStringAsync();
                    _logger.LogError("❌ [ERRO HTTP] Gemini retornou erro!");
                    _logger.LogError($"   Status: {response.StatusCode}");
                    _logger.LogError($"   Resposta: {errorContent}");
                    
                    // Parsear erro do Gemini
                    try
                    {
                        var errorJson = JsonSerializer.Deserialize<JsonElement>(errorContent);
                        if (errorJson.TryGetProperty("error", out var errorObj))
                        {
                            var errorMessage = errorObj.GetProperty("message").GetString();
                            var errorCode = errorObj.GetProperty("code").GetInt32();
                            _logger.LogError($"   Código: {errorCode}");
                            _logger.LogError($"   Mensagem: {errorMessage}");
                            
                            // Diagnóstico específico
                            if (errorCode == 400) _logger.LogError("   💡 Possível problema: Chave API inválida ou formato de requisição incorreto");
                            if (errorCode == 403) _logger.LogError("   💡 Possível problema: Chave sem permissão ou quota excedida");
                            if (errorCode == 429) _logger.LogError("   💡 Possível problema: Rate limit excedido");
                            if (errorCode == 404) _logger.LogError("   💡 Possível problema: Modelo não encontrado ou URL incorreta");
                        }
                    }
                    catch { }
                    
                    return null;
                }

                // ============ ETAPA 6: PARSEAR RESPOSTA ============
                var responseContent = await response.Content.ReadAsStringAsync();
                _logger.LogInformation($"✅ [ETAPA 6] Resposta HTTP OK ({responseContent.Length} chars)");
                _logger.LogDebug($"   Resposta completa: {responseContent}");

                var geminiResponse = JsonSerializer.Deserialize<JsonElement>(responseContent);
                
                // Verificar estrutura da resposta
                _logger.LogInformation("🔍 [PARSING] Analisando estrutura da resposta...");
                
                if (!geminiResponse.TryGetProperty("candidates", out var candidates))
                {
                    _logger.LogError("❌ [ERRO PARSING] Propriedade 'candidates' não encontrada!");
                    _logger.LogDebug($"   Resposta: {responseContent}");
                    return null;
                }
                
                if (candidates.GetArrayLength() == 0)
                {
                    _logger.LogWarning("⚠️ [AVISO] Array 'candidates' está vazio!");
                    return null;
                }
                
                _logger.LogInformation($"   Candidates encontrados: {candidates.GetArrayLength()}");
                var firstCandidate = candidates[0];
                
                // Verificar finishReason
                if (firstCandidate.TryGetProperty("finishReason", out var finishReasonProp))
                {
                    var finishReason = finishReasonProp.GetString();
                    _logger.LogInformation($"   Finish Reason: {finishReason}");
                    
                    if (finishReason != "STOP")
                    {
                        _logger.LogWarning($"⚠️ [AVISO] FinishReason = {finishReason} (esperado: STOP)");
                        if (finishReason == "MAX_TOKENS")
                        {
                            _logger.LogError("   💡 Resposta cortada! Aumentar maxOutputTokens ou simplificar prompt");
                        }
                        else if (finishReason == "SAFETY")
                        {
                            _logger.LogError("   💡 Bloqueado por filtro de segurança!");
                        }
                    }
                }
                
                // Verificar content e parts
                if (!firstCandidate.TryGetProperty("content", out var contentElement))
                {
                    _logger.LogError("❌ [ERRO PARSING] Propriedade 'content' não encontrada!");
                    return null;
                }
                
                if (!contentElement.TryGetProperty("parts", out var parts))
                {
                    _logger.LogError("❌ [ERRO PARSING] Propriedade 'parts' não encontrada!");
                    return null;
                }
                
                if (parts.GetArrayLength() == 0)
                {
                    _logger.LogError("❌ [ERRO PARSING] Array 'parts' está vazio!");
                    return null;
                }
                
                _logger.LogInformation($"   Parts encontrados: {parts.GetArrayLength()}");
                
                if (!parts[0].TryGetProperty("text", out var textProp))
                {
                    _logger.LogError("❌ [ERRO PARSING] Propriedade 'text' não encontrada em parts[0]!");
                    return null;
                }
                
                var resultText = textProp.GetString();
                
                if (string.IsNullOrWhiteSpace(resultText))
                {
                    _logger.LogError("❌ [ERRO] Texto extraído está vazio!");
                    return null;
                }
                
                _logger.LogInformation($"✅ [OK] Texto extraído: {resultText.Length} caracteres");
                _logger.LogDebug($"   Texto: {resultText}");

                // ============ ETAPA 7: LIMPAR E PARSEAR JSON ============
                _logger.LogInformation("🧹 [ETAPA 7] Limpando markdown e parseando JSON...");
                resultText = resultText.Trim();
                
                // Remover markdown se houver
                if (resultText.StartsWith("```json"))
                {
                    _logger.LogInformation("   Removendo marcador ```json");
                    resultText = resultText.Replace("```json", "").Replace("```", "").Trim();
                }
                else if (resultText.StartsWith("```"))
                {
                    _logger.LogInformation("   Removendo marcador ```");
                    resultText = resultText.Replace("```", "").Trim();
                }
                
                _logger.LogDebug($"   JSON limpo: {resultText}");

                // Tentar parsear JSON
                AnaliseChamadoResponseDto? analise = null;
                try
                {
                    analise = JsonSerializer.Deserialize<AnaliseChamadoResponseDto>(resultText, new JsonSerializerOptions
                    {
                        PropertyNameCaseInsensitive = true
                    });
                    
                    if (analise == null)
                    {
                        _logger.LogError("❌ [ERRO JSON] Deserialização retornou null!");
                        return null;
                    }
                    
                    _logger.LogInformation("✅ [OK] JSON parseado com sucesso!");
                    _logger.LogInformation($"   CategoriaId: {analise.CategoriaId}");
                    _logger.LogInformation($"   CategoriaNome: {analise.CategoriaNome}");
                    _logger.LogInformation($"   PrioridadeId: {analise.PrioridadeId}");
                    _logger.LogInformation($"   PrioridadeNome: {analise.PrioridadeNome}");
                    _logger.LogInformation($"   TituloSugerido: {analise.TituloSugerido}");
                }
                catch (JsonException jsonEx)
                {
                    _logger.LogError(jsonEx, "❌ [ERRO JSON] Falha ao parsear resposta!");
                    _logger.LogError($"   JSON problemático: {resultText}");
                    return null;
                }
                
                // ============ ETAPA 8: BUSCAR TÉCNICO ESPECIALISTA ============
                if (analise != null)
                {
                    _logger.LogInformation("👤 [ETAPA 8] Buscando técnico especialista...");
                    var tecnicoEspecialista = await _context.Usuarios
                        .FirstOrDefaultAsync(u => u.TipoUsuario == 2 && u.CategoriaEspecialidadeId == analise.CategoriaId && u.Ativo);
                    
                    if (tecnicoEspecialista != null)
                    {
                        analise.TecnicoId = tecnicoEspecialista.Id;
                        analise.TecnicoNome = tecnicoEspecialista.NomeCompleto;
                        _logger.LogInformation($"   ✅ Técnico encontrado: {tecnicoEspecialista.NomeCompleto} (ID: {tecnicoEspecialista.Id})");
                    }
                    else
                    {
                        _logger.LogWarning($"   ⚠️ Nenhum técnico especialista encontrado para CategoriaId={analise.CategoriaId}");
                    }
                }
                
                _logger.LogInformation("═══════════════════════════════════════════════════════");
                _logger.LogInformation("🎉 [SUCESSO] Análise concluída com êxito!");
                _logger.LogInformation("═══════════════════════════════════════════════════════");
                
                return analise;
            }
            catch (HttpRequestException httpEx)
            {
                _logger.LogError("❌ [ERRO REDE] Falha na requisição HTTP!");
                _logger.LogError($"   Mensagem: {httpEx.Message}");
                _logger.LogError($"   InnerException: {httpEx.InnerException?.Message}");
                _logger.LogError("   💡 Possíveis causas:");
                _logger.LogError("      - Firewall bloqueando acesso");
                _logger.LogError("      - Proxy corporativo");
                _logger.LogError("      - DNS não resolvendo generativelanguage.googleapis.com");
                _logger.LogError("      - Sem conexão com internet");
                return null;
            }
            catch (TaskCanceledException timeoutEx)
            {
                _logger.LogError("❌ [ERRO TIMEOUT] Requisição excedeu tempo limite!");
                _logger.LogError($"   Mensagem: {timeoutEx.Message}");
                _logger.LogError("   💡 Gemini demorou mais de 30s para responder");
                return null;
            }
            catch (Exception ex)
            {
                _logger.LogError("❌ [ERRO INESPERADO] Exceção não tratada!");
                _logger.LogError($"   Tipo: {ex.GetType().Name}");
                _logger.LogError($"   Mensagem: {ex.Message}");
                _logger.LogError($"   StackTrace: {ex.StackTrace}");
                return null;
            }
        }
        
        /// <summary>
        /// Obtém a chave API do Gemini de múltiplas fontes
        /// Prioridade: 1) Variável de ambiente, 2) appsettings.json
        /// </summary>
        private string? ObterChaveAPI()
        {
            // Tentar variável de ambiente primeiro (carregada do .env)
            var apiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY");
            
            if (!string.IsNullOrEmpty(apiKey))
            {
                _logger.LogDebug("Chave obtida de: Variável de ambiente GEMINI_API_KEY");
                return apiKey.Trim().Trim('"'); // Remove aspas se houver
            }
            
            // Tentar appsettings.json
            apiKey = _configuration["GEMINI_API_KEY"] ?? _configuration["GeminiAI:ApiKey"];
            
            if (!string.IsNullOrEmpty(apiKey) && apiKey != "CONFIGURE_SUA_CHAVE_AQUI")
            {
                _logger.LogDebug("Chave obtida de: appsettings.json");
                return apiKey.Trim();
            }
            
            return null;
        }

        private async Task<string> CriarPromptAnalise(string descricaoProblema)
        {
            var categorias = await _context.Categorias.Where(c => c.Ativo).ToListAsync();
            var prioridades = await _context.Prioridades.Where(p => p.Ativo).OrderBy(p => p.Nivel).ToListAsync();

            var categoriasTexto = string.Join("\n", categorias.Select(c => $"- ID: {c.Id}, Nome: {c.Nome}, Descrição: {c.Descricao}"));
            var prioridadesTexto = string.Join("\n", prioridades.Select(p => $"- ID: {p.Id}, Nome: {p.Nome}, Nível: {p.Nivel}"));

            // Prompt otimizado para respostas mais curtas e precisas
            return $@"Você é um sistema de classificação de chamados de TI. Analise o problema e retorne APENAS um JSON válido.

PROBLEMA: {descricaoProblema}

CATEGORIAS:
{categoriasTexto}

PRIORIDADES:
{prioridadesTexto}

INSTRUÇÕES:
1. Escolha a categoria mais adequada
2. Defina a prioridade (1=Baixa, 2=Média, 3=Alta)
3. Crie um título curto (máximo 10 palavras)
4. Justifique em 1 frase

FORMATO DE RESPOSTA (JSON puro, sem markdown, sem explicações):
{{
  ""CategoriaId"": <número>,
  ""CategoriaNome"": ""<texto>"",
  ""PrioridadeId"": <número>,
  ""PrioridadeNome"": ""<texto>"",
  ""TituloSugerido"": ""<texto curto>"",
  ""Justificativa"": ""<1 frase>""
}}";
        }
    }
}
