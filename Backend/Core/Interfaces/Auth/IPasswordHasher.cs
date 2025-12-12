namespace SistemaChamados.Core.Interfaces.Auth;

/// <summary>
/// Interface para abstração de hashing de senhas.
/// Permite desacoplar a implementação específica (BCrypt, Argon2, PBKDF2, etc.)
/// do resto da aplicação, seguindo o Dependency Inversion Principle.
/// </summary>
public interface IPasswordHasher
{
    /// <summary>
    /// Gera um hash seguro de uma senha em texto plano.
    /// </summary>
    /// <param name="password">Senha em texto plano a ser hasheada.</param>
    /// <returns>Hash da senha.</returns>
    string HashPassword(string password);

    /// <summary>
    /// Verifica se uma senha em texto plano corresponde ao hash armazenado.
    /// </summary>
    /// <param name="hash">Hash armazenado no banco de dados.</param>
    /// <param name="password">Senha em texto plano fornecida pelo usuário.</param>
    /// <returns>True se a senha corresponde ao hash, False caso contrário.</returns>
    bool VerifyPassword(string hash, string password);
}
