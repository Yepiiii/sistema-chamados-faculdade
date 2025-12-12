using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Repositories;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Repositories;

public class CommentRepository(ApplicationDbContext context, ILogger<CommentRepository> logger) : ICommentRepository
{
    public async Task<List<Comentario>> GetByTicketIdWithUserAsync(int ticketId)
    {
        logger.LogInformation("Getting comments for ticket {TicketId} with user details", ticketId);
        
        return await context.Comentarios
            .Where(c => c.ChamadoId == ticketId)
            .Include(c => c.Usuario)
            .OrderBy(c => c.DataCriacao)
            .AsNoTracking()
            .ToListAsync();
    }

    public async Task AddAsync(Comentario comment)
    {
        logger.LogInformation("Adding new comment for ticket {TicketId}", comment.ChamadoId);
        
        await context.Comentarios.AddAsync(comment);
        await context.SaveChangesAsync();
    }

    public async Task SaveChangesAsync()
    {
        await context.SaveChangesAsync();
    }
}
