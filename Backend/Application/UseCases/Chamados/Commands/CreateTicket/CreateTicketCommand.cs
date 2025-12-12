using MediatR;
using SistemaChamados.Core.Entities;

namespace SistemaChamados.Application.UseCases.Chamados.Commands.CreateTicket;

/// <summary>
/// Command for creating a standard ticket (without AI analysis).
/// </summary>
public record CreateTicketCommand(
    string Titulo,
    string Descricao,
    int SolicitanteId,
    int CategoriaId,
    int PrioridadeId) : IRequest<CreateTicketResult>;

/// <summary>
/// Result of CreateTicket operation.
/// </summary>
public record CreateTicketResult
{
    public bool Success { get; init; }
    public Chamado? Ticket { get; init; }
    public string? ErrorMessage { get; init; }

    public static CreateTicketResult SuccessResult(Chamado ticket) =>
        new()
        {
            Success = true,
            Ticket = ticket
        };

    public static CreateTicketResult Failure(string errorMessage) =>
        new()
        {
            Success = false,
            ErrorMessage = errorMessage
        };
}
