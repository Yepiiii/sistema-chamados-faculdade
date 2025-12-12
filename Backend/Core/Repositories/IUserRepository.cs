using SistemaChamados.Core.Entities;

namespace SistemaChamados.Core.Repositories;

public interface IUserRepository
{
    Task<string?> GetUserNameByIdAsync(int userId);
    
    /// <summary>
    /// Busca um técnico especialista ativo por categoria de especialidade.
    /// </summary>
    /// <param name="categoriaId">ID da categoria</param>
    /// <returns>Técnico especialista ou null se não encontrado</returns>
    Task<Usuario?> GetTecnicoEspecialistaAsync(int categoriaId);
    
    /// <summary>
    /// Busca qualquer técnico ativo (fallback quando não há especialista).
    /// </summary>
    /// <returns>Técnico ativo ou null se não encontrado</returns>
    Task<Usuario?> GetTecnicoAtivoAsync();
    
    /// <summary>
    /// Busca um usuário por ID (usado pelo UserLookupService para context mapping).
    /// </summary>
    /// <param name="userId">ID do usuário</param>
    /// <returns>Usuário ou null se não encontrado</returns>
    Task<Usuario?> GetUserByIdAsync(int userId);
    
    /// <summary>
    /// Busca múltiplos usuários por IDs (batch operation para performance).
    /// </summary>
    /// <param name="userIds">Lista de IDs de usuários</param>
    /// <returns>Dicionário com usuários encontrados</returns>
    Task<Dictionary<int, Usuario>> GetUsersByIdsAsync(IEnumerable<int> userIds);
}
