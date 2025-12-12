using MediatR;
using Microsoft.Extensions.Logging;
using SistemaChamados.Core.Repositories;

namespace SistemaChamados.Application.UseCases.Chamados.Queries.GetTicketById;

/// <summary>
/// Handler for GetTicketByIdQuery.
/// Responsibilities:
/// - Retrieve ticket by ID
/// - Return ticket or not found
/// </summary>
public class GetTicketByIdHandler : IRequestHandler<GetTicketByIdQuery, GetTicketByIdResult>
{
    private readonly ITicketRepository _ticketRepository;
    private readonly ILogger<GetTicketByIdHandler> _logger;

    public GetTicketByIdHandler(
        ITicketRepository ticketRepository,
        ILogger<GetTicketByIdHandler> logger)
    {
        _ticketRepository = ticketRepository;
        _logger = logger;
    }

    public async Task<GetTicketByIdResult> Handle(GetTicketByIdQuery query, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Buscando ticket ID {TicketId}", query.TicketId);

        var chamado = await _ticketRepository.GetByIdAsync(query.TicketId);

        if (chamado == null)
        {
            _logger.LogWarning("Ticket não encontrado: ID {TicketId}", query.TicketId);
            return GetTicketByIdResult.Failure("Chamado não encontrado.");
        }

        _logger.LogInformation("Ticket encontrado: ID {TicketId}", query.TicketId);
        return GetTicketByIdResult.SuccessResult(chamado);
    }
}
