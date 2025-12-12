using SistemaChamados.Core.Shared.ValueObjects;
using SistemaChamados.Core.Shared.Extensions;
using System.Text.RegularExpressions;

namespace SistemaChamados.Core.Auth.Entities;

/// <summary>
/// Authentication User entity - Bounded Context: Authentication
/// Represents a user with credentials and roles for authentication purposes only.
/// </summary>
/// <remarks>
/// Part of DDD Bounded Context isolation (AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.2)
/// 
/// This entity is ONLY concerned with authentication:
/// - Login credentials (Email + PasswordHash)
/// - Authorization (Roles)
/// - Password management
/// 
/// This entity should NOT contain:
/// - ❌ Ticket-related properties (SolicitanteId, TecnicoId)
/// - ❌ User profile data (NomeCompleto, Telefone)
/// - ❌ Business logic from other contexts
/// 
/// Benefits of separation:
/// - Changes in Auth don't impact Tickets
/// - Clear separation of concerns
/// - Independent evolution of contexts
/// - Better testability and maintainability
/// </remarks>
public class AuthUser
{
    private readonly List<string> _roles = new();

    /// <summary>
    /// Unique identifier for the authenticated user.
    /// </summary>
    public UserId Id { get; private set; }

    /// <summary>
    /// User's email address (used for login).
    /// Must be a valid email format.
    /// </summary>
    public string Email { get; private set; } = string.Empty;

    /// <summary>
    /// Hashed password using a secure hashing algorithm (e.g., BCrypt).
    /// NEVER store plain text passwords.
    /// </summary>
    public string PasswordHash { get; private set; } = string.Empty;

    /// <summary>
    /// List of roles assigned to the user for authorization purposes.
    /// Examples: "Admin", "Tecnico", "Solicitante"
    /// </summary>
    public IReadOnlyCollection<string> Roles => _roles.AsReadOnly();

    /// <summary>
    /// Indicates whether the user account is active.
    /// Inactive users cannot authenticate.
    /// </summary>
    public bool IsActive { get; private set; }

    /// <summary>
    /// Timestamp of when the user was created.
    /// </summary>
    public DateTime CreatedAt { get; private set; }

    /// <summary>
    /// Timestamp of the last password change.
    /// Useful for password expiration policies.
    /// </summary>
    public DateTime? LastPasswordChangedAt { get; private set; }

    /// <summary>
    /// Timestamp of the last successful login.
    /// Useful for security auditing.
    /// </summary>
    public DateTime? LastLoginAt { get; private set; }

    /// <summary>
    /// Private constructor for EF Core.
    /// </summary>
    private AuthUser() { }

    /// <summary>
    /// Factory method to create a new authenticated user.
    /// </summary>
    /// <param name="email">User's email address (must be valid format).</param>
    /// <param name="passwordHash">Hashed password (never plain text).</param>
    /// <param name="roles">Initial roles to assign to the user.</param>
    /// <returns>A new AuthUser instance.</returns>
    /// <exception cref="ArgumentException">Thrown when email format is invalid or password hash is empty.</exception>
    public static AuthUser Create(string email, string passwordHash, params string[] roles)
    {
        ValidateEmail(email);
        ValidatePasswordHash(passwordHash);

        var user = new AuthUser
        {
            Id = UserId.New(),
            Email = email.Trim().ToLowerInvariant(), // Normalize email
            PasswordHash = passwordHash,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        // Add roles
        foreach (var role in roles)
        {
            user.AddRole(role);
        }

        return user;
    }

    /// <summary>
    /// Updates the user's password hash.
    /// </summary>
    /// <param name="newPasswordHash">The new hashed password.</param>
    /// <exception cref="ArgumentException">Thrown when the new password hash is invalid.</exception>
    /// <remarks>
    /// This method should only be called with a properly hashed password.
    /// Use IPasswordHasher to generate the hash before calling this method.
    /// 
    /// Example:
    /// <code>
    /// var newHash = _passwordHasher.HashPassword("NewPassword123!");
    /// authUser.UpdatePassword(newHash);
    /// </code>
    /// </remarks>
    public void UpdatePassword(string newPasswordHash)
    {
        ValidatePasswordHash(newPasswordHash);

        PasswordHash = newPasswordHash;
        LastPasswordChangedAt = DateTime.UtcNow;
    }

    /// <summary>
    /// Adds a role to the user if not already present.
    /// </summary>
    /// <param name="role">The role to add (e.g., "Admin", "Tecnico").</param>
    /// <exception cref="ArgumentException">Thrown when role is null or whitespace.</exception>
    public void AddRole(string role)
    {
        var validRole = role.RequiredString(nameof(role));
        var normalizedRole = validRole.Trim();

        if (!_roles.Contains(normalizedRole, StringComparer.OrdinalIgnoreCase))
        {
            _roles.Add(normalizedRole);
        }
    }

    /// <summary>
    /// Removes a role from the user.
    /// </summary>
    /// <param name="role">The role to remove.</param>
    public void RemoveRole(string role)
    {
        if (string.IsNullOrWhiteSpace(role))
        {
            return;
        }

        _roles.RemoveAll(r => r.Equals(role.Trim(), StringComparison.OrdinalIgnoreCase));
    }

    /// <summary>
    /// Checks if the user has a specific role.
    /// </summary>
    /// <param name="role">The role to check.</param>
    /// <returns>True if the user has the role, false otherwise.</returns>
    public bool HasRole(string role)
    {
        if (string.IsNullOrWhiteSpace(role))
        {
            return false;
        }

        return _roles.Any(r => r.Equals(role.Trim(), StringComparison.OrdinalIgnoreCase));
    }

    /// <summary>
    /// Deactivates the user account.
    /// Deactivated users cannot authenticate.
    /// </summary>
    public void Deactivate()
    {
        IsActive = false;
    }

    /// <summary>
    /// Reactivates a deactivated user account.
    /// </summary>
    public void Activate()
    {
        IsActive = true;
    }

    /// <summary>
    /// Records a successful login attempt.
    /// Updates the LastLoginAt timestamp.
    /// </summary>
    public void RecordLogin()
    {
        LastLoginAt = DateTime.UtcNow;
    }

    /// <summary>
    /// Validates email format using regex.
    /// </summary>
    private static void ValidateEmail(string email)
    {
        // Uses Guard Clause extension for validation
        email.ValidEmail(nameof(email));

        if (email.Length > 254) // RFC 5321
        {
            throw new ArgumentException("Email is too long (max 254 characters).", nameof(email));
        }
    }

    /// <summary>
    /// Validates that the password hash is not empty.
    /// </summary>
    private static void ValidatePasswordHash(string passwordHash)
    {
        passwordHash.RequiredString(nameof(passwordHash));

        // BCrypt hashes are typically 60 characters
        // Argon2 hashes can vary but are typically 80-100 characters
        if (passwordHash.Length < 20)
        {
            throw new ArgumentException(
                "Password hash appears to be too short. Ensure you're using a proper hashing algorithm (BCrypt, Argon2, etc.).",
                nameof(passwordHash));
        }
    }
}
