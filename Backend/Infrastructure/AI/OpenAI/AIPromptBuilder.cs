using SistemaChamados.Core.Repositories;

namespace SistemaChamados.Infrastructure.AI.OpenAI;

/// <summary>
/// Builder responsável por construir prompts para análise de chamados via IA.
/// Separado do OpenAIAdapter para aplicar Single Responsibility Principle.
/// </summary>
public class AIPromptBuilder
{
    private readonly ICategoryRepository _categoryRepository;
    private readonly IPriorityRepository _priorityRepository;
    private readonly ILogger<AIPromptBuilder> _logger;

    public AIPromptBuilder(
        ICategoryRepository categoryRepository,
        IPriorityRepository priorityRepository,
        ILogger<AIPromptBuilder> logger)
    {
        _categoryRepository = categoryRepository;
        _priorityRepository = priorityRepository;
        _logger = logger;
    }

    /// <summary>
    /// Cria um prompt para análise de chamado de TI, incluindo categorias e prioridades disponíveis.
    /// </summary>
    /// <param name="descricaoProblema">Descrição do problema relatado pelo usuário</param>
    /// <returns>Prompt formatado para a IA</returns>
    public async Task<string> CriarPromptAnaliseAsync(string descricaoProblema)
    {
        _logger.LogInformation("Building AI prompt for ticket analysis");

        var categorias = await _categoryRepository.GetAllActiveAsync();
        var prioridades = await _priorityRepository.GetAllActiveAsync();

        var categoriasTexto = string.Join("\n", 
            categorias.Select(c => $"- ID: {c.Id}, Nome: {c.Nome}"));
        
        var prioridadesTexto = string.Join("\n", 
            prioridades.Select(p => $"- ID: {p.Id}, Nome: {p.Nome}"));

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
  ""Justificativa"": ""<Uma breve justificativa para a sua escolha>""
}}";
    }
}
