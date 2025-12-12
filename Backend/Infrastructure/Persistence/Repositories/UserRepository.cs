using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Repositories;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Repositories;

public class UserRepository(ApplicationDbContext context, ILogger<UserRepository> logger) : IUserRepository
{
    public async Task<string?> GetUserNameByIdAsync(int userId)
    {
        logger.LogInformation("Getting user name for user {UserId}", userId);
        
        return await context.Usuarios
            .Where(u => u.Id == userId)
            .Select(u => u.NomeCompleto)
            .AsNoTracking()
            .FirstOrDefaultAsync();
    }
    
    public async Task<Usuario?> GetTecnicoEspecialistaAsync(int categoriaId)
    {
        logger.LogInformation("Getting specialist technician for category {CategoriaId}", categoriaId);
        
        return await context.Usuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(u => 
                u.TipoUsuario == 2 && 
                u.EspecialidadeCategoriaId == categoriaId && 
                u.Ativo);
    }
    
    public async Task<Usuario?> GetTecnicoAtivoAsync()
    {
        logger.LogInformation("Getting any active technician as fallback");
        
        return await context.Usuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.TipoUsuario == 2 && u.Ativo);
    }
    
    public async Task<Usuario?> GetUserByIdAsync(int userId)
    {
        logger.LogInformation("Getting user by ID {UserId} for context mapping", userId);
        
        return await context.Usuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == userId);
    }
    
    public async Task<Dictionary<int, Usuario>> GetUsersByIdsAsync(IEnumerable<int> userIds)
    {
        var ids = userIds.Distinct().ToList();
        logger.LogInformation("Getting {Count} users by IDs for batch operation", ids.Count);
        
        var usuarios = await context.Usuarios
            .AsNoTracking()
            .Where(u => ids.Contains(u.Id))
            .ToListAsync();
            
        return usuarios.ToDictionary(u => u.Id);
    }
}
