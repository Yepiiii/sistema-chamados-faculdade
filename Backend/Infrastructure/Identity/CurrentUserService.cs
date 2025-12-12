using System.Security.Claims;
using SistemaChamados.Core.Interfaces.Auth;

namespace SistemaChamados.Infrastructure.Identity;

/// <summary>
/// Implementation of ICurrentUserService using ASP.NET Core HttpContext.
/// This adapter isolates JWT Claims access from the domain and application layers.
/// Enables easy testing and migration to other authentication mechanisms (OAuth2, OIDC).
/// </summary>
/// <remarks>
/// Part of the architectural refactoring documented in AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.1
/// This service acts as an Anti-Corruption Layer between the Authentication Context and Ticketing Context.
/// 
/// Benefits:
/// - Business logic no longer depends on HttpContext or ClaimsPrincipal
/// - Easy to mock for unit tests
/// - Can be replaced with OAuth2/OIDC implementation without changing domain code
/// - Centralizes user context access logic
/// </remarks>
public class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor ?? throw new ArgumentNullException(nameof(httpContextAccessor));
    }

    /// <summary>
    /// Gets the ID of the currently authenticated user from JWT Claims.
    /// </summary>
    /// <returns>User ID as a string, or null if no user is authenticated.</returns>
    public string? UserId
    {
        get
        {
            return _httpContextAccessor.HttpContext?.User
                .FindFirst(ClaimTypes.NameIdentifier)?.Value;
        }
    }

    /// <summary>
    /// Gets the ID of the currently authenticated user as an integer.
    /// </summary>
    /// <returns>User ID as an integer.</returns>
    /// <exception cref="InvalidOperationException">Thrown when user is not authenticated or ID is invalid.</exception>
    public int GetUserIdAsInt()
    {
        var userIdStr = UserId;
        
        if (string.IsNullOrEmpty(userIdStr))
        {
            throw new InvalidOperationException(
                "Usuário não autenticado. Verifique se o token JWT é válido e contém o claim NameIdentifier.");
        }

        if (!int.TryParse(userIdStr, out var userId))
        {
            throw new InvalidOperationException(
                $"ID do usuário '{userIdStr}' não é um número inteiro válido. " +
                $"Esperado: int. Recebido: {userIdStr.GetType().Name}");
        }

        return userId;
    }

    /// <summary>
    /// Gets the email of the currently authenticated user from JWT Claims.
    /// </summary>
    /// <returns>User email, or null if not available.</returns>
    public string? Email
    {
        get
        {
            return _httpContextAccessor.HttpContext?.User
                .FindFirst(ClaimTypes.Email)?.Value;
        }
    }

    /// <summary>
    /// Checks if a user is currently authenticated.
    /// </summary>
    /// <returns>True if user is authenticated, false otherwise.</returns>
    public bool IsAuthenticated
    {
        get
        {
            return _httpContextAccessor.HttpContext?.User?.Identity?.IsAuthenticated ?? false;
        }
    }
}
