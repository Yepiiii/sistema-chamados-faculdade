using MediatR;
using Microsoft.Extensions.Logging;
using SistemaChamados.Core.Repositories;

namespace SistemaChamados.Application.UseCases.Chamados.Queries.GetTickets;

/// <summary>
/// Handler for GetTicketsQuery.
/// Responsibilities:
/// - Check and update SLA violations
/// - Apply filters (status, technician, requester, priority, search term)
/// - Return filtered tickets
/// </summary>
public class GetTicketsHandler : IRequestHandler<GetTicketsQuery, GetTicketsResult>
{
    private readonly ITicketRepository _ticketRepository;
    private readonly ILogger<GetTicketsHandler> _logger;

    public GetTicketsHandler(
        ITicketRepository ticketRepository,
        ILogger<GetTicketsHandler> logger)
    {
        _ticketRepository = ticketRepository;
        _logger = logger;
    }

    public async Task<GetTicketsResult> Handle(GetTicketsQuery query, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Buscando tickets com filtros: StatusId={StatusId}, TecnicoId={TecnicoId}, SolicitanteId={SolicitanteId}, PrioridadeId={PrioridadeId}, TermoBusca={TermoBusca}",
            query.StatusId, query.TecnicoId, query.SolicitanteId, query.PrioridadeId, query.TermoBusca);

        try
        {
            // 1. Check and update SLA violations
            // Status IDs: 1=Aberto, 2=Em Andamento, 3=Aguardando Resposta, 5=Violado
            var statusParaVerificar = new[] { 1, 2, 3 };
            var statusVioladoId = 5;

            var chamadosViolados = await _ticketRepository.GetExpiredSlaTicketsAsync(statusParaVerificar);

            if (chamadosViolados.Any())
            {
                foreach (var chamado in chamadosViolados)
                {
                    _logger.LogWarning("SLA VIOLADO: Chamado ID {ChamadoId} movido para status 'Violado'.", chamado.Id);
                    chamado.AtualizarStatus(statusVioladoId, isFechado: false);
                    await _ticketRepository.UpdateAsync(chamado);
                }
            }

            // 2. Execute query with filters
            var chamados = await _ticketRepository.GetWithFiltersAsync(
                query.StatusId,
                query.TecnicoId,
                query.SolicitanteId,
                query.PrioridadeId,
                query.TermoBusca
            );

            var chamadosList = chamados.ToList();
            _logger.LogInformation("Consulta finalizada. Resultados encontrados: {Count}", chamadosList.Count);

            return GetTicketsResult.SuccessResult(chamadosList);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao buscar chamados com filtros");
            return GetTicketsResult.Failure("Erro interno ao buscar chamados.");
        }
    }
}
