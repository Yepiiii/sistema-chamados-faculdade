namespace SistemaChamados.Mobile.Models.DTOs;

public class CriarChamadoRequestDto
{
    public string? Titulo { get; set; }
    public string Descricao { get; set; } = string.Empty;
    public int? CategoriaId { get; set; }
    public int? PrioridadeId { get; set; }
    public bool? UsarAnaliseAutomatica { get; set; }
}
