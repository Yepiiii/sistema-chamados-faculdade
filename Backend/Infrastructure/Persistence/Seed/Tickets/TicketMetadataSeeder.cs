using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Seed.Tickets;

public class TicketMetadataSeeder : IContextSeeder
{
    private readonly ILogger<TicketMetadataSeeder> _logger;
    public int Order => 2;
    public string Name => "TicketMetadataSeeder";

    public TicketMetadataSeeder(ILogger<TicketMetadataSeeder> logger)
    {
        _logger = logger;
    }

    public async Task SeedAsync(ApplicationDbContext context)
    {
        _logger.LogInformation("Seeding ticket metadata...");
        
        // Seed Categories
        if (!await context.Categorias.AnyAsync())
        {
            var categorias = new[]
            {
                new Categoria 
                { 
                    Nome = "Hardware", 
                    Descricao = "Problemas com equipamentos físicos", 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                },
                new Categoria 
                { 
                    Nome = "Software", 
                    Descricao = "Problemas com sistemas e aplicativos", 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                },
                new Categoria 
                { 
                    Nome = "Redes", 
                    Descricao = "Problemas de conectividade e internet", 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                },
                new Categoria 
                { 
                    Nome = "Infraestrutura", 
                    Descricao = "Problemas com servidores e infraestrutura", 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                }
            };
            await context.Categorias.AddRangeAsync(categorias);
            await context.SaveChangesAsync();
            _logger.LogInformation("Created {Count} categories.", categorias.Length);
        }
        else
        {
            _logger.LogInformation("Categories already exist. Skipping.");
        }

        // Seed Priorities
        if (!await context.Prioridades.AnyAsync())
        {
            var prioridades = new[]
            {
                new Prioridade 
                { 
                    Nome = "Baixa", 
                    Nivel = 1, 
                    Descricao = "Não urgente", 
                    TempoRespostaHoras = 72, 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                },
                new Prioridade 
                { 
                    Nome = "Média", 
                    Nivel = 2, 
                    Descricao = "Atenção moderada", 
                    TempoRespostaHoras = 48, 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                },
                new Prioridade 
                { 
                    Nome = "Alta", 
                    Nivel = 3, 
                    Descricao = "Requer atenção urgente", 
                    TempoRespostaHoras = 24, 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                },
                new Prioridade 
                { 
                    Nome = "Crítica", 
                    Nivel = 4, 
                    Descricao = "Emergência imediata", 
                    TempoRespostaHoras = 4, 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                }
            };
            await context.Prioridades.AddRangeAsync(prioridades);
            await context.SaveChangesAsync();
            _logger.LogInformation("Created {Count} priorities.", prioridades.Length);
        }
        else
        {
            _logger.LogInformation("Priorities already exist. Skipping.");
        }

        // Seed Status
        if (!await context.Status.AnyAsync())
        {
            var status = new[]
            {
                new Status 
                { 
                    Nome = "Aberto", 
                    Descricao = "Chamado criado e aguardando atribuição", 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                },
                new Status 
                { 
                    Nome = "Em Andamento", 
                    Descricao = "Técnico trabalhando no chamado", 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                },
                new Status 
                { 
                    Nome = "Aguardando Cliente", 
                    Descricao = "Aguardando resposta do solicitante", 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                },
                new Status 
                { 
                    Nome = "Resolvido", 
                    Descricao = "Problema solucionado", 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                },
                new Status 
                { 
                    Nome = "Fechado", 
                    Descricao = "Chamado finalizado", 
                    Ativo = true, 
                    DataCadastro = DateTime.UtcNow 
                }
            };
            await context.Status.AddRangeAsync(status);
            await context.SaveChangesAsync();
            _logger.LogInformation("Created {Count} status.", status.Length);
        }
        else
        {
            _logger.LogInformation("Status already exist. Skipping.");
        }

        _logger.LogInformation("Ticket metadata seeding completed.");
    }
}
