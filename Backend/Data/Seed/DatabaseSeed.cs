using SistemaChamados.Core.Entities;
using SistemaChamados.Data;

namespace SistemaChamados.Data.Seed;

public static class DatabaseSeed
{
    public static void Seed(ApplicationDbContext context)
    {
        // ✅ MODIFICAÇÃO TEMPORÁRIA: Separar seed de Categorias/Prioridades/Status de Usuários
        
        // Seed de entidades base (só executa se não existirem)
        if (!context.Categorias.Any())
        {
            SeedBaseEntities(context);
        }
        
        // Seed de usuários (executa se não existirem usuários)
        if (!context.Usuarios.Any())
        {
            SeedUsuarios(context);
        }
    }

    private static void SeedBaseEntities(ApplicationDbContext context)
    {
        var categorias = new[]
        {
            new Categoria { Nome = "Hardware", Descricao = "Problemas com equipamentos físicos", Ativo = true, DataCadastro = DateTime.UtcNow },
            new Categoria { Nome = "Software", Descricao = "Problemas com sistemas e aplicativos", Ativo = true, DataCadastro = DateTime.UtcNow },
            new Categoria { Nome = "Redes", Descricao = "Problemas de conectividade e internet", Ativo = true, DataCadastro = DateTime.UtcNow },
            new Categoria { Nome = "Infraestrutura", Descricao = "Problemas com servidores e infraestrutura", Ativo = true, DataCadastro = DateTime.UtcNow }
        };
        context.Categorias.AddRange(categorias);
        context.SaveChanges();

        var prioridades = new[]
        {
            new Prioridade { Nome = "Baixa", Nivel = 1, Descricao = "Não urgente", TempoRespostaHoras = 72, Ativo = true, DataCadastro = DateTime.UtcNow },
            new Prioridade { Nome = "Média", Nivel = 2, Descricao = "Atenção moderada", TempoRespostaHoras = 48, Ativo = true, DataCadastro = DateTime.UtcNow },
            new Prioridade { Nome = "Alta", Nivel = 3, Descricao = "Requer atenção urgente", TempoRespostaHoras = 24, Ativo = true, DataCadastro = DateTime.UtcNow },
            new Prioridade { Nome = "Crítica", Nivel = 4, Descricao = "Emergência imediata", TempoRespostaHoras = 4, Ativo = true, DataCadastro = DateTime.UtcNow }
        };
        context.Prioridades.AddRange(prioridades);
        context.SaveChanges();

        var status = new[]
        {
            new Status { Nome = "Aberto", Descricao = "Chamado criado e aguardando atribuição", Ativo = true, DataCadastro = DateTime.UtcNow },
            new Status { Nome = "Em Andamento", Descricao = "Técnico trabalhando no chamado", Ativo = true, DataCadastro = DateTime.UtcNow },
            new Status { Nome = "Aguardando Cliente", Descricao = "Aguardando resposta do solicitante", Ativo = true, DataCadastro = DateTime.UtcNow },
            new Status { Nome = "Resolvido", Descricao = "Problema solucionado", Ativo = true, DataCadastro = DateTime.UtcNow },
            new Status { Nome = "Fechado", Descricao = "Chamado finalizado", Ativo = true, DataCadastro = DateTime.UtcNow }
        };
        context.Status.AddRange(status);
        context.SaveChanges();
    }

    private static void SeedUsuarios(ApplicationDbContext context)
    {
        // Buscar categorias existentes para atribuir especialidades aos técnicos
        var categorias = context.Categorias.OrderBy(c => c.Id).ToList();
        
        if (categorias.Count < 3)
        {
            throw new InvalidOperationException("É necessário ter pelo menos 3 categorias cadastradas antes de criar usuários.");
        }

        // Admin - NeuroHelp
        var admin = new Usuario 
        { 
            NomeCompleto = "Carlos Mendes", 
            Email = "admin@neurohelp.com.br", 
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("Admin@123"),
            TipoUsuario = 3, // Administrador
            IsInterno = true, 
            Ativo = true, 
            DataCadastro = DateTime.UtcNow 
        };
        context.Usuarios.Add(admin);

        // Técnico Hardware
        var tecnicoHardware = new Usuario 
        { 
            NomeCompleto = "Rafael Costa", 
            Email = "rafael.costa@neurohelp.com.br", 
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("Tecnico@123"),
            TipoUsuario = 2, // Tecnico
            IsInterno = true, 
            Especialidade = "Hardware", 
            EspecialidadeCategoriaId = categorias[0].Id, 
            Ativo = true, 
            DataCadastro = DateTime.UtcNow 
        };
        context.Usuarios.Add(tecnicoHardware);

        // Técnico Software
        var tecnicoSoftware = new Usuario 
        { 
            NomeCompleto = "Ana Paula Silva", 
            Email = "ana.silva@neurohelp.com.br", 
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("Tecnico@123"),
            TipoUsuario = 2, // Tecnico
            IsInterno = true, 
            Especialidade = "Software", 
            EspecialidadeCategoriaId = categorias[1].Id, 
            Ativo = true, 
            DataCadastro = DateTime.UtcNow 
        };
        context.Usuarios.Add(tecnicoSoftware);

        // Técnico Redes
        var tecnicoRedes = new Usuario 
        { 
            NomeCompleto = "Bruno Ferreira", 
            Email = "bruno.ferreira@neurohelp.com.br", 
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("Tecnico@123"),
            TipoUsuario = 2, // Tecnico
            IsInterno = true, 
            Especialidade = "Redes", 
            EspecialidadeCategoriaId = categorias[2].Id, 
            Ativo = true, 
            DataCadastro = DateTime.UtcNow 
        };
        context.Usuarios.Add(tecnicoRedes);

        // Usuário comum - Financeiro
        var usuarioFinanceiro = new Usuario 
        { 
            NomeCompleto = "Juliana Martins", 
            Email = "juliana.martins@neurohelp.com.br", 
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("User@123"),
            TipoUsuario = 1, // Usuário comum
            IsInterno = false, 
            Ativo = true, 
            DataCadastro = DateTime.UtcNow 
        };
        context.Usuarios.Add(usuarioFinanceiro);

        // Usuário comum - RH
        var usuarioRH = new Usuario 
        { 
            NomeCompleto = "Marcelo Santos", 
            Email = "marcelo.santos@neurohelp.com.br", 
            SenhaHash = BCrypt.Net.BCrypt.HashPassword("User@123"),
            TipoUsuario = 1, // Usuário comum
            IsInterno = false, 
            Ativo = true, 
            DataCadastro = DateTime.UtcNow 
        };
        context.Usuarios.Add(usuarioRH);

        context.SaveChanges();
        
        Console.WriteLine("✅ Seed de Usuários NeuroHelp concluído!");
        Console.WriteLine("   - 6 Usuários criados (1 Admin, 3 Técnicos, 2 Usuários)");
    }
}
