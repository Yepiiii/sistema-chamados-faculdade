namespace SistemaChamados.Core.Shared.ValueObjects;

/// <summary>
/// Strongly-typed identifier for Ticket (Chamado) entities.
/// Prevents primitive obsession and provides type safety.
/// </summary>
/// <remarks>
/// Part of DDD implementation following AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.2
/// Benefits:
/// - Type safety: Cannot accidentally assign UserId to TicketId
/// - Self-documenting: Method signatures like CreateTicket(TicketId id) are clearer
/// - Validation: Ensures IDs are always valid
/// - Immutability: record struct provides value semantics
/// 
/// Example usage:
/// <code>
/// var ticketId = TicketId.New();
/// var ticket = await _repository.GetByIdAsync(ticketId);
/// </code>
/// </remarks>
public readonly record struct TicketId
{
    /// <summary>
    /// The underlying Guid value of the ticket identifier.
    /// </summary>
    public Guid Value { get; }

    /// <summary>
    /// Creates a new TicketId with the specified Guid value.
    /// </summary>
    /// <param name="value">The Guid value for this ticket identifier.</param>
    /// <exception cref="ArgumentException">Thrown when the Guid is empty.</exception>
    public TicketId(Guid value)
    {
        if (value == Guid.Empty)
        {
            throw new ArgumentException(
                "Ticket ID cannot be empty. Provide a valid Guid.", 
                nameof(value));
        }

        Value = value;
    }

    /// <summary>
    /// Creates a new TicketId from an integer value.
    /// Useful for migration from int-based IDs to Guid-based IDs.
    /// </summary>
    /// <param name="id">The integer ID to convert.</param>
    /// <returns>A TicketId with a deterministic Guid based on the integer.</returns>
    /// <remarks>
    /// This method creates a deterministic Guid from an int for backward compatibility.
    /// The Guid is created using a namespace approach to ensure consistency.
    /// Uses a different namespace than UserId to prevent collisions.
    /// </remarks>
    public static TicketId FromInt(int id)
    {
        if (id <= 0)
        {
            throw new ArgumentException("Ticket ID must be greater than zero.", nameof(id));
        }

        // Create a deterministic Guid from the int
        // Using offset to differentiate from UserId namespace
        var bytes = new byte[16];
        BitConverter.GetBytes(id).CopyTo(bytes, 0);
        bytes[15] = 0x01; // Namespace marker for TicketId
        return new TicketId(new Guid(bytes));
    }

    /// <summary>
    /// Creates a new unique TicketId.
    /// </summary>
    public static TicketId New() => new(Guid.NewGuid());

    /// <summary>
    /// Parses a string representation of a Guid into a TicketId.
    /// </summary>
    /// <param name="value">The string representation of the Guid.</param>
    /// <returns>A TicketId with the parsed Guid value.</returns>
    /// <exception cref="FormatException">Thrown when the string is not a valid Guid.</exception>
    public static TicketId Parse(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException("Ticket ID string cannot be null or empty.", nameof(value));
        }

        return new TicketId(Guid.Parse(value));
    }

    /// <summary>
    /// Tries to parse a string representation of a Guid into a TicketId.
    /// </summary>
    /// <param name="value">The string representation of the Guid.</param>
    /// <param name="ticketId">The parsed TicketId, or default if parsing fails.</param>
    /// <returns>True if parsing succeeded, false otherwise.</returns>
    public static bool TryParse(string? value, out TicketId ticketId)
    {
        if (string.IsNullOrWhiteSpace(value) || !Guid.TryParse(value, out var guid) || guid == Guid.Empty)
        {
            ticketId = default;
            return false;
        }

        ticketId = new TicketId(guid);
        return true;
    }

    /// <summary>
    /// Returns the string representation of the TicketId.
    /// </summary>
    /// <returns>The Guid value formatted as a string without braces or hyphens.</returns>
    public override string ToString() => Value.ToString("N"); // "N" format = 32 digits without hyphens

    /// <summary>
    /// Returns the string representation with hyphens.
    /// </summary>
    public string ToStringWithHyphens() => Value.ToString("D"); // "D" format = with hyphens

    /// <summary>
    /// Implicit conversion from TicketId to Guid.
    /// Allows seamless usage in APIs expecting Guid.
    /// </summary>
    public static implicit operator Guid(TicketId ticketId) => ticketId.Value;

    /// <summary>
    /// Explicit conversion from Guid to TicketId.
    /// Requires explicit cast to ensure developer intention.
    /// </summary>
    public static explicit operator TicketId(Guid guid) => new(guid);
}
