using System.Text.RegularExpressions;

namespace SistemaChamados.Core.Shared.Extensions;

/// <summary>
/// Guard Clauses para validações de string, eliminando código duplicado.
/// </summary>
public static class StringValidationExtensions
{
    /// <summary>
    /// Valida que a string não é null, vazia ou apenas espaços em branco.
    /// </summary>
    /// <param name="value">Valor a ser validado</param>
    /// <param name="parameterName">Nome do parâmetro para a mensagem de erro</param>
    /// <returns>A string validada</returns>
    /// <exception cref="ArgumentException">Se a string for inválida</exception>
    public static string RequiredString(this string? value, string parameterName)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException(
                $"{parameterName} não pode ser nulo, vazio ou conter apenas espaços em branco.",
                parameterName);
        }
        return value;
    }

    /// <summary>
    /// Valida que a string é um email válido.
    /// </summary>
    /// <param name="value">Email a ser validado</param>
    /// <param name="parameterName">Nome do parâmetro para a mensagem de erro</param>
    /// <returns>O email validado</returns>
    /// <exception cref="ArgumentException">Se o email for inválido</exception>
    public static string ValidEmail(this string? value, string parameterName)
    {
        var email = value.RequiredString(parameterName);
        
        // Regex simples para validação de email
        var emailRegex = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$", RegexOptions.IgnoreCase);
        
        if (!emailRegex.IsMatch(email))
        {
            throw new ArgumentException(
                $"{parameterName} deve ser um email válido.",
                parameterName);
        }
        
        return email;
    }

    /// <summary>
    /// Valida que a string não excede o tamanho máximo.
    /// </summary>
    /// <param name="value">String a ser validada</param>
    /// <param name="maxLength">Tamanho máximo permitido</param>
    /// <param name="parameterName">Nome do parâmetro para a mensagem de erro</param>
    /// <returns>A string validada</returns>
    /// <exception cref="ArgumentException">Se a string exceder o tamanho máximo</exception>
    public static string MaxLength(this string value, int maxLength, string parameterName)
    {
        if (value.Length > maxLength)
        {
            throw new ArgumentException(
                $"{parameterName} não pode ter mais de {maxLength} caracteres. Tamanho atual: {value.Length}.",
                parameterName);
        }
        
        return value;
    }

    /// <summary>
    /// Valida que a string tem um tamanho mínimo.
    /// </summary>
    /// <param name="value">String a ser validada</param>
    /// <param name="minLength">Tamanho mínimo permitido</param>
    /// <param name="parameterName">Nome do parâmetro para a mensagem de erro</param>
    /// <returns>A string validada</returns>
    /// <exception cref="ArgumentException">Se a string for menor que o tamanho mínimo</exception>
    public static string MinLength(this string value, int minLength, string parameterName)
    {
        if (value.Length < minLength)
        {
            throw new ArgumentException(
                $"{parameterName} deve ter pelo menos {minLength} caracteres. Tamanho atual: {value.Length}.",
                parameterName);
        }
        
        return value;
    }

    /// <summary>
    /// Valida que a string está dentro de um range de tamanho.
    /// </summary>
    /// <param name="value">String a ser validada</param>
    /// <param name="minLength">Tamanho mínimo permitido</param>
    /// <param name="maxLength">Tamanho máximo permitido</param>
    /// <param name="parameterName">Nome do parâmetro para a mensagem de erro</param>
    /// <returns>A string validada</returns>
    /// <exception cref="ArgumentException">Se a string estiver fora do range</exception>
    public static string LengthBetween(this string value, int minLength, int maxLength, string parameterName)
    {
        if (value.Length < minLength || value.Length > maxLength)
        {
            throw new ArgumentException(
                $"{parameterName} deve ter entre {minLength} e {maxLength} caracteres. Tamanho atual: {value.Length}.",
                parameterName);
        }
        
        return value;
    }

    /// <summary>
    /// Valida string não nula/vazia e aplica tamanho máximo em uma única chamada.
    /// </summary>
    /// <param name="value">String a ser validada</param>
    /// <param name="maxLength">Tamanho máximo permitido</param>
    /// <param name="parameterName">Nome do parâmetro para a mensagem de erro</param>
    /// <returns>A string validada</returns>
    public static string RequiredWithMaxLength(this string? value, int maxLength, string parameterName)
    {
        return value.RequiredString(parameterName).MaxLength(maxLength, parameterName);
    }

    /// <summary>
    /// Valida string não nula/vazia e aplica range de tamanho em uma única chamada.
    /// </summary>
    /// <param name="value">String a ser validada</param>
    /// <param name="minLength">Tamanho mínimo permitido</param>
    /// <param name="maxLength">Tamanho máximo permitido</param>
    /// <param name="parameterName">Nome do parâmetro para a mensagem de erro</param>
    /// <returns>A string validada</returns>
    public static string RequiredWithLengthBetween(this string? value, int minLength, int maxLength, string parameterName)
    {
        return value.RequiredString(parameterName).LengthBetween(minLength, maxLength, parameterName);
    }
}
