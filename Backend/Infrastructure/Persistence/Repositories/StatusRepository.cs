using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Repositories;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Repositories;

/// <summary>
/// Repository implementation for Status operations.
/// </summary>
public class StatusRepository(ApplicationDbContext context, ILogger<StatusRepository> logger) : IStatusRepository
{
    public async Task<Status?> GetByIdAsync(int statusId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("StatusRepository.GetByIdAsync - Getting status ID={StatusId}", statusId);
        
        return await context.Status
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Id == statusId, cancellationToken);
    }
    
    public async Task<Status?> GetByNameAsync(string statusName, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("StatusRepository.GetByNameAsync - Getting status by name: {StatusName}", statusName);
        
        return await context.Status
            .AsNoTracking()
            .FirstOrDefaultAsync(s => s.Nome == statusName, cancellationToken);
    }
    
    public async Task<bool> ExistsAsync(int statusId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("StatusRepository.ExistsAsync - Checking if status ID={StatusId} exists", statusId);
        
        return await context.Status
            .AsNoTracking()
            .AnyAsync(s => s.Id == statusId, cancellationToken);
    }
    
    public async Task<IReadOnlyList<Status>> GetAllActiveAsync(CancellationToken cancellationToken = default)
    {
        logger.LogDebug("StatusRepository.GetAllActiveAsync - Getting all active statuses");
        
        return await context.Status
            .AsNoTracking()
            .Where(s => s.Ativo)
            .OrderBy(s => s.Nome)
            .ToListAsync(cancellationToken);
    }
}
