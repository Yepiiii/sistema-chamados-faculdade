using Microsoft.Extensions.Logging;
using SistemaChamados.Application.DTOs;

namespace SistemaChamados.Services;

public class AIService : IAIService
{
    private readonly IOpenAIService _geminiService;
    private readonly ILogger<AIService> _logger;

    public AIService(IOpenAIService geminiService, ILogger<AIService> logger)
    {
        _geminiService = geminiService;
        _logger = logger;
    }

    public async Task<AnaliseIADto> AnalisarChamadoAsync(string titulo, string descricao)
    {
        try
        {
            _logger.LogInformation("Iniciando análise com Gemini AI para: {Titulo}", titulo);

            // Chamar o Gemini OBRIGATORIAMENTE
            var analiseGemini = await _geminiService.AnalisarChamadoAsync($"{titulo}\n{descricao}");

            if (analiseGemini == null)
            {
                _logger.LogError("Gemini retornou null. Análise falhou.");
                throw new Exception("Análise do Gemini falhou. Verifique a chave da API e os logs.");
            }

            _logger.LogInformation(
                "Gemini sugeriu CategoriaId {CategoriaId} ({CategoriaNome}) e PrioridadeId {PrioridadeId} ({PrioridadeNome})",
                analiseGemini.CategoriaId,
                analiseGemini.CategoriaNome,
                analiseGemini.PrioridadeId,
                analiseGemini.PrioridadeNome
            );

            return new AnaliseIADto
            {
                CategoriaId = analiseGemini.CategoriaId,
                PrioridadeId = analiseGemini.PrioridadeId,
                TituloSugerido = analiseGemini.TituloSugerido,
                Justificativa = analiseGemini.Justificativa,
                TecnicoId = analiseGemini.TecnicoId,
                TecnicoNome = analiseGemini.TecnicoNome
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "ERRO CRÍTICO ao usar Gemini AI");
            throw; // Propagar o erro para que o controller retorne 500
        }
    }
}
