namespace SistemaChamados.Application.DTOs.Auth;

/// <summary>
/// Result of authentication operation following the Result pattern.
/// Encapsulates success/failure without throwing exceptions.
/// </summary>
public record AuthenticationResult
{
    public bool Success { get; init; }
    public string? Token { get; init; }
    public int? TipoUsuario { get; init; }
    public string? ErrorMessage { get; init; }

    public static AuthenticationResult SuccessResult(string token, int tipoUsuario) =>
        new()
        {
            Success = true,
            Token = token,
            TipoUsuario = tipoUsuario
        };

    public static AuthenticationResult Failure(string errorMessage) =>
        new()
        {
            Success = false,
            ErrorMessage = errorMessage
        };
}
