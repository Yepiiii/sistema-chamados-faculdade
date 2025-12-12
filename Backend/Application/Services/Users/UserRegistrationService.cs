using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SistemaChamados.Application.DTOs.Users;
using SistemaChamados.Core.Entities;
using SistemaChamados.Core.Interfaces.Auth;
using SistemaChamados.Data;

namespace SistemaChamados.Application.Services.Users;

/// <summary>
/// Implementation of user registration service.
/// Responsibilities:
/// - Validate email uniqueness
/// - Hash password via IPasswordHasher
/// - Create user in database
/// - Validate category specialty (for technicians)
/// </summary>
public class UserRegistrationService : IUserRegistrationService
{
    private readonly ApplicationDbContext _context;
    private readonly IPasswordHasher _passwordHasher;
    private readonly ILogger<UserRegistrationService> _logger;

    public UserRegistrationService(
        ApplicationDbContext context,
        IPasswordHasher passwordHasher,
        ILogger<UserRegistrationService> logger)
    {
        _context = context;
        _passwordHasher = passwordHasher;
        _logger = logger;
    }

    public async Task<UserRegistrationResult> RegisterAdminAsync(string nomeCompleto, string email, string senha)
    {
        _logger.LogInformation("Tentativa de registro de Admin para o email: {Email}", email);

        // Verificar se email já existe
        if (await _context.Usuarios.AnyAsync(u => u.Email == email))
        {
            _logger.LogWarning("Tentativa de registro com email duplicado: {Email}", email);
            return UserRegistrationResult.Failure("Email já está em uso");
        }

        // Criar usuário admin
        var usuario = new Usuario
        {
            NomeCompleto = nomeCompleto,
            Email = email,
            SenhaHash = _passwordHasher.HashPassword(senha),
            TipoUsuario = 3, // Admin
            DataCadastro = DateTime.UtcNow,
            Ativo = true
        };

        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Admin registrado com sucesso: ID {UserId}, Email {Email}", usuario.Id, usuario.Email);

        return UserRegistrationResult.SuccessResult(
            usuario.Id,
            usuario.NomeCompleto,
            usuario.Email,
            usuario.TipoUsuario,
            usuario.DataCadastro,
            usuario.Ativo);
    }

    public async Task<UserRegistrationResult> RegisterUserAsync(string nomeCompleto, string email, string senha)
    {
        _logger.LogInformation("Tentativa de registro de Usuário para o email: {Email}", email);

        // Verificar se email já existe
        if (await _context.Usuarios.AnyAsync(u => u.Email == email))
        {
            _logger.LogWarning("Tentativa de registro com email duplicado: {Email}", email);
            return UserRegistrationResult.Failure("Email já está em uso");
        }

        // Criar usuário comum
        var usuario = new Usuario
        {
            NomeCompleto = nomeCompleto,
            Email = email,
            SenhaHash = _passwordHasher.HashPassword(senha),
            TipoUsuario = 1, // Usuário Comum
            DataCadastro = DateTime.UtcNow,
            Ativo = true
        };

        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Usuário registrado com sucesso: ID {UserId}, Email {Email}", usuario.Id, usuario.Email);

        return UserRegistrationResult.SuccessResult(
            usuario.Id,
            usuario.NomeCompleto,
            usuario.Email,
            usuario.TipoUsuario,
            usuario.DataCadastro,
            usuario.Ativo);
    }

    public async Task<UserRegistrationResult> RegisterTechnicianAsync(
        string nomeCompleto, 
        string email, 
        string senha, 
        int especialidadeCategoriaId)
    {
        _logger.LogInformation("Tentativa de registro de Técnico para o email: {Email}", email);

        // Verificar se email já existe
        if (await _context.Usuarios.AnyAsync(u => u.Email == email))
        {
            _logger.LogWarning("Tentativa de registro com email duplicado: {Email}", email);
            return UserRegistrationResult.Failure("Email já está em uso");
        }

        // Validar se a categoria de especialidade existe
        var categoriaExiste = await _context.Categorias.AnyAsync(c => c.Id == especialidadeCategoriaId);
        if (!categoriaExiste)
        {
            _logger.LogWarning("Tentativa de registro de técnico com categoria inválida: {CategoriaId}", especialidadeCategoriaId);
            return UserRegistrationResult.Failure("ID da Categoria de especialidade inválido.");
        }

        // Criar usuário técnico
        var usuario = new Usuario
        {
            NomeCompleto = nomeCompleto,
            Email = email,
            SenhaHash = _passwordHasher.HashPassword(senha),
            TipoUsuario = 2, // Técnico
            Ativo = true,
            DataCadastro = DateTime.UtcNow,
            EspecialidadeCategoriaId = especialidadeCategoriaId
        };

        _context.Usuarios.Add(usuario);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Técnico registrado com sucesso: ID {UserId}, Email {Email}, Especialidade {CategoriaId}", 
            usuario.Id, usuario.Email, especialidadeCategoriaId);

        return UserRegistrationResult.SuccessResult(
            usuario.Id,
            usuario.NomeCompleto,
            usuario.Email,
            usuario.TipoUsuario,
            usuario.DataCadastro,
            usuario.Ativo);
    }
}
