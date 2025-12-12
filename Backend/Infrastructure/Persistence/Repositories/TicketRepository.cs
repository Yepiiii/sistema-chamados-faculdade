using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Repositories;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Repositories;

/// <summary>
/// Repository implementation for Ticket (Chamado) operations.
/// Encapsulates all EF Core queries and data access logic.
/// Uses Primary Constructor (.NET 10) for dependency injection.
/// </summary>
public class TicketRepository(
    ApplicationDbContext context,
    ILogger<TicketRepository> logger) : ITicketRepository
{
    public async Task<Chamado> CreateAsync(Chamado ticket, CancellationToken cancellationToken = default)
    {
        logger.LogInformation("TicketRepository.CreateAsync - Creating ticket: {Title}", ticket.Titulo);
        
        context.Chamados.Add(ticket);
        await context.SaveChangesAsync(cancellationToken);
        
        logger.LogInformation("TicketRepository.CreateAsync - Ticket created with ID={Id}", ticket.Id);
        
        // Reload with navigation properties populated
        return await GetByIdWithDetailsAsync(ticket.Id, cancellationToken) 
            ?? throw new InvalidOperationException("Failed to retrieve created ticket");
    }

    public async Task<Chamado?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("TicketRepository.GetByIdAsync - Getting ticket ID={Id}", id);
        return await context.Chamados.FindAsync(new object[] { id }, cancellationToken);
    }

    public async Task<Chamado?> GetByIdWithDetailsAsync(int id, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("TicketRepository.GetByIdWithDetailsAsync - Getting ticket ID={Id} with details", id);
        
        return await context.Chamados
            .Include(c => c.Categoria)
            .Include(c => c.Prioridade)
            .Include(c => c.Status)
            .Include(c => c.Solicitante)
            .Include(c => c.Tecnico)
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.Id == id, cancellationToken);
    }

    public async Task UpdateAsync(Chamado ticket, CancellationToken cancellationToken = default)
    {
        logger.LogInformation("TicketRepository.UpdateAsync - Updating ticket ID={Id}", ticket.Id);
        
        context.Chamados.Update(ticket);
        await context.SaveChangesAsync(cancellationToken);
        
        logger.LogInformation("TicketRepository.UpdateAsync - Ticket ID={Id} updated successfully", ticket.Id);
    }

    public async Task<IEnumerable<Chamado>> GetWithFiltersAsync(
        int? statusId = null,
        int? tecnicoId = null,
        int? solicitanteId = null,
        int? prioridadeId = null,
        string? termoBusca = null,
        CancellationToken cancellationToken = default)
    {
        logger.LogInformation(
            "TicketRepository.GetWithFiltersAsync - Filters: statusId={StatusId}, tecnicoId={TecnicoId}, " +
            "solicitanteId={SolicitanteId}, prioridadeId={PrioridadeId}, termoBusca={TermoBusca}",
            statusId, tecnicoId, solicitanteId, prioridadeId, termoBusca);

        var query = context.Chamados.AsQueryable();

        // Filter by StatusId
        if (statusId.HasValue)
        {
            query = query.Where(c => c.StatusId == statusId.Value);
        }

        // Filter by TecnicoId (0 = unassigned, null = all, value > 0 = specific technician)
        if (tecnicoId.HasValue)
        {
            if (tecnicoId.Value == 0)
            {
                query = query.Where(c => c.TecnicoId == null);
            }
            else
            {
                query = query.Where(c => c.TecnicoId == tecnicoId.Value);
            }
        }

        // Filter by SolicitanteId
        if (solicitanteId.HasValue)
        {
            query = query.Where(c => c.SolicitanteId == solicitanteId.Value);
        }

        // Filter by PrioridadeId
        if (prioridadeId.HasValue)
        {
            query = query.Where(c => c.PrioridadeId == prioridadeId.Value);
        }

        // Filter by search term (ID, Title or Category)
        if (!string.IsNullOrWhiteSpace(termoBusca))
        {
            string busca = termoBusca.ToLower().Trim();
            int.TryParse(busca, out int idBusca);

            query = query.Where(c =>
                c.Id == idBusca ||
                c.Titulo.ToLower().Contains(busca) ||
                c.Categoria.Nome.ToLower().Contains(busca));
        }

        // Execute query with navigation properties and ordering
        var chamados = await query
            .Include(c => c.Categoria)
            .Include(c => c.Status)
            .Include(c => c.Prioridade)
            .Include(c => c.Solicitante)
            .Include(c => c.Tecnico)
            .OrderByDescending(c => c.DataAbertura)
            .AsNoTracking()
            .ToListAsync(cancellationToken);

        logger.LogInformation("TicketRepository.GetWithFiltersAsync - Found {Count} tickets", chamados.Count);
        
        return chamados;
    }

    public async Task<IEnumerable<Chamado>> GetExpiredSlaTicketsAsync(
        int[] statusParaVerificar,
        CancellationToken cancellationToken = default)
    {
        logger.LogInformation(
            "TicketRepository.GetExpiredSlaTicketsAsync - Checking tickets with status: {StatusIds}",
            string.Join(", ", statusParaVerificar));

        var chamadosViolados = await context.Chamados
            .Where(c => statusParaVerificar.Contains(c.StatusId) &&
                        c.SlaDataExpiracao.HasValue &&
                        c.SlaDataExpiracao < DateTime.UtcNow)
            .ToListAsync(cancellationToken);

        logger.LogInformation(
            "TicketRepository.GetExpiredSlaTicketsAsync - Found {Count} tickets with expired SLA",
            chamadosViolados.Count);

        return chamadosViolados;
    }

    public async Task<bool> ExistsAsync(int id, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("TicketRepository.ExistsAsync - Checking if ticket ID={Id} exists", id);
        return await context.Chamados.AnyAsync(c => c.Id == id, cancellationToken);
    }

    public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        logger.LogDebug("TicketRepository.SaveChangesAsync - Saving pending changes");
        int affectedRows = await context.SaveChangesAsync(cancellationToken);
        logger.LogInformation("TicketRepository.SaveChangesAsync - {Rows} rows affected", affectedRows);
        return affectedRows;
    }
}
