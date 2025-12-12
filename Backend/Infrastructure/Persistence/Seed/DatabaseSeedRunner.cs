using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Seed;

/// <summary>
/// Database Seed Runner - Orchestrates all context seeders
/// </summary>
/// <remarks>
/// Pattern: Facade + Strategy
/// Reference: AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.3 (Seed Refactoring)
/// 
/// Responsibilities:
/// - Discover all registered IContextSeeder implementations
/// - Order seeders by Order property
/// - Execute seeders sequentially
/// - Log execution progress and errors
/// - Ensure database is created before seeding
/// 
/// Benefits:
/// - Single entry point for all seeding operations
/// - Automatic discovery of new seeders via DI
/// - Consistent logging and error handling
/// - Easy to add new seeders without changing orchestration code
/// </remarks>
public class DatabaseSeedRunner
{
    private readonly IEnumerable<IContextSeeder> _seeders;
    private readonly ILogger<DatabaseSeedRunner> _logger;

    public DatabaseSeedRunner(
        IEnumerable<IContextSeeder> seeders,
        ILogger<DatabaseSeedRunner> logger)
    {
        _seeders = seeders ?? throw new ArgumentNullException(nameof(seeders));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Runs all registered seeders in order.
    /// </summary>
    /// <param name="context">ApplicationDbContext for database operations.</param>
    /// <returns>Task representing the async operation.</returns>
    public async Task RunAllAsync(ApplicationDbContext context)
    {
        if (context == null)
        {
            throw new ArgumentNullException(nameof(context));
        }

        _logger.LogInformation("🌱 Starting database seeding process...");

        try
        {
            // Ensure database exists and is up to date
            _logger.LogInformation("Ensuring database exists...");
            await context.Database.EnsureCreatedAsync();
            
            // Apply pending migrations
            var pendingMigrations = await context.Database.GetPendingMigrationsAsync();
            if (pendingMigrations.Any())
            {
                _logger.LogWarning("⚠️ Found {Count} pending migrations. Applying...", 
                    pendingMigrations.Count());
                await context.Database.MigrateAsync();
                _logger.LogInformation("✅ Migrations applied successfully.");
            }

            // Get ordered seeders
            var orderedSeeders = _seeders.OrderBy(s => s.Order).ToList();

            if (!orderedSeeders.Any())
            {
                _logger.LogWarning("⚠️ No seeders registered. Skipping seeding process.");
                return;
            }

            _logger.LogInformation("Found {Count} seeders to execute.", orderedSeeders.Count);

            // Execute each seeder
            var totalSeeders = orderedSeeders.Count;
            var currentSeeder = 0;

            foreach (var seeder in orderedSeeders)
            {
                currentSeeder++;
                
                _logger.LogInformation(
                    "📦 [{Current}/{Total}] Running seeder: {SeederName} (Order: {Order})",
                    currentSeeder,
                    totalSeeders,
                    seeder.Name,
                    seeder.Order);

                var startTime = DateTime.UtcNow;

                try
                {
                    await seeder.SeedAsync(context);
                    
                    var duration = DateTime.UtcNow - startTime;
                    _logger.LogInformation(
                        "✅ [{Current}/{Total}] {SeederName} completed in {Duration}ms",
                        currentSeeder,
                        totalSeeders,
                        seeder.Name,
                        duration.TotalMilliseconds);
                }
                catch (Exception ex)
                {
                    _logger.LogError(
                        ex,
                        "❌ [{Current}/{Total}] {SeederName} failed: {ErrorMessage}",
                        currentSeeder,
                        totalSeeders,
                        seeder.Name,
                        ex.Message);

                    // Decide whether to continue or stop on error
                    // For now, we'll stop on first error
                    throw new InvalidOperationException(
                        $"Seeder '{seeder.Name}' failed. See inner exception for details.",
                        ex);
                }
            }

            _logger.LogInformation("🎉 Database seeding completed successfully!");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ Database seeding failed: {ErrorMessage}", ex.Message);
            throw;
        }
    }

    /// <summary>
    /// Runs a specific seeder by name (for debugging/testing).
    /// </summary>
    /// <param name="context">ApplicationDbContext for database operations.</param>
    /// <param name="seederName">Name of the seeder to run.</param>
    public async Task RunSeederAsync(ApplicationDbContext context, string seederName)
    {
        if (context == null)
        {
            throw new ArgumentNullException(nameof(context));
        }

        if (string.IsNullOrWhiteSpace(seederName))
        {
            throw new ArgumentException("Seeder name cannot be empty.", nameof(seederName));
        }

        var seeder = _seeders.FirstOrDefault(s => 
            s.Name.Equals(seederName, StringComparison.OrdinalIgnoreCase));

        if (seeder == null)
        {
            var availableSeeders = string.Join(", ", _seeders.Select(s => s.Name));
            throw new InvalidOperationException(
                $"Seeder '{seederName}' not found. Available seeders: {availableSeeders}");
        }

        _logger.LogInformation("🌱 Running specific seeder: {SeederName}", seeder.Name);

        try
        {
            await seeder.SeedAsync(context);
            _logger.LogInformation("✅ Seeder {SeederName} completed successfully.", seeder.Name);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "❌ Seeder {SeederName} failed: {ErrorMessage}", 
                seeder.Name, ex.Message);
            throw;
        }
    }
}
