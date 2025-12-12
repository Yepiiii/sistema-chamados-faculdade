using SistemaChamados.Core.Entities;

namespace SistemaChamados.Core.Repositories;

public interface ICommentRepository
{
    Task<List<Comentario>> GetByTicketIdWithUserAsync(int ticketId);
    Task AddAsync(Comentario comment);
    Task SaveChangesAsync();
}
