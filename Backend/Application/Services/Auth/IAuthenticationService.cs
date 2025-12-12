using SistemaChamados.Application.DTOs.Auth;

namespace SistemaChamados.Application.Services.Auth;

/// <summary>
/// Service responsible for user authentication operations.
/// Follows SRP by focusing solely on authentication logic.
/// </summary>
public interface IAuthenticationService
{
    /// <summary>
    /// Authenticates a user with email and password.
    /// </summary>
    /// <param name="email">User email</param>
    /// <param name="password">User password (plain text)</param>
    /// <returns>AuthenticationResult with token if successful, or error message</returns>
    Task<AuthenticationResult> AuthenticateAsync(string email, string password);
}
