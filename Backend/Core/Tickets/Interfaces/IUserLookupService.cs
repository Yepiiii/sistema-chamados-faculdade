using SistemaChamados.Core.Shared.ValueObjects;
using SistemaChamados.Core.Tickets.Entities;

namespace SistemaChamados.Core.Tickets.Interfaces;

/// <summary>
/// User Lookup Service - Context Mapping Interface (Anti-Corruption Layer)
/// </summary>
/// <remarks>
/// This interface serves as a bridge between Bounded Contexts:
/// - Tickets Context → Requests user data
/// - Auth Context → Provides user data (via Infrastructure implementation)
/// 
/// Architecture Pattern: Context Mapping (AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.2)
/// 
/// Purpose:
/// - Decouples Tickets context from Auth context
/// - Allows Tickets to get user information without direct dependency on AuthUser
/// - Infrastructure layer implements the translation/mapping
/// 
/// Benefits:
/// - ✅ Bounded Context isolation maintained
/// - ✅ Tickets doesn't know about Auth implementation details
/// - ✅ Easy to test (mock the service)
/// - ✅ Can change Auth implementation without affecting Tickets
/// 
/// Usage Example:
/// <code>
/// // In a Use Case or Service within Tickets Context:
/// var ticketUser = await _userLookupService.GetUserForTicketAsync(userId);
/// var ticket = Ticket.Create(
///     titulo: "Issue",
///     descricao: "Description",
///     solicitanteId: ticketUser.Id,
///     nomeSolicitante: ticketUser.NomeExibicao,
///     ...
/// );
/// </code>
/// </remarks>
public interface IUserLookupService
{
    /// <summary>
    /// Retrieves user information from Auth context and maps to TicketUser.
    /// </summary>
    /// <param name="userId">User identifier (Strongly Typed ID).</param>
    /// <returns>TicketUser with information needed for ticket operations.</returns>
    /// <exception cref="InvalidOperationException">Thrown when user is not found.</exception>
    Task<TicketUser> GetUserForTicketAsync(UserId userId);

    /// <summary>
    /// Retrieves multiple users at once (batch operation).
    /// Optimizes performance when loading many tickets with different users.
    /// </summary>
    /// <param name="userIds">Collection of user identifiers.</param>
    /// <returns>Dictionary mapping UserId to TicketUser.</returns>
    Task<Dictionary<UserId, TicketUser>> GetUsersForTicketsAsync(IEnumerable<UserId> userIds);

    /// <summary>
    /// Checks if a user exists and is active.
    /// </summary>
    /// <param name="userId">User identifier.</param>
    /// <returns>True if user exists and is active, false otherwise.</returns>
    Task<bool> UserExistsAsync(UserId userId);
}
