using MediatR;
using Microsoft.Extensions.Logging;
using SistemaChamados.Core.Repositories;

namespace SistemaChamados.Application.UseCases.Chamados.Commands.UpdateTicket;

/// <summary>
/// Handler for UpdateTicketCommand.
/// Responsibilities:
/// - Validate ticket exists
/// - Validate new status
/// - Validate technician (if provided)
/// - Update ticket using domain methods
/// - Handle business rules (e.g., unassign -> reopen)
/// </summary>
public class UpdateTicketHandler : IRequestHandler<UpdateTicketCommand, UpdateTicketResult>
{
    private readonly ITicketRepository _ticketRepository;
    private readonly IStatusRepository _statusRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<UpdateTicketHandler> _logger;

    public UpdateTicketHandler(
        ITicketRepository ticketRepository,
        IStatusRepository statusRepository,
        IUserRepository userRepository,
        ILogger<UpdateTicketHandler> logger)
    {
        _ticketRepository = ticketRepository;
        _statusRepository = statusRepository;
        _userRepository = userRepository;
        _logger = logger;
    }

    public async Task<UpdateTicketResult> Handle(UpdateTicketCommand command, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Atualizando ticket ID {TicketId}", command.TicketId);

        // 1. Validate ticket exists
        var chamado = await _ticketRepository.GetByIdAsync(command.TicketId);
        if (chamado == null)
        {
            return UpdateTicketResult.Failure("Chamado não encontrado.");
        }

        // 2. Validate new status
        var status = await _statusRepository.GetByIdAsync(command.StatusId);
        if (status == null)
        {
            return UpdateTicketResult.Failure("O StatusId fornecido é inválido.");
        }

        // 3. Validate technician if provided
        if (command.TecnicoId.HasValue)
        {
            var tecnico = await _userRepository.GetUserByIdAsync(command.TecnicoId.Value);
            if (tecnico == null || !tecnico.Ativo)
            {
                return UpdateTicketResult.Failure("O TecnicoId fornecido é inválido ou o usuário está inativo.");
            }
        }

        // 4. Update ticket using domain methods
        bool isFechado = command.StatusId == 4; // Status "Fechado"
        chamado.AtualizarStatus(command.StatusId, isFechado, command.CurrentUserId);
        chamado.AtribuirTecnico(command.TecnicoId);

        // 5. Business rule: If unassigned and not "Em Andamento", reopen
        if (!command.TecnicoId.HasValue && command.StatusId != 2)
        {
            chamado.AtualizarStatus(1, false); // Status "Aberto"
        }

        // 6. Persist changes
        await _ticketRepository.UpdateAsync(chamado);

        _logger.LogInformation("Ticket atualizado com sucesso: ID {TicketId}", command.TicketId);

        return UpdateTicketResult.SuccessResult(chamado);
    }
}
