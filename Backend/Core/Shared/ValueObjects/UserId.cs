namespace SistemaChamados.Core.Shared.ValueObjects;

/// <summary>
/// Strongly-typed identifier for User entities.
/// Prevents primitive obsession and provides type safety.
/// </summary>
/// <remarks>
/// Part of DDD implementation following AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.2
/// Benefits:
/// - Type safety: Cannot accidentally assign TicketId to UserId
/// - Self-documenting: Method signatures are clearer
/// - Validation: Ensures IDs are always valid
/// - Immutability: record struct provides value semantics
/// </remarks>
public readonly record struct UserId
{
    /// <summary>
    /// The underlying Guid value of the user identifier.
    /// </summary>
    public Guid Value { get; }

    /// <summary>
    /// Creates a new UserId with the specified Guid value.
    /// </summary>
    /// <param name="value">The Guid value for this user identifier.</param>
    /// <exception cref="ArgumentException">Thrown when the Guid is empty.</exception>
    public UserId(Guid value)
    {
        if (value == Guid.Empty)
        {
            throw new ArgumentException(
                "User ID cannot be empty. Provide a valid Guid.", 
                nameof(value));
        }

        Value = value;
    }

    /// <summary>
    /// Creates a new UserId from an integer value.
    /// Useful for migration from int-based IDs to Guid-based IDs.
    /// </summary>
    /// <param name="id">The integer ID to convert.</param>
    /// <returns>A UserId with a deterministic Guid based on the integer.</returns>
    /// <remarks>
    /// This method creates a deterministic Guid from an int for backward compatibility.
    /// The Guid is created using a namespace approach to ensure consistency.
    /// </remarks>
    public static UserId FromInt(int id)
    {
        if (id <= 0)
        {
            throw new ArgumentException("User ID must be greater than zero.", nameof(id));
        }

        // Create a deterministic Guid from the int
        // Using a namespace UUID approach for consistency
        var bytes = new byte[16];
        BitConverter.GetBytes(id).CopyTo(bytes, 0);
        return new UserId(new Guid(bytes));
    }

    /// <summary>
    /// Creates a new unique UserId.
    /// </summary>
    public static UserId New() => new(Guid.NewGuid());

    /// <summary>
    /// Parses a string representation of a Guid into a UserId.
    /// </summary>
    /// <param name="value">The string representation of the Guid.</param>
    /// <returns>A UserId with the parsed Guid value.</returns>
    /// <exception cref="FormatException">Thrown when the string is not a valid Guid.</exception>
    public static UserId Parse(string value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException("User ID string cannot be null or empty.", nameof(value));
        }

        return new UserId(Guid.Parse(value));
    }

    /// <summary>
    /// Tries to parse a string representation of a Guid into a UserId.
    /// </summary>
    /// <param name="value">The string representation of the Guid.</param>
    /// <param name="userId">The parsed UserId, or default if parsing fails.</param>
    /// <returns>True if parsing succeeded, false otherwise.</returns>
    public static bool TryParse(string? value, out UserId userId)
    {
        if (string.IsNullOrWhiteSpace(value) || !Guid.TryParse(value, out var guid) || guid == Guid.Empty)
        {
            userId = default;
            return false;
        }

        userId = new UserId(guid);
        return true;
    }

    /// <summary>
    /// Returns the string representation of the UserId.
    /// </summary>
    /// <returns>The Guid value formatted as a string without braces or hyphens.</returns>
    public override string ToString() => Value.ToString("N"); // "N" format = 32 digits without hyphens

    /// <summary>
    /// Returns the string representation with hyphens.
    /// </summary>
    public string ToStringWithHyphens() => Value.ToString("D"); // "D" format = with hyphens

    /// <summary>
    /// Implicit conversion from UserId to Guid.
    /// Allows seamless usage in APIs expecting Guid.
    /// </summary>
    public static implicit operator Guid(UserId userId) => userId.Value;

    /// <summary>
    /// Explicit conversion from Guid to UserId.
    /// Requires explicit cast to ensure developer intention.
    /// </summary>
    public static explicit operator UserId(Guid guid) => new(guid);
}
