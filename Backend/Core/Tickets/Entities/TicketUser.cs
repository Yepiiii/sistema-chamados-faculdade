using SistemaChamados.Core.Shared.ValueObjects;
using SistemaChamados.Core.Shared.Extensions;

namespace SistemaChamados.Core.Tickets.Entities;

/// <summary>
/// Ticket User entity - Bounded Context: Tickets
/// Represents a user in the context of ticket management (requester, technician).
/// This is a projection/cache of user data needed by the Tickets context.
/// </summary>
/// <remarks>
/// Part of DDD Bounded Context isolation (AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.2)
/// 
/// This entity is ONLY concerned with ticket-related user information:
/// - Display name for tickets
/// - Contact email for notifications
/// - User identification
/// 
/// This entity should NOT contain:
/// - ❌ Authentication data (PasswordHash, Roles)
/// - ❌ Authorization logic
/// - ❌ Detailed user profile (all personal data)
/// 
/// Benefits of separation:
/// - Tickets context doesn't depend on Auth context
/// - Can load tickets without JOIN to Auth tables
/// - Each context evolves independently
/// - Better performance (denormalized data)
/// 
/// Context Mapping:
/// - AuthUser (Auth Context) → TicketUser (Tickets Context)
/// - Mapping happens in Application Layer
/// </remarks>
public class TicketUser
{
    /// <summary>
    /// Unique identifier for the user (shared with Auth context).
    /// </summary>
    public UserId Id { get; private set; }

    /// <summary>
    /// Display name shown in tickets (e.g., "João Silva").
    /// This is a snapshot/cache from the Auth or User Profile context.
    /// </summary>
    public string NomeExibicao { get; private set; } = string.Empty;

    /// <summary>
    /// Contact email for notifications related to tickets.
    /// This may differ from the authentication email.
    /// </summary>
    public string EmailContato { get; private set; } = string.Empty;

    /// <summary>
    /// User type in the ticket context.
    /// Examples: "Solicitante", "Tecnico", "Admin"
    /// </summary>
    public string TipoUsuario { get; private set; } = string.Empty;

    /// <summary>
    /// Specialty or department (for technicians).
    /// Examples: "Rede", "Hardware", "Software"
    /// </summary>
    public string? Especialidade { get; private set; }

    /// <summary>
    /// Indicates whether the user is active for ticket operations.
    /// </summary>
    public bool IsAtivo { get; private set; }

    /// <summary>
    /// Private constructor for EF Core.
    /// </summary>
    private TicketUser() { }

    /// <summary>
    /// Factory method to create a new TicketUser.
    /// </summary>
    /// <param name="id">User identifier.</param>
    /// <param name="nomeExibicao">Display name for tickets.</param>
    /// <param name="emailContato">Contact email for notifications.</param>
    /// <param name="tipoUsuario">User type in ticket context.</param>
    /// <param name="especialidade">Specialty (optional, for technicians).</param>
    /// <returns>A new TicketUser instance.</returns>
    public static TicketUser Create(
        UserId id,
        string nomeExibicao,
        string emailContato,
        string tipoUsuario,
        string? especialidade = null)
    {
        var validNome = nomeExibicao.RequiredString(nameof(nomeExibicao));
        var validEmail = emailContato.RequiredString(nameof(emailContato));
        var validTipo = tipoUsuario.RequiredString(nameof(tipoUsuario));

        return new TicketUser
        {
            Id = id,
            NomeExibicao = validNome.Trim(),
            EmailContato = validEmail.Trim().ToLowerInvariant(),
            TipoUsuario = validTipo.Trim(),
            Especialidade = especialidade?.Trim(),
            IsAtivo = true
        };
    }

    /// <summary>
    /// Updates the display name.
    /// </summary>
    /// <param name="novoNome">New display name.</param>
    public void AtualizarNome(string novoNome)
    {
        var validNome = novoNome.RequiredString(nameof(novoNome));
        NomeExibicao = validNome.Trim();
    }

    /// <summary>
    /// Updates the contact email.
    /// </summary>
    /// <param name="novoEmail">New contact email.</param>
    public void AtualizarEmail(string novoEmail)
    {
        var validEmail = novoEmail.RequiredString(nameof(novoEmail));
        EmailContato = validEmail.Trim().ToLowerInvariant();
    }

    /// <summary>
    /// Updates the specialty (for technicians).
    /// </summary>
    /// <param name="especialidade">New specialty.</param>
    public void AtualizarEspecialidade(string? especialidade)
    {
        Especialidade = especialidade?.Trim();
    }

    /// <summary>
    /// Deactivates the user for ticket operations.
    /// </summary>
    public void Desativar()
    {
        IsAtivo = false;
    }

    /// <summary>
    /// Reactivates the user for ticket operations.
    /// </summary>
    public void Ativar()
    {
        IsAtivo = true;
    }
}
