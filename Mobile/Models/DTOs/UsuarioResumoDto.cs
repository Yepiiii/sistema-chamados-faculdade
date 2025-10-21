namespace SistemaChamados.Mobile.Models.DTOs;

public class UsuarioResumoDto
{
    public int Id { get; set; }
    public string NomeCompleto { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public int TipoUsuario { get; set; } // 1=Aluno, 2=Técnico, 3=Admin
}
