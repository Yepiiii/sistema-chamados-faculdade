using SistemaChamados.Application.DTOs.Users;

namespace SistemaChamados.Application.Services.Users;

/// <summary>
/// Service responsible for user registration operations.
/// Follows SRP by focusing solely on user creation logic.
/// </summary>
public interface IUserRegistrationService
{
    /// <summary>
    /// Registers a new admin user.
    /// </summary>
    Task<UserRegistrationResult> RegisterAdminAsync(string nomeCompleto, string email, string senha);

    /// <summary>
    /// Registers a new regular user (comum).
    /// </summary>
    Task<UserRegistrationResult> RegisterUserAsync(string nomeCompleto, string email, string senha);

    /// <summary>
    /// Registers a new technician user with category specialty.
    /// </summary>
    Task<UserRegistrationResult> RegisterTechnicianAsync(
        string nomeCompleto, 
        string email, 
        string senha, 
        int especialidadeCategoriaId);
}
