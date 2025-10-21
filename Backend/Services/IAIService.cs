using SistemaChamados.Application.DTOs;

namespace SistemaChamados.Services;

public interface IAIService
{
    Task<AnaliseIADto> AnalisarChamadoAsync(string titulo, string descricao);
}
