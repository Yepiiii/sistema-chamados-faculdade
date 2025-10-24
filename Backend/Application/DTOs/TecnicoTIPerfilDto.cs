namespace SistemaChamados.Application.DTOs;

public class TecnicoTIPerfilDto
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string? AreaAtuacao { get; set; }
    
    /// <summary>
    /// Nível do técnico: 1=Básico, 3=Sênior/Especialista
    /// NOTA: Nível 2 foi removido - sistema com 2 técnicos
    /// </summary>
    public int NivelTecnico { get; set; }
    
    /// <summary>
    /// Descrição do nível
    /// </summary>
    public string NivelDescricao => NivelTecnico switch
    {
        1 => "Nível 1 - Suporte Básico",
        2 => "Nível 2 - Suporte Intermediário (DESATIVADO)",
        3 => "Nível 3 - Especialista Sênior",
        _ => "Nível Desconhecido"
    };
    
    public DateTime DataContratacao { get; set; }
    public int TotalChamadosAtribuidos { get; set; }
}
