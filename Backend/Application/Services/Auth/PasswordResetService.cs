using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SistemaChamados.Application.DTOs.Auth;
using SistemaChamados.Core.Interfaces.Auth;
using SistemaChamados.Data;
using SistemaChamados.Services;
using System.Security.Cryptography;

namespace SistemaChamados.Application.Services.Auth;

/// <summary>
/// Implementation of password reset service.
/// Responsibilities:
/// - Generate secure reset tokens
/// - Send password reset emails
/// - Validate reset tokens
/// - Update user passwords
/// </summary>
public class PasswordResetService : IPasswordResetService
{
    private readonly ApplicationDbContext _context;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IEmailService _emailService;
    private readonly ILogger<PasswordResetService> _logger;

    public PasswordResetService(
        ApplicationDbContext context,
        IPasswordHasher passwordHasher,
        IEmailService emailService,
        ILogger<PasswordResetService> logger)
    {
        _context = context;
        _passwordHasher = passwordHasher;
        _emailService = emailService;
        _logger = logger;
    }

    public async Task<PasswordResetResult> InitiatePasswordResetAsync(string email)
    {
        _logger.LogInformation("Iniciando processo de recuperação de senha para: {Email}", email);

        var usuario = await _context.Usuarios.FirstOrDefaultAsync(u => u.Email == email);

        // Por segurança, não informamos se o usuário foi encontrado ou não
        if (usuario == null)
        {
            _logger.LogWarning("Tentativa de recuperação de senha para email não cadastrado: {Email}", email);
            return PasswordResetResult.SuccessResult(
                "Se um usuário com este e-mail existir, um link de redefinição de senha foi enviado.");
        }

        // 1. Gerar token seguro e aleatório
        var token = Convert.ToHexString(RandomNumberGenerator.GetBytes(64));

        // 2. Salvar token e data de expiração
        usuario.PasswordResetToken = token;
        usuario.ResetTokenExpires = DateTime.UtcNow.AddMinutes(30); // Token expira em 30 minutos

        _context.Usuarios.Update(usuario);
        await _context.SaveChangesAsync();

        // 3. Enviar email apropriado baseado no tipo de usuário
        var subject = "Redefinição de Senha - Sistema de Chamados";
        string message = BuildEmailMessage(usuario.NomeCompleto, token, usuario.TipoUsuario);

        try
        {
            await _emailService.SendEmailAsync(usuario.Email, subject, message);
            var tipoUsuarioNome = usuario.TipoUsuario switch
            {
                1 => "Cliente/Mobile",
                2 => "Técnico/Desktop",
                3 => "Admin/Desktop",
                _ => "Desconhecido"
            };
            _logger.LogInformation("Email de redefinição enviado com sucesso para {Email} (Tipo: {TipoUsuario})", 
                usuario.Email, tipoUsuarioNome);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Erro ao enviar email de redefinição para usuário ID {UserId}", usuario.Id);
            return PasswordResetResult.Failure("Erro ao enviar email");
        }

        return PasswordResetResult.SuccessResult(
            "Se um usuário com este e-mail existir, um link de redefinição de senha foi enviado.");
    }

    public async Task<PasswordResetResult> ResetPasswordAsync(string token, string newPassword)
    {
        _logger.LogInformation("Tentativa de resetar senha com token");

        // 1. Encontrar usuário pelo token
        var usuario = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.PasswordResetToken == token);

        // 2. Validar token
        if (usuario == null || usuario.ResetTokenExpires < DateTime.UtcNow)
        {
            _logger.LogWarning("Tentativa de reset com token inválido ou expirado");
            return PasswordResetResult.Failure("Token inválido ou expirado.");
        }

        // 3. Criar hash da nova senha
        var novoSenhaHash = _passwordHasher.HashPassword(newPassword);

        // 4. Atualizar senha e limpar token
        usuario.SenhaHash = novoSenhaHash;
        usuario.PasswordResetToken = null;
        usuario.ResetTokenExpires = null;

        _context.Usuarios.Update(usuario);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Senha redefinida com sucesso para usuário ID {UserId}", usuario.Id);

        return PasswordResetResult.SuccessResult("Senha redefinida com sucesso.");
    }

    private string BuildEmailMessage(string nomeCompleto, string token, int tipoUsuario)
    {
        if (tipoUsuario == 1)
        {
            // Email para Clientes (Mobile) - inclui o token no corpo
            return $@"
                <h1>Redefinição de Senha</h1>
                <p>Olá, {nomeCompleto},</p>
                <p>Você solicitou a redefinição da sua senha no aplicativo mobile.</p>
                <p>Use o código abaixo no aplicativo para criar uma nova senha:</p>
                <div style='background-color: #f0f0f0; padding: 15px; margin: 20px 0; border-radius: 5px; font-family: monospace; font-size: 14px; word-break: break-all;'>
                    <strong>Código de Redefinição:</strong><br/>
                    {token}
                </div>
                <p><strong>Instruções:</strong></p>
                <ol>
                    <li>Abra o aplicativo Sistema de Chamados</li>
                    <li>Vá para a tela de redefinição de senha</li>
                    <li>Cole o código acima no campo indicado</li>
                    <li>Digite sua nova senha</li>
                </ol>
                <p>Se você não solicitou isso, por favor, ignore este e-mail.</p>
                <p><em>Este código expirará em 30 minutos.</em></p>";
        }
        else
        {
            // Email para Técnicos e Admins (Desktop) - usa o link do Vercel
            var resetLink = $"https://sistema-chamados-faculdade.vercel.app/resetar-senha-desktop.html?token={token}";
            return $@"
                <h1>Redefinição de Senha</h1>
                <p>Olá, {nomeCompleto},</p>
                <p>Você solicitou a redefinição da sua senha. Por favor, clique no link abaixo para criar uma nova senha:</p>
                <p style='margin: 20px 0;'>
                    <a href='{resetLink}' style='background-color: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; display: inline-block;'>Redefinir Minha Senha</a>
                </p>
                <p>Ou copie e cole o seguinte link no seu navegador:</p>
                <p style='background-color: #f0f0f0; padding: 10px; border-radius: 5px; word-break: break-all;'>{resetLink}</p>
                <p>Se você não solicitou isso, por favor, ignore este e-mail.</p>
                <p><em>Este link expirará em 30 minutos.</em></p>";
        }
    }
}
