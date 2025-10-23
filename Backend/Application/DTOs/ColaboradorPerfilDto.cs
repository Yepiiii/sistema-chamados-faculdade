namespace SistemaChamados.Application.DTOs;

public class ColaboradorPerfilDto
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string Matricula { get; set; } = string.Empty;
    public string? Departamento { get; set; }
    public DateTime DataAdmissao { get; set; }
}
