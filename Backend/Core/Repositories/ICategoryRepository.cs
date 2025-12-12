using SistemaChamados.Core.Entities;

namespace SistemaChamados.Core.Repositories;

/// <summary>
/// Repository interface for Category (Categoria) operations.
/// </summary>
public interface ICategoryRepository
{
    /// <summary>
    /// Gets a category by its ID.
    /// </summary>
    Task<Categoria?> GetByIdAsync(int categoryId, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Checks if a category exists.
    /// </summary>
    Task<bool> ExistsAsync(int categoryId, CancellationToken cancellationToken = default);
    
    /// <summary>
    /// Gets all active categories.
    /// </summary>
    Task<IReadOnlyList<Categoria>> GetAllActiveAsync(CancellationToken cancellationToken = default);
}
