using Microsoft.EntityFrameworkCore;
using SistemaChamados.Data;
using SistemaChamados.Infrastructure.Persistence.Seeders;

namespace SistemaChamados.Infrastructure.Persistence.Seed;

/// <summary>
/// Database seeder orchestrator.
/// Isolates database initialization logic from application entry point (Program.cs).
/// Uses scoped DbContext and executes all registered IDataSeeders in order.
/// Follows Single Responsibility Principle: delegates actual seeding to specialized seeders.
/// </summary>
public class DatabaseSeeder
{
    /// <summary>
    /// Ensures database is created, migrations applied, and initial data seeded.
    /// Should be called during application startup.
    /// </summary>
    /// <param name="serviceProvider">Service provider to resolve scoped DbContext and seeders</param>
    public static async Task EnsureDatabaseInitializedAsync(IServiceProvider serviceProvider)
    {
        // Create a scope to resolve DbContext - prevents connection leaks
        using var scope = serviceProvider.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<DatabaseSeeder>>();
        
        try
        {
            // 1. Apply pending migrations (creates DB if doesn't exist)
            await context.Database.MigrateAsync();
            
            // 2. Resolve all registered seeders
            var seeders = scope.ServiceProvider.GetServices<IDataSeeder>();
            
            if (!seeders.Any())
            {
                logger.LogWarning("Nenhum seeder registrado. Banco pode estar sem dados iniciais.");
                return;
            }
            
            // 3. Execute seeders in order (MetadataSeeder → UserSeeder → DemoDataSeeder)
            foreach (var seeder in seeders.OrderBy(s => s.Order))
            {
                var seederName = seeder.GetType().Name;
                logger.LogInformation("Executando {SeederName}...", seederName);
                await seeder.SeedAsync();
            }
            
            logger.LogInformation("✅ Database seeding concluído com sucesso!");
        }
        catch (Exception ex)
        {
            // Log error but don't crash application
            logger.LogError(ex, "❌ Erro ao inicializar banco de dados e seed");
            throw; // Re-throw to prevent app startup with bad DB state
        }
    }
}
