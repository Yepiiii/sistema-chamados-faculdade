using MediatR;
using Microsoft.Extensions.Logging;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Repositories;

namespace SistemaChamados.Application.UseCases.Chamados.Commands.CreateTicket;

/// <summary>
/// Handler for CreateTicketCommand.
/// Responsibilities:
/// - Validate ticket metadata (category, priority, user)
/// - Calculate SLA expiration
/// - Create ticket with "Aberto" status
/// - Persist to database
/// </summary>
public class CreateTicketHandler : IRequestHandler<CreateTicketCommand, CreateTicketResult>
{
    private readonly ITicketRepository _ticketRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly IPriorityRepository _priorityRepository;
    private readonly IStatusRepository _statusRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<CreateTicketHandler> _logger;

    public CreateTicketHandler(
        ITicketRepository ticketRepository,
        ICategoryRepository categoryRepository,
        IPriorityRepository priorityRepository,
        IStatusRepository statusRepository,
        IUserRepository userRepository,
        ILogger<CreateTicketHandler> logger)
    {
        _ticketRepository = ticketRepository;
        _categoryRepository = categoryRepository;
        _priorityRepository = priorityRepository;
        _statusRepository = statusRepository;
        _userRepository = userRepository;
        _logger = logger;
    }

    public async Task<CreateTicketResult> Handle(CreateTicketCommand command, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Criando ticket: {Titulo}", command.Titulo);

        // 1. Validate category
        var categoria = await _categoryRepository.GetByIdAsync(command.CategoriaId);
        if (categoria == null)
        {
            return CreateTicketResult.Failure("Categoria não encontrada ou inativa");
        }

        // 2. Validate priority
        var prioridade = await _priorityRepository.GetByIdAsync(command.PrioridadeId);
        if (prioridade == null)
        {
            return CreateTicketResult.Failure("Prioridade não encontrada ou inativa");
        }

        // 3. Validate user
        var solicitante = await _userRepository.GetUserByIdAsync(command.SolicitanteId);
        if (solicitante == null || !solicitante.Ativo)
        {
            return CreateTicketResult.Failure("Usuário não encontrado ou inativo");
        }

        // 4. Calculate SLA expiration based on priority
        DateTime? slaExpiracao = null;
        if (prioridade.TempoRespostaHoras > 0)
        {
            slaExpiracao = DateTime.UtcNow.AddHours(prioridade.TempoRespostaHoras);
        }

        // 5. Get "Aberto" status
        var statusAberto = await _statusRepository.GetByNameAsync("Aberto");
        if (statusAberto == null)
        {
            _logger.LogError("Status 'Aberto' não encontrado no banco de dados");
            return CreateTicketResult.Failure("Status 'Aberto' não encontrado no banco de dados.");
        }

        // 6. Create ticket using DDD factory method
        var novoChamado = Chamado.Criar(
            titulo: command.Titulo,
            descricao: command.Descricao,
            solicitanteId: command.SolicitanteId,
            categoriaId: command.CategoriaId,
            prioridadeId: command.PrioridadeId,
            statusAberto: statusAberto.Id,
            slaDataExpiracao: slaExpiracao
        );

        // 7. Persist to database
        var chamadoCompleto = await _ticketRepository.CreateAsync(novoChamado);

        _logger.LogInformation("Ticket criado com sucesso: ID {TicketId}", chamadoCompleto.Id);

        return CreateTicketResult.SuccessResult(chamadoCompleto);
    }
}
