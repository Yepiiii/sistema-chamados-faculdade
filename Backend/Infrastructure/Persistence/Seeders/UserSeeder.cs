using Microsoft.EntityFrameworkCore;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Interfaces.Auth;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Seeders;

/// <summary>
/// Seeder responsável APENAS por popular usuários do sistema.
/// Usa IPasswordHasher para desacoplar da implementação específica de hashing (BCrypt, Argon2, etc.).
/// Executa APÓS MetadataSeeder (depende de Categorias para especialidades de técnicos).
/// </summary>
public class UserSeeder : IDataSeeder
{
    private readonly ApplicationDbContext _context;
    private readonly IPasswordHasher _passwordHasher;

    public UserSeeder(ApplicationDbContext context, IPasswordHasher passwordHasher)
    {
        _context = context;
        _passwordHasher = passwordHasher;
    }

    public int Order => 2; // Executa após MetadataSeeder

    public async Task SeedAsync()
    {
        // Verifica se já existem usuários
        if (await _context.Usuarios.AnyAsync())
        {
            Console.WriteLine("⏭️  UserSeeder: Usuários já existem, pulando seed.");
            return;
        }

        // Buscar categorias existentes para atribuir especialidades aos técnicos
        var categorias = await _context.Categorias.OrderBy(c => c.Id).ToListAsync();
        
        if (categorias.Count < 3)
        {
            throw new InvalidOperationException(
                "UserSeeder requer pelo menos 3 categorias cadastradas. Execute MetadataSeeder primeiro.");
        }

        await SeedAdminAsync();
        await SeedTecnicosAsync(categorias);
        await SeedUsuariosAsync();

        Console.WriteLine("✅ UserSeeder: 6 Usuários criados (1 Admin, 3 Técnicos, 2 Usuários Comuns)");
    }

    private async Task SeedAdminAsync()
    {
        var admin = new Usuario 
        { 
            NomeCompleto = "Carlos Mendes", 
            Email = "admin@neurohelp.com.br", 
            SenhaHash = _passwordHasher.HashPassword("Admin@123"),
            TipoUsuario = 3, // Administrador
            IsInterno = true, 
            Ativo = true, 
            DataCadastro = DateTime.UtcNow 
        };

        await _context.Usuarios.AddAsync(admin);
        await _context.SaveChangesAsync();
    }

    private async Task SeedTecnicosAsync(List<Categoria> categorias)
    {
        var tecnicos = new[]
        {
            new Usuario 
            { 
                NomeCompleto = "Rafael Costa", 
                Email = "rafael.costa@neurohelp.com.br", 
                SenhaHash = _passwordHasher.HashPassword("Tecnico@123"),
                TipoUsuario = 2, // Tecnico
                IsInterno = true, 
                Especialidade = "Hardware", 
                EspecialidadeCategoriaId = categorias[0].Id, 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Usuario 
            { 
                NomeCompleto = "Ana Paula Silva", 
                Email = "ana.silva@neurohelp.com.br", 
                SenhaHash = _passwordHasher.HashPassword("Tecnico@123"),
                TipoUsuario = 2, // Tecnico
                IsInterno = true, 
                Especialidade = "Software", 
                EspecialidadeCategoriaId = categorias[1].Id, 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Usuario 
            { 
                NomeCompleto = "Bruno Ferreira", 
                Email = "bruno.ferreira@neurohelp.com.br", 
                SenhaHash = _passwordHasher.HashPassword("Tecnico@123"),
                TipoUsuario = 2, // Tecnico
                IsInterno = true, 
                Especialidade = "Redes", 
                EspecialidadeCategoriaId = categorias[2].Id, 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            }
        };

        await _context.Usuarios.AddRangeAsync(tecnicos);
        await _context.SaveChangesAsync();
    }

    private async Task SeedUsuariosAsync()
    {
        var usuarios = new[]
        {
            new Usuario 
            { 
                NomeCompleto = "Juliana Martins", 
                Email = "juliana.martins@neurohelp.com.br", 
                SenhaHash = _passwordHasher.HashPassword("User@123"),
                TipoUsuario = 1, // Usuário comum
                IsInterno = false, 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            },
            new Usuario 
            { 
                NomeCompleto = "Marcelo Santos", 
                Email = "marcelo.santos@neurohelp.com.br", 
                SenhaHash = _passwordHasher.HashPassword("User@123"),
                TipoUsuario = 1, // Usuário comum
                IsInterno = false, 
                Ativo = true, 
                DataCadastro = DateTime.UtcNow 
            }
        };

        await _context.Usuarios.AddRangeAsync(usuarios);
        await _context.SaveChangesAsync();
    }
}
