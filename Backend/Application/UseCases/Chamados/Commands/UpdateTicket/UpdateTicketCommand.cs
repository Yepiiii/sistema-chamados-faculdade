using MediatR;
using SistemaChamados.Core.Entities;

namespace SistemaChamados.Application.UseCases.Chamados.Commands.UpdateTicket;

/// <summary>
/// Command for updating a ticket.
/// </summary>
public record UpdateTicketCommand(
    int TicketId,
    int StatusId,
    int? TecnicoId,
    int? CurrentUserId) : IRequest<UpdateTicketResult>;

/// <summary>
/// Result of UpdateTicket operation.
/// </summary>
public record UpdateTicketResult
{
    public bool Success { get; init; }
    public Chamado? Ticket { get; init; }
    public string? ErrorMessage { get; init; }

    public static UpdateTicketResult SuccessResult(Chamado ticket) =>
        new()
        {
            Success = true,
            Ticket = ticket
        };

    public static UpdateTicketResult Failure(string errorMessage) =>
        new()
        {
            Success = false,
            ErrorMessage = errorMessage
        };
}
