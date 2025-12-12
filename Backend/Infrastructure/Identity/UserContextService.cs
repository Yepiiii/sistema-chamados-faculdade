using System.Security.Claims;
using SistemaChamados.Core.Interfaces;

namespace SistemaChamados.Infrastructure.Identity;

/// <summary>
/// Implementation of IUserContextService using ASP.NET Core HttpContext.
/// This adapter isolates JWT Claims access from the domain and application layers.
/// Enables easy testing and migration to other authentication mechanisms (OAuth2, OIDC).
/// </summary>
public class UserContextService : IUserContextService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UserContextService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor ?? throw new ArgumentNullException(nameof(httpContextAccessor));
    }

    /// <summary>
    /// Gets the ID of the currently authenticated user from JWT Claims.
    /// </summary>
    /// <returns>User ID as a string, or null if no user is authenticated.</returns>
    public string? GetCurrentUserId()
    {
        return _httpContextAccessor.HttpContext?.User
            .FindFirst(ClaimTypes.NameIdentifier)?.Value;
    }

    /// <summary>
    /// Gets the ID of the currently authenticated user as an integer.
    /// </summary>
    /// <returns>User ID as an integer.</returns>
    /// <exception cref="InvalidOperationException">Thrown when user is not authenticated or ID is invalid.</exception>
    public int GetCurrentUserIdAsInt()
    {
        var userIdStr = GetCurrentUserId();
        
        if (string.IsNullOrEmpty(userIdStr))
        {
            throw new InvalidOperationException("Usuário não autenticado ou token inválido.");
        }

        if (!int.TryParse(userIdStr, out var userId))
        {
            throw new InvalidOperationException($"ID do usuário '{userIdStr}' não é um número válido.");
        }

        return userId;
    }

    /// <summary>
    /// Gets the email of the currently authenticated user from JWT Claims.
    /// </summary>
    /// <returns>User email, or null if not available.</returns>
    public string? GetCurrentUserEmail()
    {
        return _httpContextAccessor.HttpContext?.User
            .FindFirst(ClaimTypes.Email)?.Value;
    }

    /// <summary>
    /// Checks if a user is currently authenticated.
    /// </summary>
    /// <returns>True if user is authenticated, false otherwise.</returns>
    public bool IsAuthenticated()
    {
        return _httpContextAccessor.HttpContext?.User?.Identity?.IsAuthenticated ?? false;
    }
}
