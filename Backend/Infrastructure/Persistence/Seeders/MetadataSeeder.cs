using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Interfaces.Auth;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Seeders;

/// <summary>
/// Seeder responsável APENAS por popular metadados do sistema (Categorias, Prioridades e Status).
/// Deve executar ANTES de UserSeeder e DemoDataSeeder.
/// </summary>
public class MetadataSeeder : IDataSeeder
{
    private readonly ApplicationDbContext _context;

    public MetadataSeeder(ApplicationDbContext context)
    {
        _context = context;
    }

    public int Order => 1; // Executa primeiro

    public async Task SeedAsync()
    {
        // Verifica se já existem dados
        if (await _context.Categorias.AnyAsync() || 
            await _context.Prioridades.AnyAsync() || 
            await _context.Status.AnyAsync())
        {
            Console.WriteLine("⏭️  MetadataSeeder: Dados já existem, pulando seed.");
            return;
        }

        await SeedCategoriasAsync();
        await SeedPrioridadesAsync();
        await SeedStatusAsync();

        Console.WriteLine("✅ MetadataSeeder: Categorias, Prioridades e Status criados com sucesso!");
    }

    private async Task SeedCategoriasAsync()
    {
        var categorias = new[]
        {
            new Categoria 
            { 
                Nome = "Hardware", 
                Descricao = "Problemas com equipamentos físicos (computadores, impressoras, periféricos)", 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Categoria 
            { 
                Nome = "Software", 
                Descricao = "Problemas com sistemas operacionais, aplicativos e licenças", 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Categoria 
            { 
                Nome = "Redes", 
                Descricao = "Problemas de conectividade, Wi-Fi, VPN e infraestrutura de rede", 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Categoria 
            { 
                Nome = "Infraestrutura", 
                Descricao = "Problemas com servidores, banco de dados e arquitetura de sistemas", 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            }
        };

        await _context.Categorias.AddRangeAsync(categorias);
        await _context.SaveChangesAsync();
    }

    private async Task SeedPrioridadesAsync()
    {
        var prioridades = new[]
        {
            new Prioridade 
            { 
                Nome = "Baixa", 
                Nivel = 1, 
                Descricao = "Problema não urgente, pode ser resolvido em até 3 dias", 
                TempoRespostaHoras = 72, 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Prioridade 
            { 
                Nome = "Média", 
                Nivel = 2, 
                Descricao = "Problema com impacto moderado, requer atenção em 2 dias", 
                TempoRespostaHoras = 48, 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Prioridade 
            { 
                Nome = "Alta", 
                Nivel = 3, 
                Descricao = "Problema urgente com impacto significativo, resposta em 24h", 
                TempoRespostaHoras = 24, 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Prioridade 
            { 
                Nome = "Crítica", 
                Nivel = 4, 
                Descricao = "Emergência que paralisa operações, resposta imediata em 4h", 
                TempoRespostaHoras = 4, 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            }
        };

        await _context.Prioridades.AddRangeAsync(prioridades);
        await _context.SaveChangesAsync();
    }

    private async Task SeedStatusAsync()
    {
        var status = new[]
        {
            new Status 
            { 
                Nome = "Aberto", 
                Descricao = "Chamado criado e aguardando atribuição a um técnico", 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Status 
            { 
                Nome = "Em Andamento", 
                Descricao = "Técnico está trabalhando ativamente na resolução", 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Status 
            { 
                Nome = "Aguardando Cliente", 
                Descricao = "Aguardando informações ou ação do solicitante", 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Status 
            { 
                Nome = "Resolvido", 
                Descricao = "Problema solucionado, aguardando confirmação do cliente", 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Status 
            { 
                Nome = "Fechado", 
                Descricao = "Chamado finalizado e arquivado", 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            }
        };

        await _context.Status.AddRangeAsync(status);
        await _context.SaveChangesAsync();
    }
}
