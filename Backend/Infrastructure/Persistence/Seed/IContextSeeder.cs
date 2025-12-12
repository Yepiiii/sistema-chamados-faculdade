using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Seed;

/// <summary>
/// Context Seeder Interface - Modular Seeding Infrastructure
/// </summary>
/// <remarks>
/// Pattern: Strategy + Template Method
/// Reference: AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.3 (Seed Refactoring)
/// 
/// Purpose:
/// - Separate seed logic by Bounded Context
/// - Enable ordered execution (Auth → Tickets → Demo)
/// - Improve maintainability and testability
/// 
/// Implementation Guidelines:
/// - Each Bounded Context should have its own seeder
/// - Use Order property to control execution sequence
/// - Keep seeders idempotent (can run multiple times safely)
/// - Log seeding operations for debugging
/// 
/// Example Implementations:
/// - AuthContextSeeder: Order = 1 (users, roles)
/// - TicketMetadataSeeder: Order = 2 (status, categories, priorities)
/// - TicketDemoDataSeeder: Order = 3 (sample tickets)
/// </remarks>
public interface IContextSeeder
{
    /// <summary>
    /// Execution order for the seeder.
    /// Lower numbers run first (e.g., Auth = 1, Tickets = 2, Demo = 3).
    /// </summary>
    /// <remarks>
    /// Order Guidelines:
    /// - 1-10: Core infrastructure (Auth, System Config)
    /// - 11-20: Domain metadata (Ticket Status, Categories, Priorities)
    /// - 21-30: Reference data (Demo users, sample tickets)
    /// - 31+: Test data (Integration tests, load testing)
    /// </remarks>
    int Order { get; }

    /// <summary>
    /// Seeder name for logging purposes.
    /// </summary>
    string Name { get; }

    /// <summary>
    /// Seeds data into the database for this specific context.
    /// </summary>
    /// <param name="context">ApplicationDbContext for database access.</param>
    /// <returns>Task representing the async operation.</returns>
    /// <remarks>
    /// Implementation Requirements:
    /// - MUST be idempotent (check if data exists before inserting)
    /// - SHOULD use transactions for atomicity
    /// - SHOULD log operations for debugging
    /// - MUST NOT depend on other seeders directly
    /// - SHOULD use raw SQL or EF Core (avoid business logic layer)
    /// 
    /// Example:
    /// <code>
    /// public async Task SeedAsync(ApplicationDbContext context)
    /// {
    ///     if (!await context.Usuarios.AnyAsync())
    ///     {
    ///         // Seed users...
    ///     }
    /// }
    /// </code>
    /// </remarks>
    Task SeedAsync(ApplicationDbContext context);
}
