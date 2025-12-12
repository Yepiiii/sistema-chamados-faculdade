using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Seed.Tickets;

/// <summary>
/// Ticket Demo Data Seeder - Seeds sample tickets for development/testing
/// </summary>
/// <remarks>
/// Bounded Context: Tickets (Demo Data)
/// Order: 3 (runs after Auth and TicketMetadata seeders)
/// 
/// Seeds:
/// - Sample tickets with different statuses, priorities, and categories
/// - Related entities (comments, attachments if applicable)
/// 
/// IMPORTANT: Only runs in Development environment!
/// 
/// Reference: AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.3 (Seed by Context)
/// </remarks>
public class TicketDemoDataSeeder : IContextSeeder
{
    private readonly ILogger<TicketDemoDataSeeder> _logger;
    private readonly IHostEnvironment _environment;

    public int Order => 3; // Runs after Auth (1) and TicketMetadata (2)

    public string Name => "TicketDemoDataSeeder";

    public TicketDemoDataSeeder(
        ILogger<TicketDemoDataSeeder> logger,
        IHostEnvironment environment)
    {
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _environment = environment ?? throw new ArgumentNullException(nameof(environment));
    }

    public async Task SeedAsync(ApplicationDbContext context)
    {
        // Only run in Development environment
        if (!_environment.IsDevelopment())
        {
            _logger.LogInformation("Skipping demo data seeding - not in Development environment.");
            return;
        }

        _logger.LogInformation("Seeding demo ticket data (Development only)...");

        // Check if tickets already exist (idempotency)
        if (await context.Chamados.AnyAsync())
        {
            _logger.LogInformation("Tickets already exist. Skipping demo data seeding.");
            return;
        }

        // Get existing data from database (seeded by previous seeders)
        var usuarios = await context.Usuarios.ToListAsync();
        var categorias = await context.Categorias.ToListAsync();
        var prioridades = await context.Prioridades.ToListAsync();
        var status = await context.Status.ToListAsync();

        if (!usuarios.Any() || !categorias.Any() || !prioridades.Any() || !status.Any())
        {
            _logger.LogWarning("Cannot seed demo tickets - missing required data (users, categories, priorities, or status).");
            return;
        }

        // Find specific entities
        var solicitantes = usuarios.Where(u => u.TipoUsuario == 1).ToList(); // Solicitantes
        var tecnicos = usuarios.Where(u => u.TipoUsuario == 2).ToList(); // Tecnicos
        
        var catHardware = categorias.FirstOrDefault(c => c.Nome == "Hardware");
        var catSoftware = categorias.FirstOrDefault(c => c.Nome == "Software");
        var catRedes = categorias.FirstOrDefault(c => c.Nome == "Redes");
        
        var prioAlta = prioridades.FirstOrDefault(p => p.Nome == "Alta");
        var prioMedia = prioridades.FirstOrDefault(p => p.Nome == "Média");
        var prioBaixa = prioridades.FirstOrDefault(p => p.Nome == "Baixa");
        
        var statusAberto = status.FirstOrDefault(s => s.Nome == "Aberto");
        var statusAndamento = status.FirstOrDefault(s => s.Nome == "Em Andamento");
        var statusResolvido = status.FirstOrDefault(s => s.Nome == "Resolvido");

        if (solicitantes.Count < 2 || tecnicos.Count < 2 || 
            catHardware == null || catSoftware == null || 
            prioAlta == null || prioMedia == null || 
            statusAberto == null || statusAndamento == null)
        {
            _logger.LogWarning("Missing required entities for creating demo tickets.");
            return;
        }

        _logger.LogInformation("Creating demo tickets...");

        var chamados = new List<Chamado>
        {
            // Ticket 1: Hardware - Alta prioridade - Em Andamento
            new Chamado
            {
                Titulo = "Computador não liga",
                Descricao = "O computador da estação de trabalho 15 não está ligando. Já foi verificado o cabo de energia e está conectado corretamente.",
                SolicitanteId = solicitantes[0].Id,
                TecnicoId = tecnicos.FirstOrDefault(t => t.Especialidade == "Hardware")?.Id,
                CategoriaId = catHardware.Id,
                PrioridadeId = prioAlta.Id,
                StatusId = statusAndamento.Id,
                DataAbertura = DateTime.UtcNow.AddDays(-2),
                DataUltimaAtualizacao = DateTime.UtcNow.AddHours(-3)
            },

            // Ticket 2: Software - Média prioridade - Aberto
            new Chamado
            {
                Titulo = "Erro ao acessar sistema de vendas",
                Descricao = "Ao tentar acessar o sistema de vendas, aparece uma mensagem de erro 'Servidor não disponível'.",
                SolicitanteId = solicitantes[1].Id,
                CategoriaId = catSoftware.Id,
                PrioridadeId = prioMedia.Id,
                StatusId = statusAberto.Id,
                DataAbertura = DateTime.UtcNow.AddHours(-5),
                DataUltimaAtualizacao = DateTime.UtcNow.AddHours(-5)
            },

            // Ticket 3: Redes - Alta prioridade - Aberto
            new Chamado
            {
                Titulo = "Internet lenta no setor financeiro",
                Descricao = "Toda a equipe do financeiro está com internet extremamente lenta, impossibilitando o trabalho com sistemas online.",
                SolicitanteId = solicitantes[0].Id,
                CategoriaId = catRedes?.Id ?? catHardware.Id,
                PrioridadeId = prioAlta.Id,
                StatusId = statusAberto.Id,
                DataAbertura = DateTime.UtcNow.AddHours(-1),
                DataUltimaAtualizacao = DateTime.UtcNow.AddHours(-1)
            },

            // Ticket 4: Hardware - Baixa prioridade - Resolvido
            new Chamado
            {
                Titulo = "Teclado com tecla defeituosa",
                Descricao = "A tecla 'A' do teclado está travando ocasionalmente.",
                SolicitanteId = solicitantes[1].Id,
                TecnicoId = tecnicos.FirstOrDefault(t => t.Especialidade == "Hardware")?.Id,
                CategoriaId = catHardware.Id,
                PrioridadeId = prioBaixa?.Id ?? prioMedia.Id,
                StatusId = statusResolvido?.Id ?? statusAndamento.Id,
                DataAbertura = DateTime.UtcNow.AddDays(-5),
                DataUltimaAtualizacao = DateTime.UtcNow.AddDays(-4),
                DataFechamento = DateTime.UtcNow.AddDays(-4)
            },

            // Ticket 5: Software - Média prioridade - Em Andamento
            new Chamado
            {
                Titulo = "Atualização do sistema contábil",
                Descricao = "Solicito a atualização do sistema contábil para a versão mais recente com as novas funcionalidades fiscais.",
                SolicitanteId = solicitantes[0].Id,
                TecnicoId = tecnicos.FirstOrDefault(t => t.Especialidade == "Software")?.Id,
                CategoriaId = catSoftware.Id,
                PrioridadeId = prioMedia.Id,
                StatusId = statusAndamento.Id,
                DataAbertura = DateTime.UtcNow.AddDays(-3),
                DataUltimaAtualizacao = DateTime.UtcNow.AddDays(-1)
            }
        };

        await context.Chamados.AddRangeAsync(chamados);
        await context.SaveChangesAsync();

        _logger.LogInformation("Created {Count} demo tickets successfully.", chamados.Count);
        _logger.LogInformation("Demo data seeding completed.");
    }
}
