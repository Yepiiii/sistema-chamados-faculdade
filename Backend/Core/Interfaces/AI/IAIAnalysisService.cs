using SistemaChamados.Application.DTOs;

namespace SistemaChamados.Core.Interfaces.AI
{
    /// <summary>
    /// Abstração para serviços de análise de chamados com IA.
    /// Permite trocar provedores (OpenAI, Gemini, Azure OpenAI) sem modificar o código do domínio.
    /// </summary>
    public interface IAIAnalysisService
    {
        /// <summary>
        /// Analisa a descrição de um problema e retorna sugestões de categorização e priorização.
        /// </summary>
        /// <param name="descricaoProblema">Texto descrevendo o problema reportado</param>
        /// <returns>Análise com categoria, prioridade, título e técnico sugeridos, ou null se falhar</returns>
        Task<AnaliseChamadoResponseDto?> AnalisarChamadoAsync(string descricaoProblema);
    }
}
