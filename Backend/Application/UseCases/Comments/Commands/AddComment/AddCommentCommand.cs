using MediatR;
using SistemaChamados.Application.DTOs;

namespace SistemaChamados.Application.UseCases.Comments.Commands.AddComment;

/// <summary>
/// Command for adding a comment to a ticket.
/// </summary>
public record AddCommentCommand(
    int ChamadoId,
    int UsuarioId,
    string Texto) : IRequest<AddCommentResult>;

/// <summary>
/// Result of AddComment operation.
/// </summary>
public record AddCommentResult
{
    public bool Success { get; init; }
    public ComentarioResponseDto? Comment { get; init; }
    public string? ErrorMessage { get; init; }

    public static AddCommentResult SuccessResult(ComentarioResponseDto comment) =>
        new()
        {
            Success = true,
            Comment = comment
        };

    public static AddCommentResult Failure(string errorMessage) =>
        new()
        {
            Success = false,
            ErrorMessage = errorMessage
        };
}
