using SistemaChamados.Core.Entities;

namespace SistemaChamados.Core.Repositories;

/// <summary>
/// Repository interface for Status operations.
/// </summary>
public interface IStatusRepository
{
    /// <summary>
    /// Gets a status by its ID.
    /// </summary>
    Task<Status?> GetByIdAsync(int statusId, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets a status by its name.
    /// </summary>
    Task<Status?> GetByNameAsync(string statusName, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Checks if a status exists.
    /// </summary>
    Task<bool> ExistsAsync(int statusId, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets all active statuses.
    /// </summary>
    Task<IReadOnlyList<Status>> GetAllActiveAsync(CancellationToken cancellationToken = default);
}
