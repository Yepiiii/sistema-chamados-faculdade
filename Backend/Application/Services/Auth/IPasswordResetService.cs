using SistemaChamados.Application.DTOs.Auth;

namespace SistemaChamados.Application.Services.Auth;

/// <summary>
/// Service responsible for password reset operations.
/// Follows SRP by focusing solely on password recovery logic.
/// </summary>
public interface IPasswordResetService
{
    /// <summary>
    /// Initiates password reset process by generating token and sending email.
    /// </summary>
    /// <param name="email">User email</param>
    /// <returns>PasswordResetResult indicating success or failure</returns>
    Task<PasswordResetResult> InitiatePasswordResetAsync(string email);

    /// <summary>
    /// Completes password reset by validating token and updating password.
    /// </summary>
    /// <param name="token">Reset token received by email</param>
    /// <param name="newPassword">New password (plain text)</param>
    /// <returns>PasswordResetResult indicating success or failure</returns>
    Task<PasswordResetResult> ResetPasswordAsync(string token, string newPassword);
}
