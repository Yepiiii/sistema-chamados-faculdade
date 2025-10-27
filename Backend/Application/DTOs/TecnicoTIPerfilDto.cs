namespace SistemaChamados.Application.DTOs;

public class TecnicoTIPerfilDto
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string? AreaAtuacao { get; set; }
    
    /// <summary>
    /// Nível do técnico: 2=Intermediário, 3=Sênior/Especialista
    /// </summary>
    public int NivelTecnico { get; set; }
    
    /// <summary>
    /// Descrição do nível
    /// </summary>
    public string NivelDescricao => NivelTecnico switch
    {
        2 => "Nível 2 - Suporte Intermediário",
        3 => "Nível 3 - Especialista Sênior",
        _ => "Nível Desconhecido"
    };
    
    public DateTime DataContratacao { get; set; }
    public int TotalChamadosAtribuidos { get; set; }
}
