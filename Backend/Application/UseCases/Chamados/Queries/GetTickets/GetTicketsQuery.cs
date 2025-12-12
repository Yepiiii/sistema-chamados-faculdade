using MediatR;
using SistemaChamados.Core.Entities;

namespace SistemaChamados.Application.UseCases.Chamados.Queries.GetTickets;

/// <summary>
/// Query for retrieving tickets with optional filters.
/// </summary>
public record GetTicketsQuery(
    int? StatusId = null,
    int? TecnicoId = null,
    int? SolicitanteId = null,
    int? PrioridadeId = null,
    string? TermoBusca = null) : IRequest<GetTicketsResult>;

/// <summary>
/// Result of GetTickets query.
/// </summary>
public record GetTicketsResult
{
    public bool Success { get; init; }
    public IEnumerable<Chamado>? Tickets { get; init; }
    public string? ErrorMessage { get; init; }

    public static GetTicketsResult SuccessResult(IEnumerable<Chamado> tickets) =>
        new()
        {
            Success = true,
            Tickets = tickets
        };

    public static GetTicketsResult Failure(string errorMessage) =>
        new()
        {
            Success = false,
            ErrorMessage = errorMessage
        };
}
