using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Seeders;

/// <summary>
/// Seeder responsável APENAS por criar chamados de demonstração/exemplo.
/// Depende de MetadataSeeder e UserSeeder estarem já executados.
/// Útil para ambientes de desenvolvimento e demonstrações.
/// </summary>
public class DemoDataSeeder : IDataSeeder
{
    private readonly ApplicationDbContext _context;

    public DemoDataSeeder(ApplicationDbContext context)
    {
        _context = context;
    }

    public int Order => 3; // Executa por último (após Metadata e Users)

    public async Task SeedAsync()
    {
        // Verifica se já existem chamados
        if (await _context.Chamados.AnyAsync())
        {
            Console.WriteLine("⏭️  DemoDataSeeder: Chamados já existem, pulando seed.");
            return;
        }

        // Verificar dependências
        var usuarios = await _context.Usuarios.ToListAsync();
        var categorias = await _context.Categorias.ToListAsync();
        var prioridades = await _context.Prioridades.ToListAsync();
        var status = await _context.Status.ToListAsync();

        if (usuarios.Count < 2 || categorias.Count < 3 || prioridades.Count < 3 || status.Count < 2)
        {
            Console.WriteLine("⚠️  DemoDataSeeder: Dependências insuficientes. Pulando seed de chamados demo.");
            return;
        }

        await SeedChamadosDemoAsync(usuarios, categorias, prioridades, status);

        Console.WriteLine("✅ DemoDataSeeder: Chamados de demonstração criados com sucesso!");
    }

    private async Task SeedChamadosDemoAsync(
        List<Usuario> usuarios, 
        List<Categoria> categorias, 
        List<Prioridade> prioridades, 
        List<Status> status)
    {
        // Localizar usuários específicos
        var solicitante1 = usuarios.FirstOrDefault(u => u.Email.Contains("juliana")) ?? usuarios.First();
        var solicitante2 = usuarios.FirstOrDefault(u => u.Email.Contains("marcelo")) ?? usuarios.Skip(1).First();
        var tecnicoHardware = usuarios.FirstOrDefault(u => u.Especialidade == "Hardware");
        var tecnicoSoftware = usuarios.FirstOrDefault(u => u.Especialidade == "Software");

        // Localizar metadados
        var categoriaHardware = categorias.FirstOrDefault(c => c.Nome == "Hardware") ?? categorias.First();
        var categoriaSoftware = categorias.FirstOrDefault(c => c.Nome == "Software") ?? categorias.Skip(1).First();
        var categoriaRedes = categorias.FirstOrDefault(c => c.Nome == "Redes") ?? categorias.Skip(2).First();
        
        var prioridadeAlta = prioridades.FirstOrDefault(p => p.Nome == "Alta") ?? prioridades.First();
        var prioridadeMedia = prioridades.FirstOrDefault(p => p.Nome == "Média") ?? prioridades.First();
        var prioridadeBaixa = prioridades.FirstOrDefault(p => p.Nome == "Baixa") ?? prioridades.First();
        
        var statusAberto = status.FirstOrDefault(s => s.Nome == "Aberto") ?? status.First();
        var statusEmAndamento = status.FirstOrDefault(s => s.Nome == "Em Andamento") ?? status.First();

        var chamadosDemo = new[]
        {
            new Chamado
            {
                Titulo = "Computador não liga após queda de energia",
                Descricao = "Após a queda de energia ontem, meu computador não liga mais. A luz do estabilizador acende, mas o PC não dá sinal de vida.",
                SolicitanteId = solicitante1.Id,
                CategoriaId = categoriaHardware.Id,
                PrioridadeId = prioridadeAlta.Id,
                StatusId = statusEmAndamento.Id,
                TecnicoId = tecnicoHardware?.Id,
                DataAbertura = DateTime.UtcNow.AddDays(-2)
            },
            new Chamado
            {
                Titulo = "Erro ao abrir planilhas do Excel - arquivo corrompido",
                Descricao = "Não consigo mais abrir minhas planilhas do Excel. Aparece erro dizendo que o arquivo está corrompido ou foi modificado de forma incorreta.",
                SolicitanteId = solicitante2.Id,
                CategoriaId = categoriaSoftware.Id,
                PrioridadeId = prioridadeMedia.Id,
                StatusId = statusEmAndamento.Id,
                TecnicoId = tecnicoSoftware?.Id,
                DataAbertura = DateTime.UtcNow.AddDays(-1)
            },
            new Chamado
            {
                Titulo = "Internet lenta no setor financeiro",
                Descricao = "A conexão de internet do setor financeiro está extremamente lenta desde esta manhã. Sites demoram muito para carregar e o sistema ERP fica travando.",
                SolicitanteId = solicitante1.Id,
                CategoriaId = categoriaRedes.Id,
                PrioridadeId = prioridadeAlta.Id,
                StatusId = statusAberto.Id,
                DataAbertura = DateTime.UtcNow.AddHours(-4)
            },
            new Chamado
            {
                Titulo = "Impressora não reconhece papel na bandeja",
                Descricao = "A impressora do RH está dando erro de 'sem papel' mesmo com a bandeja cheia. Já tentei tirar e recolocar o papel.",
                SolicitanteId = solicitante2.Id,
                CategoriaId = categoriaHardware.Id,
                PrioridadeId = prioridadeBaixa.Id,
                StatusId = statusAberto.Id,
                DataAbertura = DateTime.UtcNow.AddHours(-1)
            }
        };

        await _context.Chamados.AddRangeAsync(chamadosDemo);
        await _context.SaveChangesAsync();

        Console.WriteLine($"   - {chamadosDemo.Length} chamados de demonstração criados");
    }
}
