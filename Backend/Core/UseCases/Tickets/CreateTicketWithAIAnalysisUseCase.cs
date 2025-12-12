using SistemaChamados.Application.DTOs;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Interfaces.AI;
using SistemaChamados.Core.Repositories;
using SistemaChamados.Core.Domain.Services;

namespace SistemaChamados.Core.UseCases.Tickets;

/// <summary>
/// Result object for CreateTicketWithAIAnalysis operation.
/// </summary>
public record CreateTicketResult
{
    public bool Success { get; init; }
    public string? ErrorMessage { get; init; }
    public Chamado? Ticket { get; init; }
    
    public static CreateTicketResult Ok(Chamado ticket) => new() { Success = true, Ticket = ticket };
    public static CreateTicketResult Error(string message) => new() { Success = false, ErrorMessage = message };
}

/// <summary>
/// Use Case: Creates a ticket with AI analysis.
/// Encapsulates all business logic: validation, AI interaction, SLA calculation, and persistence.
/// The controller doesn't need to know about AI, SLA, or database details.
/// </summary>
public class CreateTicketWithAIAnalysisUseCase(
    IAIAnalysisService aiService,
    ITicketRepository ticketRepository,
    IStatusRepository statusRepository,
    IUserRepository userRepository,
    ICategoryRepository categoryRepository,
    IPriorityRepository priorityRepository,
    SlaCalculationService slaCalculationService)
{
    private readonly IAIAnalysisService _aiService = aiService;
    private readonly ITicketRepository _ticketRepository = ticketRepository;
    private readonly IStatusRepository _statusRepository = statusRepository;
    private readonly IUserRepository _userRepository = userRepository;
    private readonly ICategoryRepository _categoryRepository = categoryRepository;
    private readonly IPriorityRepository _priorityRepository = priorityRepository;
    private readonly SlaCalculationService _slaCalculationService = slaCalculationService;

    /// <summary>
    /// Executes the use case: analyzes the problem description with AI and creates a ticket.
    /// </summary>
    /// <param name="request">Request containing the problem description</param>
    /// <param name="userId">ID of the authenticated user creating the ticket</param>
    /// <param name="cancellationToken">Cancellation token</param>
    /// <returns>Result containing the created ticket or error message</returns>
    public async Task<CreateTicketResult> ExecuteAsync(
        AnalisarChamadoRequestDto request, 
        int userId, 
        CancellationToken cancellationToken = default)
    {
        // 1. Validate input
        if (string.IsNullOrWhiteSpace(request.DescricaoProblema))
        {
            return CreateTicketResult.Error("Descrição do problema é obrigatória.");
        }

        // 2. Validate user exists
        var usuario = await _userRepository.GetUserByIdAsync(userId);
        if (usuario == null || !usuario.Ativo)
        {
            return CreateTicketResult.Error("Usuário não encontrado ou inativo.");
        }

        // 3. Get AI analysis
        var analise = await _aiService.AnalisarChamadoAsync(request.DescricaoProblema);
        if (analise == null)
        {
            return CreateTicketResult.Error("Erro ao obter análise da IA. Tente novamente.");
        }

        // 4. Validate AI-suggested metadata exists
        var validationResult = await ValidateTicketMetadataAsync(analise, cancellationToken);
        if (!validationResult.IsValid)
        {
            return CreateTicketResult.Error(validationResult.ErrorMessage!);
        }

        // 5. Calculate SLA expiration date using Domain Service
        var slaExpiration = _slaCalculationService.CalculateSlaExpiration(validationResult.Priority!);

        // 6. Get "Aberto" status
        var statusAberto = await _statusRepository.GetByNameAsync("Aberto", cancellationToken);
        if (statusAberto == null)
        {
            return CreateTicketResult.Error("Status 'Aberto' não encontrado no banco de dados.");
        }

        // 7. Create ticket entity using DDD Factory Method
        var novoChamado = Chamado.Criar(
            titulo: analise.TituloSugerido,
            descricao: request.DescricaoProblema,
            solicitanteId: userId,
            categoriaId: analise.CategoriaId,
            prioridadeId: analise.PrioridadeId,
            statusAberto: statusAberto.Id,
            slaDataExpiracao: slaExpiration
        );

        // Atribui técnico se a IA sugeriu
        if (analise.TecnicoId.HasValue)
        {
            novoChamado.AtribuirTecnico(analise.TecnicoId);
        }

        // 8. Persist ticket
        var createdTicket = await _ticketRepository.CreateAsync(novoChamado, cancellationToken);

        return CreateTicketResult.Ok(createdTicket);
    }

    /// <summary>
    /// Validates that category and priority exist in the database.
    /// </summary>
    private async Task<ValidationResult> ValidateTicketMetadataAsync(
        AnaliseChamadoResponseDto analise, 
        CancellationToken cancellationToken)
    {
        var categoria = await _categoryRepository.GetByIdAsync(analise.CategoriaId, cancellationToken);
        if (categoria == null)
        {
            return ValidationResult.Invalid("A IA retornou uma CategoriaId inválida.");
        }

        var prioridade = await _priorityRepository.GetByIdAsync(analise.PrioridadeId, cancellationToken);
        if (prioridade == null)
        {
            return ValidationResult.Invalid("A IA retornou uma PrioridadeId inválida.");
        }

        return ValidationResult.Valid(prioridade);
    }

    /// <summary>
    /// Internal validation result helper.
    /// </summary>
    private record ValidationResult
    {
        public bool IsValid { get; init; }
        public string? ErrorMessage { get; init; }
        public Prioridade? Priority { get; init; }

        public static ValidationResult Valid(Prioridade priority) => new() 
        { 
            IsValid = true, 
            Priority = priority 
        };
        
        public static ValidationResult Invalid(string message) => new() 
        { 
            IsValid = false, 
            ErrorMessage = message 
        };
    }
}
