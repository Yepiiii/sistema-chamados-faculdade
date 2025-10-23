namespace SistemaChamados.Application.DTOs;

public class TecnicoTIPerfilDto
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string? AreaAtuacao { get; set; }
    public DateTime DataContratacao { get; set; }
    public int TotalChamadosAtribuidos { get; set; }
}
