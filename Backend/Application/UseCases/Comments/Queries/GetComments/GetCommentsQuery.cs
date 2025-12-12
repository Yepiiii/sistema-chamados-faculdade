using MediatR;
using SistemaChamados.Application.DTOs;

namespace SistemaChamados.Application.UseCases.Comments.Queries.GetComments;

/// <summary>
/// Query for retrieving all comments for a ticket.
/// </summary>
public record GetCommentsQuery(int ChamadoId) : IRequest<GetCommentsResult>;

/// <summary>
/// Result of GetComments query.
/// </summary>
public record GetCommentsResult
{
    public bool Success { get; init; }
    public IEnumerable<ComentarioResponseDto>? Comments { get; init; }
    public string? ErrorMessage { get; init; }

    public static GetCommentsResult SuccessResult(IEnumerable<ComentarioResponseDto> comments) =>
        new()
        {
            Success = true,
            Comments = comments
        };

    public static GetCommentsResult Failure(string errorMessage) =>
        new()
        {
            Success = false,
            ErrorMessage = errorMessage
        };
}
