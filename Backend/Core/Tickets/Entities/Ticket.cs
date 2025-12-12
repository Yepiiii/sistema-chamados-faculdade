using SistemaChamados.Core.Shared.ValueObjects;
using SistemaChamados.Core.Shared.Extensions;

namespace SistemaChamados.Core.Tickets.Entities;

/// <summary>
/// Ticket entity - Bounded Context: Tickets (Refactored for Clean Architecture)
/// Represents a support ticket with full decoupling from Authentication context.
/// </summary>
/// <remarks>
/// Clean Architecture Principles Applied (AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.2):
/// 
/// ✅ Bounded Context Isolation:
///    - Uses UserId (Strongly Typed ID) instead of Usuario navigation property
///    - No JOIN to Authentication tables when loading tickets
///    - NomeSolicitanteSnapshot provides denormalized data for performance
/// 
/// ✅ Encapsulation:
///    - All setters are private
///    - State changes only via behavior methods
///    - Factory method ensures valid ticket creation
/// 
/// ✅ Domain Logic:
///    - Business rules enforced in methods
///    - Invariants protected
///    - No anemic model
/// 
/// Performance Benefits:
///    - No N+1 queries for user data
///    - Single table queries for ticket lists
///    - Denormalized snapshot for fast reads
/// </remarks>
public class Ticket
{
    /// <summary>
    /// Private constructor for EF Core.
    /// Application code must use Create() factory method.
    /// </summary>
    private Ticket() { }

    /// <summary>
    /// Ticket identifier (Strongly Typed ID).
    /// </summary>
    public TicketId Id { get; private set; }

    /// <summary>
    /// Ticket title (short description).
    /// </summary>
    public string Titulo { get; private set; } = string.Empty;

    /// <summary>
    /// Detailed problem description.
    /// </summary>
    public string Descricao { get; private set; } = string.Empty;

    /// <summary>
    /// Requester's user identifier (Strongly Typed ID).
    /// This references a user in the Auth context, but WITHOUT navigation property.
    /// </summary>
    public UserId SolicitanteId { get; private set; }

    /// <summary>
    /// Requester's name snapshot (denormalized for performance).
    /// This avoids JOINs to Auth tables when listing tickets.
    /// </summary>
    /// <remarks>
    /// This is intentional denormalization following CQRS read model principles.
    /// Updated via Application Layer when user profile changes.
    /// </remarks>
    public string NomeSolicitanteSnapshot { get; private set; } = string.Empty;

    /// <summary>
    /// Assigned technician's user identifier (optional).
    /// </summary>
    public UserId? TecnicoId { get; private set; }

    /// <summary>
    /// Assigned technician's name snapshot (denormalized).
    /// </summary>
    public string? NomeTecnicoSnapshot { get; private set; }

    /// <summary>
    /// Category identifier.
    /// </summary>
    public int CategoriaId { get; private set; }

    /// <summary>
    /// Priority identifier.
    /// </summary>
    public int PrioridadeId { get; private set; }

    /// <summary>
    /// Status identifier.
    /// </summary>
    public int StatusId { get; private set; }

    /// <summary>
    /// Ticket creation date (UTC).
    /// </summary>
    public DateTime DataAbertura { get; private set; }

    /// <summary>
    /// Ticket closing date (UTC, nullable).
    /// </summary>
    public DateTime? DataFechamento { get; private set; }

    /// <summary>
    /// Last update date (UTC, nullable).
    /// </summary>
    public DateTime? DataUltimaAtualizacao { get; private set; }

    /// <summary>
    /// SLA expiration date (UTC, nullable).
    /// </summary>
    public DateTime? SlaDataExpiracao { get; private set; }

    /// <summary>
    /// User who closed the ticket (optional).
    /// </summary>
    public UserId? FechadoPorId { get; private set; }

    /// <summary>
    /// Factory method to create a new ticket.
    /// </summary>
    /// <param name="titulo">Ticket title (required, max 200 chars).</param>
    /// <param name="descricao">Problem description (required, max 5000 chars).</param>
    /// <param name="solicitanteId">Requester's user ID.</param>
    /// <param name="nomeSolicitante">Requester's name snapshot.</param>
    /// <param name="categoriaId">Category ID.</param>
    /// <param name="prioridadeId">Priority ID.</param>
    /// <param name="statusAberto">Initial status ID (usually "Open").</param>
    /// <param name="slaDataExpiracao">SLA expiration date (optional).</param>
    /// <returns>Valid Ticket instance.</returns>
    /// <exception cref="ArgumentException">Thrown when data is invalid.</exception>
    public static Ticket Create(
        string titulo,
        string descricao,
        UserId solicitanteId,
        string nomeSolicitante,
        int categoriaId,
        int prioridadeId,
        int statusAberto,
        DateTime? slaDataExpiracao = null)
    {
        // Domain validations using Guard Clauses
        var validTitulo = titulo.RequiredWithMaxLength(200, nameof(titulo));
        var validDescricao = descricao.RequiredWithMaxLength(5000, nameof(descricao));
        var validNomeSolicitante = nomeSolicitante.RequiredString(nameof(nomeSolicitante));

        if (categoriaId <= 0)
            throw new ArgumentException("ID da categoria inválido.", nameof(categoriaId));

        if (prioridadeId <= 0)
            throw new ArgumentException("ID da prioridade inválido.", nameof(prioridadeId));

        if (statusAberto <= 0)
            throw new ArgumentException("ID do status inválido.", nameof(statusAberto));

        return new Ticket
        {
            Id = TicketId.New(),
            Titulo = validTitulo.Trim(),
            Descricao = validDescricao.Trim(),
            SolicitanteId = solicitanteId,
            NomeSolicitanteSnapshot = validNomeSolicitante.Trim(),
            CategoriaId = categoriaId,
            PrioridadeId = prioridadeId,
            StatusId = statusAberto,
            DataAbertura = DateTime.UtcNow,
            SlaDataExpiracao = slaDataExpiracao
        };
    }

    /// <summary>
    /// Assigns a technician to the ticket.
    /// </summary>
    /// <param name="tecnicoId">Technician's user ID.</param>
    /// <param name="nomeTecnico">Technician's name snapshot.</param>
    public void AtribuirTecnico(UserId? tecnicoId, string? nomeTecnico = null)
    {
        TecnicoId = tecnicoId;
        NomeTecnicoSnapshot = nomeTecnico?.Trim();
        DataUltimaAtualizacao = DateTime.UtcNow;
    }

    /// <summary>
    /// Updates the ticket status.
    /// </summary>
    /// <param name="novoStatusId">New status ID.</param>
    /// <param name="isFechado">Indicates if the ticket is being closed.</param>
    /// <param name="fechadoPorId">ID of the user closing the ticket.</param>
    public void AtualizarStatus(int novoStatusId, bool isFechado = false, UserId? fechadoPorId = null)
    {
        if (novoStatusId <= 0)
            throw new ArgumentException("ID do status inválido.", nameof(novoStatusId));

        StatusId = novoStatusId;
        DataUltimaAtualizacao = DateTime.UtcNow;

        if (isFechado)
        {
            DataFechamento = DateTime.UtcNow;
            FechadoPorId = fechadoPorId;
        }
        else
        {
            DataFechamento = null;
            FechadoPorId = null;
        }
    }

    /// <summary>
    /// Updates the category.
    /// </summary>
    /// <param name="novaCategoriaId">New category ID.</param>
    public void AtualizarCategoria(int novaCategoriaId)
    {
        if (novaCategoriaId <= 0)
            throw new ArgumentException("ID da categoria inválido.", nameof(novaCategoriaId));

        CategoriaId = novaCategoriaId;
        DataUltimaAtualizacao = DateTime.UtcNow;
    }

    /// <summary>
    /// Updates the priority.
    /// </summary>
    /// <param name="novaPrioridadeId">New priority ID.</param>
    public void AtualizarPrioridade(int novaPrioridadeId)
    {
        if (novaPrioridadeId <= 0)
            throw new ArgumentException("ID da prioridade inválido.", nameof(novaPrioridadeId));

        PrioridadeId = novaPrioridadeId;
        DataUltimaAtualizacao = DateTime.UtcNow;
    }

    /// <summary>
    /// Updates the requester name snapshot (called when user profile changes).
    /// </summary>
    /// <param name="novoNome">New requester name.</param>
    public void AtualizarNomeSolicitante(string novoNome)
    {
        var validNome = novoNome.RequiredString(nameof(novoNome));
        NomeSolicitanteSnapshot = validNome.Trim();
    }

    /// <summary>
    /// Updates the technician name snapshot (called when user profile changes).
    /// </summary>
    /// <param name="novoNome">New technician name.</param>
    public void AtualizarNomeTecnico(string? novoNome)
    {
        NomeTecnicoSnapshot = novoNome?.Trim();
    }

    /// <summary>
    /// Checks if the ticket is overdue based on SLA.
    /// </summary>
    /// <returns>True if overdue, false otherwise.</returns>
    public bool EstaVencido()
    {
        if (!SlaDataExpiracao.HasValue)
            return false;

        return DateTime.UtcNow > SlaDataExpiracao.Value && !DataFechamento.HasValue;
    }

    /// <summary>
    /// Calculates remaining time until SLA expiration.
    /// </summary>
    /// <returns>TimeSpan remaining, or null if no SLA or already closed.</returns>
    public TimeSpan? TempoRestanteSla()
    {
        if (!SlaDataExpiracao.HasValue || DataFechamento.HasValue)
            return null;

        var remaining = SlaDataExpiracao.Value - DateTime.UtcNow;
        return remaining.TotalSeconds > 0 ? remaining : TimeSpan.Zero;
    }
}
