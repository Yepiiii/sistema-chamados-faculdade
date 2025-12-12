namespace SistemaChamados.Core.Interfaces;

/// <summary>
/// Service for accessing the current authenticated user context.
/// Abstracts authentication details (JWT Claims) from business logic.
/// This enables the domain layer to remain independent of ASP.NET Core infrastructure.
/// </summary>
public interface IUserContextService
{
    /// <summary>
    /// Gets the ID of the currently authenticated user.
    /// </summary>
    /// <returns>User ID as a string, or null if no user is authenticated.</returns>
    string? GetCurrentUserId();

    /// <summary>
    /// Gets the ID of the currently authenticated user as an integer.
    /// </summary>
    /// <returns>User ID as an integer.</returns>
    /// <exception cref="InvalidOperationException">Thrown when user is not authenticated or ID is invalid.</exception>
    int GetCurrentUserIdAsInt();

    /// <summary>
    /// Gets the email of the currently authenticated user.
    /// </summary>
    /// <returns>User email, or null if not available.</returns>
    string? GetCurrentUserEmail();

    /// <summary>
    /// Checks if a user is currently authenticated.
    /// </summary>
    /// <returns>True if user is authenticated, false otherwise.</returns>
    bool IsAuthenticated();
}
