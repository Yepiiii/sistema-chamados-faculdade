using SistemaChamados.Infrastructure.Persistence.Seed;

namespace SistemaChamados.Infrastructure.Extensions;

/// <summary>
/// Extension methods for database initialization during application startup.
/// Keeps Program.cs clean and focused on pipeline configuration.
/// </summary>
public static class DatabaseExtensions
{
    /// <summary>
    /// Ensures database is created, migrations are applied, and initial seed data is populated.
    /// Call this method in Program.cs after app.Build() but before app.Run().
    /// </summary>
    /// <param name="app">The web application instance</param>
    /// <returns>The same application instance for method chaining</returns>
    /// <example>
    /// var app = builder.Build();
    /// await app.EnsureDatabaseSeedingAsync();
    /// app.Run();
    /// </example>
    public static async Task<WebApplication> EnsureDatabaseSeedingAsync(this WebApplication app)
    {
        await DatabaseSeeder.EnsureDatabaseInitializedAsync(app.Services);
        return app;
    }
}
