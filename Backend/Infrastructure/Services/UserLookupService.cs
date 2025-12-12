using SistemaChamados.Core.Repositories;
using SistemaChamados.Core.Shared.ValueObjects;
using SistemaChamados.Core.Tickets.Entities;
using SistemaChamados.Core.Tickets.Interfaces;

namespace SistemaChamados.Infrastructure.Services;

/// <summary>
/// User Lookup Service Implementation - Context Mapping Bridge
/// </summary>
/// <remarks>
/// This service is part of the Infrastructure Layer and implements the Context Mapping
/// between Auth and Tickets Bounded Contexts.
/// 
/// Architecture Pattern: Anti-Corruption Layer (AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.2)
/// 
/// Responsibilities:
/// - Access Auth context data via IUserRepository
/// - Transform Auth entities to Tickets entities (Usuario → TicketUser)
/// - Provide user information to Tickets context without coupling
/// 
/// Implementation Notes:
/// - Uses IUserRepository for data access (following repository pattern)
/// - In a microservices architecture, this could call an Auth API
/// - Caches can be added here for performance (e.g., IMemoryCache)
/// 
/// Future Improvements:
/// - Add caching layer (Redis/MemoryCache)
/// - Implement batch loading for better performance
/// - Add metrics/logging for monitoring
/// </remarks>
public class UserLookupService : IUserLookupService
{
    private readonly IUserRepository _userRepository;

    public UserLookupService(IUserRepository userRepository)
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
    }

    /// <summary>
    /// Retrieves user information from Auth context and maps to TicketUser.
    /// </summary>
    public async Task<TicketUser> GetUserForTicketAsync(UserId userId)
    {
        // UserId is a struct, no need for null check
        // Validation happens inside UserId constructor

        // Convert UserId (Guid) to int for querying existing Usuario table
        // NOTE: This is a temporary solution during migration.
        // Once Usuario table uses Guid IDs, this conversion can be removed.
        int userIdInt;
        
        // Try to parse as legacy int ID
        if (int.TryParse(userId.Value.ToString("N").Substring(0, 8), System.Globalization.NumberStyles.HexNumber, null, out var parsedId))
        {
            userIdInt = parsedId;
        }
        else
        {
            // Fallback: try FromInt conversion
            // This assumes UserId was created via UserId.FromInt(intValue)
            // The Guid format stores the int in a specific way
            var guidBytes = userId.Value.ToByteArray();
            userIdInt = BitConverter.ToInt32(guidBytes, 0);
        }

        // Use repository instead of direct DbContext access
        var usuario = await _userRepository.GetUserByIdAsync(userIdInt);

        if (usuario == null)
        {
            throw new InvalidOperationException($"Usuário com ID {userId} não encontrado.");
        }

        // Map Usuario (Auth context) → TicketUser (Tickets context)
        return TicketUser.Create(
            id: UserId.FromInt(usuario.Id),
            nomeExibicao: usuario.NomeCompleto,
            emailContato: usuario.Email,
            tipoUsuario: MapTipoUsuario(usuario.TipoUsuario),
            especialidade: usuario.Especialidade
        );
    }

    /// <summary>
    /// Retrieves multiple users at once (batch operation).
    /// Optimizes performance when loading many tickets with different users.
    /// </summary>
    public async Task<Dictionary<UserId, TicketUser>> GetUsersForTicketsAsync(IEnumerable<UserId> userIds)
    {
        if (userIds == null || !userIds.Any())
        {
            return new Dictionary<UserId, TicketUser>();
        }

        // Convert UserIds to int for querying
        var userIdsInt = userIds
            .Select(uid => 
            {
                var guidBytes = uid.Value.ToByteArray();
                return BitConverter.ToInt32(guidBytes, 0);
            })
            .Distinct()
            .ToList();

        // Use repository batch operation
        var usuariosDict = await _userRepository.GetUsersByIdsAsync(userIdsInt);

        // Map to dictionary
        var result = new Dictionary<UserId, TicketUser>();
        
        foreach (var usuario in usuariosDict.Values)
        {
            var userId = UserId.FromInt(usuario.Id);
            var ticketUser = TicketUser.Create(
                id: userId,
                nomeExibicao: usuario.NomeCompleto,
                emailContato: usuario.Email,
                tipoUsuario: MapTipoUsuario(usuario.TipoUsuario),
                especialidade: usuario.Especialidade
            );
            
            result[userId] = ticketUser;
        }

        return result;
    }

    /// <summary>
    /// Checks if a user exists and is active.
    /// </summary>
    public async Task<bool> UserExistsAsync(UserId userId)
    {
        // UserId is a struct, always has a value

        try
        {
            // Convert UserId to int
            var guidBytes = userId.Value.ToByteArray();
            var userIdInt = BitConverter.ToInt32(guidBytes, 0);

            var usuario = await _userRepository.GetUserByIdAsync(userIdInt);
            return usuario != null && usuario.Ativo;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Maps integer TipoUsuario to string representation.
    /// </summary>
    private static string MapTipoUsuario(int tipoUsuario)
    {
        return tipoUsuario switch
        {
            1 => "Solicitante",
            2 => "Tecnico",
            3 => "Admin",
            _ => "Desconhecido"
        };
    }
}
