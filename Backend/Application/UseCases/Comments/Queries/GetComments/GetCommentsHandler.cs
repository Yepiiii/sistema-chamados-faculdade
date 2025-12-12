using MediatR;
using Microsoft.Extensions.Logging;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Core.Repositories;

namespace SistemaChamados.Application.UseCases.Comments.Queries.GetComments;

/// <summary>
/// Handler for GetCommentsQuery.
/// Responsibilities:
/// - Validate ticket exists
/// - Retrieve comments with user information
/// - Map to DTOs
/// </summary>
public class GetCommentsHandler : IRequestHandler<GetCommentsQuery, GetCommentsResult>
{
    private readonly ITicketRepository _ticketRepository;
    private readonly ICommentRepository _commentRepository;
    private readonly ILogger<GetCommentsHandler> _logger;

    public GetCommentsHandler(
        ITicketRepository ticketRepository,
        ICommentRepository commentRepository,
        ILogger<GetCommentsHandler> logger)
    {
        _ticketRepository = ticketRepository;
        _commentRepository = commentRepository;
        _logger = logger;
    }

    public async Task<GetCommentsResult> Handle(GetCommentsQuery query, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Buscando comentários para chamado ID {ChamadoId}", query.ChamadoId);

        // 1. Validate ticket exists
        var chamadoExiste = await _ticketRepository.ExistsAsync(query.ChamadoId);
        if (!chamadoExiste)
        {
            return GetCommentsResult.Failure("Chamado não encontrado.");
        }

        // 2. Retrieve comments with user information
        var comentarios = await _commentRepository.GetByTicketIdWithUserAsync(query.ChamadoId);

        // 3. Map to DTOs
        var comentarioDtos = comentarios.Select(c => new ComentarioResponseDto
        {
            Id = c.Id,
            Texto = c.Texto,
            DataCriacao = c.DataCriacao,
            UsuarioId = c.UsuarioId,
            UsuarioNome = c.Usuario.NomeCompleto,
            ChamadoId = c.ChamadoId
        }).ToList();

        _logger.LogInformation("Encontrados {Count} comentários para chamado ID {ChamadoId}", comentarioDtos.Count, query.ChamadoId);

        return GetCommentsResult.SuccessResult(comentarioDtos);
    }
}
