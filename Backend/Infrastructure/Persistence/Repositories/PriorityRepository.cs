using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Repositories;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Repositories;

/// <summary>
/// Repository implementation for Priority (Prioridade) operations.
/// </summary>
public class PriorityRepository(ApplicationDbContext context, ILogger<PriorityRepository> logger) : IPriorityRepository
{
    public async Task<Prioridade?> GetByIdAsync(int priorityId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("PriorityRepository.GetByIdAsync - Getting priority ID={PriorityId}", priorityId);
        
        return await context.Prioridades
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Id == priorityId, cancellationToken);
    }
    
    public async Task<bool> ExistsAsync(int priorityId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("PriorityRepository.ExistsAsync - Checking if priority ID={PriorityId} exists", priorityId);
        
        return await context.Prioridades
            .AsNoTracking()
            .AnyAsync(p => p.Id == priorityId, cancellationToken);
    }
    
    public async Task<IReadOnlyList<Prioridade>> GetAllActiveAsync(CancellationToken cancellationToken = default)
    {
        logger.LogDebug("PriorityRepository.GetAllActiveAsync - Getting all active priorities");
        
        return await context.Prioridades
            .AsNoTracking()
            .Where(p => p.Ativo)
            .OrderBy(p => p.Nivel)
            .ToListAsync(cancellationToken);
    }
}
