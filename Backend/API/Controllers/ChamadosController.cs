using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Application.UseCases.Chamados.Commands.CreateTicket;
using SistemaChamados.Application.UseCases.Chamados.Commands.CreateWithAI;
using SistemaChamados.Application.UseCases.Chamados.Commands.UpdateTicket;
using SistemaChamados.Application.UseCases.Chamados.Queries.GetTicketById;
using SistemaChamados.Application.UseCases.Chamados.Queries.GetTickets;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Interfaces.Auth;
using SistemaChamados.Core.Repositories;
using MediatR;

namespace SistemaChamados.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChamadosController : ControllerBase
{
    private readonly ITicketRepository _ticketRepository;
    private readonly ICommentRepository _commentRepository;
    private readonly IUserRepository _userRepository;
    private readonly ICategoryRepository _categoryRepository;
    private readonly IPriorityRepository _priorityRepository;
    private readonly IStatusRepository _statusRepository;
    private readonly ILogger<ChamadosController> _logger;
    private readonly IMediator _mediator;
    private readonly ICurrentUserService _currentUserService;

    public ChamadosController(
        ITicketRepository ticketRepository,
        ICommentRepository commentRepository,
        IUserRepository userRepository,
        ICategoryRepository categoryRepository,
        IPriorityRepository priorityRepository,
        IStatusRepository statusRepository,
        ILogger<ChamadosController> logger,
        IMediator mediator,
        ICurrentUserService currentUserService)
    {
        _ticketRepository = ticketRepository;
        _commentRepository = commentRepository;
        _userRepository = userRepository;
        _categoryRepository = categoryRepository;
        _priorityRepository = priorityRepository;
        _statusRepository = statusRepository;
        _logger = logger;
        _mediator = mediator;
        _currentUserService = currentUserService;
    }

    [HttpPost]
    public async Task<IActionResult> CriarChamado([FromBody] CriarChamadoRequestDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Get current user ID using Anti-Corruption Layer
        int solicitanteId;
        try
        {
            solicitanteId = _currentUserService.GetUserIdAsInt();
        }
        catch (InvalidOperationException)
        {
            return Unauthorized("Token inválido ou não contém o ID do usuário.");
        }

        // Delegate to CQRS Command Handler (Phase 4.1)
        var command = new CreateTicketCommand(
            request.Titulo,
            request.Descricao,
            solicitanteId,
            request.CategoriaId,
            request.PrioridadeId);

        var result = await _mediator.Send(command);

        if (!result.Success)
        {
            return BadRequest(result.ErrorMessage);
        }

        return Ok(result.Ticket);
    }
[HttpGet]
public async Task<IActionResult> GetChamados([FromQuery] int? statusId, [FromQuery] int? tecnicoId, [FromQuery] int? solicitanteId, [FromQuery] int? prioridadeId, [FromQuery] string? termoBusca)
{
    // Delegate to CQRS Query Handler (Phase 4.1)
    var query = new GetTicketsQuery(statusId, tecnicoId, solicitanteId, prioridadeId, termoBusca);
    var result = await _mediator.Send(query);

    if (!result.Success)
    {
        return StatusCode(500, result.ErrorMessage);
    }

    return Ok(result.Tickets);
}

[HttpGet("{id}")]
public async Task<IActionResult> GetChamadoPorId(int id)
{
    var chamado = await _ticketRepository.GetByIdWithDetailsAsync(id);

    if (chamado == null)
    {
        return NotFound("Chamado não encontrado.");
    }

    return Ok(chamado);
}

[HttpPut("{id}")]
public async Task<IActionResult> AtualizarChamado(int id, [FromBody] AtualizarChamadoDto request)
{
    // Get current user ID (optional for update)
    int? currentUserId = null;
    try
    {
        currentUserId = _currentUserService.GetUserIdAsInt();
    }
    catch { }

    // Delegate to CQRS Command Handler (Phase 4.1)
    var command = new UpdateTicketCommand(id, request.StatusId, request.TecnicoId, currentUserId);
    var result = await _mediator.Send(command);

    if (!result.Success)
    {
        return BadRequest(result.ErrorMessage);
    }

    return Ok(result.Ticket);
}

/// <summary>
/// Creates a ticket with AI analysis using CQRS pattern with MediatR.
/// Controller responsibility: Delegate to UserContextService and send command to handler.
/// All business logic is delegated to the Command Handler.
/// </summary>
[HttpPost("analisar")]
public async Task<IActionResult> AnalisarChamado([FromBody] AnalisarChamadoRequestDto request)
{
    try
    {
        // 1. ✅ REFATORADO: Anti-Corruption Layer - Zero conhecimento de JWT
        int userId;
        try
        {
            userId = _currentUserService.GetUserIdAsInt();
        }
        catch (InvalidOperationException ex)
        {
            return Unauthorized(ex.Message);
        }

        // 2. Create command and send via MediatR
        var command = new CreateTicketWithAIAnalysisCommand(
            DescricaoProblema: request.DescricaoProblema,
            UserId: userId
        );

        var result = await _mediator.Send(command, HttpContext.RequestAborted);

        // 3. Map Command result to HTTP response
        if (!result.Success)
        {
            return BadRequest(result.ErrorMessage);
        }

        return CreatedAtAction(
            nameof(GetChamadoPorId), 
            new { id = result.Ticket!.Id }, 
            result.Ticket);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Erro inesperado ao criar chamado com análise de IA.");
        return StatusCode(500, "Ocorreu um erro inesperado ao processar seu chamado.");
    }
}
}
