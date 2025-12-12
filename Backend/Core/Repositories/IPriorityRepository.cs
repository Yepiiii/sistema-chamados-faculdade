using SistemaChamados.Core.Entities;

namespace SistemaChamados.Core.Repositories;

/// <summary>
/// Repository interface for Priority (Prioridade) operations.
/// </summary>
public interface IPriorityRepository
{
    /// <summary>
    /// Gets a priority by its ID.
    /// </summary>
    Task<Prioridade?> GetByIdAsync(int priorityId, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Checks if a priority exists.
    /// </summary>
    Task<bool> ExistsAsync(int priorityId, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets all active priorities.
    /// </summary>
    Task<IReadOnlyList<Prioridade>> GetAllActiveAsync(CancellationToken cancellationToken = default);
}
