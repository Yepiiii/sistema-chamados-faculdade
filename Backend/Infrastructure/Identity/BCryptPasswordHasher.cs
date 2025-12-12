using SistemaChamados.Core.Interfaces.Auth;

namespace SistemaChamados.Infrastructure.Identity;

/// <summary>
/// Implementação concreta de IPasswordHasher usando a biblioteca BCrypt.Net.
/// Encapsula a dependência do BCrypt, permitindo fácil substituição por outro algoritmo (Argon2, PBKDF2, etc.)
/// sem impactar o resto da aplicação.
/// </summary>
public class BCryptPasswordHasher : IPasswordHasher
{
    /// <summary>
    /// Gera um hash BCrypt de uma senha em texto plano.
    /// O BCrypt inclui automaticamente um salt aleatório e múltiplas iterações para segurança.
    /// </summary>
    /// <param name="password">Senha em texto plano a ser hasheada.</param>
    /// <returns>Hash BCrypt da senha.</returns>
    public string HashPassword(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
        {
            throw new ArgumentException("A senha não pode ser vazia ou nula.", nameof(password));
        }

        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    /// <summary>
    /// Verifica se uma senha em texto plano corresponde ao hash BCrypt armazenado.
    /// </summary>
    /// <param name="hash">Hash BCrypt armazenado no banco de dados.</param>
    /// <param name="password">Senha em texto plano fornecida pelo usuário.</param>
    /// <returns>True se a senha corresponde ao hash, False caso contrário.</returns>
    public bool VerifyPassword(string hash, string password)
    {
        if (string.IsNullOrWhiteSpace(hash))
        {
            throw new ArgumentException("O hash não pode ser vazio ou nulo.", nameof(hash));
        }

        if (string.IsNullOrWhiteSpace(password))
        {
            throw new ArgumentException("A senha não pode ser vazia ou nula.", nameof(password));
        }

        try
        {
            return BCrypt.Net.BCrypt.Verify(password, hash);
        }
        catch (Exception)
        {
            // Se o hash for inválido ou corrompido, retorna false
            return false;
        }
    }
}
