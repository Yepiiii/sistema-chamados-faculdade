using SistemaChamados.Application.DTOs;

namespace SistemaChamados.Services
{
    public interface IGeminiService
    {
        Task<AnaliseChamadoResponseDto?> AnalisarChamadoAsync(string descricaoProblema);
        
        /// <summary>
        /// Analisa chamado com contexto do sistema de handoff para decisão mais precisa
        /// </summary>
        Task<AnaliseChamadoComHandoffDto?> AnalisarChamadoComHandoffAsync(
            string titulo, 
            string descricao, 
            List<TecnicoScoreDto> tecnicosDisponiveis);
    }
}