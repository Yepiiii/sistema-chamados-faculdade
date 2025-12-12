using SistemaChamados.Core.Entities;

namespace SistemaChamados.Core.Repositories;

/// <summary>
/// Repository interface for Ticket (Chamado) operations.
/// Abstracts data access from business logic following Repository Pattern.
/// Controllers and Use Cases should NEVER depend on ApplicationDbContext directly.
/// </summary>
public interface ITicketRepository
{
    /// <summary>
    /// Creates a new ticket and returns it with all navigation properties loaded.
    /// </summary>
    Task<Chamado> CreateAsync(Chamado ticket, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets a ticket by ID without navigation properties (lightweight).
    /// </summary>
    Task<Chamado?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets a ticket by ID with all navigation properties (Categoria, Prioridade, Status, etc).
    /// </summary>
    Task<Chamado?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Updates an existing ticket.
    /// </summary>
    Task UpdateAsync(Chamado ticket, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Lists tickets with optional filters and full navigation properties.
    /// </summary>
    Task<IEnumerable<Chamado>> GetWithFiltersAsync(
        int? statusId = null,
        int? tecnicoId = null,
        int? solicitanteId = null,
        int? prioridadeId = null,
        string? termoBusca = null,
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets tickets with expired SLA for status update.
    /// Returns tickets with StatusId in specified array that have SlaDataExpiracao less than current time.
    /// </summary>
    Task<IEnumerable<Chamado>> GetExpiredSlaTicketsAsync(
        int[] statusParaVerificar,
        CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Checks if a ticket exists by ID.
    /// </summary>
    Task<bool> ExistsAsync(int id, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Saves all pending changes to the database.
    /// Useful for batch operations or when UpdateAsync is not enough.
    /// </summary>
    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
