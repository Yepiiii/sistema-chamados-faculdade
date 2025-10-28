namespace SistemaChamados.Mobile.Models.DTOs;

public class AnaliseChamadoResponseDto
{
    public string SugeridoTitulo { get; set; } = string.Empty;
    public int? SugeridoCategoriaId { get; set; }
    public int? SugeridoPrioridadeId { get; set; }
}
