namespace SistemaChamados.Application.DTOs;

public class AnaliseIADto
{
    public int CategoriaId { get; set; }
    public int PrioridadeId { get; set; }
    public string? TituloSugerido { get; set; }
    public string? Justificativa { get; set; }
    public int? TecnicoId { get; set; }
    public string? TecnicoNome { get; set; }
}
