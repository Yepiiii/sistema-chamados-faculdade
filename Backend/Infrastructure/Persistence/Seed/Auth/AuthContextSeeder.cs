using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Interfaces.Auth;
using SistemaChamados.Data;

namespace SistemaChamados.Infrastructure.Persistence.Seed.Auth;

/// <summary>
/// Auth Context Seeder - Seeds authentication-related data
/// </summary>
/// <remarks>
/// Bounded Context: Authentication
/// Order: 1 (runs first, as other contexts may depend on users)
/// 
/// Seeds:
/// - Admin user
/// - Technician users
/// - Regular users
/// 
/// Reference: AUDITORIA_ARQUITETURAL_NEUROHELP.md - Phase 4.3 (Seed by Context)
/// </remarks>
public class AuthContextSeeder : IContextSeeder
{
    private readonly IPasswordHasher _passwordHasher;
    private readonly ILogger<AuthContextSeeder> _logger;

    public int Order => 1; // Auth must run first

    public string Name => "AuthContextSeeder";

    public AuthContextSeeder(
        IPasswordHasher passwordHasher,
        ILogger<AuthContextSeeder> logger)
    {
        _passwordHasher = passwordHasher ?? throw new ArgumentNullException(nameof(passwordHasher));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task SeedAsync(ApplicationDbContext context)
    {
        _logger.LogInformation("Seeding authentication data...");

        // Check if users already exist (idempotency)
        if (await context.Usuarios.AnyAsync())
        {
            _logger.LogInformation("Users already exist. Skipping authentication seeding.");
            return;
        }

        _logger.LogInformation("Creating default users...");

        // First, get categories for technician specialization (will be seeded by TicketMetadataSeeder)
        // Note: TicketMetadataSeeder runs with Order=2, after this seeder
        // So we create users first, then update specializations later if needed
        // For now, we'll set Especialidade as string only

        var usuarios = new List<Usuario>
        {
            // Admin User
            new Usuario
            {
                NomeCompleto = "Carlos Mendes",
                Email = "admin@neurohelp.com.br",
                SenhaHash = _passwordHasher.HashPassword("Admin@123"),
                TipoUsuario = 3, // Admin
                IsInterno = true,
                Ativo = true,
                DataCadastro = DateTime.UtcNow
            },

            // Technician Users
            new Usuario
            {
                NomeCompleto = "Rafael Costa",
                Email = "rafael.costa@neurohelp.com.br",
                SenhaHash = _passwordHasher.HashPassword("Tecnico@123"),
                TipoUsuario = 2, // Tecnico
                IsInterno = true,
                Especialidade = "Hardware",
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
                Ativo = true,
                DataCadastro = DateTime.UtcNow
            },

            // Regular Users (Requesters)
            new Usuario
            {
                NomeCompleto = "Juliana Martins",
                Email = "juliana.martins@neurohelp.com.br",
                SenhaHash = _passwordHasher.HashPassword("User@123"),
                TipoUsuario = 1, // Solicitante
                IsInterno = false,
                Ativo = true,
                DataCadastro = DateTime.UtcNow
            },
            new Usuario
            {
                NomeCompleto = "Marcelo Santos",
                Email = "marcelo.santos@neurohelp.com.br",
                SenhaHash = _passwordHasher.HashPassword("User@123"),
                TipoUsuario = 1, // Solicitante
                IsInterno = false,
                Ativo = true,
                DataCadastro = DateTime.UtcNow
            }
        };

        await context.Usuarios.AddRangeAsync(usuarios);
        await context.SaveChangesAsync();

        // Now link technicians to their specialization categories
        var categorias = await context.Categorias.ToListAsync();
        if (categorias.Any())
        {
            var tecnicoHardware = await context.Usuarios
                .FirstOrDefaultAsync(u => u.Email == "rafael.costa@neurohelp.com.br");
            var tecnicoSoftware = await context.Usuarios
                .FirstOrDefaultAsync(u => u.Email == "ana.silva@neurohelp.com.br");
            var tecnicoRedes = await context.Usuarios
                .FirstOrDefaultAsync(u => u.Email == "bruno.ferreira@neurohelp.com.br");

            var catHardware = categorias.FirstOrDefault(c => c.Nome == "Hardware");
            var catSoftware = categorias.FirstOrDefault(c => c.Nome == "Software");
            var catRedes = categorias.FirstOrDefault(c => c.Nome == "Redes");

            if (tecnicoHardware != null && catHardware != null)
                tecnicoHardware.EspecialidadeCategoriaId = catHardware.Id;
            
            if (tecnicoSoftware != null && catSoftware != null)
                tecnicoSoftware.EspecialidadeCategoriaId = catSoftware.Id;
            
            if (tecnicoRedes != null && catRedes != null)
                tecnicoRedes.EspecialidadeCategoriaId = catRedes.Id;

            await context.SaveChangesAsync();
            _logger.LogInformation("Linked technicians to their specialization categories.");
        }

        _logger.LogInformation("Created {Count} users successfully.", usuarios.Count);
        _logger.LogInformation("Default credentials:");
        _logger.LogInformation("  Admin: admin@neurohelp.com.br / Admin@123");
        _logger.LogInformation("  Tecnico: rafael.costa@neurohelp.com.br / Tecnico@123");
        _logger.LogInformation("  User: juliana.martins@neurohelp.com.br / User@123");
    }
}
