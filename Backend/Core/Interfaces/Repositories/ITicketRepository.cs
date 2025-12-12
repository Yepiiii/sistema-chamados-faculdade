using SistemaChamados.Core.Entities;

namespace SistemaChamados.Core.Interfaces.Repositories;

/// <summary>
/// Repository para operações de persistência de Chamados (Tickets).
/// Abstrai o acesso ao banco de dados, seguindo o Repository Pattern.
/// </summary>
public interface ITicketRepository
{
    /// <summary>
    /// Adiciona um novo chamado ao banco de dados.
    /// </summary>
    /// <param name="chamado">Entidade Chamado a ser adicionada.</param>
    /// <param name="cancellationToken">Token de cancelamento.</param>
    /// <returns>O chamado criado com ID preenchido.</returns>
    Task<Chamado> AddAsync(Chamado chamado, CancellationToken cancellationToken = default);

    /// <summary>
    /// Busca um chamado por ID sem navegações (lightweight).
    /// </summary>
    /// <param name="id">ID do chamado.</param>
    /// <param name="cancellationToken">Token de cancelamento.</param>
    /// <returns>Chamado ou null se não encontrado.</returns>
    Task<Chamado?> GetByIdAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Busca um chamado por ID com todas as navegações (entidades relacionadas).
    /// Inclui: Categoria, Status, Prioridade, Solicitante, Técnico, Comentários, Anexos.
    /// </summary>
    /// <param name="id">ID do chamado.</param>
    /// <param name="cancellationToken">Token de cancelamento.</param>
    /// <returns>Chamado completo ou null se não encontrado.</returns>
    Task<Chamado?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Atualiza um chamado existente.
    /// </summary>
    /// <param name="chamado">Entidade Chamado com alterações.</param>
    /// <param name="cancellationToken">Token de cancelamento.</param>
    Task UpdateAsync(Chamado chamado, CancellationToken cancellationToken = default);

    /// <summary>
    /// Lista chamados com filtros opcionais e navegações completas.
    /// </summary>
    /// <param name="statusId">Filtro por StatusId (opcional).</param>
    /// <param name="tecnicoId">Filtro por TecnicoId (0 = não atribuídos, null = todos, valor > 0 = técnico específico).</param>
    /// <param name="solicitanteId">Filtro por SolicitanteId (opcional).</param>
    /// <param name="prioridadeId">Filtro por PrioridadeId (opcional).</param>
    /// <param name="termoBusca">Termo de busca por ID, Titulo ou Categoria (opcional).</param>
    /// <param name="cancellationToken">Token de cancelamento.</param>
    /// <returns>Lista de chamados ordenada por DataAbertura (descrescente).</returns>
    Task<IEnumerable<Chamado>> GetWithFiltersAsync(
        int? statusId = null,
        int? tecnicoId = null,
        int? solicitanteId = null,
        int? prioridadeId = null,
        string? termoBusca = null,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Busca chamados com SLA expirado para atualização de status.
    /// Retorna chamados com StatusId em {1, 2, 3} (Aberto, Em Andamento, Aguardando)
    /// que tenham SlaDataExpiracao menor que a data atual.
    /// </summary>
    /// <param name="statusParaVerificar">IDs dos status a verificar (ex: {1, 2, 3}).</param>
    /// <param name="cancellationToken">Token de cancelamento.</param>
    /// <returns>Lista de chamados com SLA violado.</returns>
    Task<IEnumerable<Chamado>> GetExpiredSlaTicketsAsync(
        int[] statusParaVerificar,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Verifica se um chamado existe pelo ID.
    /// </summary>
    /// <param name="id">ID do chamado.</param>
    /// <param name="cancellationToken">Token de cancelamento.</param>
    /// <returns>True se existe, False caso contrário.</returns>
    Task<bool> ExistsAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Salva todas as alterações pendentes no banco de dados.
    /// </summary>
    /// <param name="cancellationToken">Token de cancelamento.</param>
    /// <returns>Número de entidades afetadas.</returns>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
