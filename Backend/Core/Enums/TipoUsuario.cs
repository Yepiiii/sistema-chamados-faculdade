namespace SistemaChamados.Core.Enums;

/// <summary>
/// Tipos de usuários do sistema com suas respectivas permissões
/// </summary>
public enum TipoUsuario
{
    /// <summary>
    /// Colaborador: Pode criar chamados e visualizar apenas seus próprios chamados
    /// </summary>
    Colaborador = 1,

    /// <summary>
    /// Técnico TI: Pode visualizar chamados atribuídos a ele e encerrá-los
    /// </summary>
    TecnicoTI = 2,

    /// <summary>
    /// Administrador: Acesso total ao sistema
    /// </summary>
    Admin = 3
}
