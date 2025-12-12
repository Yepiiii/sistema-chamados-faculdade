using MediatR;
using SistemaChamados.Core.Entities;

namespace SistemaChamados.Application.UseCases.Chamados.Queries.GetTicketById;

/// <summary>
/// Query for retrieving a single ticket by ID.
/// </summary>
public record GetTicketByIdQuery(int TicketId) : IRequest<GetTicketByIdResult>;

/// <summary>
/// Result of GetTicketById query.
/// </summary>
public record GetTicketByIdResult
{
    public bool Success { get; init; }
    public Chamado? Ticket { get; init; }
    public string? ErrorMessage { get; init; }

    public static GetTicketByIdResult SuccessResult(Chamado ticket) =>
        new()
        {
            Success = true,
            Ticket = ticket
        };

    public static GetTicketByIdResult Failure(string errorMessage) =>
        new()
        {
            Success = false,
            ErrorMessage = errorMessage
        };
}
