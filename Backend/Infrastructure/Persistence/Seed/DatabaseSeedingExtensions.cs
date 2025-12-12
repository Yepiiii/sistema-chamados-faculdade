using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Seed;

/// <summary>
/// Extension methods for database seeding.
/// </summary>
/// <remarks>
/// Reference: AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.3 (Seed Refactoring)
/// 
/// Usage in Program.cs:
/// <code>
/// var app = builder.Build();
/// await app.UseDatabaseSeedingAsync();
/// app.Run();
/// </code>
/// 
/// Configuration:
/// - Runs automatically on application startup
/// - Creates scope for DI resolution
/// - Logs all operations
/// - Fails fast on errors
/// </remarks>
public static class DatabaseSeedingExtensions
{
    /// <summary>
    /// Executes database seeding using all registered IContextSeeder implementations.
    /// </summary>
    /// <param name="host">The application host.</param>
    /// <param name="forceReseed">If true, will reseed even if data exists (dangerous!).</param>
    /// <returns>The same host for chaining.</returns>
    /// <exception cref="InvalidOperationException">Thrown when seeding fails.</exception>
    /// <remarks>
    /// This method:
    /// 1. Creates a DI scope
    /// 2. Resolves ApplicationDbContext and DatabaseSeedRunner
    /// 3. Executes all seeders in order
    /// 4. Disposes scope
    /// 
    /// Best Practices:
    /// - Call this AFTER app.Build() but BEFORE app.Run()
    /// - Only use forceReseed in development environment
    /// - Monitor logs for seeding progress
    /// - Handle exceptions appropriately
    /// </remarks>
    public static async Task<IHost> UseDatabaseSeedingAsync(
        this IHost host, 
        bool forceReseed = false)
    {
        if (host == null)
        {
            throw new ArgumentNullException(nameof(host));
        }

        using (var scope = host.Services.CreateScope())
        {
            var services = scope.ServiceProvider;
            var logger = services.GetRequiredService<ILogger<DatabaseSeedRunner>>();

            try
            {
                logger.LogInformation("🌱 Initializing database seeding...");

                var context = services.GetRequiredService<ApplicationDbContext>();
                var seedRunner = services.GetRequiredService<DatabaseSeedRunner>();

                // Optional: Check if database needs seeding
                if (!forceReseed)
                {
                    var hasData = await context.Usuarios.AnyAsync();
                    if (hasData)
                    {
                        logger.LogInformation(
                            "✅ Database already contains data. Skipping seeding. " +
                            "Use forceReseed=true to override.");
                        return host;
                    }
                }

                if (forceReseed)
                {
                    logger.LogWarning(
                        "⚠️ Force reseed is enabled. This may overwrite existing data!");
                }

                // Run all seeders
                await seedRunner.RunAllAsync(context);

                logger.LogInformation("✅ Database seeding initialization completed.");
            }
            catch (Exception ex)
            {
                logger.LogError(ex, 
                    "❌ An error occurred while seeding the database: {ErrorMessage}", 
                    ex.Message);

                // In production, you might want to continue even if seeding fails
                // For now, we'll rethrow to make errors visible during development
                throw new InvalidOperationException(
                    "Database seeding failed. See inner exception for details.", ex);
            }
        }

        return host;
    }

    /// <summary>
    /// Executes a specific seeder by name (for debugging).
    /// </summary>
    /// <param name="host">The application host.</param>
    /// <param name="seederName">Name of the seeder to run.</param>
    /// <returns>The same host for chaining.</returns>
    public static async Task<IHost> RunSeederAsync(this IHost host, string seederName)
    {
        if (host == null)
        {
            throw new ArgumentNullException(nameof(host));
        }

        if (string.IsNullOrWhiteSpace(seederName))
        {
            throw new ArgumentException("Seeder name cannot be empty.", nameof(seederName));
        }

        using (var scope = host.Services.CreateScope())
        {
            var services = scope.ServiceProvider;
            var context = services.GetRequiredService<ApplicationDbContext>();
            var seedRunner = services.GetRequiredService<DatabaseSeedRunner>();

            await seedRunner.RunSeederAsync(context, seederName);
        }

        return host;
    }

    /// <summary>
    /// Registers seeding infrastructure in DI container.
    /// </summary>
    /// <param name="services">Service collection.</param>
    /// <returns>Service collection for chaining.</returns>
    /// <remarks>
    /// Call this in Program.cs:
    /// <code>
    /// builder.Services.AddDatabaseSeeding();
    /// </code>
    /// 
    /// This automatically registers:
    /// - DatabaseSeedRunner (orchestrator)
    /// - AuthContextSeeder (Order 1)
    /// - TicketMetadataSeeder (Order 2)
    /// - TicketDemoDataSeeder (Order 3, Development only)
    /// </remarks>
    public static IServiceCollection AddDatabaseSeeding(this IServiceCollection services)
    {
        // Register the seed runner
        services.AddScoped<DatabaseSeedRunner>();

        // Register all context seeders in order
        services.AddScoped<IContextSeeder, Auth.AuthContextSeeder>();
        services.AddScoped<IContextSeeder, Tickets.TicketMetadataSeeder>();
        services.AddScoped<IContextSeeder, Tickets.TicketDemoDataSeeder>();

        return services;
    }
}
