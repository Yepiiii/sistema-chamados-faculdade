using MediatR;
using Microsoft.Extensions.Logging;
using SistemaChamados.Application.DTOs;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Repositories;

namespace SistemaChamados.Application.UseCases.Comments.Commands.AddComment;

/// <summary>
/// Handler for AddCommentCommand.
/// Responsibilities:
/// - Validate ticket exists
/// - Create comment entity
/// - Add comment to ticket (domain method)
/// - Persist comment
/// - Return comment DTO
/// </summary>
public class AddCommentHandler : IRequestHandler<AddCommentCommand, AddCommentResult>
{
    private readonly ITicketRepository _ticketRepository;
    private readonly ICommentRepository _commentRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILogger<AddCommentHandler> _logger;

    public AddCommentHandler(
        ITicketRepository ticketRepository,
        ICommentRepository commentRepository,
        IUserRepository userRepository,
        ILogger<AddCommentHandler> logger)
    {
        _ticketRepository = ticketRepository;
        _commentRepository = commentRepository;
        _userRepository = userRepository;
        _logger = logger;
    }

    public async Task<AddCommentResult> Handle(AddCommentCommand command, CancellationToken cancellationToken)
    {
        _logger.LogInformation("Adicionando comentário ao chamado ID {ChamadoId}", command.ChamadoId);

        // 1. Validate ticket exists
        var chamado = await _ticketRepository.GetByIdAsync(command.ChamadoId);
        if (chamado == null)
        {
            return AddCommentResult.Failure("Chamado não encontrado.");
        }

        // 2. Create comment entity
        var novoComentario = new Comentario
        {
            Texto = command.Texto,
            ChamadoId = command.ChamadoId,
            UsuarioId = command.UsuarioId,
            DataCriacao = DateTime.UtcNow
        };

        // 3. Add comment using domain method
        chamado.AdicionarComentario(novoComentario);
        await _ticketRepository.UpdateAsync(chamado);

        // 4. Persist comment
        await _commentRepository.AddAsync(novoComentario);

        // 5. Get user name for response DTO
        var nomeUsuario = await _userRepository.GetUserNameByIdAsync(command.UsuarioId);

        var responseDto = new ComentarioResponseDto
        {
            Id = novoComentario.Id,
            Texto = novoComentario.Texto,
            DataCriacao = novoComentario.DataCriacao,
            UsuarioId = novoComentario.UsuarioId,
            UsuarioNome = nomeUsuario ?? "Usuário",
            ChamadoId = novoComentario.ChamadoId
        };

        _logger.LogInformation("Comentário adicionado com sucesso: ID {CommentId}", novoComentario.Id);

        return AddCommentResult.SuccessResult(responseDto);
    }
}
