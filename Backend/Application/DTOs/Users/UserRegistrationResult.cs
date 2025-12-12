namespace SistemaChamados.Application.DTOs.Users;

/// <summary>
/// Result of user registration operation following the Result pattern.
/// Encapsulates success/failure without throwing exceptions.
/// </summary>
public record UserRegistrationResult
{
    public bool Success { get; init; }
    public int? UserId { get; init; }
    public string? NomeCompleto { get; init; }
    public string? Email { get; init; }
    public int? TipoUsuario { get; init; }
    public DateTime? DataCadastro { get; init; }
    public bool? Ativo { get; init; }
    public string? ErrorMessage { get; init; }

    public static UserRegistrationResult SuccessResult(
        int userId,
        string nomeCompleto,
        string email,
        int tipoUsuario,
        DateTime dataCadastro,
        bool ativo) =>
        new()
        {
            Success = true,
            UserId = userId,
            NomeCompleto = nomeCompleto,
            Email = email,
            TipoUsuario = tipoUsuario,
            DataCadastro = dataCadastro,
            Ativo = ativo
        };

    public static UserRegistrationResult Failure(string errorMessage) =>
        new()
        {
            Success = false,
            ErrorMessage = errorMessage
        };
}
