namespace SistemaChamados.Mobile.Models.Entities;

/// <summary>
/// Entidade de usuário do sistema.
/// Representa um usuário simplificado para uso no mobile.
/// </summary>
public class Usuario
{
    public int Id { get; set; }
    
    /// <summary>
    /// Nome completo do usuário.
    /// IMPORTANTE: Usar "NomeCompleto" para consistência com backend.
    /// </summary>
    public string NomeCompleto { get; set; } = string.Empty;
    
    public string Email { get; set; } = string.Empty;
}
