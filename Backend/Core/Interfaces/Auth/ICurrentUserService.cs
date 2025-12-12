namespace SistemaChamados.Core.Interfaces.Auth;

/// <summary>
/// Anti-Corruption Layer for User Authentication Context.
/// Abstracts JWT Claims and authentication details from business logic.
/// Enables easy testing and migration to OAuth2/OIDC without impacting domain code.
/// </summary>
/// <remarks>
/// Part of the architectural refactoring documented in AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.1
/// This interface decouples the Ticketing Bounded Context from the Authentication mechanism.
/// </remarks>
public interface ICurrentUserService
{
    /// <summary>
    /// Gets the ID of the currently authenticated user.
    /// </summary>
    /// <returns>User ID as a string, or null if no user is authenticated.</returns>
    /// <remarks>
    /// Returns string to maintain compatibility with various ID formats (GUID, int, etc.).
    /// Use GetUserIdAsInt() if you need a strongly-typed integer ID.
    /// </remarks>
    string? UserId { get; }

    /// <summary>
    /// Gets the ID of the currently authenticated user as an integer.
    /// </summary>
    /// <returns>User ID as an integer.</returns>
    /// <exception cref="InvalidOperationException">Thrown when user is not authenticated or ID is invalid.</exception>
    /// <remarks>
    /// Use this property when you know the ID is an integer (e.g., in the database).
    /// Throws an exception instead of returning null to enforce null-safety in business logic.
    /// </remarks>
    int GetUserIdAsInt();

    /// <summary>
    /// Gets the email of the currently authenticated user.
    /// </summary>
    /// <returns>User email, or null if not available in the authentication context.</returns>
    string? Email { get; }

    /// <summary>
    /// Checks if a user is currently authenticated.
    /// </summary>
    /// <returns>True if user is authenticated, false otherwise.</returns>
    /// <remarks>
    /// Use this to validate authentication before accessing UserId or Email properties.
    /// Example: if (!_currentUserService.IsAuthenticated) throw new UnauthorizedException();
    /// </remarks>
    bool IsAuthenticated { get; }
}
