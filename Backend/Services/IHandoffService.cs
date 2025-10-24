using SistemaChamados.Application.DTOs;

namespace SistemaChamados.Services;

public interface IHandoffService
{
    /// <summary>
    /// Atribui técnico automaticamente baseado em categoria (método legado)
    /// </summary>
    Task<int?> AtribuirTecnicoAsync(int categoriaId);
    
    /// <summary>
    /// Atribui técnico com algoritmo inteligente baseado em score
    /// </summary>
    Task<AtribuicaoResultadoDto> AtribuirTecnicoInteligenteAsync(
        int chamadoId, 
        int categoriaId, 
        int prioridadeId,
        string metodoAtribuicao = "Automatico");
    
    /// <summary>
    /// Calcula score de adequação de técnicos para um chamado
    /// </summary>
    Task<List<TecnicoScoreDto>> CalcularScoresTecnicosAsync(
        int categoriaId, 
        int prioridadeId);
    
    /// <summary>
    /// Redistribui chamados se técnico ficar indisponível
    /// </summary>
    Task<int> RedistribuirChamadosAsync(int tecnicoId);
    
    /// <summary>
    /// Obtém estatísticas de distribuição de chamados
    /// </summary>
    Task<Dictionary<int, int>> ObterDistribuicaoCargaAsync();
}
