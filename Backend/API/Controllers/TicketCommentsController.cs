using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Application.UseCases.Comments.Commands.AddComment;
using SistemaChamados.Application.UseCases.Comments.Queries.GetComments;
using SistemaChamados.Core.Interfaces.Auth;

namespace SistemaChamados.API.Controllers;

/// <summary>
/// Controller dedicated to ticket comments operations.
/// Separated from ChamadosController following SRP (Phase 4.3).
/// Uses CQRS pattern with MediatR for all operations.
/// </summary>
[ApiController]
[Route("api/chamados")]
[Authorize]
public class TicketCommentsController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<TicketCommentsController> _logger;

    public TicketCommentsController(
        IMediator mediator,
        ICurrentUserService currentUserService,
        ILogger<TicketCommentsController> logger)
    {
        _mediator = mediator;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    /// <summary>
    /// Retrieves all comments for a specific ticket.
    /// </summary>
    /// <param name="chamadoId">Ticket ID</param>
    /// <returns>List of comments with user information</returns>
    [HttpGet("{chamadoId}/comentarios")]
    public async Task<IActionResult> GetComentarios(int chamadoId)
    {
        var query = new GetCommentsQuery(chamadoId);
        var result = await _mediator.Send(query);

        if (!result.Success)
        {
            return NotFound(result.ErrorMessage);
        }

        return Ok(result.Comments);
    }

    /// <summary>
    /// Adds a new comment to a ticket.
    /// </summary>
    /// <param name="chamadoId">Ticket ID</param>
    /// <param name="request">Comment data</param>
    /// <returns>Created comment with user information</returns>
    [HttpPost("{chamadoId}/comentarios")]
    public async Task<IActionResult> AdicionarComentario(int chamadoId, [FromBody] CriarComentarioDto request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        // Get current user ID using Anti-Corruption Layer
        int usuarioId;
        try
        {
            usuarioId = _currentUserService.GetUserIdAsInt();
        }
        catch (InvalidOperationException)
        {
            return Unauthorized("Token inválido ou não contém o ID do usuário.");
        }

        // Delegate to CQRS Command Handler
        var command = new AddCommentCommand(chamadoId, usuarioId, request.Texto);
        var result = await _mediator.Send(command);

        if (!result.Success)
        {
            return NotFound(result.ErrorMessage);
        }

        return CreatedAtAction(nameof(GetComentarios), new { chamadoId = chamadoId }, result.Comment);
    }
}
