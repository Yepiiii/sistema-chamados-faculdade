namespace SistemaChamados.Application.DTOs;

public class PrioridadeDto
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public int Nivel { get; set; }
    public string? Descricao { get; set; }
}
