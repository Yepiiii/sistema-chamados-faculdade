using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SistemaChamados.Application.DTOs.Auth;
using SistemaChamados.Core.Interfaces.Auth;
using SistemaChamados.Data;

namespace SistemaChamados.Application.Services.Auth;

/// <summary>
/// Implementation of authentication service.
/// Responsibilities:
/// - Validate user credentials
/// - Verify user is active
/// - Generate JWT token
/// - Log authentication attempts
/// </summary>
public class AuthenticationService : IAuthenticationService
{
    private readonly ApplicationDbContext _context;
    private readonly IPasswordHasher _passwordHasher;
    private readonly ITokenService _tokenService;
    private readonly ILogger<AuthenticationService> _logger;

    public AuthenticationService(
        ApplicationDbContext context,
        IPasswordHasher passwordHasher,
        ITokenService tokenService,
        ILogger<AuthenticationService> logger)
    {
        _context = context;
        _passwordHasher = passwordHasher;
        _tokenService = tokenService;
        _logger = logger;
    }

    public async Task<AuthenticationResult> AuthenticateAsync(string email, string password)
    {
        _logger.LogInformation("Tentativa de login recebida para o email: {Email}", email);

        // Buscar usuário pelo email
        var usuario = await _context.Usuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Email == email);

        if (usuario == null)
        {
            _logger.LogWarning("Usuário não encontrado para o email: {Email}", email);
            return AuthenticationResult.Failure("Email ou senha inválidos.");
        }

        _logger.LogInformation("Usuário encontrado: ID {UserId}, Email {UserEmail}", usuario.Id, usuario.Email);

        // Verificar senha
        bool senhaValida;
        try
        {
            _logger.LogInformation("Verificando senha recebida contra o hash do usuário ID {UserId}", usuario.Id);
            senhaValida = _passwordHasher.VerifyPassword(usuario.SenhaHash, password);
            _logger.LogInformation("Resultado da verificação de senha para o usuário ID {UserId}: {SenhaValida}", usuario.Id, senhaValida);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro durante a verificação de senha para o usuário ID {UserId}", usuario.Id);
            return AuthenticationResult.Failure("Erro interno ao verificar a senha.");
        }

        if (!senhaValida)
        {
            _logger.LogWarning("Senha inválida para o usuário ID {UserId}", usuario.Id);
            return AuthenticationResult.Failure("Email ou senha inválidos.");
        }

        // Verificar se usuário está ativo
        if (!usuario.Ativo)
        {
            _logger.LogWarning("Tentativa de login por usuário inativo: ID {UserId}", usuario.Id);
            return AuthenticationResult.Failure("Usuário inativo.");
        }

        // Gerar token JWT
        var token = _tokenService.GenerateToken(usuario);
        _logger.LogInformation("Login bem-sucedido e token gerado para o usuário ID {UserId}", usuario.Id);

        return AuthenticationResult.SuccessResult(token, usuario.TipoUsuario);
    }
}
