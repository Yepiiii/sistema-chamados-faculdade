using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Repositories;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Repositories;

/// <summary>
/// Repository implementation for Category (Categoria) operations.
/// </summary>
public class CategoryRepository(ApplicationDbContext context, ILogger<CategoryRepository> logger) : ICategoryRepository
{
    public async Task<Categoria?> GetByIdAsync(int categoryId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("CategoryRepository.GetByIdAsync - Getting category ID={CategoryId}", categoryId);
        
        return await context.Categorias
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.Id == categoryId, cancellationToken);
    }
    
    public async Task<bool> ExistsAsync(int categoryId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("CategoryRepository.ExistsAsync - Checking if category ID={CategoryId} exists", categoryId);
        
        return await context.Categorias
            .AsNoTracking()
            .AnyAsync(c => c.Id == categoryId, cancellationToken);
    }
    
    public async Task<IReadOnlyList<Categoria>> GetAllActiveAsync(CancellationToken cancellationToken = default)
    {
        logger.LogDebug("CategoryRepository.GetAllActiveAsync - Getting all active categories");
        
        return await context.Categorias
            .AsNoTracking()
            .Where(c => c.Ativo)
            .OrderBy(c => c.Nome)
            .ToListAsync(cancellationToken);
    }
}
