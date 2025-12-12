namespace SistemaChamados.Application.DTOs.Auth;

/// <summary>
/// Result of password reset operation following the Result pattern.
/// Encapsulates success/failure without throwing exceptions.
/// </summary>
public record PasswordResetResult
{
    public bool Success { get; init; }
    public string? Message { get; init; }
    public string? ErrorMessage { get; init; }

    public static PasswordResetResult SuccessResult(string message) =>
        new()
        {
            Success = true,
            Message = message
        };

    public static PasswordResetResult Failure(string errorMessage) =>
        new()
        {
            Success = false,
            ErrorMessage = errorMessage
        };
}
