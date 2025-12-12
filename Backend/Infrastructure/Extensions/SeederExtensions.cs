using Microsoft.EntityFrameworkCore;
using SistemaChamados.Data;
using SistemaChamados.Infrastructure.Persistence.Seeders;

namespace SistemaChamados.Infrastructure.Extensions;

/// <summary>
/// Extension methods para orquestração de data seeders.
/// Centraliza a execução ordenada de todos os seeders do sistema.
/// </summary>
public static class SeederExtensions
{
    /// <summary>
    /// Orquestra a execução de todos os seeders do sistema de forma ordenada.
    /// Garante que o banco de dados existe e executa os seeders na sequência correta:
    /// 1. MetadataSeeder (categorias, prioridades, status)
    /// 2. UserSeeder (admin, técnicos, usuários)
    /// 3. DemoDataSeeder (chamados de exemplo - apenas em Development)
    /// </summary>
    /// <param name="app">A instância da aplicação web</param>
    /// <returns>A mesma instância da aplicação para method chaining</returns>
    /// <example>
    /// var app = builder.Build();
    /// app.UseMainSeeder();
    /// app.Run();
    /// </example>
    public static WebApplication UseMainSeeder(this WebApplication app)
    {
        // Executa seeding de forma assíncrona mas aguarda conclusão antes de continuar
        Task.Run(async () => await ExecuteSeedersAsync(app)).Wait();
        return app;
    }

    private static async Task ExecuteSeedersAsync(WebApplication app)
    {
        // Criar scope para resolver dependências scoped (DbContext, Seeders)
        using var scope = app.Services.CreateScope();
        var services = scope.ServiceProvider;
        var logger = services.GetRequiredService<ILogger<WebApplication>>();

        try
        {
            // 1. Obter DbContext e garantir que o banco existe
            var context = services.GetRequiredService<ApplicationDbContext>();
            
            logger.LogInformation("🔄 Iniciando inicialização do banco de dados...");
            
            // Aplica migrations pendentes (cria banco se não existir)
            await context.Database.MigrateAsync();
            
            logger.LogInformation("✅ Banco de dados inicializado com sucesso!");

            // 2. Resolver seeders individuais (não usa IDataSeeder para ter controle fino)
            var metadataSeeder = services.GetRequiredService<MetadataSeeder>();
            var userSeeder = services.GetRequiredService<UserSeeder>();
            var demoDataSeeder = services.GetRequiredService<DemoDataSeeder>();

            // 3. Executar seeders na ordem correta
            logger.LogInformation("🌱 Executando seeders de dados...");

            // 3.1 - MetadataSeeder (sempre executa)
            logger.LogInformation("  📊 Executando MetadataSeeder...");
            await metadataSeeder.SeedAsync();

            // 3.2 - UserSeeder (sempre executa)
            logger.LogInformation("  👥 Executando UserSeeder...");
            await userSeeder.SeedAsync();

            // 3.3 - DemoDataSeeder (apenas em Development)
            if (app.Environment.IsDevelopment())
            {
                logger.LogInformation("  🎭 Executando DemoDataSeeder (ambiente de desenvolvimento)...");
                await demoDataSeeder.SeedAsync();
            }
            else
            {
                logger.LogInformation("  ⏭️  DemoDataSeeder pulado (ambiente de produção)");
            }

            logger.LogInformation("✅ Todos os seeders executados com sucesso!");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "❌ Erro ao executar seeders de dados");
            
            // Em desenvolvimento, mostra exceção completa
            if (app.Environment.IsDevelopment())
            {
                throw;
            }
            
            // Em produção, apenas loga mas não impede a aplicação de subir
            logger.LogWarning("⚠️  Aplicação continuará sem dados iniciais");
        }
    }
}
